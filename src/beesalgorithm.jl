# Kirsten Van Huffel & Tristan Vanneste

module BeesAlgorithm

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
# using Zygote

# export all functions that are relevant for the user
export initialize_population, compute_objective, compute_fitness, foodsource_info_prob, create_newsolution, employed_bee_phase, onlooker_bee_phase, Scouting, ArtificialBeeColonization, sphere, ackley, rosenbrock, branin, rastrigine

"""
    initialize_population(D::Number, bounds_lower::Vector, bounds_upper::Vector, Np::Number)

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
 [-2, 2, 5, -5]
 [2, 1, -5, 1]
 [4, 1, 2, 2]
 [-3, -4, -2, -2]
 [1, 2, 4, 3]
 [4, -2, 3, -4]
 [1, 1, 0, -1]
 [2, -2, -2, -5]
 [-3, 2, 3, -3]
```
"""
function initialize_population(D::Number, bounds_lower::Vector, bounds_upper::Vector, Np::Number)
    population = []   
    for i in 1:Np
        food_source = collect(rand(bounds_lower[i]:bounds_upper[i]) for i in 1:D)
        append!(population, [food_source])
    end  
    return population
end	

"""
    compute_objective(input, f::Function)

Calculates the objective values for a certain function. 

Input
- input: input values
- f: the function that you want to use for computing objective values

Output 
- output: objective values


##Examples

```julia-repl
julia> D=4
julia> n=9
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> population = initialize_population(D, bounds_lower, bounds_upper, n)
julia> compute_objective(population, sphere)
9-element Array{Any,1}:
 34
 75
 18
 51
 42
 51
 31
 42
 59

 julia> compute_objective(population, ackley)
 9-element Array{Any,1}:
  8.836638915350669
 11.587599478917705
  6.914978162949289
 10.20776787857683
  9.538956614465143
 10.20776787857683
  8.538932726524155
  9.538956614465143
 10.722262633846869
```

"""
function compute_objective(input, f::Function)
    if length(input)==1
        objective = f(sum(input))
        output = objective
    else
        objectives_population = []
        for j in 1:length(input)
            food_source = input[j]
            objective = f(food_source)
            append!(objectives_population, objective)
        end
        output = objectives_population
    end
    return output
end

""" 
    compute_fitness(objective_values)

This functions computes the fitness of a population.
The fitness is computed as 1/(1+objective_values).
The bigger the objective values the smaller the fitness values.

Input
- objective values: objective values 

Output
- fitness values: fitness values

##Examples

```julia-repl
julia> objective_values = [4 5 -1]
julia> compute_fitness(objective_values)
3-element Array{Any,1}:
 0.2
 0.16666666666666666
 2
```

"""
function compute_fitness(objective_values)
    fitness_values = []
    
    for i in 1:length(objective_values)
        objective_value = objective_values[i]
        
        if objective_value >= 0
            fitness = 1/(1+objective_value)
     
        else
            fitness = 1+abs(objective_value)
        end
        
        append!(fitness_values, fitness)
    end
    return fitness_values
end	


""" 
    foodsource_info_prob(fitness_values)

This function measures the food source information in probabilities. 
The food source information is calculated as following: 0.9*(fitness_value/maximum(fitness_values)) + 0.1. 

Input
- fitness_values: fitness values

Output
- probabilities: probabilities of the food source information 


##Examples

```julia-repl
julia> fitness_values = [0.2 0.16 1]
julia> foodsource_info_prob(fitness_values)
3-element Array{Any,1}:
 0.28
 0.24400000000000002
 1.0
 ```

"""
function foodsource_info_prob(fitness_values)
    probabilities = []
    
    for i in 1:length(fitness_values)
        fitness_value = fitness_values[i] 
        probability = 0.9*(fitness_value/maximum(fitness_values)) + 0.1
        append!(probabilities, probability)
    end
    
    return probabilities
end	


