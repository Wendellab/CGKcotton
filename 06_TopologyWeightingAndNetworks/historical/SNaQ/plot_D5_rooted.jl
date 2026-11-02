using PhyloNetworks
using PhyloPlots
using RCall

results = isempty(ARGS) ? "snaq_results" : ARGS[1]
network = PhyloNetworks.readnewick(joinpath(results, "hmax1.best.network"))
# A tip name places the root on the edge leading to that outgroup.
PhyloNetworks.rootatnode!(network, "D5")
write(joinpath(results, "hmax1_D5_rooted.network"), PhyloNetworks.writenewick(network) * "\n")

for extension in ["pdf", "png"]
    output = joinpath(results, "hmax1_D5_rooted." * extension)
    if extension == "pdf"
        R"pdf"(output, width=8, height=6)
    else
        R"png"(output, width=1600, height=1200, res=200)
    end
    R"par"(mar=[3, 1, 3, 1])
    PhyloPlots.plot(network; showgamma=true, useedgelength=false)
    R"title"(main="SNaQ network rooted on D5")
    R"mtext"("Inheritance proportions shown; branches not to scale", side=1, line=1)
    R"dev.off()"
    println("Saved ", output)
end
