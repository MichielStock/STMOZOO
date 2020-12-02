using Documenter

using STMOZOO
using STMOZOO.Example

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, Softmax], # add your module
    pages=Any[
        "Example" => "man/example.md",  # add the page to your documentation
        "Softmax" => "man/softmax.md",
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#