### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 0ca837e0-42ef-11eb-17fa-9335cb9a3997
using InteractiveUtils, Plots, PlutoUI

# ╔═╡ eee523f0-436e-11eb-2e92-d59ed5c533e6
md" 	
# The Artificial Bee Algorithm - Tutorial

## Introduction
The artificial bee algorithm (ABC) is a swarm intelligence metaheuristics algorithm for solving optimization problems. In this tutorial, the module **BeesAlgorithm**, which implements the ABC algorithm for optimization of **continuous functions**, will be demonstrated. Several test functions such as the **Sphere, Ackley, Rosenbrock, Branin** and **Rastrigine** function will be minimized to illustrate the efficacy of the ABC algorithm. Visualizations are provided to show the convergence of the ABC algorithm.

## Concept
##### General
The ABC algorithm is inspired by the **foraging behaviour of honey bees**. Honey bees collect nectar from flower patches as a food source for the colony. Bees are send to explore different flower patches and they communicate the quality of these food sources through waggle dances. Good sites are continually exploited, while bees are sent out in search of additional promising sites.

##### Metaphor

As a methaphor for the foraging behaviour of bees, the ABC algorithm relies on 3 main components:

- **Food sources**, which can be considered as potential solutions of the optimization problem.

- **Employed foragers**. They exploit a food source, return to the colony to share their information with a certain probility, perform a waggle dance and recruit other bees, and then continue to forage at the food source.  

- **Unemployed foragers**. This category consists of 2 types of bees. On the one hand, the **onlooker bees** watch the waggel dances to become a recruit and start searching for a food source. On the other hand, the **scout bees** start searching for interesting flower patches around the nest spontaneously.


The fitness of a solution or food source is inversely related with the value of the objective function in this solution. Thus, a higher fitness corresponds to a lower objective value. In the optimization process, we want to **maximize fitness** and **minimize the objective function** to find the minimizer of a continous function. 



The following phases in the ABC algorithm can be distinguished:

**1) Employed bee phase**\
Employed bees try to identify better food source than the one they were associated previously. A new solution is generated using a partner solution. Thereafter, greedy selection is performed, meaning that a new solution only  will be accepted if it is better than the current solution. Every bee in the swarm will explores one food source. All solutions get an opportunity to generate a new solution in the employed bee phase.

**2) Onlooker bee phase**\
In the onlooker bee phase, a food source is selected for further exploitation with a probability related to the nectar amount, i.e. a solution with higher fitness will have a higher probability to be chosen. Fitter solutions may undergo multiple onlooker bee explorations. As in the employed bee phase, new solutions are generated using a partner solution and greedy selection is performed. In contrast to the employed bee phase, not every food source will be explored, since every onlooker bee will explore a certain food source with a certain probability (depending on nectar amount).

During the 2 phases above, a trial counter is registered for every foos source. Each time a food source fails to generate a solution with higher fitness, the trial counter is elevated by 1 unit.

The solution with highest fitness so far is kept apart in memory during the entire process and updated as better food sources are discovered.

**3) Scout bee phase**\
If the value of the trial counter for a certain solution is greater than fixed limit, then a solution can enter the scout phase. The latter food source is then considered as exhausted and will therefore be abandoned by the bees. After discarding the exhausted solution, a new random solution is generated and the trial counter of this solution is reset to zero.

 
 
"

# ╔═╡ 3c1c9be0-4373-11eb-1b1e-3d3f2e6afb19
md" 	
## Visualization of the ABC algorithm
#### Evolution of bee swarms during optimization 
"

# ╔═╡ 7a2fdff0-4373-11eb-337a-8fb102ef7b78
md"  **Loading packages** "

# ╔═╡ 99ef02ce-4373-11eb-3592-ef0287dca72c
md" **Upload functions**\
The explanation of these functions can be retrieved on the documentation page."

# ╔═╡ 70832f00-42a3-11eb-047e-a38754853775
begin
	""" Initialize population
	
	This function generates n random solutions (food sources) within the domain 
	of the variables to form an initial population for the ABC algorithm
	
	Input
	- D: number of variables
	- bounds_lower: lower bounds of variables in vector
	- bounds_upper: upper bounds of variables in vector
	- n: number of solutions in population
	
	"""
	
	function initialize_population(D, bounds_lower, bounds_upper, n)
	    # controleer inputs met assert!
	    #lower bounds < upper bounds (@assert)
	    # n>0 (@assert)
	    # D>0
	    population = []   
	    for i in 1:n
	        food_source = collect(rand(bounds_lower[i]:bounds_upper[i]) for i in 1:D)
	        append!(population, [food_source])
	    end
	        
	    return population
	end	
	
	
