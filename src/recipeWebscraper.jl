
module recipeWebscraper

using HTTP, Gumbo, Cascadia, CSV

export scrapeRecipe, loadRecipeDBCSV

# recipe number goes from 2610 to 149191
# downloaded everything until 18788

"""
    scrapeRecipe(scrapeBegin,scrapeEnd,csvPath)

Download recipetitles and their corresponding ingredients from the recipe database of cosylab as a dictionary.
The recipes are downloaded based on their recipe number. This number can range from 2610 to 149191.
To get a recipenumber one should look at the last number of the url of a certain recipe.
For example, the recipe for 'Speculoosbavarois' is number 106585.
The recipes get automatically saved in a csv file where the first column is the recipetitle and the second column
is the list of ingredients.

## Input:
- scrapeBegin: The recipe number where the iteration should begin.
- scrapeEnd: The recipe number after which the iteration should and.
- csvPath: The path where the csv file is stored.

## Examples:

The example below downloads the recipes 2700 to 2702 and 
stores them in the csv file 'recipedb.csv' in the current folder.

```julia-repl
julia> scrapeRecipe(2700,2702,"./recipedb.csv")
```
"""
function scrapeRecipe(scrapeBegin,scrapeEnd,csvPath)

    for i = scrapeBegin:scrapeEnd
        # get the webpage
        htmlText = HTTP.request("GET","https://cosylab.iiitd.edu.in/recipedb/search_recipeInfo/$i")
        htmlBody = parsehtml(String(htmlText.body))

        # get the needed elements out of the webpage
        recipeTitle = eachmatch(Selector("h3"),htmlBody.root)[1].children[1].text
        print("recipe number $i : $recipeTitle\n")
        ingredientTab = eachmatch(Selector("#ingredient_nutri"),htmlBody.root)
        ingredientTabel = eachmatch(Selector("#myTable"),ingredientTab[1])
        ingredientLinks = eachmatch(Selector("td a"),ingredientTabel[1])
        ingredientList = []
        for ingredientLink in ingredientLinks
            try
                append!(ingredientList, [ingredientLink.children[1].text])
            catch y
            end
        end

        # write the data to the DB
        if isfile(csvPath)
            CSV.write(csvPath, Dict(recipeTitle => ingredientList), append = true) 
        else
            CSV.write(csvPath, Dict(recipeTitle => ingredientList), append = false) 
        end
         
    end
    print("done")
end


function loadRecipeDBCSV(csvPath)
    # read the dictionary from the csv file
    print("Loading the recipe database.\n")
    tempDict = CSV.File(csvPath) |> Dict
    recipeDict = Dict()
    
    # parse the ingredient list to the right format
    print("Parsing ingredients to right format.\n\n")
    for recipe in keys(tempDict)
        ingredientList = tempDict[recipe]
        recipeDict[recipe] = eval(Meta.parse(ingredientList))
    end
    return recipeDict 
end

end