""" 
    create_newsolution(solution::Vector, population, bounds_lower::Vector, bounds_upper::Vector)

Creates new solution by changing one variable using a partner solution.

Input
- solutions: current solution 
- population : population of solutions 
- bounds_lower: lower bounds of variables 
- bounds_upper: upper bounds of variables 

Output
- solution_new: new solution with one variable changed using the partner solutions


##Examples

```julia-repl
julia> solution = [4 0 1 4]
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> D=4
julia> n=9
julia> population = initialize_population(D, bounds_lower, bounds_upper, n)
julia> create_newsolution(solution, population, bounds_lower, bounds_upper)
1×4 Array{Float64,2}:
 -1.49748  0.0  1.0  4.0
 ```

"""
function create_newsolution(solution, population, bounds_lower::Vector, bounds_upper::Vector)
    # select random variable to change       
    randomvar1_index = rand(1:size(solution)[1], 1)

    # select partner solution to generate new solution        
    randompartner_index = rand(1:size(population)[1], 1)

    # select random variable in partner solution to exchange with

    randompartner = population[randompartner_index, :][1]
    randomvar2_index = rand(1:length(randompartner), 1)

    # create new food location
    phi = rand()*2-1 #random number between -1 and 1     
    global solution_new = float(deepcopy(solution))
    a = solution[randomvar1_index] 
    b = randompartner[randomvar2_index]
    solution_new[randomvar1_index] = a + phi*(a - b)

    # check if lower bound is violated
    if solution_new[randomvar1_index] < bounds_lower[randomvar1_index] 
        solution_new[randomvar1_index] = bounds_lower[randomvar1_index]
    end

    # check if upper bound is violated
    if solution_new[randomvar1_index] > bounds_upper[randomvar1_index]
        solution_new[randomvar1_index] = bounds_upper[randomvar1_index]
    end
return solution_new
end


""" 
    employed_bee_phase(population, bounds_lower::Vector, bounds_upper::Vector, trial::Vector, Np::Number, f::Function)

This functions employs the employed bee phase. 

Input
- population: population of solutions 
- bounds_lower: lower bounds of variables 
- bounds_upper: upper bounds of variables 
- trial: current trial of solutions
- Np: number of food sources/employed bees/onlooker bees
- f: the function that you want to use for computing objective values

Output
- population_new_evolved: new population values
- fitness_new_evolved: new fitness values
- objective_new_evolved: new objective values
- trial: updated trials of solutions in population
    When original solution has failed to generate better solution, trial counter is increased by 1 unit
    When better solution has been found, the trial counter for this new solution is set to zero


## Examples
 
```julia-repl
julia> trial = zeros(size(population)[1])
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> D=4
julia> N=9
julia> population = initialize_population(D, bounds_lower, bounds_upper, n)
julia> population_new_evolved, fitness_new_evolved, objective_new_evolved, trial = employed_bee_phase(population, bounds_lower, bounds_upper, trial,n ,sphere)
julia> population_new_evolved
9-element Array{Any,1}:
 [5.0, -5.0, 5.0, 2.748420414594148]
 [2, 4, 0, -4]
 [-5.0, 2.0, 0.0, -1.1761590179019343]
 [1, 5, 5, -2]
 [2.0, -1.0, -3.0, 0.75942632274392]
 [1, 5, -1, 1]
 [0.0, 3.1592990065770192, -2.0, -3.0]
 [-4, 3, 3, 2]
 [3, 2, -3, -3]
 ```
"""
function employed_bee_phase(population, bounds_lower::Vector, bounds_upper::Vector, trial, Np::Number, f::Function)
    population_new = []
    
    # create new food sources
    for i in 1:Np
        solution = population[i, :][1]
        solution_new = solution
        while solution_new == solution
            solution_new = create_newsolution(solution, population, bounds_lower, bounds_upper)
        end
        append!(population_new, [solution_new])
    end
    
    # evaluate fitness old and new population
    objective_values_old = compute_objective(population, f)
    fitness_old = compute_fitness(objective_values_old)
    objective_values_new = compute_objective(population_new, f)
    fitness_new = compute_fitness(objective_values_new)

    # perform greedy selection
    population_new_evolved = []
    fitness_new_evolved = []
    objective_new_evolved = []
    
    for j in 1:Np
        if fitness_new[j] > fitness_old[j]
            append!(population_new_evolved, [population_new[j]])
            append!(fitness_new_evolved, fitness_new[j])
            append!(objective_new_evolved, objective_values_new[j])
            trial[j] = 0
        else 
            append!(population_new_evolved, [population[j]]) 
            append!(fitness_new_evolved, fitness_old[j])
            append!(objective_new_evolved, objective_values_old[j])
            trial[j] += 1
        end
    end
    
    return population_new_evolved, fitness_new_evolved, objective_new_evolved, trial
