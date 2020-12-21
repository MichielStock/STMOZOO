using Documenter

using STMOZOO
using STMOZOO.Example
using STMOZOO.BeesAlgorithm

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example,BeesAlgorithm], # add your module
    pages=Any[
        "Example" => "man/example.md",
        "BeesAlgorithm" => "man/beesalgorithm.md",  # add the page to your documentation
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#