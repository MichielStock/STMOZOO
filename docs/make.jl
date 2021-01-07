using Documenter

using STMOZOO
using STMOZOO.LocalSearch

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[LocalSearch], # add your module
    pages=Any[
        "Sudoku_local" => "man/Sudoku_local.md"
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#