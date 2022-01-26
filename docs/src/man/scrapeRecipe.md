```@docs

```


# recipeWebscraper

This is a supporting module that allows the user to download recipes from [the cosylab recipe database](https://cosylab.iiitd.edu.in/recipedb/) based on their recipe number and exports them to a **.csv** file.

```@docs
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
```