end

# ╔═╡ 74b19670-42a3-11eb-2ffb-253407cbad76
 
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
 

# ╔═╡ 7f387140-42a3-11eb-1b22-8f9ca4f6bacd
begin
	""" Fitness function
	
	Input
	- objective values
	
	Output
	- fitness values
	
	
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
	
	
end

# ╔═╡ 8e011470-42a3-11eb-0443-a70ffec0d6f3
begin
	""" Food source information (measured in probabilities)
	
	Input
	- fitness values
	
	Output
	- probability/food source information values
	
	
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
	
	
end

# ╔═╡ a8d02d90-42a3-11eb-36d5-d319a05d9347
begin
	""" Create new solution by changing one variable using partner solution
	
	Input
	- solutions (location of food sources)
	
	Output
	- new solution with one variable changed
	
	
	"""
	
	function create_newsolution(solution, population, bounds_lower, bounds_upper)
	    
	    # select random variable to change       
	    randomvar1_index = rand(1:length(solution), 1)
	        
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
	
	
end

# ╔═╡ 85259fae-42a3-11eb-0431-67e3278dbfb0
begin
	""" Employed bee phase function
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
	
	"""
	
	function employed_bee_phase(population, bounds_lower, bounds_upper, trial, Np, f::Function)
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
	
	
end

# ╔═╡ 9b02b33e-42a3-11eb-16b2-4fc4e0e2ba50
begin
	""" Onlooker bee phase function
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
	
	"""
	
	function onlooker_bee_phase(population, bounds_lower, bounds_upper, trial, Np, f::Function)
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
	
	
	
end

# ╔═╡ f14360b0-42e9-11eb-1f4c-35d1a9eb188e
begin
	# Defining the test functions
	function sphere(x)
	    d = length(x)
	    return sum(x.^2)
	end  
	
	function ackley(x; a=20, b=0.2, c=2π)
	    d = length(x)
	    return -a * exp(-b*sqrt(sum(x.^2)/d)) -
	        exp(sum(cos.(c .* x))/d) + a + exp(1)
	end
	
	function rosenbrock((x1, x2); a=1, b=100)
	    # 2 dimensions!
	    return (a-x1)^2 + b*(x2-x1^2)^2
	end
	
	function branin((x1, x2); a=1, b=5.1/(4pi^2), c=5/pi, r=6, s=10, t=1/8pi)
	    # 2 dimensions!
	    return a * (x2 - b * x1^2 + c * x1 - r)^2 + s * (1 - t) * cos(x1) + s
	end
	
	function rastrigine(x; A=10)
	    return length(x) * A + sum(x.^2 .- A .* cos.(2pi .* x))
	end
end

# sphere: the minimum value of zero is at (0,0)
# ackley: the minimum value of zero is at (0,0)
# rosebrock: the minimum value of zero is at (1,1)
# brunin: Branin-Hoo, function has three global minima: at (-3.14, 12.275), (3.14, 2.275), (9.42, 2.475)
# rastrigine: the minimum value of zero is at (0,0)

# ╔═╡ a9462a5e-4373-11eb-3b48-39a2596229a9
md" **Choose the test function** you want to minimize with the select button below."

# ╔═╡ 27f302ee-42ea-11eb-2d9e-49dffc0d983d
@bind functie Select(["ackley", "sphere","rosenbrock","branin","rastrigine"])

# ╔═╡ 3235a8d2-42ea-11eb-1fe1-6d91eca83dad
begin
	if functie == "ackley"
		f_optimize = ackley;
	end	
	if functie == "sphere"
		f_optimize = sphere;
	end	
	if functie == "rosenbrock"
		f_optimize = rosenbrock;
	end 	
	if functie == "branin"
		f_optimize = branin;
	end 	
	if functie == "rastrigine"
		f_optimize = rastrigine;
	end 	
end

# ╔═╡ 085c34e0-4374-11eb-1ba7-7fb1af1d38a4
md" Choose the **swarm size S** (even number). \
The **number of decision variables D** (determining the dimension of the optimization problem) is fixed to 2 in this tutorial for  visualization purposes.\
The **limit** is fixed to a convenient value of D*(S/2). "



# ╔═╡ 0388b3ce-4374-11eb-03f4-9b4c74bd5ff0
S = 24

# ╔═╡ 350644d0-4375-11eb-2b68-8fb8f4bd7c2a
D = 2

# ╔═╡ 9ca62a10-42a3-11eb-1650-6544fb0ebd31
begin
	""" Scouting function
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
	
	
	"""
	
	function Scouting(population, bounds_lower, bounds_upper, trials, fitness, objective, limit, f::Function)
	        
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
	
	
	
