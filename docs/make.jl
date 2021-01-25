using Documenter
using STMOZOO
using STMOZOO.LocalSearch
using STMOZOO.Example
using STMOZOO.Raytracing
using STMOZOO.polygon
using STMOZOO.EulerianPath
using STMOZOO.SingleCellNMF
using STMOZOO.GenProgAlign
using STMOZOO.MaximumFlow

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),

    modules=[Example,
            SingleCellNMF,
            GenProgAlign,
            LocalSearch,
            EulerianPath,
            MaximumFlow,
            Raytracing,
        ], # add your module
    pages=Any[
        "Example"=> "man/example.md",  # add the page to your documentation
        "GenProgAlign" => "man/gen_prog_align.md",
	      "SingleCellNMF"=>"man/single_cell_nmf.md",
        "Sudoku_local" => "man/Sudoku_local.md",
        "EulerianPath" => "man/EulerianPath.md",
        "polygon"=> "man/polygon.md",
        "MaximumFlow" => "man/maximumflow.md",
        "Raytracing" => "man/raytracing.md"
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#
