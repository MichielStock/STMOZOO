# A package that optimizes your fridge use!!
# concept: Maximize amount of fridge used. Minimize amount of recipes used, minimize amount of extra ingredients needed

include("../src/recipeWebscraper.jl")

using .recipeWebscraper

function createIngredientDatabase(recipeDict)
    # create an unique vector of all possible ingredients
    ingredientList = []
    for ingredients in values(recipeDict)
        append!(ingredientList,ingredients)
    end
    ingredientList = unique(ingredientList)

    return ingredientList
end

function checkIngredients(fridgeList,ingredientList)
    print("Checking if the food in your fridge is found in our database.\n\n")

    # check if the ingredients in the fridge are found in the database
    for food in fridgeList
        if food in ingredientList
            print("Found $food in the ingredient database.\n")
        else
            print("Did not find $food in the ingredient database.\n\n")
            if any(occursin.(food,ingredientList))
                print("Possible alternatives in database:\n")
                alternatives = ingredientList[occursin.(food,ingredientList)]
                for (indexNum, alternative) in enumerate(alternatives)
                    print("[$indexNum] $alternative\n")
                end
                print("If you want to take an alternative type its number, else type no.\n")
                answer = readline()
                if answer != "no"
                    correctInput = false
                    while !correctInput
                        try
                            answer = parse(Int64,answer)
                            correctInput = true
                        catch
                            print("Please only type the number of the alternative, eg. 1\n")
                            answer = readline()
                        end
                    end
                    fridgeList[fridgeList .== food] .= alternatives[answer]
                    print("Replaced $food with $(alternatives[answer])\n")
                end
            else
                print("Did not find any alternative in the ingredient database.\n")
            end
        end
    end
    print("Done checking ingredients.\n\n")

    return fridgeList
end

fridgeObjective(x::Array{Float64}) = sum(x[1:end-1]) + 6*sum(x[1:end-1] .== 0) + 2*x[end]

function fridgeObjective(ingredientList,fridgeList)
    overlap = sum([food in ingredientList for food in fridgeList])
    remainingFood = length(fridgeList) - overlap
    extraIngredients = length(ingredientList) - overlap
    return overlap + 6*remainingFood + 2*extraIngredients
end

function bestOverlap(recipeDict,fridgeList)
    bestObjective = Inf
    bestRecipe = ""
    for recipe in keys(recipeDict)
        objective = fridgeObjective(recipeDict[recipe],fridgeList)
        if objective < bestObjective
            bestObjective = objective
            bestRecipe = recipe
        end
    end
    return bestRecipe
end

function findBestRecipe(fridgeList, csvPath)
    # load the recipe dictionary from the csv file
    recipeDict = loadRecipeDBCSV(csvPath)

    # create a list of all ingredients in your database
    ingredientList = createIngredientDatabase(recipeDict)

    # check for every food in your fridge if it's in the database. If not check if their are alternatives.
    fridgeList = checkIngredients(fridgeList, ingredientList)

    # find the best recipe
    return bestOverlap(recipeDict,fridgeList)
end

function recipeToNumVector(fridgeList,ingredientList)
    numVector = zeros(length(fridgeList)+1)
    for i in 1:length(fridgeList)
        numVector[i] = fridgeList[i] in ingredientList ? 1 : 0
    end
    numVector[end] = length(ingredientList) - sum(numVector)
    return numVector
end

compatible(x...) = !any(sum(x)[1:end-1] .>= 2)

function findBestCombo(fridgeList, recipeDict, numRecipes)

    bestCombo = Dict()
    ingredientsArray = []
    namesArray = []

    for (name,ingredients) in recipeDict
        push!(namesArray,name)
        push!(ingredientsArray, recipeToNumVector(fridgeList, ingredients))
    end

    for i = 1:numRecipes

        bestOrder = sortperm(ingredientsArray, by=fridgeObjective)
        ingredientsArray = ingredientsArray[bestOrder]
        namesArray = namesArray[bestOrder]

        tempRecipeName = namesArray[i]
        bestCombo[tempRecipeName] = ingredientsArray[i]

        if all(isone.(sum(values(bestCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList .== bestCombo[tempRecipeName]) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList .== bestCombo[tempRecipeName]) == 0]

        if isempty(namesArray)
            print("found max $i compatible recipes.\n")
            break
        end

    end

    for recipeName in keys(bestCombo)
        print("$(recipeName) : $(recipeDict[recipeName])\n")
    end
end

testList = ["cheese","potato","tomato","cabbage"]
recipeDict = loadRecipeDBCSV("./data/recipeDB.csv")

findBestCombo(testList, recipeDict, 3)

#bestRecipe = findBestRecipe(testList, "./docs/recipeDB.csv")

#print(bestRecipe)


