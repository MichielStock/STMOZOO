### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c80a0f15-2c37-4c40-a543-2e6c3fead1be
using Images, StatsBase, Plots, PlutoUI, Distributions, Random

# ╔═╡ 171fee18-20f6-11eb-37e5-2d04caea8c35
md"""
# Genetic Algorithms

*By Jordi Verbruggen & Jietse Verweirder*

## Introduction

**Genetic algorithms (GAs)** are described as optimization algorithms that make use of concepts originating from biological evolution, such as natural selection and survival of the fittest. 
By introducing these concepts into the algorithm, a population will evolve to an optimal solution. 
**The population** is a representation of possible solutions, called chromosomes, to the problem in question. Each chromosome in their turn is comprised of genes, which are the actual number values of the solution. The algorithm will then apply evolutionary operators, such as **mutation**, **recombination** and **selection**, over several generations, to converge the population to the best possible solution. 
**A fitness function** is used to determine which solution is the most optimal in the population, determining the objective function quality of the solution. Every generation, better solutions are created until **the termination criteria** are met or until a certain amount of generations has been run. The GA is terminated and the optimal solution should have been found. Although not guaranteed, most solutions will be of sufficient high quality. 

A schematic overview of all the steps in the process is portrayed below.
"""

# ╔═╡ 98b278e9-5cc9-4e36-9d1a-75eb9f4158de
md"""

![](https://github.com/JietseV/GeneticAlgorithms.jl/blob/master/notebook/Figs/GA_Overview.png?raw=true)
"""

# ╔═╡ d89c31c5-f2b3-4b52-8e47-580c62979687
md"""
During this presentation we will introduce the general concepts of GAs. We will build up a GA by introducing all its different aspects. Along the way, the option will be given to experiment with the different parameters and evaluate their effect on the algorithm. As a running example, to explain the concept we will make use of **Himmelblau's function** where we will try to find one of its four minima. The function is written as follows:

```math 
\begin{equation}
	f(x,y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2
\end{equation}
```
A visualization of the function is given. *(Use the sliders to move the plot around.)*
"""

# ╔═╡ ba845736-b141-484a-9b10-fc73ecf31db3
md"""
Angle 1:
$(@bind ca1 Slider(0:90,default=50,show_value=true))

Angle 2:
$(@bind ca2 Slider(1:90,default=75,show_value=true))
"""

# ╔═╡ cccaf5fb-3c95-4ea9-b699-0cee2f12542e
md"""

The function takes x and y coordinates that have real number values. Therefore the representation of the individuals will be a tuple of the x and y coordinates. In principle all techniques that are discussed here, are applicable to any function represented by chromosomes with real numbers. Bit string representations are also often used in GAs, and most, but not all, of what is discussed further can be applied to that, which is important to keep in mind. To illustrate the implementation with bitstrings, figures of this process have been added.

In a last part of the notebook functionality has been added where custom objectives can be found via a genetic algorithm. Here you can write your function and set up some parameters to find the the extremeties of the objective. **Important to mention here: the functions have to be 2D or 3D.**
"""

# ╔═╡ 8212a676-3167-438a-944d-5eeae72d54d8
md"""
## Initial population

The first step in creating a genetic algorithm is defining the **initial population.** Each individual in the population contains a set of variables, descibed as genes. These genes as a whole form a chromosome, which can be seen as a possible solution. In most of the cases simple binary values are used to represent the genes. An example is portrayed below.

"""

# ╔═╡ 9365760a-10e5-48a4-ae77-b3f1a686f8e3
md"""

![](https://github.com/JietseV/GeneticAlgorithms.jl/blob/master/notebook/Figs/Init_Pop.png?raw=true)
"""

# ╔═╡ a8cd1caa-feb2-442f-ba8f-27619bfbff84
md"""

A few things have to be taken into account when designing the initial population:

- **The population size:** A smaller population has a higher change for a premature convergence, while a large population requires more computing time.
	
- **The diversity:** A low diverstity will also result in a premature convergence.


Overall, there are two primary methods to initialize a population in a GA: 
	
- **Random Initialization:** Populate the initial population with completely random  solutions.

- **Heuristic initialization:** Populate the initial population using a known heuristic for the problem. The population exists of solutions that are already guided a few steps closer to the exact solution of the problem.

*The code to initialize goes as follows:*
"""

# ╔═╡ eba0c158-54d3-4f56-8b1a-5d3ddba001db
"""
	random_init_pop(ps, gs, i_x, i_y)

Inputs:

	- ps: Population Size: The desired size of the population
	- gs: Genome Size: The desired size of the genome. Options: 1 or 2 (integers)
	- i_x: Interval to define the range of the generated float numbers on the x-axis
	- i_y: Interval to define the range of the generated float numbers on the y-axis

Output:

	- pop: A random initial population
"""
function random_init_pop(ps, gs, i_x, i_y)

	if gs == 2
		pop = [
			[rand(Uniform(i_x[1], i_x[2])),rand(Uniform(i_y[1],i_y[2]))] for _ in 1:ps
		]
	else
		pop = [[rand(Uniform(i_x[1], i_x[2]))] for _ in 1:ps]
	end
	
	return pop
	
end;

# ╔═╡ 41dd8e8d-0f4c-407e-90c5-6f450fe318fe
population = random_init_pop(100, 2, [-4,4], [-4,4])

