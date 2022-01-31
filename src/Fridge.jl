module Fridge

include("recipeWebscraper.jl")

using .recipeWebscraper, JLD2

export checkIngredients, greedyFindCombo, findBestRecipe, randomCombo, Neighbour, SAFindCombo, scrapeRecipe, loadRecipeDBCSV

#==================================================
          CHECK INGREDIENTS FUNCTIONS
==================================================#

function createIngredientDatabase(recipeDict)
    # create an unique vector of all ingredients used in the recipe database
    ingredientList = []
    for ingredients in values(recipeDict)
        append!(ingredientList,ingredients)
    end
    ingredientList = unique(ingredientList)

    return ingredientList
end

"""
    checkIngredients(fridgeList, ingredientList)

This function checks if the foods in your fridge are also found in the ingredient overview 
of the recipe database. If they are not found in the database, regex is used to find possible alternatives.
For instance cheese may be replaced by swiss cheese.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- ingredientList: A list containing all the different ingredients that are used in the recipe database.

## Output:
- fridgeList: The (adapted) given fridgeList

"""
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

#==================================================
            OBJECTIVE FUNCTIONS
==================================================#

# objective function used to score a single recipe
fridgeObjective(x::Array{Int64}) = sum(x[1:end-1]) + 6*sum(x[1:end-1] .== 0) + 2*x[end]

# objective function used to score a combination of recipes
fridgeObjective(x) = compatible(x) ? sum(sum(x) .== 0)*6 + sum(x)[end]*2 : Inf 

#==================================================
                GREEDY ALGORITHM
==================================================#

