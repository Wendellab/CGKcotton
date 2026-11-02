using PhyloNetworks
using PhyloPlots
using RCall

# Supply the results folder as the first command-line argument.
results = isempty(ARGS) ? "snaq_results" : ARGS[1]
network = PhyloNetworks.readnewick(joinpath(results, "hmax1.best.network"))

# Draw relationships, with inheritance proportions on hybrid edges.
# Edge lengths are not drawn to scale: this is not a dated tree.
for extension in ["pdf", "png"]
    output = joinpath(results, "hmax1_network." * extension)
    if extension == "pdf"
        R"pdf"(output, width=8, height=6)
    else
        R"png"(output, width=1600, height=1200, res=200)
    end
    R"par"(mar=[2, 1, 3, 1])
    PhyloPlots.plot(network; showgamma=true, useedgelength=false)
    R"title"(main="SNaQ: one hybridization", sub="Inheritance proportions shown; branches not to scale")
    R"dev.off()"
    println("Saved ", output)
end