# ╔═╡ 37b9fce9-e99c-424f-a614-8169b7edf0d6
md"""
## Fitness

As we want to improve our population over time, it is of absolute importance to select  individuals that have a high **fitness level**. To determine the fitness level of an individual, we have to implement a **fitness function**. This function takes a candidate solution to the problem as input and produces a numeric value as output indicating how “fit” or how good the solution is. 

Due to the fact that the fitness value has to be calculated after each generation, the fitness function should not only correlate closely with the designer's goal, but it also should be computationally efficient. If the fitness function becomes the bottleneck of the algorithm, then the overall efficiency of the genetic algorithm will be greatly reduced.

**The fitness function used as example here is based on Himmelblau's optimization function:**
			
$$f(x, y) = (x^2 + y − 11)^2 + (x + y^2 − 7)^2$$

The x- and y-values are the first
and second gene in the chromosome of the individual, respectively. 

As we want to calculate the minima of the Himmelblau function, we take the negative of the function as its fitness value.

"""

# ╔═╡ f4969be8-815e-43bc-adaf-a6e1eeec1226
"""
	fitness(p, ff, extremeties)
	
Inputs:
	
	- p: The population you are working with
	- ff: The fitness function
	- extremeties: Indicate if you want to calculate the minima of maxima of the 
				   function. Options: "minima" or "maxima"

Output: 

	- pf: A calculated fitness score for each individual in 
						  the population based on the fitness function
	

"""
function fitness(p, ff, extremeties)
	@assert(extremeties == "minima" || extremeties == "maxima", "extremeties has to be one of the following values: 'minima' or 'maxima' (without quotation marks)")

	d = length(p[1])
	@assert(d == 1 || d == 2, "function has to be 2d or 3d")
	
	if d == 2
		if extremeties == "minima"
			pf = [[[ind[1], ind[2]], -ff(ind[1], ind[2])] for ind in p]
		else
			pf = [[[ind[1], ind[2]], ff(ind[1],ind[2])] for ind in p]
		end
	else
		if extremeties == "minima"
			pf = [[[ind[1]], -ff(ind[1])] for ind in p]
		else
			pf = [[[ind[1]], ff(ind[1])] for ind in p]
		end
	end

	return pf
end;

# ╔═╡ ccb197ff-f322-4f14-acb5-ba64a343d234
md"""
## Termination criteria

The run of the algorithm comes to an end when certain termination critera are met, and these termination conditions must be pre-determined. It has been observed that initially, the GA progresses very fast with better solutions coming in every few iterations, but this tends to saturate in the later stages, where the improvements are very small. We usually want a termination condition such that our solution is close to the optimal at the end of the run.

**Usually, we keep one of the following termination conditions:**

- *No improvement in the population for X iterations.*

- *An absolute number of generations is reached.*

- *The objective function value has reached a certain pre-defined value.*

The code goes as follows:
"""

# ╔═╡ 2bcdbbf0-2473-40d9-8c85-cec3b6ca4b31
"""
	check_term(pf, σ, nmax)

Inputs:

	- pf: Population_fitness: The fitness scores per individual determinded by 
						  	  the fitness function
	- σ: Threshold for the standard deviation
	- nmax: The number of generations the maximal fitness has not changed

Output: 

	- bool: Depending on the fact that the criteria were met or not

"""
function check_term(pf, σ, nmax) 
	
	return std([x[2] for x in pf]) < σ && nmax >= 5

end;

# ╔═╡ c6155621-9a86-4747-b0ec-65e779670b57
md"""
## Selection

During selection, the parent chromosomes are chosen for later "breeding purposes", this is implemented by **the crossover operator.** Different methods of selection are available and some are discussed below. Note that an individual can be selected more than one time, otherwise the population would not change.
"""

# ╔═╡ 953edf56-a957-4c61-8a89-9709dc6dfd65
md"""

### Roulette Wheel Selection

As the name suggests, this way of selecting parents is based on turning a roulette wheel. The chance of selecting an individual is proportional to its fitness. The higher its fitness, the bigger its pocket will be on the roulette wheel, thus resulting in a higher chance of being selected.

**The chance for an individual to be selected can be mathematically written as:**

```math 
\begin{equation}
	p_i = \frac{f_i}{\sum_{j=1}^{N} f_j}
\end{equation}
```

Where:
- *pᵢ is the probability for choosing individual i*
- *fᵢ is the fitness of individual i*
- *N is the size of the population*

We implement this in code:
"""

# ╔═╡ 79eb48df-26de-4965-b078-9bb20313247a
"""

	roulette_wheel_selection(population_fitness)

Input:

	- population_fitness: A list where each element consists of the individual 
						  and its corresponding fitness

Output:

	- pool: A list with the selected individuals for the mating pool

"""
function roulette_wheel_selection(population_fitness)

	# extract the individuals from the list
	p = [pf[1] for pf in population_fitness]

	# extract the weights from the list, which are its fitness proportions
	fitness = [pf[2] for pf in population_fitness]
	w = [fᵢ / sum(fitness) for fᵢ in fitness]

	# randomly choose the same number of individuals but with its chance of being
	# choosen proportional to its fitness
	pool = sample(p, Weights(w), length(population_fitness))

	return pool
	
end;