end

""" 
onlooker_bee_phase(population, bounds_lower::Vector, bounds_upper::Vector, trial::Vector, Np::Number, f::Function)  

This function employs the onlooker bee phase. 

Input
- population: population of solutions 
- bounds_lower: lower bounds of variables 
- bounds_upper: upper bounds of variables 
- trial: current trial of solutions
- Np: number of food sources/employed bees/onlooker bees
- f: the function that you want to use for computing objective values

Output
- population: new population values
- fitness_new_evolved: new fitness values
- objective_new_evolved: new objective values
- trial: updated trials of solutions in population
    When original solution has failed to generate better solution, trial counter is increased by 1 unit
    When better solution has been found, the trial counter for this new solution is set to zero


##Examples
 
```julia-repl
julia> trial = zeros(size(population)[1])
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> D=4
julia> N=9
julia> population = initialize_population(D, bounds_lower, bounds_upper, n)
julia> population_new_evolved, fitness_new_evolved, objective_new_evolved, trial = onlooker_bee_phase(population, bounds_lower, bounds_upper, trial,n ,sphere)
julia> population_new_evolved
9-element Array{Any,1}:
 [-1.0, -5.0, 0.5313751547457599, 5.0]
 [-1, -3, -4, -2]
 [0, 1, -3, 5]
 [1.0, -4.0, -5.0, 1.8770812747894876]
 [-0.944880850158663, -1.2865870734899967, 0.04370050469571929, 1.0]
 [4, -3, 5, 5]
 [0.0, 1.0208794819836884, 0.0, -3.0]
 [-2, 2, 5, -1]
 [-5, -3, -4, 5]
 ```

"""
function onlooker_bee_phase(population, bounds_lower::Vector, bounds_upper::Vector, trial, Np::Number, f::Function)
    m = 0 # onlooker bee
    n = 1 # food source
    
    objective_values = compute_objective(population,f)
    fitness = compute_fitness(objective_values)
    # first calculate the probability values
    proba = foodsource_info_prob(fitness)
    
    while m <= Np # we want for every onlooker bee a new solution
        r = rand()
        if r <= proba[n]
            solution = population[n, :][1] # solution n
            objective_values_old = compute_objective([solution], f)
            fitness_old = compute_fitness(objective_values_old)
            
            solution_new = solution
            while solution_new == solution
                solution_new = create_newsolution(solution, population, bounds_lower, bounds_upper)
            end
    
            objective_values_new = compute_objective([solution_new], f)
            fitness_new = compute_fitness(objective_values_new)
            
            if fitness_new > fitness_old # if this get accepted 
                population[n, :] = [solution_new]
                trial[n]=0
            else 
                trial[n] += 1
            end
            m = m + 1
        end
        # if the rand < proba is not sattisfied
        n = n +1
        if n > Np 
            n = 1
        end
    end
    objective_new_evolved = compute_objective(population,f)
    fitness_new_evolved = compute_fitness(objective_new_evolved)
    
    return population, fitness_new_evolved, objective_new_evolved, trial
end	