end

# ╔═╡ b023f0e0-42a3-11eb-18f9-c1b132fb5276
begin
	""" Artificial Bee Colony Algorithm

This functions runs the Artificial Bee Colony Algorithm with as output the optimal solution of the size D.

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

"""

function ArtificialBeeColonization(D, bounds_lower, bounds_upper, S, T, limit, f::Function)
    @assert D > 0 # only a positive number of decision variables
    @assert bounds_lower <= bounds_upper # lower bounds must be lower than the upperbounds or equal
    @assert length(bounds_lower) == length(bounds_upper) == D  # length of the boundries must be equal to the number of decision variables
    @assert iseven(S) # swarm size must be an even number
    @assert S > 0 # swarm size can not be negative
    @assert T > 0 # number of cylces must be positive
 
    
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
	
end

# ╔═╡ c7c64720-437f-11eb-15a2-477ab2fe0792
limit = D * (S/2)

# ╔═╡ caa5b6d0-4373-11eb-0cdd-1961e6698727
md" Appropriate parameters for the chosen test function are defined. Next, the **ABC algorithm executes the searching procedure** for finding the global minimum of the test function."

# ╔═╡ f347e610-42a3-11eb-2116-ef50f1246cf3
begin 

	if functie == "sphere"
		T = 35
		bounds_lower = [-100,-100];  
		bounds_upper = [100,100];
	end
	
	if functie == "ackley"
		T = 50
		bounds_lower = [-30,-30];  
		bounds_upper = [30,30];
	end
	
	if functie == "rosenbrock"
		T = 1000
		bounds_lower = [-100, -100];  
		bounds_upper = [100,100];
	end
	
	if functie == "branin"
		T = 50
		bounds_lower = [-5,0];  
		bounds_upper = [10,15];
	end
	
	if functie == "rastrigine"
		T = 50
		bounds_lower = [-5,-5];  
		bounds_upper = [5,5];	
	end
end

# ╔═╡ 54c02380-42a4-11eb-0240-7b2d895cb337
begin
	optimal_solution,populations, best_fitness_tracker = ArtificialBeeColonization(D, bounds_lower, bounds_upper, S, T, limit, f_optimize)
	optimal_solution 
end

# ╔═╡ 9bb28f50-4374-11eb-2b10-e5effcbc8438
md" Below a **contour plot** and **surface plot** of the test function can be seen. Move the slider to see how the location of bees changes over time during the optimization procedure. "

# ╔═╡ b81d7f30-42a5-11eb-27ce-f1cc849ffdc5
@bind step Slider(1:T; show_value=true)

# ╔═╡ 9e2b4e60-42ee-11eb-0d7f-c1faa8426796
begin
		x = []; y = []; z = []
		for bee in populations[step]
			append!(x,bee[1]); append!(y, bee[2]); append!(z, 0)
		end
	 
	
		if functie == "sphere"
			x2=range(bounds_lower[1],bounds_upper[1], step=1)
			y2=range(bounds_lower[2],bounds_upper[2], step=1)
			f(x2,y2) = (x2^2+y2^2)
		end
	
		if functie == "ackley"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.75)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.75)
		    d = 2
			c=2*3.14
			a=20
			b=0.2
		    f(x2,y2) = -a * exp(-b*sqrt((x2^2+y2^2)/d))-exp((cos(c*x2)+cos(c*y2))/d) + a + exp(1)  
		
		end
		
		if functie == "rosenbrock"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			a=1
			b=5
		    f(x2,y2) = (a-x2)^2 + b*(y2-x2^2)^2
		end	
	
		if functie == "branin"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			a=1 
			b=5.1/(4pi^2)
			c=5/pi
			r=6
			s=10
			t=1/8pi
		    f(x2,y2) = a * (y2 - b * x2^2 + c * x2 - r)^2 + s * (1 - t) * cos(x2) + s
		end	
	
		if functie == "rastrigine"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			A=10
			d=2
		    f(x2,y2) = d*A + x2^2-A*cos(2pi*x2) + y2^2-A*cos(2pi*y2)
		end	
end

# ╔═╡ 581a22f0-42af-11eb-1d59-df5f1efa5732
begin

	plot(x2,y2,f,st=:contour,
		label="Objective function",
		xlims=(bounds_lower[1],bounds_upper[1]),
		ylims=(bounds_lower[2],bounds_upper[2]),
		legend=:outerbottom) 
	
	scatter!(x, y,  
		xlabel="x1", 
		ylabel="x2",
		zlabel="x3",
		title="Evolution of populations over time",
		titlefont = font(15),
		c="blue", 
		markershape=  :circle,
		label="Position of bees after iteration "*string(step),
		legend = :outerbottom)