# ╔═╡ 8623b228-c627-4f81-8f6f-6de074b8ec20
md"""
### Rank Selection

In **rank selection**, individuals are ranked based on their fitness. The individual with the worst fitness is given rank one, the individual with the best fitness is given rank N. In rank selection, the fitness values can even be negative, as it is their rank that counts and not their actual value. 

**The probability with which an individual can be selected can then be given by:**

```math 
\begin{equation}
	p_i = \frac{r_i}{n(n-1)}
\end{equation}
```

Where:
- *pᵢ is the probability for choosing individual i*
- *rᵢ is the rank of individual i*
- *n the total number of ranks, which is equal to the number of individuals in the population*

We implement this in code:
"""

# ╔═╡ 84d49f43-8ac3-4e73-991c-a54bb9fe9b5f
md"""
### Steady State Selection

During **steady state selection** a proportion of individuals with the highest fitness is choosen as a mating pool. An equal proportion of individual with the lowest fitness values is removed from the population and replaced by the offspring of the mating pool.

We can write the code as follows:

"""

# ╔═╡ 07e1c8b6-c3fd-4f5f-bbb0-fe6595813d55
"""
	steady_state_selection(pf, Δ)

Input:

	- pf: Population Fitness: A list where each element consists of the individual 
						  	  and its corresponding fitness
	- Δ: The proportion of fittest individuals that need to be selected

Output:

	- pool: A list with the selected individuals for the mating pool
"""
function steady_state_selection(pf, Δ)
	@assert(Δ <= 0.5, "Proportion of selected individuals has to be smaller than 0.5")
	
	# sort the population based on fitness in descending order
	sorted_population_fitness = sort(pf, by=pf->pf[2], rev=true)

	# calculate the number of individuals that need to be selected
	n_ind = trunc(Int, Δ * length(pf))

	# return the mating pool
	pool = [spf[1] for spf in sorted_population_fitness[1:n_ind]]
	
	return pool
end;

# ╔═╡ 307af9a7-6b0c-44ad-a5b0-d9b0c18b5db4
md"""
### Tournament Selection

Here selection happens by means of **tournaments between randomly choosen individuals** from the population. In the tournament, the individual with the biggest fitness is chosen with the biggest probability, the individual with the second highest probability has the second best probability to be chosen, and so on. 

**The probability with which the individual with the highest fitness is chosen, is a given value and can be written as:**

```math 
\begin{equation}
	p_i = P * (1-P)^{i-1}
\end{equation}
```

Where:
- *pᵢ is the selection probability for the i-th fittest individual in the tournament*
- *P is the selection probability for the best individual in the tournament with 0 < P ≤ 1*

Each individual has the same chance to be chosen for a tournament. Selection continues until a mating pool with the same size as the population has been formed.

We write the code as follows:
"""

# ╔═╡ 6cf8534b-2fa1-4762-9526-bd3c2da99843
"""
	tournament_selection(population_fitness, k, prob)

Input:

	- population_fitness: A list where each element consists of the individual and 
						  its corresponding fitness
	- k: The tournament size. The number of individuals selected for the 
	     tournament
	- prob: The probability with which the fittest individual in the tournament is
		    selected

Output:

	- pool: A list with the selected individuals for the mating pool
"""
function tournament_selection(population_fitness, k, prob)
	@assert(0 < prob <= 1, "prob has to be between 0 and 1 (1 included)")
	
	@assert(k <= length(population_fitness), "the tournament has to be smaller then the population size!")
	
	pool = Array{Float64}[]
	while length(pool) < length(population_fitness)

		# build the tournament by randomly selecting k individuals from the population
		# each individual can only be selected once for a tournament
		t = sample(population_fitness, k, replace=true)

		# sort the tournament based on the fitness values
		sorted_t = sort(t, by=t->t[2], rev=true)

		# get all individuals
		p = [pf[1] for pf in population_fitness]

		# get their weights (selection probabilities)
		w = [prob * (1-prob)^i for i in 0:k-1]

		# add the choosen individual to the mating pool
		push!(pool, sample(p, Weights(w)))
	end

	return pool
	
end;

# ╔═╡ 5096d7c0-0189-4c89-9ec0-13e7aac9aa8a
md"""
## Crossover

The most significant way to stochastically generate new solutions from an existing population is by **recombination (crossover)** of parental chromosomes. 

There exist a few different types of crossover:

- **Single Point Crossover:** A crossover point on the parent organism string is selected. All data beyond that point in the organism string is swapped between the two parent organisms. Strings are characterized by Positional Bias.

- **Two-Point Crossover:** This is a specific case of a N-point Crossover technique. Two random points are chosen on the individual chromosomes (strings) and the genetic material is exchanged at these points.

- **Uniform Crossover:** Each gene (bit) is selected randomly from one of the corresponding genes of the parent chromosomes. Tossing of a coin can be seen as an example technique.

For this example we introduce the "Single Point Crossover" 
"""

# ╔═╡ 0be0a442-8c9f-4035-b926-998f0c63ade7
md"""

![](https://github.com/JietseV/GeneticAlgorithms.jl/blob/master/notebook/Figs/Crossover.png?raw=true)
"""

