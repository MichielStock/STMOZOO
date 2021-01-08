using Documenter

using STMOZOO
using STMOZOO.Example

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, ODEGenProg],
    pages=Any[
        "Example" => "man/example.md", 
        "ODEGenProg" => "man/odegenprog.md",
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#