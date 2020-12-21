using Documenter

using STMOZOO
using STMOZOO.BeesAlgorithm

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[BeesAlgorithm], # add your module
    pages=Any[
        "Example"=> "man/beesalgorithm.md",  # add the page to your documentation
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#