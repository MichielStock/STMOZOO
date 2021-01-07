using Documenter

using STMOZOO
using STMOZOO.Example
using STMOZOO.SingleCellNMF

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, SingleCellNMF], # add your module
    pages=Any[
        "Example"=> "man/example.md",  # add the page to your documentation
	"SingleCellNMF"=>"man/single_cell_nmf.md"
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#
