using Documenter

using STMOZOO
using STMOZOO.Example
using STMOZOO.GenProgAlign

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, GenProgAlign], # add your module
    pages=Any[
        "Example"=> "man/example.md", 
        "GenProgAlign" => "man/gen_prog_align.md", # add the page to your documentation
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#