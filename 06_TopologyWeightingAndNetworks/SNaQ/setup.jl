# Run once on Nova to create a Julia environment on Nova, not from a PC manifest.
using Pkg
Pkg.activate(@__DIR__)
Pkg.add(PackageSpec(name="CSV", version="0.10.17"))
Pkg.add(PackageSpec(name="DataFrames", version="1.8.2"))
Pkg.add(PackageSpec(name="PhyloNetworks", version="1.4.0"))
Pkg.add(PackageSpec(name="SNaQ", version="1.2.0"))
Pkg.add(PackageSpec(name="PhyloPlots", version="2.1.0"))
Pkg.add(PackageSpec(name="RCall", version="0.14.13"))
Pkg.build("RCall")
Pkg.precompile()
using CSV, DataFrames, PhyloNetworks, SNaQ, PhyloPlots, RCall
Pkg.status()
