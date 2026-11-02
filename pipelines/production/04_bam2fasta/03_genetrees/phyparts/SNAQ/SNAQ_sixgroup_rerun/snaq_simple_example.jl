using CSV
using DataFrames
using PhyloNetworks
using SNaQ

# Work in the folder containing this script
cd(@__DIR__)

# Read gene trees and sample-to-group assignments
trees = readmultinewick("../n18784_filter_trees_bs03_rt.tre")

groups = CSV.read(
    "groups_C1_C2.tsv", DataFrame;
    delim='\t',
    header=[:sample, :group],
    stringtype=String
)

sample_to_group = Dict(groups.sample .=> groups.group)

# Calculate quartet concordance factors
quartets, names = countquartetsintrees(
    trees, sample_to_group;
    weight_byallele=false
)

cf = DataFrame(tablequartetCF(quartets, names))
cf = select(cf, :t1, :t2, :t3, :t4,
            :CF12_34, :CF13_24, :CF14_23)

# A new output folder; stops if it already exists
mkdir("simple_results")
CSV.write("simple_results/quartetCF.csv", cf)

# Prepare quartet data and starting tree
data = SNaQ.readtableCF(cf)
tree = readnewick("((((G1,G2G3),K),(C1,C2)),D5);")

# Infer networks: 30 searches at each reticulation limit
net0 = SNaQ.snaq!(
    deepcopy(tree), data;
    hmax=0, runs=30, seed=12340,
    filename="simple_results/h0", outgroup="D5"
)

net1 = SNaQ.snaq!(
    deepcopy(net0), data;
    hmax=1, runs=30, seed=12341,
    filename="simple_results/h1", outgroup="D5"
)

net2 = SNaQ.snaq!(
    deepcopy(net1), data;
    hmax=2, runs=30, seed=12342,
    filename="simple_results/h2", outgroup="D5"
)

net3 = SNaQ.snaq!(
    deepcopy(net2), data;
    hmax=3, runs=30, seed=12343,
    filename="simple_results/h3", outgroup="D5"
)

# Compare scores: smaller is better
scores = DataFrame(
    hmax = [0, 1, 2, 3],
    score = [loglik(net0), loglik(net1), loglik(net2), loglik(net3)]
)

CSV.write("simple_results/scores.csv", scores)
println(scores)