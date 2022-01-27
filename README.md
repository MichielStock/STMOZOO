
# Fridge.jl
<img align="right" width="100" height="100" src="FridgeLogo.png">
by <i>Ward Van Belle</i>

A package that optimizes your fridge use while reducing your waste pile!!

This package tries to find the best recipes for you based on a recipe database. In our eyes (and the eyes of the objective function), the best recipes are the ones that use as much ingredients from your fridge as possible and that don't need extra ingredients from the grocery store.

## How to use this package?
There are several ways for you to use this package. 

1. First and foremost you should have a **recipe database**. This database should be a .csv file or a .jld2 file containing the recipe names in one column and a list containing the ingredient names in the next column. For instance:

    | recipeName | Ingredients |
    |:----------:|:-----------:|
    | french fries| potatoes, salt|
    | boiled eggs | eggs, salt|

2. If you just want to find an approximation of the best recipe combo. Then you can use the `greedyFindCombo` function. This performs a greedy search to find a quick solution. However, if you want a chance for a better solution, then you can use the `findBestRecipe` function. This function checks if your ingredients are in the database, and if not it offers possible alternatives. Next it uses **simulated annealing** to find a better recipe combination.

## Help I don't have a database (recipeWebscraper.jl)

Don't worry, we got you covered with `recipeWebscraper.jl`. This module includes a function that downloads recipes from [the cosylab recipe database](https://cosylab.iiitd.edu.in/recipedb/) based on their recipe number and exports them to a **.csv** file. 

You can use the `scrapeRecipe` function for this. Using this method it is possible to download around 16 000 recipes before you get kicked from the site. Therefore it is recommended to look at the cuisine you would like to download and start from the earliest recipe number in this cuisine. Recipe numbers can be found by looking at the end of the url of a recipe page eg. [Belgian Chocolate Mousse](https://cosylab.iiitd.edu.in/recipedb/search_recipeInfo/106541) is the first Belgian recipe and has the recipe number **106541**.


