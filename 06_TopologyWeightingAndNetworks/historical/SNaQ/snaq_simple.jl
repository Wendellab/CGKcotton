############################################################
# SNaQ analysis for the Australian cotton gene trees
# Run from the folder containing this script with:
# julia --project=. snaq_simple.jl
############################################################

using CSV
using DataFrames
using PhyloNetworks
using SNaQ

# Files in this folder.
gene_tree_file = "n18784_filter_trees_bs03_rt.tre"
group_file = "groups.tsv"
astral_file = "n18784_filter_trees_bs03_rt_astral_rt.tre"
output_directory = "snaq_results"
mkpath(output_directory)

# Read the existing sample-to-group map: sample<TAB>group.
group_table = CSV.read(group_file, DataFrame; delim='\t', header=false, stringtype=String)
rename!(group_table, [:sample, :group])
sample_to_group = Dict(String(r.sample) => String(r.group) for r in eachrow(group_table))

#approved_groups = Set(["C", "G1", "G2G3", "K", "D5"])
#Set(values(sample_to_group)) == approved_groups || error("Expected groups C, G1, G2G3, K, D5")

# Keep polytomies. An unresolved quartet is not randomly resolved.
gene_trees = readmultinewick(gene_tree_file)

#length(gene_trees) == 18784 || error("Expected 18,784 gene trees")
#expected_samples = Set(keys(sample_to_group))
#for (i, tree) in enumerate(gene_trees)
#    labels = tiplabels(tree)
#    Set(labels) == expected_samples && length(labels) == 40 || error("Taxon mismatch in tree $i")
#end

# Calculate five-group quartet concordance factors. Each gene has equal weight.
quartets, group_names = countquartetsintrees(gene_trees, sample_to_group;
    weight_byallele=false, showprogressbar=true)
cf_table = DataFrame(tablequartetCF(quartets, group_names; keepQwithoutgenes=false))
# Older SNaQ versions require ngenes to be integer. With multiple samples
# per group, ngenes can be fractional, so leave this metadata column out.
cf_table = select(cf_table, [:t1, :t2, :t3, :t4, :CF12_34, :CF13_24, :CF14_23])
CSV.write(joinpath(output_directory, "quartetCF.csv"), cf_table)
println("Saved quartetCF.csv with ", nrow(cf_table), " four-group sets")
show(cf_table; allcols=true); println()

# SNaQ needs a starting tree with the SAME group names as the CF table.
# This is the group-level form of your ASTRAL arrangement.
starting_tree_file = joinpath(output_directory, "starting_tree.nwk")
write(starting_tree_file, "((((G1,G2G3),K),C),D5);\n")
starting_tree = readnewick(starting_tree_file)

# Compare a tree (hmax=0) and a network allowing one hybridization (hmax=1).
# Ten independent searches is a short first run; use 30 or more for final work.
runs = 10
for hmax in [0, 1, 2, 3]
    println("Searching hmax = ", hmax)
    cf_data = SNaQ.readtableCF(cf_table)
    prefix = joinpath(output_directory, "hmax$(hmax)")
    network = SNaQ.snaq!(deepcopy(starting_tree), cf_data; hmax=hmax, runs=runs,
                    seed=20260909 + hmax, filename=prefix, outgroup="D5")
    write(prefix * ".best.network", writenewick(network) * "\n")
    println("Saved ", prefix, ".best.network")
end

println("Finished. Lower negative log-pseudolikelihood is a better fit.")
