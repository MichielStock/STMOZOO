using Documenter

using STMOZOO
using STMOZOO.Example
using STMO.EulerianPath

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, EulerianPath], # add your module
    pages=Any[
        "Example"=> "man/example.md",  # add the page to your documentation
        "EulerianPath" => "man/Eulerian_Path.md"
        ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#