end

# ╔═╡ 71321ef0-42eb-11eb-0635-b1ce95226c75
begin
	if functie == sphere
		zlims=(-2,10000)
	end
	if functie == ackley
		zlims=(-50,100)
	end
	
	plot(x2,y2,f,st=:surface,
		label="Objective function",
		# camera=(-30,30),
		xlims=(bounds_lower[1],bounds_upper[1]),
		ylims=(bounds_lower[2],bounds_upper[2]),
		zlims=zlims,
		legend=:outerbottom) #,c=my_cg) #,camera=(-30,30))
	
	scatter!(x, y, z, 
		xlabel="x1", 
		ylabel="x2",
		# title="Evolution of populations over time",
		# titlefont = font(15),
		c="blue", 
		markershape=  :circle,
		label="Position of bees after iteration "*string(step),
		legend = :outerbottom)
end

# ╔═╡ 65bf09be-4377-11eb-2415-3b8be310a065
md" With the chosen parameters, the **Sphere, Ackley** and **Rastrigine** function have a minimizer at (0,0). 

The **Rosenbrock** function has a minimum value of zero at (0,0) and the **Branin** function has 3 global minima: (-pi, 12.275), (pi, 2.275) and (9.425, 2.475).  " 

# ╔═╡ 4219c780-4381-11eb-2289-316eb02b282f
md" 


#### Evolution of fitness during optimization


Below, for each iteration the **fitness** value for the best food source so far at that iteration is plotted."

# ╔═╡ 076d2e10-4381-11eb-3e12-6f9d9abe7f9a
plot(best_fitness_tracker,label="Fitness",	xlabel="iteration", 
		ylabel="fitness", title="Evolution of fitness", legend=:outerbottom)

# ╔═╡ 0c78a8b0-4379-11eb-20dc-3dd46dc183d3
md" #### References


"

# ╔═╡ Cell order:
# ╟─eee523f0-436e-11eb-2e92-d59ed5c533e6
# ╟─3c1c9be0-4373-11eb-1b1e-3d3f2e6afb19
# ╟─7a2fdff0-4373-11eb-337a-8fb102ef7b78
# ╠═0ca837e0-42ef-11eb-17fa-9335cb9a3997
# ╟─99ef02ce-4373-11eb-3592-ef0287dca72c
# ╟─70832f00-42a3-11eb-047e-a38754853775
# ╟─74b19670-42a3-11eb-2ffb-253407cbad76
# ╟─7f387140-42a3-11eb-1b22-8f9ca4f6bacd
# ╟─85259fae-42a3-11eb-0431-67e3278dbfb0
# ╟─8e011470-42a3-11eb-0443-a70ffec0d6f3
# ╟─9b02b33e-42a3-11eb-16b2-4fc4e0e2ba50
# ╟─9ca62a10-42a3-11eb-1650-6544fb0ebd31
# ╟─a8d02d90-42a3-11eb-36d5-d319a05d9347
# ╟─b023f0e0-42a3-11eb-18f9-c1b132fb5276
# ╟─f14360b0-42e9-11eb-1f4c-35d1a9eb188e
# ╠═a9462a5e-4373-11eb-3b48-39a2596229a9
# ╟─27f302ee-42ea-11eb-2d9e-49dffc0d983d
# ╠═3235a8d2-42ea-11eb-1fe1-6d91eca83dad
# ╟─085c34e0-4374-11eb-1ba7-7fb1af1d38a4
# ╠═0388b3ce-4374-11eb-03f4-9b4c74bd5ff0
# ╟─350644d0-4375-11eb-2b68-8fb8f4bd7c2a
# ╟─c7c64720-437f-11eb-15a2-477ab2fe0792
# ╟─caa5b6d0-4373-11eb-0cdd-1961e6698727
# ╠═f347e610-42a3-11eb-2116-ef50f1246cf3
# ╠═54c02380-42a4-11eb-0240-7b2d895cb337
# ╟─9bb28f50-4374-11eb-2b10-e5effcbc8438
# ╟─b81d7f30-42a5-11eb-27ce-f1cc849ffdc5
# ╟─9e2b4e60-42ee-11eb-0d7f-c1faa8426796
# ╟─581a22f0-42af-11eb-1d59-df5f1efa5732
# ╠═71321ef0-42eb-11eb-0635-b1ce95226c75
# ╟─65bf09be-4377-11eb-2415-3b8be310a065
# ╟─4219c780-4381-11eb-2289-316eb02b282f
# ╠═076d2e10-4381-11eb-3e12-6f9d9abe7f9a
# ╠═0c78a8b0-4379-11eb-20dc-3dd46dc183d3