# ╔═╡ 9c2f897a-663e-4408-8364-1582ef6cba9c
md"""
This method of recombination is implemented by introducing two equatations:

$$C_1 = \alpha P_1 + (1 − \alpha)P_2$$

$$C_2 = (1 − \alpha)P_1 + \alpha P_2$$

Where:
- *P1 is the gene of parent one*
- *P2 is the gene of parent two*
- *C1 is the gene of child/offspring one*
- *C2 is the gene of child/offspring two*
- *α is a factor by wich the parental genes are divided*

This technique is also called **whole arithmetic crossover** and goes as follows:

First, the mating pool is shuffled to make random parings of parents. Two parents are selected that are adjacent in the mating pool list. Then the genome of the parents is divided over the offspring with a factor α, resulting in two children. Eventually the whole population is replaced by offspring.

The code goes as follows:
"""

# ╔═╡ 1e7552ac-9c46-479d-b26e-5d776e3cc5af
"""
	crossover(pool, α)

Inputs:

	- pool: The mating pool that is selected for further breeding
	- α: the crossover rate: A float between 0 and 1 to determine the part of 
		 					 the genome that is going to be crossed

Output: 

	- offspring: Next generation of individuals (population) that replaces 
				 the previous population
"""
function crossover(pool, α)
	@assert(0<α<1, "crossover rate has to be between 0 and 1")
	
	# shuffle the mating pool 
	shuffle(pool)
	
	# create offspring
	offspring = Array{Float64}[] 	

	# go over the mating pool
	for i in 1:2:length(pool)
		child1 = []
		child2 = []
		for (j, gene) in enumerate(pool[i])
			# divide the genome of the parents over the children with a factor α
			push!(child1, (α * gene + (1-α) * pool[i + 1][j]))
			push!(child2, (α * pool[i + 1][j] + (1 - α) * gene))
		end
		push!(offspring, child1)
		push!(offspring, child2)
	end

	return offspring
	
end;

# ╔═╡ 3347f3d5-dd43-40ff-bbed-f8f06532be47
md"""
## Mutation

During **mutation**, small changes are introduced to the genes of the chromosomes. By doing this, genetic diversity is maintained within the population. If mutation wasn't applied, genetic diversity would go down with each generation of the algorithm. The applied changes can not be to large, otherwise a perfectly good solution would be changed completely, destroying the work that already had been put into it. 

To ensure the changes are not too big, a **creep mutational operator** can be used. Hereby only a small amount is added or substracted from the gene value, often a Gaussian deviate. Also important is that after many generations, the change is getting smaller so that the solution can be fine-tuned. **The mutation rate gives the proportion of genes that need to be mutated.** When applying mutation to a bitstring, a flip of one bit can be applied to introduce the change. 
"""

# ╔═╡ 82b5a573-6013-408f-99c9-f105708f948e
md"""

![](https://github.com/JietseV/GeneticAlgorithms.jl/blob/master/notebook/Figs/Mutation.png?raw=true)
"""

# ╔═╡ 0b598ee8-8671-4b99-87b8-1a65a2d63aa2
md"""

We code this as follows:
"""

# ╔═╡ 1b6763ba-ae24-4f63-b7e8-545364ddab89
"""
	mutation(offspring, pm, generation)

Input

	- offspring: List of individuals after crossover
	- pm: Mutation rate, the proportion of genes that need to be mutated
	- generation: The generation the algorithm is currently in

Output

	- offspring: List of individuals with mutated genes
"""
function mutation(offspring, pm, generation)

	# initiate a Gaussian distribution
	gd = truncated(Normal(0.0, 1/(generation + 1)), 0.0, Inf)

	# the number of chromosomes in the population
	n_ind = length(offspring)

	# the number of genes in each chromosome
	n_genes = length(offspring[1])

	# based on the mutation rate, calculate exact number of genes that should mutate
	nmut = trunc(Int, n_ind * n_genes * pm)

	# keep track of what genes are already mutated and of the number of mutated genes
	used, mutated = Tuple{Int, Int}[], 0

	# go on as long as there are still genes that need to be mutated
	while mutated < nmut
		ind = rand(1:n_ind)				# choose a random individual (index)
		g = rand(1:n_genes)				# choose a random gene (index)
		if !((ind,g) in used)			# when not mutated yet, mutate the gene
			gene = offspring[ind][g] 	# select the gene (value)
			gene += rand(gd)			# add random Gaussian deviate to the gene
			offspring[ind][g] = gene 	# change the gene
			push!(used, (ind,g))		# keep track of mutated genes
			mutated += 1 				# keep track of number of mutated genes
		end
	end

	return offspring
	
end;

# ╔═╡ 6a60527b-0f46-4bf0-bd6f-91e509737a32
md"""
## The complete algorithm

Now that we have been introduced to the different aspects of a genetic algorithm, it  it time to put it all together and start seeking the minima of our Himmelblau's function:

"""

# ╔═╡ 97af696e-d076-40b3-a5d5-ec363350d7b7
md"""

To better understand the influences of the different parameters, you can change them below. Alter the parameters and look in which way they change the efficiency of the algorithm. What is the effect of the population size or mutation rate, for example?

"""

# ╔═╡ 6ba87a23-5114-4126-b6a2-0981992d8a46
md"""
Population size:
$(@bind pop_size_h Slider(0:250,default=100,show_value=true))

Standard deviation σ for the termination criteria:
$(@bind σₕ NumberField(0:0.00000001:1,default=0.001))

The crossover rate α determines the proportion of dividing the parent genes during crossover:
$(@bind αₕ Slider(0:0.01:1,default=0.5,show_value=true))

The mutation rate: proportion of the genes that need to undergo mutation each generation:
$(@bind pmₕ Slider(0:0.01:1,default=0.10,show_value=true))
"""

