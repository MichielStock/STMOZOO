using Documenter, STMOZOO
using STMOZOO.Fridge

makedocs(sitename="Fridge.jl",
    format = Documenter.HTML(),
    modules=[Fridge], # add your module
    pages=Any[
        "index.md",
        "main function" => "man/mainFunction.md",
        "search algorithms" => "man/searchAlgorithms",
        "recipe webscraper"=> "man/recipeWebscraper.md",
    ])

#=
deploydocs(
            repo = "github.com/wardvanbelle/Fridge.jl",
        )
=#