""" 
    Scouting(population, bounds_lower::Vector, bounds_upper::Vector, trials::Vector, fitness, objective, limit::Number, f::Function)  

This function employs the scouting phase. 

Input
- population : population of solutions 
- bounds_lower: lower bounds of variables 
- bounds_upper: upper bounds of variables 
- trials: current trial of solutions
- fitness: fitness values
- objective: objective values
- limit: limit value
- f: the function that you want to use for computing objective values

Output 
- population: new population values
- fitness: new fitness values
- objective: new objective values
- trials: updated trials of solutions in population
    When original solution has failed to generate better solution, trial counter is increased by 1 unit
    When better solution has been found, the trial counter for this new solution is set to zero

##Examples
 
```julia-repl
julia> trial = trial = ones(size(population)[1])
julia> bounds_lower = [-5,-5,-5,-5]
julia> bounds_upper = [5,5,5,5]
julia> D=4
julia> N=9
julia> population = initialize_population(D, bounds_lower, bounds_upper, n)
julia> population 
9-element Array{Any,1}:
 [3, 1, 2, -2]
 [-5, 4, 4, 2]
 [-4, 5, -2, -4]
 [5, 5, -5, 0]
 [-2, -4, 5, 5]
 [1, 2, 5, -2]
 [1, -1, 5, -5]
 [-2, -5, -4, -5]
 [5, -1, -1, -1]
julia> objective= compute_objective(population,sphere)
julia> fitness = compute_fitness(objective)
julia> population_new_evolved, fitness_new_evolved, objective_new_evolved, trial  = Scouting(population, bounds_lower, bounds_upper, trial, fitness, objective, 0, sphere)
julia> population_new_evolved
9-element Array{Any,1}:
 [3, 1, 2, -2]
 [-5, 4, 4, 2]
 [-2.959166963468496, 2.2098469985145712, -0.2708630367391418, 4.89872222904274]
 [5, 5, -5, 0]
 [-2, -4, 5, 5]
 [1, 2, 5, -2]
 [1, -1, 5, -5]
 [-2, -5, -4, -5]
 [5, -1, -1, -1]
 ```

"""
function Scouting(population, bounds_lower::Vector, bounds_upper::Vector, trials, fitness, objective, limit::Number, f::Function)
        
    # check whether the trial vector exceed the limit value and importantly where
    index_exceed = trials .> limit

    if sum(index_exceed) >= 1 # there is minimal one case where we exceed the limit
        if sum(maximum(trials) .== trials) > 1 # multiple cases have the same maximum so chose randomly
            possible_scoutings = findall(trials .== maximum(trials))
            idx = rand(1:size(possible_scoutings)[1])
            global scouting_array = possible_scoutings[idx]
        else # only one array has a maximum => chose this one 
        
            global scouting_array = argmax(trials)
        end
        pop = population[scouting_array]
        fit = fitness[scouting_array]
        obj = objective[scouting_array]
        trail = trials[scouting_array]
    
        #creating random population
        sol_new = bounds_lower + (bounds_upper-bounds_lower) .* rand(D) # -5 *(10*rand)
        new_obj = compute_objective([sol_new],f)
        new_fit = compute_fitness(new_obj)
    
        # replacing the new population
        population[scouting_array] = sol_new
        fitness[scouting_array] = new_fit[1]
        objective[scouting_array] = new_obj
        trials[scouting_array] = 0
    
    end
    return population, fitness, objective, trials  
end

""" 
    ArtificialBeeColonization(D::Number, bounds_lower::Vector, bounds_upper::Vector, S::Number, T::Number, limit::Number, f::Function)

This functions runs the Artificial Bee Colony Algorithm with as output the optimal solution of the size D (number of decision variables).

Input
- D: number of decision variables
- bounds_lower: lower bounds of variables 
- bounds_upper: upper bounds of variables 
- S: swarm size
- T: number of cycles
- limit: decides when scouts phase needs to be executed (often taken Np*D)
- f: the function that you want to use for computing objective values



Output
- optimal_solution: gives a vector of the size of D with the optimal solution  
- populations: all populations that were computed during the algorithm
-fitness_tracker: vector with all fitness values for already done iterations 

##Examples

```julia-repl
julia> S = 24
julia> bounds_lower = [-100,-100,-100,-100]
julia> bounds_upper = [100,100,100,100]
julia> D=4
julia> limit = D * (S/2)
julia> T = 500
julia> optimal_solution,populations,best_fitness_tracker = ArtificialBeeColonization(D, bounds_lower, bounds_upper, S, T, limit, sphere)
julia> optimal_solution
4-element Array{Float64,1}:
  1.4537737816170574e-9
 -9.379333377223156e-9
 -2.478809612571768e-9
  3.9716934385662925e-11
```
"""
function ArtificialBeeColonization(D::Number, bounds_lower::Vector, bounds_upper::Vector, S::Number, T::Number, limit::Number, f::Function)
    @assert D > 0 "D must be positive" 
    @assert bounds_lower <= bounds_upper "Lower bounds must be smaller than upper bounds"
    @assert length(bounds_lower) == length(bounds_upper) == D  "The length of the lower bounds must be equal to the length of the upper bounds and the number of decision variables"
    @assert iseven(S) "The particle swarm size must be an even number"
    @assert S > 0 "Particle swarm size must be a positive number"
    @assert T > 0 "Number of cycles must be positive"
 
    
    Np = Int8(S/2) # number of food sources/employed bees/onlooker bees
    
    # initialize population
    population = initialize_population(D, bounds_lower, bounds_upper, Np)
    
    # calculate objective values and fitness values for population
    objective_values = compute_objective(population, f)
    fitness_values = compute_fitness(objective_values)
    
    # initialize trial vector for population
    trial = zeros(Np, 1)
    best_fitness = 0
    best_fitness_tracker = []
    optimal_solution = []
    populations = []
    for iterations in 1:T
    
        ## EMPLOYED BEE PHASE
        population, fitness_values, objective_values, trial = employed_bee_phase(population, bounds_lower, bounds_upper, trial, Np, f::Function)
    
    
        ## ONLOOKER BEE PHASE
        population, fitness_values, objective_values, trial = onlooker_bee_phase(population, bounds_lower, bounds_upper, trial, Np, f::Function)  
       
        ## SCOUTING PHASE
        if maximum(fitness_values) > best_fitness
            best_fitness = maximum(fitness_values)
            ind = argmax(fitness_values)
            optimal_solution = population[ind]
            
        end
            
        population, fitness_values, objective_values, trial = Scouting(population, bounds_lower, bounds_upper, trial, fitness_values, objective_values, limit, f::Function)
        
        if maximum(fitness_values) > best_fitness
            best_fitness = maximum(fitness_values)
            ind = argmax(fitness_values)
            optimal_solution = population[ind]
            
        end
        populations = append!(populations, [population])
        best_fitness_tracker = append!(best_fitness_tracker, best_fitness)
    end

    return optimal_solution,populations, best_fitness_tracker