# ╔═╡ 48a851ce-fd14-4516-a172-c720f24bf153
md"""
We will visualize the different generations in order to get a better understanding of the inner workings of the algorithm.
The visualization of the different steps of the solution can be seen here. You might need to fiddle with the angles again to get a good viewing point. 
We recommend looking at where your solution is converging and using the first plot to set the values for both angles (they are the same angles in both plots). 
Moreover, to control the speed of the animation, you can alter the frames per second and the number of generations shown. Together these two will also decide how long it will run.
"""

# ╔═╡ 34360486-0f98-46bf-bdb6-550164e3b051
md"""

On the animation, we clearly see how the algorithm works. The initial population is drawn to one of the minima while also exploring other directions. In the beginning all points are randomly distributed, which is normal behaviour. After some generations, the points begin to huddle together forming a more uniform front. Then they start to migrate towards one of the minima in the plot. The later generations are finetuning of the solutions and making all solutions in the population as identical as possible (depending on the σ value given to the algorithm). 

"""

# ╔═╡ 22c1df68-673f-4791-a705-0b45a42da211
md"""
## Custom functions

To enable people to enter their own functions, we rewrite the algorithm more generally. Here you can again play with the different parameters but also enter your custom function. The functions can be 2D or 3D, which needs to be indicated by the genome size. A genome size of 1 denotes a 2D function (one variable) and a genome size of 2 denotes a 3D function (two variables).

"""

# ╔═╡ 5af46f82-c323-4472-aa68-76d253eb35b9
md"""
Population size:
$(@bind pop_size_c Slider(0:250,default=100,show_value=true))

Genome size:
$(@bind gs Select([1, 2]))

Interval to search in:

X-axis:
From
$(@bind i_lower_x NumberField(-1000000:1000000, default=-1))
To
$(@bind i_upper_x NumberField(-1000000:1000000, default=1))

Y-axis (for functions in 3D):
From
$(@bind i_lower_y NumberField(-1000000:1000000, default=-1))
To
$(@bind i_upper_y NumberField(-1000000:1000000, default=1))

Which extremeties are you looking for:
$(@bind extr Select(["minima", "maxima"]))

Standard deviation σ for the termination criteria:
$(@bind σ_custom NumberField(0:0.00000001:1,default=0.001))

The crossover rate α determines the proportion of dividing the parent genes during crossover:
$(@bind α_custom Slider(0:0.01:1,default=0.5,show_value=true))

The mutation rate: proportion of the genes that need to undergo mutation each generation:
$(@bind pm_custom Slider(0:0.01:1,default=0.10,show_value=true))
"""

# ╔═╡ cc6edd6d-0328-4692-834d-aa5258076d21
# write your function here: f(x) = ... if genome size = 1 or f(x,y) = ... if genome size = 2 then save to execute the algorithm
f(x) = x^2

# ╔═╡ 3ff092e2-7af2-4b4b-bd29-2b0310cae48f
md"""
## Appendices
"""

