using Documenter

using STMOZOO
using STMOZOO.LocalSearch
using STMOZOO.Example
using STMOZOO.SingleCellNMF
using STMOZOO.GenProgAlign

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example,
            SingleCellNMF,
            GenProgAlign,
        LocalSearch,
        ], # add your module
    pages=Any[
        "Example"=> "man/example.md",  # add the page to your documentation
      "GenProgAlign" => "man/gen_prog_align.md",
	"SingleCellNMF"=>"man/single_cell_nmf.md",
        "Sudoku_local" => "man/Sudoku_local.md",    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#
