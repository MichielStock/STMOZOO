include("../src/recipeWebscraper.jl")

using .recipeWebscraper

recipeDict = loadRecipeDBCSV("./docs/recipeDB-small.csv")
ingredientList = []

for ingredients in values(recipeDict)
    append!(ingredientList,ingredients)
end

ingredientList = unique(ingredientList)

testList = ["cheese","potato"]

for testProd in testList
    if testProd in ingredientList
        print("found $testProd in the ingredientlist")
    else
        print("did not find $testProd in the ingredientlist")
    end
    print("\n")
end

print(ingredientList[occursin.("cheese",ingredientList)])