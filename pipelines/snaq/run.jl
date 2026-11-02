# Derived from the supplied six-group SNaQ workflow. Run setup.jl once first.
using Pkg
code_dir = @__DIR__
Pkg.activate(code_dir)
output_dir = abspath(get(ENV, "CGK_SNAQ_OUTPUT", joinpath(code_dir, "..", "..", "outputs", "snaq")))
mkpath(output_dir)
cd(output_dir)
using CSV, DataFrames, PhyloNetworks, SNaQ, PhyloPlots, RCall

# STEP 1: PREPARE QUARTETS
function prepare_quartets()
# Run from SNAQ_sixgroup_rerun. Stop if the stage folder already exists.
ispath("step1") && error("step1 exists. Use a new analysis folder for a fresh run.")
groups = CSV.read(haskey(ENV, "CGK_SNAQ_GROUPS") ? ENV["CGK_SNAQ_GROUPS"] : error("Set CGK_SNAQ_GROUPS to your sample-to-group TSV"), DataFrame; delim='\t', header=[:sample,:group], stringtype=String)
sample_to_group = Dict(String(r.sample)=>String(r.group) for r in eachrow(groups))
@assert nrow(groups) == length(sample_to_group) == 40
@assert Set(values(sample_to_group)) == Set(["C1","C2","G1","G2G3","K","D5"])
trees = readmultinewick(haskey(ENV, "CGK_GENE_TREES") ? ENV["CGK_GENE_TREES"] : error("Set CGK_GENE_TREES to the 18,784-tree Newick file"))
@assert length(trees) == 18784
for (i, tree) in enumerate(trees)
    labels = tiplabels(tree)
    length(labels) == 40 && Set(labels) == Set(keys(sample_to_group)) || error("Taxon mismatch: tree $i")
end
mkdir("step1")
CSV.write("step1/sample_counts.csv", combine(groupby(groups,:group),nrow=>:samples))
# Keep unresolved branches. Each locus shares its weight among sample combinations.
quartets, names = countquartetsintrees(trees, sample_to_group; weight_byallele=false, showprogressbar=true)
full_table = DataFrame(tablequartetCF(quartets,names;keepQwithoutgenes=false))
CSV.write("step1/quartetCF_with_counts.csv",full_table)
cf = select(full_table,[:t1,:t2,:t3,:t4,:CF12_34,:CF13_24,:CF14_23])
@assert nrow(cf) == 15
for r in eachrow(cf)
    values = [r.CF12_34,r.CF13_24,r.CF14_23]
    @assert all(isfinite,values) && all(x->0<=x<=1,values)
    @assert isapprox(sum(values),1.0;atol=1e-8)
end
CSV.write("step1/quartetCF.csv",cf)
# Group-level topology used previously; C1/C2 and G1/G2G3 are sister pairs.
write("step1/starting_tree.nwk","((((G1,G2G3),K),(C1,C2)),D5);\n")
write("step1/step1.done","40 samples; 18784 trees; 15 quartet sets\n")

end
prepare_quartets()

# STEP 2: INFER NETWORKS
function infer_networks()
isfile("step1/step1.done") || error("Complete step1 first")
ispath("step2") && error("step2 already exists; do not overwrite results")
mkdir("step2")
open("step2/software_versions.txt","w") do io
    println(io,"Julia ",VERSION)
    Pkg.status(;io=io)
end
cf = CSV.read("step1/quartetCF.csv",DataFrame)
previous_best = readnewick("step1/starting_tree.nwk")
# 30 independently seeded searches per maximum; 120 searches in total.
runs = 30
scores = DataFrame(hmax=Int[],negative_log_pseudolikelihood=Float64[],actual_reticulations=Int[],searches=Int[])
for hmax in [0,1,2,3]
    println("Starting hmax = ",hmax); flush(stdout)
    data = SNaQ.readtableCF(deepcopy(cf))
    prefix = "step2/hmax$(hmax)"
    network = SNaQ.snaq!(deepcopy(previous_best),data;
        hmax=hmax,runs=runs,seed=20261020+hmax,filename=prefix,outgroup="D5")
    rootatnode!(network,"D5")
    write(prefix*".best.network",writenewick(network)*"\n")
    push!(scores,(hmax,network.loglik,network.numHybrids,runs))
    CSV.write("step2/score_summary.csv",scores)
    previous_best = network
end
write("step2/step2.done","Finished hmax 0,1,2,3; 30 searches each\n")

end
infer_networks()

# STEP 3: PLOT RESULTS
function plot_results()
isfile("step2/step2.done") || error("Complete step2 first")
ispath("step3") && error("step3 already exists; do not overwrite plots")
mkdir("step3")
# Gamma labels are read from the fitted network: no manually typed values.
for hmax in [0,1,2,3]
    network = readnewick("step2/hmax$(hmax).best.network")
    rootatnode!(network,"D5")
    for extension in ["pdf","png"]
        output = "step3/hmax$(hmax)_D5_rooted."*extension
        if extension == "pdf"
            R"pdf"(output,width=9,height=6)
        else
            R"png"(output,width=1800,height=1200,res=200)
        end
        R"par"(mar=[3,1,3,1])
        PhyloPlots.plot(network;showgamma=true,useedgelength=false)
        R"title"(main="Six-group SNaQ: hmax = $(hmax)")
        R"mtext"("D5-rooted; inheritance probabilities shown; branches not to scale",side=1,line=1)
        R"dev.off()"
    end
end
# A simple score plot: lower negative log-pseudolikelihood = better fit.
scores = CSV.read("step2/score_summary.csv",DataFrame)
x = scores.hmax
y = scores.negative_log_pseudolikelihood
R"pdf"("step3/score_comparison.pdf",width=7,height=5)
R"plot"(x,y,type="b",xlab="Maximum allowed reticulations (hmax)",ylab="Negative log-pseudolikelihood",pch=19)
R"dev.off()"
cp("step2/score_summary.csv","step3/score_summary.csv")
write("step3/step3.done","Finished network figures and score plot\n")

end
plot_results()
