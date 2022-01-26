module Fridge

include("recipewebscraper.jl")

using .recipeWebscraper, JLD2

export checkIngredients, greedyFindCombo, findBestRecipe, removeRecipe, SAFindCombo

#==================================================
          CHECK INGREDIENTS FUNCTIONS
==================================================#

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

#==================================================
            OBJECTIVE FUNCTIONS
==================================================#

fridgeObjective(x::Array{Int64}) = sum(x[1:end-1]) + 6*sum(x[1:end-1] .== 0) + 2*x[end]

fridgeObjective(x) = compatible(x) ? sum(sum(x) .== 0)*6 + sum(x)[end]*2 : Inf # arbitrary weight for now

#==================================================
                GREEDY ALGORITHM
==================================================#

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

        tempRecipeName = namesArray[1]
        bestCombo[tempRecipeName] = ingredientsArray[1]

        if all(isone.(sum(values(bestCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& bestCombo[tempRecipeName][1:end-1] ) == 0]

        if isempty(namesArray)
            break
        end

    end

    return bestCombo
end

#==================================================
                NEIGBOURHOODS
==================================================#

function RandomCombo(fridgeList, recipeDict, numRecipes)
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

        if all(isone.(sum(values(randCombo))))
            break
        end

        namesArray = [name for (name, ingredientList) in zip(namesArray, ingredientsArray) if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]
        ingredientsArray = [ingredientList for ingredientList in ingredientsArray if sum(ingredientList[1:end-1] .& randCombo[tempRecipeName][1:end-1] ) == 0]

        if isempty(namesArray)
            break
        end

    end

    return randCombo
end

function removeRecipe(curSolution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)
    toRemove = rand(curSolution)[1]
    # adapt the fridgeList so that only ingredients from the removed ingredient are available
    tempFridgeList = copy(fridgeList)
    for recipe in keys(curSolution)
        if recipe != toRemove
            tempFridgeList = [i for i in fridgeList if !in(i,recipeDict[recipe])]
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
        neighbour = RandomCombo(tempFridgeList, tempRecipeDict, numRecipes)
    else
        neighbour = GreedyFindCombo(tempFridgeList, tempRecipeDict, numRecipes)
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
	#track!(tracker, f, s) # not yet implemented, maybe later

	# current temperature
	T = Tmax
	while T > Tmin
        print("T = $T \n")
		# repeat kT times
		for i in 1:kT
			sn = removeRecipe(solution, fridgeList, recipeDict, numRecipes, tabuList, randRecipe)  # random neighbor
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
		#track!(tracker, f, s) # not yet implemented, maybe later

		# decay temperature
		T *= r
	end

    return solution
end

#==================================================
                OVERVIEW FUNCTION
==================================================#

function findBestRecipe(fridgeList, csvPath; numRecipes=3, randRecipe=false)
    # load the recipe dictionary from the db file
    recipeDict = csvPath[end-3:end] == ".csv" ? loadRecipeDBCSV(csvPath) : load(csvPath)

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

function recipeToNumVector(fridgeList,ingredientList)
    numVector = zeros(Int64,length(fridgeList)+1)
    for i in 1:length(fridgeList)
        numVector[i] = fridgeList[i] in ingredientList ? 1 : 0
    end
    numVector[end] = length(ingredientList) - sum(numVector)
    return numVector
end

compatible(x) = !any(sum(x)[1:end-1] .>= 2)

end # module