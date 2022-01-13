# A package that optimizes your fridge use!!
# concept: Maximize amount of fridge used. Minimize amount of recipes used, minimize amount of extra ingredients needed

include("../src/recipeWebscraper.jl")

using .recipeWebscraper, JLD2

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

fridgeObjective(x::Array{Float64}) = sum(x[1:end-1]) + 6*sum(x[1:end-1] .== 0) + 2*x[end]

fridgeObjective(x) = compatible(x) ? sum(sum(x) .== 0)*4 + sum(x)[end]*2 : Inf # arbitrary weight for now

#==================================================
                GREEDY ALGORITHM
==================================================#

function GreedyFindCombo(fridgeList, recipeDict, numRecipes)

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

    print("Greedy search results:\n")

    for recipeName in keys(bestCombo)
        print("$(recipeName) : $(recipeDict[recipeName])\n")
    end

    return bestCombo
end

#==================================================
                NEIGBOURHOODS
==================================================#

#=
IDEETJES

1) verwijder 1 ingredient en kijk of je dan een andere combinatie kan vormen met mindere score
2) verwijder een recept en kijk of je een combo kan vinden van recepten die een betere score geven dan de huidige versie
=#

function removeRecipe(curSolution, fridgeList, recipeDict)
    
end

#==================================================
        SIMULATED ANNEALING ALGORITHM
==================================================#

function SAFindCombo(curSolution,  fridgeList, recipeDict;
    kT=100, # repetitions per temperature
    r=0.95, # cooling rate
    Tmax=2, # maximal temperature to start
    Tmin=1) # minimal temperature to end
    
    @assert 0 < Tmin < Tmax "Temperatures should be positive"
	@assert 0 < r < 1 "cooling rate is between 0 and 1"
	solution = curSolution
	obj = fridgeObjective(solution)
	#track!(tracker, f, s) # not yet implemented, maybe later

	# current temperature
	T = Tmax
	while T > Tmin
		# repeat kT times
		for _ in 1:kT
			sn = removeRecipe(curSolution, fridgeList, recipeDict)  # random neighbor
			obj_sn = fridgeObjective(sn)
			# if the neighbor improves the solution, keep it
			# otherwise accept with a probability determined by the
			# Metropolis heuristic
			if obj_sn > obj || rand() < exp(-(obj-obj_sn)/T)
				solution = sn
				obj = obj_sn
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

function findBestRecipe(fridgeList, csvPath; numRecipes=3)
    # load the recipe dictionary from the csv file
    recipeDict = loadRecipeDBCSV(csvPath)

    # create a list of all ingredients in your database
    ingredientList = createIngredientDatabase(recipeDict)

    # check for every food in your fridge if it's in the database. If not check if their are alternatives.
    fridgeList = checkIngredients(fridgeList, ingredientList)

    # find the best greedy recipe
    greedySolution = GreedyFindCombo(fridgeList, recipeDict, numRecipes)

    # find the best recipe with SA
    SASolution = SAFindCombo(greedySolution,  fridgeList, recipeDict)

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
    numVector = zeros(length(fridgeList)+1)
    for i in 1:length(fridgeList)
        numVector[i] = fridgeList[i] in ingredientList ? 1 : 0
    end
    numVector[end] = length(ingredientList) - sum(numVector)
    return numVector
end

compatible(x) = !any(sum(x)[1:end-1] .>= 2)


#==================================================
     TEST CORNER - MOVE LATER TO fridgeTest.jl
==================================================#


testList = ["cheese","potato","tomato","cabbage"]
# recipeDict = loadRecipeDBCSV("./data/recipeDB.csv") # this should be used the first time, else load jld2 file

recipeDict = load("./data/recipeDB.jld2")

test = GreedyFindCombo(testList, recipeDict, 3)
testRecipes = [i for i in values(test)]



#bestRecipe = findBestRecipe(testList, "./docs/recipeDB.csv")

#print(bestRecipe)


