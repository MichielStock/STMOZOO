# Kirsten Van Huffel & Tristan Vanneste

module BeesAlgorithm

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
# using Zygote

# export all functions that are relevant for the user
export initialize_population, evaluate_population

"""
    
    initialize_population(D, bounds_lower, bounds_upper, Np)

    This function generates Np random solutions (food sources) within the domain 
    of the variables to form an initial population for the ABC algorithm.
    
    Input
    - D: number of decision variables
    - bounds_lower: lower bounds of variables 
    - bounds_upper: upper bounds of variables 
    - Np: number of food sources/employed bees/onlooker bees
    
    Output 
    - population: a random solution of the size D


## Examples


```julia-repl
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> D=4
julia> n=9
julia> initialize_population(D, bounds_lower, bounds_upper, n)
9-element Array{Any,1}:
 [1, -5, -5, 2]
 [3, -4, -3, -4]
 [2, -5, 0, 4]
 [-5, 2, 0, -1]
 [2, -2, 0, 4]
 [4, -2, -5, 5]
 [4, -3, -2, -2]
 [-3, 2, 4, -3]
 [3, -2, -1, 4]
```
"""
function initialize_population(D, bounds_lower, bounds_upper, Np)
    population = []   
    for i in 1:Np
        food_source = collect(rand(bounds_lower[i]:bounds_upper[i]) for i in 1:D)
        append!(population, [food_source])
    end  
    return population
end	

"""
    evaluate_population()

explanation
"""
function evaluate_population() 
    return
end

end