using Documenter

using STMOZOO
using STMOZOO.Fridge

makedocs(sitename="Fridge.jl",
    format = Documenter.HTML(),
    modules=[Fridge], # add your module
    pages=[
        "index.md",
        "main function" => "man/mainFunction.md",
        "search algorithms" => "man/searchAlgorithms.md",
        "recipe webscraper"=> "man/recipeWebscraper.md",
    ])

#=
deploydocs(
            repo = "github.com/wardvanbelle/Fridge.jl",
        )
=#