end

""" 
    sphere(x)

This is computing the sphere function values for the input values of x. 

Input
- x: input values for the sphere function

Output
- output: output values for the sphere function


##Examples

```julia-repl
julia> sphere(4)
16
julia> sphere([4,5])
41
```

"""
function sphere(x)
    return sum(x.^2)
end

""" 
    ackley(x; a=20, b=0.2, c=2π)

This is computing the ackley function values for the input values of x. 
        
Input
- x: input values for the ackley function
        
Output
- output: output values for the ackley function  
        

##Examples

```julia-repl
julia> ackley(4)
11.013420717655569
julia> ackley([4,5])
11.913518152857637
```

"""
function ackley(x; a=20, b=0.2, c=2π)
    d = length(x)
    return -a * exp(-b*sqrt(sum(x.^2)/d)) -
        exp(sum(cos.(c .* x))/d) + a + exp(1)
end

""" 
    rosenbrock(x; a=1, b=5)

This is computing the rosenbrock function values for the input values of x. 
Watch out! This function always needs a 2-element Array as input
        
Input
- x: input values for the rosenbrock function
        
Output
- output: output values for the rosenbrock function  
        

##Examples

```julia-repl
julia> rosenbrock([4,5])
614
```

"""
function rosenbrock(x; a=1, b=5)
    # 2 dimensions!
    return (a-x[1])^2 + b*(x[2]-x[1]^2)^2
end

""" 
    branin((x1, x2); a=1, b=5.1/(4pi^2), c=5/pi, r=6, s=10, t=1/8pi)

This is computing the branin function values for the input values of x. 
Watch out! This function always needs a 2-element Array as input
        
Input
- x: input values for the branin function
        
Output
- output: output values for the branin function  
        

##Examples

```julia-repl
julia> branin([4,5])
14.608661704375713
```

"""
function branin((x1, x2); a=1, b=5.1/(4pi^2), c=5/pi, r=6, s=10, t=1/8pi)
    # 2 dimensions!
    return a * (x2 - b * x1^2 + c * x1 - r)^2 + s * (1 - t) * cos(x1) + s
end
""" 
    rastrigine(x; A=10)

This is computing the rastrigine function values for the input values of x. 

        
Input
- x: input values for the rastrigine function
        
Output
- output: output values for the rastrigine function  
        

##Examples

```julia-repl
julia> rastrigine(4)
16.0
julia> rastrigine([4,5])
41.0
```

"""
function rastrigine(x; A=10)
    return length(x) * A + sum(x.^2 .- A .* cos.(2pi .* x))
end

end