# ╔═╡ b4a64a85-640d-4386-b7ad-87d87671aac9
function plot_himmelblau(ca1, ca2, points=Array{Float64}[]) 
	f(x,y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2
	x=range(-4.6,stop=4.6,length=100)
	y=range(-4.6,stop=4.6,length=100)
	cg = cgrad([
		:black,
		:lightblue, 
		:blue, 
		:darkblue, 
		:lightgreen,
		:green,
		:darkgreen,
		:yellow, 
		:orange, 
		:red, 
		:brown
	])
	q = plot(
		x,y,f,
		st=:surface, 
		c = cg, 
		camera = (ca1,ca2), 
		zlim = (0,200),
		xlab = "x",
		ylab = "y",
	)
	if length(points) != 0
		x = [p[1] for p in points]
		y = [p[2] for p in points]
		z = [f(p[1], p[2]) for p in points]
		plot!(q,x,y,z,seriestype=:scatter, legend=false, zlim = (0,200), c=:white)
	end
	return q
end

# ╔═╡ d73ee58d-536b-4d19-bb3a-cae8c3bcc4c8
plot_himmelblau(ca1, ca2)

# ╔═╡ 1cef7433-e0a8-4ec7-a7a7-e7bd24efa20f
function plot_3d(ca1, ca2, f, i_lower_x, i_upper_x, i_lower_y, i_upper_y, points=Array{Float64}[])
	x=range(i_lower_x,stop=i_upper_x,length=100)
	y=range(i_lower_y,stop=i_upper_y,length=100)
	cg = cgrad([
		:black,
		:lightblue, 
		:blue, 
		:darkblue, 
		:lightgreen,
		:green,
		:darkgreen,
		:yellow, 
		:orange, 
		:red, 
		:brown
	])
	q = plot(
		x,y,f,
		st=:surface, 
		c = cg, 
		camera = (ca1,ca2), 
		zlim = (f(i_lower_x,i_lower_y), f(i_upper_x, i_upper_y)),
		xlab = "x",
		ylab = "y",
	)
	if length(points) != 0
		x = [p[1] for p in points]
		y = [p[2] for p in points]
		z = [f(p[1], p[2]) for p in points]
		plot!(q,x,y,z,seriestype=:scatter, legend=false, zlim=(f(i_lower_x,i_lower_y), f(i_upper_x, i_upper_y)), c=:white)
	end
	return q
end

# ╔═╡ c4838943-8a9d-46f9-88d5-6df92b66c8d4
function plot_2d(i_lower_x, i_upper_x, f, points=Array{Float64}[])
	x = range(i_lower_x, i_upper_x, length=100)
	r = plot(
		x,f,
		c = :black,
		xlab = "x",
		ylab = "y",
	)
	if length(points) != 0
		x = [p[1] for p in points]
		y = [f(p[1]) for p in points]
		plot!(r,x,y,seriestype=:scatter, legend=false, c=:white)
	end
	return r
end

# ╔═╡ 46862350-c094-4489-83a2-ea4b670a16c0
f_himmelblau(x,y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2

# ╔═╡ 2daddc2a-bc0e-4e8e-adde-f99660c9ac10
population_fitness = fitness(population, f_himmelblau, "minima")

# ╔═╡ 3bc3a212-fe9f-4416-9b95-9d061d50a08d
pool_roulette = roulette_wheel_selection(population_fitness)

# ╔═╡ a6da65cb-817d-4637-b7a7-0830488696e0
"""
	rank_selection(pf)

Input:

	- pf: Population Fitness: A list where each element consists of the individual 
						  	  and its corresponding fitness

Output:

	- pool: A list with the selected individuals for the mating pool
"""
function rank_selection(pf)

	# the number of ranks
	n = length(population_fitness)

	# initiate the lists containing the individuals 
	# and their weights (selection probability)
	p, w = Array{Float64}[], Float64[]
	for (rank, ind) in enumerate(sort(pf, by=pf->pf[2]))
		push!(p, ind[1])
		push!(w, (rank / (n * (n - 1))))
	end

	# select the mating pool based on their selection probabilities
	pool = sample(p, Weights(w), n)

	return pool
end;

# ╔═╡ fc0a7329-5d93-4519-ace0-626aa376fc1b
"""
	minima_himmelblau(pop_size, σ, α, pm, ff)

Input:

	- pop_size: The population size
	- σ: The standarddeviation used to determine the termination criteria
	- α: The crossover rate
	- pm: The mutation rate
	- ff: Fitness Function

Output:

	- generations: A list with the population in every generation
"""
function minima_himmelblau(pop_size, σ, α, pm, ff)

	# counters
	generation, generation_max = 0, 0

	# the initial population
	population = random_init_pop(pop_size, 2, [-4,4], [-4,4])

	# population with its fitness values
	f_pop = fitness(population, ff, "minima")

	# the maximal fitness value
	max_fitness = maximum([x[2] for x in f_pop])

	# keep track of each population in each generation
	generations = Array{Array{Float64}}[]
	push!(generations, population)

	# keep going untill termination criteria are true or
	# until 1 milion generations
	while !check_term(f_pop, σ, generation_max) && generation < 1000000

		# keep track of the number of generations the maximal fitness does not change
		if maximum([x[2] for x in f_pop]) > max_fitness
			max_fitness = maximum([x[2] for x in f_pop])
			generation_max = 0
		else
			generation_max += 1
		end

		# selection
		mate_pool = rank_selection(f_pop)

		# crossover
		offspring = crossover(mate_pool, α)

		# mutation
		population = mutation(offspring, pm, generation)

		# track each population in each generation
		push!(generations, population)

		# fitness of new population
		f_pop = fitness(population, ff, "minima")

		# track the number of generations
		generation += 1
		
	end
	
	return generations
end;

# ╔═╡ c75e7eb2-ea7c-4448-ad5b-54955ee5cd8c
"""
	genetic_algorithm(pop_size, gs, i_x, i_y, extremeties, σ, α, pm, ff)

Input:

	- pop_size: The population size
	- gs: Genome Size: Indicates wheter the function is 2d or 3d
	- i_x: Interval: Interval in which the extrema need to be searched on the x-axis
	- i_y: Interval: Interval in which the extrema need to be searched on the y-axis
	- extremeties: Wheter the minima or maxima need to be searched: Options: "minima" 
				   or "maxima"
	- σ: The standarddeviation used to determine the termination criteria
	- α: The crossover rate
	- pm: The mutation rate
	- ff: Fitness Function

Output:

	- generations: A list with the population in every generation
"""
function genetic_algorithm(pop_size, gs, i_x, i_y, extremeties, σ, α, pm, ff)

	# counters
	generation, generation_max = 0, 0

	# the initial population
	population = random_init_pop(pop_size, gs, i_x, i_y)

	# population with its fitness values
	f_pop = fitness(population, ff, extremeties)

	# the maximal fitness value
	max_fitness = maximum([x[2] for x in f_pop])

	# keep track of each population in each generation
	generations = Array{Array{Float64}}[]
	push!(generations, population)

	# keep going untill termination criteria are true or
	# until 1 milion generations
	while !check_term(f_pop, σ, generation_max) && generation < 1000000

		# keep track of the number of generations the maximal fitness does not change
		if maximum([x[2] for x in f_pop]) > max_fitness
			max_fitness = maximum([x[2] for x in f_pop])
			generation_max = 0
		else
			generation_max += 1
		end

		# selection
		mate_pool = rank_selection(f_pop)

		# crossover
		offspring = crossover(mate_pool, α)

		# mutation
		population = mutation(offspring, pm, generation)

		# track each population in each generation
		push!(generations, population)

		# fitness of new population
		f_pop = fitness(population, ff, extremeties)

		# track the number of generations
		generation += 1
		
	end
	
	return generations
end;

# ╔═╡ 23000c68-7864-409f-b5fe-b43b9a2164c3
pool_rank = rank_selection(population_fitness)

# ╔═╡ fa31ea0c-b3dd-4145-bb35-3698308371a7
offspring = crossover(pool_rank, 0.5)

# ╔═╡ 93634846-dc90-4021-bf4c-de1b13f476cc
offspring_mutated = mutation(offspring, 0.9, 1)

# ╔═╡ ba2820c1-649f-4551-98d8-ce113e309b22
pool_steady_state = steady_state_selection(population_fitness, 0.4)

# ╔═╡ 4408b037-e336-4382-8468-28d1746c23d3
pool_tournament = tournament_selection(population_fitness,50,0.9)

# ╔═╡ 5aed7665-1131-4715-90ca-dca12c038a68
generations_himmelblau = minima_himmelblau(pop_size_h, σₕ, αₕ, pmₕ, f_himmelblau)

# ╔═╡ 7dbb864c-b3d9-4cd1-8c48-9a61be67334f
md"""

Number of generations to show:
$(@bind g NumberField(1:length(generations_himmelblau),default=50))

Frames per second:
$(@bind fps NumberField(1:50, default=5))

Angle 1:
$(@bind ca3 NumberField(1:90,default=50))

Angle 2:
$(@bind ca4 NumberField(1:90,default=75))
"""

# ╔═╡ 453b235b-bd4f-446f-b767-b71a197cc66c
begin
	anim = @animate for (i,s) in enumerate(generations_himmelblau[1:g])
		plot_himmelblau(ca3, ca4, s)
		plot!(title="Generation: $i")
	end
	gif(anim, fps=fps)
end

# ╔═╡ 5f1b386d-daf0-46ca-a90a-89c954eb2d11
generations_custom = genetic_algorithm(pop_size_c, gs, [i_lower_x,i_upper_x], [i_lower_y,i_upper_y], extr, σ_custom, α_custom, pm_custom, f)

# ╔═╡ 26f2bdca-e7bc-4e80-86ca-d4dc29d71aa0
md"""

Number of generations to show:
$(@bind ge NumberField(1:length(generations_custom),default=1))

Frames per second:
$(@bind frps NumberField(1:50, default=5))

Only relevant for 3D functions:

Angle 1:
$(@bind ca5 NumberField(1:90,default=50))
Angle 2:
$(@bind ca6 NumberField(1:90,default=75))
"""

# ╔═╡ 19b91d8e-d03d-4b76-8358-5a4b1e90604d
begin
	anima = @animate for (i,s) in enumerate(generations_custom[1:ge])
		if gs == 2
			plot_3d(ca5,ca6,f,i_lower_x,i_upper_x,i_lower_y,i_upper_y,s)
		else
			plot_2d(i_lower_x,i_upper_x,f,s)
		end
		plot!(title="Generation: $i")
	end
	gif(anima, fps=frps)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Distributions = "~0.25.37"
Images = "~0.25.0"
Plots = "~1.25.4"
PlutoUI = "~0.7.27"
StatsBase = "~0.33.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9faf218ea18c51fcccaf956c8d39614c9d30fe8b"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "1ee88c4c76caa995a885dc2f22a5d548dfbbc0ba"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.2.2"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d711603452231bad418bd5e0c91f1abd650cba71"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.3"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "6a8dc9f82e5ce28279b6e3e2cea9421154f5bd0d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.37"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "84f04fe68a3176a583b864e492578b9466d87f1e"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "3fe985505b4b667e1ae303c9ca64d181f09d5c05"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.3"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "67551df041955cc6ee2ed098718c8fcd7fc7aebe"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.12.0"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b9a93bcdf34618031891ee56aad94cfff0843753"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "92243c07e786ea3458532e199eb3feee0e7e08eb"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.4.1"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[ImageContrastAdjustment]]
deps = ["ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "0d75cafa80cf22026cea21a8e6cf965295003edc"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.10"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "7a20463713d239a19cbad3f6991e404aca876bda"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.15"

[[ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "15bd05c1c0d5dbb32a9a3d7e0ad2d50dd6167189"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.1"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "a2951c93684551467265e0e32b577914f69532be"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.9"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "ca8d917903e7a1126b6583a097c5cb7a0bedeac1"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.2"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "5581e18a74a5838bd919294a7138c2663d065238"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.0"

[[ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1d2d73b14198d10f7f12bf7f8481fd4b3ff5cd61"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.0"

[[ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "36832067ea220818d105d718527d6ed02385bf22"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.7.0"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "d0ac64c9bee0aed6fdbb2bc0e5dfa9a3a78e3acc"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.3"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "b4b161abc8252d68b13c5cc4a5f2ba711b61fec5"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.3"

[[Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "35dc1cd115c57ad705c7db9f6ef5cc14412e8f00"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.0"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "00019244715621f473d399e4e1842e479a69a42e"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.2"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "09ef0c32a26f80b465d808a1ba1e85775a282c97"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.17"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "2af69ff3c024d13bde52b34a2a7d6887d4e7b438"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "6d105d40e30b635cfed9d52ec29cf456e27d38f8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.12"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "71d65e9242935132e71c4fbf084451579491166a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.4"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[Quaternions]]
deps = ["DualNumbers", "LinearAlgebra"]
git-tree-sha1 = "adf644ef95a5e26c8774890a509a55b7791a139f"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "dbf5f991130238f10abbf4f2d255fb2837943c43"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "7f5a513baec6f122401abfc8e9c074fdac54f6c1"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "de9e88179b584ba9cf3cc5edbb7a41f26ce42cda"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "bedb3e17cc1d94ce0e6e66d3afa47157978ba404"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "991d34bbff0d9125d93ba15887d6594e8e84b305"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.3"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╠═c80a0f15-2c37-4c40-a543-2e6c3fead1be
# ╟─171fee18-20f6-11eb-37e5-2d04caea8c35
# ╟─98b278e9-5cc9-4e36-9d1a-75eb9f4158de
# ╟─d89c31c5-f2b3-4b52-8e47-580c62979687
# ╟─d73ee58d-536b-4d19-bb3a-cae8c3bcc4c8
# ╟─ba845736-b141-484a-9b10-fc73ecf31db3
# ╟─cccaf5fb-3c95-4ea9-b699-0cee2f12542e
# ╟─8212a676-3167-438a-944d-5eeae72d54d8
# ╟─9365760a-10e5-48a4-ae77-b3f1a686f8e3
# ╟─a8cd1caa-feb2-442f-ba8f-27619bfbff84
# ╠═eba0c158-54d3-4f56-8b1a-5d3ddba001db
# ╠═41dd8e8d-0f4c-407e-90c5-6f450fe318fe
# ╟─37b9fce9-e99c-424f-a614-8169b7edf0d6
# ╠═f4969be8-815e-43bc-adaf-a6e1eeec1226
# ╠═2daddc2a-bc0e-4e8e-adde-f99660c9ac10
# ╟─ccb197ff-f322-4f14-acb5-ba64a343d234
# ╠═2bcdbbf0-2473-40d9-8c85-cec3b6ca4b31
# ╟─c6155621-9a86-4747-b0ec-65e779670b57
# ╟─953edf56-a957-4c61-8a89-9709dc6dfd65
# ╠═79eb48df-26de-4965-b078-9bb20313247a
# ╠═3bc3a212-fe9f-4416-9b95-9d061d50a08d
# ╟─8623b228-c627-4f81-8f6f-6de074b8ec20
# ╠═a6da65cb-817d-4637-b7a7-0830488696e0
# ╠═23000c68-7864-409f-b5fe-b43b9a2164c3
# ╟─84d49f43-8ac3-4e73-991c-a54bb9fe9b5f
# ╠═07e1c8b6-c3fd-4f5f-bbb0-fe6595813d55
# ╠═ba2820c1-649f-4551-98d8-ce113e309b22
# ╟─307af9a7-6b0c-44ad-a5b0-d9b0c18b5db4
# ╠═6cf8534b-2fa1-4762-9526-bd3c2da99843
# ╠═4408b037-e336-4382-8468-28d1746c23d3
# ╟─5096d7c0-0189-4c89-9ec0-13e7aac9aa8a
# ╟─0be0a442-8c9f-4035-b926-998f0c63ade7
# ╟─9c2f897a-663e-4408-8364-1582ef6cba9c
# ╠═1e7552ac-9c46-479d-b26e-5d776e3cc5af
# ╠═fa31ea0c-b3dd-4145-bb35-3698308371a7
# ╟─3347f3d5-dd43-40ff-bbed-f8f06532be47
# ╟─82b5a573-6013-408f-99c9-f105708f948e
# ╟─0b598ee8-8671-4b99-87b8-1a65a2d63aa2
# ╠═1b6763ba-ae24-4f63-b7e8-545364ddab89
# ╠═93634846-dc90-4021-bf4c-de1b13f476cc
# ╟─6a60527b-0f46-4bf0-bd6f-91e509737a32
# ╠═fc0a7329-5d93-4519-ace0-626aa376fc1b
# ╟─97af696e-d076-40b3-a5d5-ec363350d7b7
# ╟─6ba87a23-5114-4126-b6a2-0981992d8a46
# ╟─48a851ce-fd14-4516-a172-c720f24bf153
# ╟─453b235b-bd4f-446f-b767-b71a197cc66c
# ╟─7dbb864c-b3d9-4cd1-8c48-9a61be67334f
# ╟─34360486-0f98-46bf-bdb6-550164e3b051
# ╟─22c1df68-673f-4791-a705-0b45a42da211
# ╠═c75e7eb2-ea7c-4448-ad5b-54955ee5cd8c
# ╟─5af46f82-c323-4472-aa68-76d253eb35b9
# ╠═cc6edd6d-0328-4692-834d-aa5258076d21
# ╟─19b91d8e-d03d-4b76-8358-5a4b1e90604d
# ╟─26f2bdca-e7bc-4e80-86ca-d4dc29d71aa0
# ╟─3ff092e2-7af2-4b4b-bd29-2b0310cae48f
# ╟─b4a64a85-640d-4386-b7ad-87d87671aac9
# ╟─1cef7433-e0a8-4ec7-a7a7-e7bd24efa20f
# ╟─c4838943-8a9d-46f9-88d5-6df92b66c8d4
# ╟─46862350-c094-4489-83a2-ea4b670a16c0
# ╟─5aed7665-1131-4715-90ca-dca12c038a68
# ╟─5f1b386d-daf0-46ca-a90a-89c954eb2d11
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