"""
    greedyFindCombo(fridgeList, recipeDict, numRecipes)

This function uses greedy search to find a good combination of recipes that match your fridge content.
It ranks all recipes based on the following formula

``score = (ingredients from fridge used) + 6*(ingredients in fridge remaining) + 2*(extra ingredients needed)``

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.

## Output:
- bestCombo: A dictionary containing the best found combination of recipes.

"""
function greedyFindCombo(fridgeList, recipeDict, numRecipes)

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

        # break if all recipes that are left, don't use anything from the fridge
        if all(ingredientsArray[1][1:end-1] .== 0)
            break
        end

        tempRecipeName = namesArray[1]
        bestCombo[tempRecipeName] = ingredientsArray[1]

        # break if all ingredients are used
        if all(isone.(sum(values(bestCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]

        # break if there are no recipes left
        if isempty(namesArray)
            break
        end

    end

    return bestCombo
end

#==================================================
                NEIGBOURHOODS
==================================================#

"""
    randomCombo(fridgeList, recipeDict, numRecipes)

This function gives a random combination of recipes from the provided recipe dictionary.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.

## Output:
- randCombo: A dictionary containing a random combination of recipes.
"""
function randomCombo(fridgeList, recipeDict, numRecipes)

    randCombo = Dict()
    ingredientsArray = []
    namesArray = []

    for (name,ingredients) in recipeDict
        push!(namesArray,name)
        push!(ingredientsArray, recipeToNumVector(fridgeList, ingredients))
    end

    for i = 1:numRecipes

        randIndex = rand(1:length(namesArray))
        tempRecipeName = namesArray[randIndex]
        randCombo[tempRecipeName] = ingredientsArray[randIndex]

        # break if all ingredients are used
        if all(isone.(sum(values(randCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]

        # break if there are no recipes left
        if isempty(namesArray)
            break
        end

    end

    return randCombo
end

"""
    Neighbour(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)

This is a function that looks for a neighbour of the current solution. This function is used in the simulated annealing algorithm.
It also uses a tabulist to stimulate the use of new solutions.

## Input:
- curSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.
- tabuList: A list of recipes that should not be used in the found neighbour.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used for the neighbour.

## Output:
- neighbour: A dictionary containing a combination of recipes.

"""
function Neighbour(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)

    toRemove = rand(curSolution)[1]
    # adapt the fridgeList so that only ingredients from the removed ingredient are available
    tempFridgeList = copy(fridgeList)
    for recipe in keys(curSolution)
        if recipe != toRemove
            tempFridgeList = [i for i in fridgeList if !in(i,recipeDict[recipe])]
            numRecipes -= 1
        end
    end
    # adapt the recipeDict and use greedy search to find a new solution
    tempRecipeDict = copy(recipeDict)
    for recipe in keys(curSolution)
        delete!(tempRecipeDict,recipe)
    end

    for recipe in tabuList
        try delete!(tempRecipeDict,recipe)
        catch e
        end
    end

    if randRecipe
        neighbour = randomCombo(tempFridgeList, tempRecipeDict, numRecipes)
    else
        neighbour = greedyFindCombo(tempFridgeList, tempRecipeDict, numRecipes)
    end

    # correct recipe vectors
    for recipe in keys(neighbour)
        neighbour[recipe] = recipeToNumVector(fridgeList,recipeDict[recipe])
    end

    # here combine the two dictionaries
    tempCurSolution = copy(curSolution)
    delete!(tempCurSolution,toRemove)
    neighbour = merge(neighbour,tempCurSolution)

    return neighbour
end

#==================================================
        SIMULATED ANNEALING ALGORITHM
==================================================#

"""
    SAFindCombo(curSolution,  fridgeList, recipeDict, numRecipes, randRecipe; kT=100, r=0.75, Tmax=4, Tmin=1, tabuLength=3)

This function uses simulated annealing to find a better combination of recipes that match your fridge content.
It starts with the current solution and tries to improve this.

## Input:
- curSolution: The current best combination of recipes, given as a dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- fridgeList: A list containing the different foods in your fridge as a string.
- recipeDict: A dictionary in which the keys are the recipe names and the responding values are a list of the needed ingredients.
- numRecipes: The max amount of recipes that a combo should contain.
- tabuList: A list of recipes that should not be used in the found neighbour.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used for the neighbour.

## Optional Inputs:
- kT: repetitions per temperature
- r: cooling rate 
- Tmax: maximal temperature to start
- Tmin: minimal temperature to end
- tabuLength: Number of cycli that recipe needs to be blocked

## Output:
- solution: A dictionary containing the best found combination of recipes.

"""
function SAFindCombo(curSolution,  fridgeList, recipeDict, numRecipes, randRecipe;
    kT=100, # repetitions per temperature
    r=0.75, # cooling rate
    Tmax=4, # maximal temperature to start
    Tmin=1, # minimal temperature to end
    tabuLength=3) # number of cycli that recipe needs to be blocked
    
    @assert 0 < Tmin < Tmax "Temperatures should be positive"
	@assert 0 < r < 1 "cooling rate is between 0 and 1"
	solution = curSolution
	obj = fridgeObjective([i for i in values(solution)])
    tabuList = String[i for i in keys(curSolution)] 

	# current temperature
	T = Tmax
	while T > Tmin
        print("T = $T \n")
		# repeat kT times
		for i in 1:kT
			sn = Neighbour(solution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)  # random neighbor
			obj_sn = fridgeObjective([i for i in values(sn)])
			# if the neighbor improves the solution, keep it
			# otherwise accept with a probability determined by the
			# Metropolis heuristic
			if obj_sn < obj || rand() < exp(-(obj_sn-obj)/T)
				solution = sn
				obj = obj_sn
			end

            for recipe in keys(sn)
                if !in(recipe, tabuList)
                    if length(tabuList) < tabuLength
                        pushfirst!(tabuList,recipe)
                    else
                        pop!(tabuList)
                        pushfirst!(tabuList,recipe) 
                    end
                end
            end
		end

		# decay temperature
		T *= r
	end

    return solution
end

#==================================================
                OVERVIEW FUNCTION
==================================================#

"""
    findBestRecipe(fridgeList, csvPath; numRecipes=3, randRecipe=false)

This function combines all other functions. This function checks if your ingredients are in the database, 
if not it offers possible alternatives. Next it uses simulated annealing to find a better recipe combination.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- dataPath: A relative or absolute path to a .csv or .jld2 file containing the recipe database.

## Optional Inputs:
- numRecipes: The max amount of recipes that a combo should contain.
- randRecipe: A Boolean `true` or `false` value. When `true`, random recipes are used to find the neighbour in simulated annealing.

## Output:
- SASolution: A dictionary containing the best found combination of recipes.

"""
function findBestRecipe(fridgeList, dataPath; numRecipes=3, randRecipe=false)


    # load the recipe dictionary from the db file
    recipeDict = dataPath[end-3:end] == ".csv" ? loadRecipeDBCSV(dataPath) : load(dataPath)

    # create a list of all ingredients in your database
    ingredientList = createIngredientDatabase(recipeDict)

    # check for every food in your fridge if it's in the database. If not check if their are alternatives.
    fridgeList = checkIngredients(fridgeList, ingredientList)

    # find the best greedy recipe
    greedySolution = GreedyFindCombo(fridgeList, recipeDict, numRecipes)
    print("greedySolution = $greedySolution\n")

    # find the best recipe with SA
    SASolution = SAFindCombo(greedySolution,  fridgeList, recipeDict, numRecipes, randRecipe)

    # print the solution 
    print("The best recipes to make are:\n\n")
    for recipeName in keys(SASolution)
        print("$(recipeName) : $(recipeDict[recipeName])\n")
    end

    return SASolution
end

#==================================================
            SUPPORTING FUNCTIONS
==================================================#

"""
    recipeToNumVector(fridgeList,ingredientList)

This function changes an ingredients list of a recipe to a numeric vector. This vector has a length equal
to the number of foods in your fridge plus one. If a certain food from the fridge is used in the recipe, that position in the vector is a 1.
If not it is a 0. The last index of the vector contains the amount of extra ingredients needed.

## Input:
- fridgeList: A list containing the different foods in your fridge as a string.
- ingredientList: A list containing all the ingredients used in a specific recipe.

## Output:
- numVector: This vector has a length equal to the number of foods in your fridge plus one. If a certain food from the fridge is used in the recipe, 
that position in the vector is a 1. If not it is a 0. The last index of the vector contains the amount of extra ingredients needed.

"""
function recipeToNumVector(fridgeList,ingredientList)

    numVector = zeros(Int64,length(fridgeList)+1)
    for i in 1:length(fridgeList)
        numVector[i] = fridgeList[i] in ingredientList ? 1 : 0
    end
    numVector[end] = length(ingredientList) - sum(numVector)
    return numVector
end

compatible(x) = !any(sum(x)[1:end-1] .>= 2) # checks if two recipes use a same ingredient

end # module