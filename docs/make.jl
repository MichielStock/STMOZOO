using Documenter

using Fridge

makedocs(sitename="Fridge.jl",
    format = Documenter.HTML(),
    modules=[Fridge], # add your module
    pages=[
        "index.md",
        "main function" => "mainFunction.md",
        "search algorithms" => "searchAlgorithms.md",
        "recipe webscraper"=> "recipeWebscraper.md",
    ])

deploydocs(
            repo = "github.com/wardvanbelle/Fridge.jl",
        )