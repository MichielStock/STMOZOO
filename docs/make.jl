using Documenter

using STMOZOO
using STMOZOO.Fridge

makedocs(sitename="Fridge.jl",
    format = Documenter.HTML(),
    modules=[Fridge], # add your module
    pages=Any[
        "scrapeRecipe"=> "man/scrapeRecipe.md",  # add the page to your documentation
    ])

#=
deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )
=#