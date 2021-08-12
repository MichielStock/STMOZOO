using Documenter

using STMOZOO
using STMOZOO.SudokuSolver

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[SudokuSolver], # add your module
    pages=Any[
        "Sudoku"=> "man/sudoku.md",  # add the page to your documentation
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#