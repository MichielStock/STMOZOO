using Documenter

using STMOZOO
using STMOZOO.Example
using STMOZOO.Cuckoo

makedocs(sitename="STMO ZOO",
    format = Documenter.HTML(),
    modules=[Example, Cuckoo],  
    pages=Any[
        "Example"=> "man/example.md",  
        "Cuckoo"=> "man/cuckoo.md"
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#