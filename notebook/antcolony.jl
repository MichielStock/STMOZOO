### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ 45160a1e-cb93-48bf-b2b9-35c337780a73
using ShortCodes, Plots, Random, LinearAlgebra

# ╔═╡ 69899fd8-3b3f-4220-8997-88208c6177ca
md"""
*Natalie Thomas*\
*STMO Fall 2021*\
"""

# ╔═╡ 3a5e53ea-b36d-4e97-af88-75bee3180b2a
md"""
# Ant Colony Optimization
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/ant_chalkboard.jpg?raw=true)
#### So you want to learn about Ant Colony Optimization

*Target audience*: This notebook is intended for people with introductory knowledge of optimization problems and related terminology, and whom are relatively inexperienced with Julia. 

*After completing this notebook, the student will be able to answer the following questions*: 
- What is the point of Ant Colony Optimization? What problem does it try to solve?
- What is the biological behavior that inspires ACO? 
- How does ACO differ from other algorithms that solve the Travelling Salesman Problem? 
- In what way is ACO stochastic? In what way is ACO probabilistic? 
- How can ACO be implemented in Julia?
- What are some limitations of ACO?
- In what situations is ACO most applicable?
- What are some more advanced ideas that improve upon a basic ACO algorithm? 

We begin with a review of some terminology, and an introduction to the Travelling Salesman Problem. 

#### Prerequisite terminology:
**Heuristic**: A problem-solving approach that does not guarantee an optimal solution but returns a sufficient enough approximation; typically employed when finding the optimal solution is impossible or inefficient.

**Metaheuristic**: From "meta" (above) and "heurisein" (to find). These methods begin from a null solution and build toward a complete solution, the goal being to escape being trapped in local optima. These methods could also comprise of a local search beginning with a complete solution and iteratively modifying it to search for a better one. 

**NP-problem**: A nondeterministic polynomial time problem. A solution for this problem can be reduced to a polynomial-time verification. The optimum solution of NP-problem often (but not always) requires an exhaustive search. 

**NP-hard problem**: A class of problem that is translatable into an NP-problem; it is at least as hard as an NP-problem. A problem is NP-hard if its algorithm can be translated into another algorithm for any other NP-hard problem.

**Pheromone**: A chemical produced and secreted into the environment by an animal which affects the behavior or physiology of other animals of that species. Pheromones can encode many different signals and may be sensed/smelled by other community members and (for example) trigger a social response. 


## Inspiration for ACO
### The Travelling Salesman Problem
**Ant Colony Optimization** (ACO) is an umbrella term for a group of algorithms used to solve the Travelling Salesman Problem (TSP).

> **Problem definition**: Given a list of cities and the distances between each pair of cities, find the shortest possible route that visits each city exactly once and returns to the origin city.

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/TSP_solution_200w.png?raw=true)

The solution to the TSP is a route that minimizes the distance a salesman must travel to complete their sales route and return to their home (or starting) city. Therein lies the challenge: the TSP is an NP-hard problem, so an exhaustive search of all possible solutions is not only unideal, it is often impossible due to combinatorial explosion. On the other hand, any proposed solution can be easily checked against another to see which is the shorter route. 

There are many flavors of optimization algorithms that give heuristic solutions to the TSP. Developing TSP algorithms is of interest because of the ubiqutiy of such problems. Planning vehicular/trucking routes is one of the more straightforward applications of TSP, but aside from planning and logistics, the TSP appears frequently in other industries such as computing and bioinformatics (for example: [DNA sequencing](http://www.cs.cmu.edu/afs/cs/academic/class/15210-s15/www/lectures/genome-notes.pdf) and [microchip manufactoring](https://www.emerald.com/insight/content/doi/10.1108/03056120910979512/full/html)).
"""

# ╔═╡ 6608e84a-fb31-492a-aced-70b32e3c6a14
md""" 
### Ant foraging behavior

Ant Colony Optimization is a term for a group of metaheuristics that solve the TSP. ACO simulates ant foraging behavior and is established using the indirect information transmission mechanism of an ant colony.

Ants live in community nests or colonies. When a forager ant leaves its colony, it travels randomly until it finds a food source, then it carries as much food as possible back to its colony. Along the way, it deposits pheromones. Pheromones faciliate indirect communication with the colony and convey information about the food the ant is carrying. Other ants can smell the pheromones and retrace the original ant's path to the food. The higher the level of pheromone, the greater probability that proceeding ants follow the same path. This develops into a positive-feedback loop: as more ants choose a particular path, they in turn deposit more pheromones along that path, which makes the path even more attractive. Ultimately, the collective pheromone deposits of many ants over various paths converges on an optimal (shortest) path between the colony and the food. 

#### Any colony simulation
The YouTube video below shows an ant foraging simulation. Pheromone trails are shown in white.

##### **!** *Exercise*: Answer the following questions as you watch the video:
- How do the paths converge (or not) over time?
- Does the path convergence rate seem to be steady, grow, or decay over time?
- Do the pheromone concentration remain steady or fade over time?
- Why do some ants seem to ignore the pheromone trail all together?
"""

# ╔═╡ 249340e4-c31a-46a3-a620-ceef9abaadb5
YouTube("3YXikOL_3l0", 0, 15) 

# ╔═╡ a5078d2c-4ce0-4c9f-af45-e6b2dde62277
md"""
##### **!** *Bonus questions*:
- In the first half of the simulation, one path seems to emerge as optimal. What physical event causes this optimal path to be modified in the second half of the video?
- How can you connect the event in the previous question to a real-life TSP? How is this analagous to the way a real-life problem might change over time? 
"""

# ╔═╡ 67d95176-fc53-4daa-931f-1a7baa29e888
md"""
## ACO: from inspiration to implementation 
By now you have an intuitive understanding of the real colony behavior underlying ACO algorithms. But how do they work exactly? In the following sections, you will:

1. Learn the general scheme underling ACO.
2. Examine the inputs and parameters needed to run ACO (note that this notebook demonstrates just one of countless ways to implement ACO).
3. Practice writing the most relevant functions needed for ACO. 
4. Gain an understanding of the limitations of ACO and be introduced to some of the advanced concepts that are applied in other ACO algorithms. 

### ACO algorithm
The algorithm closely mirrors the biological behavior of ant colonies: In reality, ants depart their colony and begin a random search for food. Once located, ants deposit a pheromone trail from the food source back to the colony. In our TSP context, we slightly re-imagine this behavior. Think of the ants as being given a list of food locations before they leave their colony. They must visit each location before returning to their colony, and the goal is to find the shortest possible route to achieve this. Each ant's initial route is conducted at random (there is no strategy to picking the first route). Future ants will fine-tune the path by following pheromone signals with some level of probability dependent on pheromone strength. Over time, pheromone signals fade, but an optimal solution emerges as ants converge on the shortest path. 

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/ACO_diagram.jpg?raw=true)
\
*Diagram: (1) Two intial paths **a** and **b** from ant nest **N** to a food source **F**. (2) Continued path traversal. Path segments accumulate more pheromones as they are travelled by more ants. (3) A solution emerges when ants converge on a path. Pheromones on discarded path segments fade and no additional pheromone is deposited.*

In our algorithm, "ants" are agents that locate solutions by moving through a parameter space representative of all possible solutions. To begin, they traverse the space randomly and individually. Each ant will be associated with a solution that is equal to the cumulative distance it travelled, and the path itself is also recorded. Each ant's solution is scored, where a score is equal to the total length of the ant's route. Remember that the goal is to minimize distance travelled, so the shorter the path, the higher the solution quality. Ants lay down pheromones (which are associated to their route) that are proportional to the quality of their respective solutions. 

After initial (random) paths and path scores are calculated, the ants are deployed again. This time, pheromones *inform*, but do not dictate, path decisions. After each successive run (or iteration), path scores per ant are re-calculated and pheromones are adjusted accordingly. The algorithm stops after a fixed number of iterations. 


#### Important features of ACO:
- ACO is a **probabilistic** technique in that it makes use of *a priori* information about the structure of possible good solutions to produce new ones. This is communicated by pheromones, which attract ants to more attractive paths.  
- ACO has an element of **randomness** or stochasticity. Path decisions are made by randomly selecting a value from a cumulative probability array constructed according to pheromone information (the selected value corresponds to deciding where to go next). This means ants retain some "individualism" and can forge or follow a path that does not adhere to the (current) best solution. 
- **Pheromones evaporate** over time, which helps avoid getting stuck in local optima.
- ACO can run **continuously** and can therefore adadpt to environmental conditions in real time. 

"""

# ╔═╡ 4d3e3f09-ee88-47b5-a03f-93d034cbee45
md"""
#### Pseudocode: ACO overview
- **n**: number of cities the ants must visit, including the origin city (default: 10)
- **a**: number of ants that will traverse the parameter space (default: 4)
- **k**: number of iterations (default: 10)

>*input*  **a** and **n**\
>\
>\
> *repeat* **k** times:\
>
>> 1. generate ant paths\
>> 2. calculate path scores\
>> 3. find best solution\
>> 4. update pheromone trail\
>*output* the solution (trail) and it's value (total length): **solutionpath** and **solutionlength**
"""

# ╔═╡ 2395128d-9af8-460e-a36f-05b3aeb00afb
md""" 
#### Now let's create our algorithm.
An example implementation of ACO is demonstrated in the following sections. You will be provided opportunity to practice writing more interesting and ACO-relevant functions for the algorithm, while components such as initialization are some helper functions are provided directly. 
"""

# ╔═╡ 139df66d-b0bf-4adb-891a-18c9fad6db87
md"""
## Initialization
Before running the main ACO function, we need to initialize many objects. The is performed by the provided `init_aco` function.

Run `init_aco` below. It has two optional parameters, `n` and `a`, which are the number of cities and the number of ants, respectively. 
The default values are 10 cities and 4 ants. Run the function without parameters values (`init_aco()`) to initializate with default values. Otherwise, choose the number of cities and ants: `init_aco(n,a)`.
"""

# ╔═╡ 47c98bd7-f84d-455d-a417-5ffc93fa6fdd
#run init_aco(n,a) here

# ╔═╡ 49b1e095-6ef7-43a0-8594-5fea87e21f9f
md"""
##### What did we initialize?
`init_aco` returns several objects:
- `start`: integer representing a randomly selected start city (you can also think of this as the colony location)
- `dists`: symmetric distance matrix for which any entry *(i,j)* represents the distance between two cities *i* and *j*
- `ants`: each ant is a vector containing a solution or route, i.e. an ordered list of cities; initially this is a random ordering
- `best_T`: vector corresponding to the ant that found the shortest trail (route)
- `best_L`: length of `best_T`
- `pheromones`:  square matrix with as many rows/columns as there are cities, for which any entry  *(i,j)* represents the pheromone value associated with travel between any two cities *i* and *j*

Store these values in variable names for future use.
"""

# ╔═╡ 525465ac-a5e0-4c98-baf6-29d60a33420a
#re-run init_aco() here, providing variable names to store the returned values in

# ╔═╡ 2e5ff5ca-04fa-47c0-b9d5-03130097df57
md""" ##### **!** *Comprehension check*: What is the initial pheromone value for any pair of cities? What is the reasoning behind this initialization?
"""

# ╔═╡ 82a213e4-3c70-48c5-8b82-f4ff6ea55603
#print the pheremone matrix here

# ╔═╡ 681ec771-af2c-41e1-8d6a-3067188c3d6e
md" ##### **!** *Comprehension check*: How can you tell that the distance matrix is symmetric? Why does it have that property? "

# ╔═╡ 66ee64f3-1f1d-42b5-808a-fa0c5c017ba3
#print the distance matrix here

# ╔═╡ dbb0ae04-589b-475d-ba59-95367fccd96b
md"""
##### **!** *Want to see more?*
The function definition for `init_aco(n,a)` is available at the end of this notebook, along with definitions of its helper functions:

- `makegraphdists(n)`\
- `initants(start, a, n)`\
- `randomtrail(start, n)`\
- `best_trail(ants, dists)`\
- `initpheromones(n, dists)`

"""

# ╔═╡ 06009ce9-99a0-4568-814b-4f56cfd1815a
md"""
## Optimization: main body

After running initialization, we already have a solution to our problem. Of course, since the initialized ant paths are random, this solution is almost certainly garbage. Now we aim to optimize the solution by performing iterative runs of our main algorithm.

Recall the pseudocode for the main ACO loop:

#### `aco`
>*input* **a** and **n**
>\
>\
> *repeat* **k** times:\
>
>> 1. generate ant paths\
>> 2. calculate path scores\
>> 3. find best solution\
>> 4. update pheromone trail\
>*output* the solution (route) and it's value (length): **solutionpath** and **pathlength**

Rather than attempting to translate this pseudocode into one function, we create separate functions for each of the four tasks, along with some helper functions. In the end, the function `aco` makes use of all sub-functions to enact ACO as described in the pseudocode.

We will take a top-down approach to examine a few functions for this algorithm. First, you will try completing the `aco` function. After that you'll take a try at writing a few of the sub-functions, including `updateants` and `updatepheromones`, `trailsum`.

*This may seem counter-intuitive at first*: After all, writing `aco` will involve calling functions you haven't even written yet! For now, just go with it. We'll revisit this question later.
"""

# ╔═╡ 1922c5e9-8275-4fbd-9d4b-af92d0ffb039
md"""
###### **!** *Exercise*: Complete the `aco` function below. 

You can call the following functions:

- `updateants(ants, pheromones, dists, start)` : updates ant path solutions
- `updatepheromones(pheromones, ants, dists)` : updates pheromone matrix
- `best_trail(ants, dists)` : finds the best trail among `ants`
- `trailsum(trail, dists)` : finds the sum of a single ant trail
"""

# ╔═╡ 43d58b74-9388-4b97-9a94-7191952f4184
"""
	aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)

Runs ACO k times and returns the shortest path and its length. 

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: array of solution "ant" arrays
	- best_T: best trail in ants
	- best_L: length of best_t
	- pheromones: pheromone matrix 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants 
	- k: an index

Outputs:

	- best_T: updated best trail
	- best_L: length of best_L
"""
function aco_exercise(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)

	i = 1 #loop counter
    currbest_T = zeros(Int64, n) #init currbest_T
	currbest_L = 0 #init currbest_L
	
	while missing # termination condition 
		
		missing #update ant paths
		missing	#update pheromone matrix 

		missing #find best of the current ant trails
		missing #find length of current best trail

		if missing #check whether current best trail is global best
			missing #what should happen if the program finds a new global best?
		end

		missing #increment loop count	
	
	end 
	
	return best_L, best_T
end

# ╔═╡ 1ce28f18-368d-4a0c-84e6-129d7fed30a5
md"""

##### **!** *Check your solution*

Reveal the solution below by clicking the eye icon at the left of the function chunk ("Main.workspace###.aco"). 

It is not expected that your solution for this or any other function is identical to the one provided. The purpose is only to practice implementing the ideas, and to think about why the structure of any function (and the overall program organization) is designed as it is.
"""

# ╔═╡ 4b715a6a-2015-4893-95a3-d866aa25a5e3
md"Solution:"

# ╔═╡ faa44127-59c5-486e-9e2a-19c768830da0
md"""
##### **!** *Thought experiment*: Top-down writing

Writing a function before actually defining the sub-functions that it calls (as we have just done) is analogous to a boss delegating tasks. Imagine two modes as you work on these functions: **Boss Mode** and **Worker Mode**

**Boss Mode**: As the boss, your job is to maintain the "bigger picture" of the project. Making calls to sub-functions, for example, is comparable to off-loading tasks on assistants: you don't get involved in the particulars. You trust that the employees will report back with the work you've assigned, when you call on them.

**Worker Mode**: In this mode, you are handed a task, and the bigger purpose of that task may be unclear. You might ask questions like "Okay, but why do it like this?" In this mode, you have to trust that the boss has a good reason for their particular request.

There will be a few more exercises where you will finish writing incomplete functions. In some exercises you will work in **Boss Mode**, and in others you will be in **Worker Mode**.
"""

# ╔═╡ cf3cc491-25be-4dd4-86ab-c47e0bc23024
md"""
## Optimization: inside the loop
Now we look to the steps inside the loop:
- generate ant paths
- calculate path scores
- find best solution
- update pheromone trail
"""

# ╔═╡ 97e31857-bb2a-4cca-bf04-9da7e74796b1
md"""
### Generate ant paths

###### **!** *Exercise*: Complete the `updateants` function below. 

You can call the following function:

- `buildtrail(k, start, pheromones, dists, n)` : updates a single path solution while taking pheromone information into account

"""


# ╔═╡ c7e297b2-dd4c-4bba-9f79-0b7059191e95
"""
	updateants(ants, pheromones, dists)

Build a new trail for each ant while taking pheromone values into account

Inputs:

	- ants: array of solution "ant" arrays
	- pheromones: pheromone matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- ants: updated array of ant (solution) arrays 
"""
function updateants_exercise(ants, pheromones, dists, start)
	n = Int64(size(dists,2)) 
	num_ants = Int64(length(ants)) #a
	for k in missing #for each of k ants

		missing #build a new trail
		missing #update the ants vector by assigning the new trail to the kth ant 
	end
end

# ╔═╡ 2706d829-7637-48b7-a0ca-317b18ca71b6
md"Solution:"

# ╔═╡ 87c58a34-5477-493c-ad9c-9a99b1d9206c
md"""
### Calculate path scores
A path score is the same as the sum of the distances between each of the path segments.
##### **!** *Exercise*: Complete the `trailsum` function below. 

You can call the following function:

- `distance(cityX, cityY, dists)` : returns the distance between `cityX` and `cityY` according to the distance matrix `dists`
"""

# ╔═╡ 6cfc4a6e-049d-48db-a4a5-5fb60ed32e7f
"""
	trailsum(trail, dists) 

Calculates the sum of the entire path taken by the ant.  

Inputs:

	- trail: a solution (completed path)
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- result: sum of trail from begin to end but not back to start again 
"""
function trailsum_exercise(trail, dists) # total length of a trail (sum of distances)

	result = 0.0 #initialize a result variable
	
	for i in 1:missing
		result = missing #find the sum of the trail

	end
	return missing
end

# ╔═╡ 52fe76d0-1b43-4100-b63f-4a4fd928149f
md"Solution:"

# ╔═╡ 573dfc88-1d67-405a-8f7f-2763833283b9
md"""
### Find best solutions

This is already handled by the while loop in `aco`. (Scroll up and re-read the function code to verify!)

"""

# ╔═╡ f451c468-b840-4843-b442-d792ebbf785d
md"""
### Update pheromone trail
This is a great example of working in Worker Mode. The particulars of the math and reasoning behind this function are outside the scope of this notebook, but if you're curious, you can read about it [here](http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms).

##### **!** *Exercise*: Complete the `updatepheromones` function below. 

You can call the following function:

- `trailsum(ants[k], dists)`
- `is_edge(i, j, ants[k])` (e.g. `is_edge(cityX, cityY, ants[k]`)
"""

# ╔═╡ eed57c64-de54-473c-970e-d452715902fb
md"""
#### Equation for updating pheromones 

 $τ_{i,j}$ is the amount of pheromone on any edge $(i,j)$\. Pheromone amounts are updated according to the following equation:\

> $τ_{i,j} ← (1-ρ)τ_{i,j} + ∑_k Δτ_{i,j}^k$\
where $(1-ρ)τ_{i,j}$ is a pheromone decrease factor and $∑_k Δτ_{i,j}^k$, a pheromone increase factor, with: 

-  $ρ$: the rate of pheromone evaporation
-  $∑_k Δτ_{i,j}^k$: the amount of pheromone to deposit 

"""

# ╔═╡ 888991d5-b77a-4ca8-a885-2ac10b028a72
"""
	updatepheromones(k, start, pheromones, dists, ρ)

Updates pheromone entry for any edge (i,j) in a pheromone matrix  

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of of ants, where each ant is a solution array
	- best_T: the index of the best solution in the ants array 
	- best_L: the length of best_T
	- pheromones: the pheromone matrix 
	- nn: number of cities the ants must visit (including the origin city)
	- a: number of ants that will traverse the parameter space
	- k: n - 1

Outputs:

	- updated pheromone matrix 
"""
function updatepheromones_exercise(pheromones, ants, dists, ρ::Real=0.01, Q::Real=2.0)
	# initialize variables
	pher_rows = size(pheromones,1)
	pher_cols = size(pheromones,2)
	num_ants = length(ants)

	# for each entry in pheromones matrix, and each ant in ants, 
		#compute the length of the Kth ant trail, then compute it's decrease factor and increase factor, then update the relevant entry in pheromones.
	for i in 1:missing 	
		for j in 1:missing 
			for k in 1:missing 	
				missing  		# compute length of Kth ant trail
           		decrease = missing #decrease factor: (1-ρ) * τ_{i,j}  
				
				# check for an edge in the trail
				if missing 		# if there is an edge
					increase = missing  # increase factor =  Q / path length  
				end
    
				pheromones[i,j] = missing # update the pheromone value 
 
                pheromones[j,i] = missing  # maintain matrix symmetry
				
				# bound pheromone value between 1e-5 and 1e5
				pheromones .= clamp.(pheromones,1e-5,1e5)
			end 
		end 
	end
end 

# ╔═╡ d916c673-ad4f-4475-8141-06d068f32efa
md"Solution:"

# ╔═╡ bf508a6c-425a-4da0-9143-8298f06988e3
md"""
### The pheromone matrix was updated, now what? 

The first pass through the main loop of `aco` is trivial. Random ant paths are generated, the path scores are calculated and the best path is identified, and then the pheromone values are updated. 

Now comes the interesting part: in the next loop iteration, ants use the pheromone matrix to inform their trail choices. For each ant, the `nextcity` function selects the next city to add to the route. It does at each step of the path until an ant has a complete solution. 

Selecting the next city is accomplished by creating a cumulative probability array that reflects the attractiveness of going to any particular city next (remember that attractiveness is determined by pheromone presence). By definition, the total probability of going to any city is $1.0$ (meaning that the ant cannot stay where it is). A random number $p$ between $0$ and $1$ is chosen. The interval of the cumulative probability in which $p$ lies indicates which city to go to next. 

**For example**: the table below shows the probability of travelling to cities $0,1,2,3$ or $4$. 
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/probs_array.PNG?raw=true)

Note that City $2$ has the highest probability by far. A value $p$ is randomly chosen between $0$ and $1$. Let's say $p = 0.538$. Where does this value lie in the cumulative probability distribution? 

Then the cumulative probability array is: 

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/cumul_array.PNG?raw=true)

 You can see that $p$ lies in the interval $(0.09,0.87)$, corresponding to City $2$. The ant will travel to City $2$ next. 

##### **!** *Comprehension check*: How does drawing randomly from the cumulative probability distribution translate into using pheromone information?
The more attractive the city is, the bigger 'slice' it will have of the cumulative probability array. Then when a number is randomly drawn, more attactive cities will be more likely to be selected, although there is still a chance to pick an unattactive city. 

This is a pretty cool property of ACO: the ant still has some measure of "free will" it its decision making! 
"""

# ╔═╡ f6de5186-e714-4962-801e-e1e52bef8af7
md"""
##### **!** *Want to see more?*
The function definition for the following main loop helper functions are available at the end of this notebook:

- `buildtrail(k, start, pheromones, dists)`
- `getprobs(k, cityX, visited, pheromones, dists)`
- `distance(cityX, cityY, dists)`
- `is_edge(cityX, cityY, trail)`
"""

# ╔═╡ 2a9212c3-529f-4e13-90bf-f702498ceabc
md"""
## Running ACO

We initialized the necessary variables and completed the main functions described in the ACO pseudocode. Now you are ready to run `aco`!
"""

# ╔═╡ dc8cfbbc-53f0-405f-8d66-8134e4ac798c
md"##### Initialization step 
(as seen before)"

# ╔═╡ 080072a9-97f0-486e-bc0f-c61cd3737d55
md"""
##### Optimization
Variables returned by `init_aco` will be entered as paramteres for `aco`
"""

# ╔═╡ 9a339baf-b98d-46d3-88e5-e535e007349c
md" Note that `aco` returns both the solution value (path length) and the solution (path itself). Print them individually:"

# ╔═╡ 14a24548-efb4-41a6-82e1-5c9a5ef0c7cb
md"""
### Plot solution
"""

# ╔═╡ 64dae470-6b3b-487f-b663-25f10b7b9567
md"""
### Epilogue

ACO is not always as good as other state-of-the-art solutions for TSP. It may suffer from slow convergence speed or may prematurely converge before finding the global optimum. Still, ACO has the potential to drive the search for ever better TSP solutions and therefore remains an ongoing area of research. In fact, ["An improved ant colony optimization algorithm based on context for toursim route planning"](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257317#sec001) was just publiched in September 2021.  
"""

# ╔═╡ 31e6f16e-e12e-474f-9c27-5bff01c53310
md"""
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/Elettes_cartoon.png?raw=true)
Cartoon by Elette, age 8
"""

# ╔═╡ 40785798-1223-4efe-870e-e37b0b761af1
md""" ## Appendix"""

# ╔═╡ 20cb8ca8-0f07-4afa-a380-c539cdff8871
md"""
### Initialization functions
The script for `init_aco` and its helper functions is given below. 

Function relationships:

	init_aco(n::Int=10, a::Int=4)

		makegraphdists(n) 

		initants(a, n)

			randomtrail(start, n) 

				getidx(trail, target) 

		initpheromones(n)

		trailsum(trail, dists) 

		best_trail(ants, dists)
*Note*: indention denotes one function calling another. For example, `randomtrail` calls `getidx`. 
"""

# ╔═╡ 3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
"""
	makegraphdists(n) 

Generates an nxn symmetric matrix with 0s on the diagonal 

Inputs:

	- n: number of cities the ants must visit (including the origin city)

Outputs:

	- matrix: a simulated graph
"""
function makegraphdists(n::Int)

	m = rand(1:10, n, n)  
	matrix = Symmetric(m)

	for i in 1:n
		matrix[i,i] = 0
	end

	return matrix
	
end

# ╔═╡ 97cf8701-7622-4537-8091-1a38acefa9dd
"""
	getidx(trail, target)

A helper function for randomtrail

Inputs:
	- trail: a solution vector 
	- target: a city in the trail

Outputs:

	- returns the index of the target within trail 
"""
function getidx(trail,target::Int)
	for i in 1:(length(trail))
		if trail[i] == target
			return i 
		end
	end
end

# ╔═╡ ea9bcc44-9351-4156-bf61-3368c507d5cf
"""
	randomtrail(start, n)

Generates a random trail through all cities in the graph

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- n: number of cities the ants must visit (including the origin city)

Outputs:

	- a random trail whose length is n-1 , and starts at 'start' city
"""
function randomtrail(start::Int, n::Int)

	
	#Allocate a 'basic' trail [1,2,3,4,5...n-1
	chrono_trail = 1:(n-1) |> collect #chronological trail 
	
	trail = shuffle(chrono_trail)

	idx = getidx(trail, start)
	temp = trail[1]  #Julia starts at 1 indexing
	trail[1] = trail[idx] #swap the start city with the 
	trail[idx] = temp 
	return trail
end

# ╔═╡ e45b3588-f8a7-439a-ac97-bafb9253f6a3
"""
	initants(start, a, n)

Returns an array of of randomized solutions

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants that will traverse the parameter space

Outputs:

	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
"""
function initants(start::Int, a::Int, n::Int)
	
	ants = [] # init array that will hold trail arrays 
	
	for k in 1:a
		t = randomtrail(start, n)	
		push!(ants,t)
	end
  
  return ants
		
end

# ╔═╡ 3f3d611b-dbe2-420e-bf94-89229eca9ab9
"""
	initpheromones(n, dists)

Returns an initialized pheromone array with all pheromone values set to 0.01. 

Inputs:

	- n: number of cities the ants must visit (including the origin city)
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- pheromones: the pheromones array 
"""
function initpheromones(n::Int)
  	pheromones = zeros(n,n)
	fill!(pheromones, 0.01)
  return pheromones
end

# ╔═╡ 7a01418b-2543-433b-942e-92ce38a29496
md"""
### Main loop functions
Helper functions for the main loop functions are defined below.

Function relationships:

	aco(start, dists, ants, best_T, best_L, pheromones, n, a, maxTime::Int=10)

		updateants(ants, pheromones, dists)

				buildtrail(k, start, pheromones, dists)

						nextcity(k, cityX, visited, pheromones, dists) 

							getprobs(k, cityX, visited, pheromones, dists)

								distance(cityX, cityY, dists) 

						distance(cityX, cityY, dists) 

			updatepheromones(pheromones, ants, dists)

				is_edge(cityX, cityY, trail) 
"""

# ╔═╡ c8de83fa-1519-48d0-b257-97bfeb4952ad
"""
	distance(city_x, city_y, graphDistances)

Returns the distance between city_x and city_y

Inputs:

	- city_x: a city/location 
	- city_y: a city/location
	- graphDistances: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- the distance between city_x and city_y
"""
function distance(city_x::Int, city_y::Int, graphDistances)

	return graphDistances[city_x,city_y]
end

# ╔═╡ 306cd489-470c-45c5-bace-1624512087ab
"""
	trailsum(trail, dists) 

Calculates the sum of the entire path taken by the ant.  

Inputs:

	- trail: a solution (completed path)
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- result: sum of trail from begin to end but not back to start again 
"""
function trailsum(trail, dists) # total length of a trail (sum of distances)

	result = 0.0
	
	for  i in 1:(length(trail)-1)
		result += distance(trail[i], trail[i+1], dists) 
		         #Distance(cityX, cityY, graphDistances)
	end
	#add Distance(trail[i], trail[1], dists) ???? 
	return result
end

# ╔═╡ edf145a2-ae6f-4e01-beb1-5be1d5c1250d
"""
	best_trail(ants, dists)

Calculates the best trail in ants array and returns its index. 

Inputs:

	- ants: an array of of ants, where each ant is a solution array
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- the index of the best solution in the ants array 
"""
function best_trail(ants, dists)
	
	#set 1st ant trail as best 
	best_l = trailsum(ants[1], dists)
	idxbest = 1
	n = size(dists,2) 
	
	#check the rest of the trails
	for k in 2:length(ants)
		len = trailsum(ants[k], dists)
		if len < best_l
			best_l = len
			idxbest = k
		end
	end
	
	return ants[idxbest]
end

# ╔═╡ 206fc0de-a6d3-4597-9ce3-f63bdd853d1c
"""
	init_aco(n::Int=10, a::Int=4)

Initializes start city `start`, distance matrix `dists`, ant (solutions) `ants`, the solution `best_t`, and its value/length `best_l`. 

Inputs:

	- n: an integer determining the number of cities in the graph
	- a: an integer determing the number of ants that travel the graph	

Outputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
	- best_t: the index of the best solution in the ants array 
	- best_l: the total length of best_t
"""
function init_aco(n::Int=10, a::Int=4)
	
	start = Int64(rand(1:10))
	dists = makegraphdists(n)
	ants = initants(start, a, n)	
	
	best_t = best_trail(ants, dists)	
    best_l = trailsum(best_t, dists)		

    pheromones = initpheromones(n)		
	
	return start, dists, ants, best_t, best_l, pheromones, n, a
end

# ╔═╡ 3e2075fb-44dd-4cbc-89dd-8b8df32ca4e7
startCity, dists, ants, bestTrail, bestLength, pheromones, n, a = init_aco(10,4) 

# ╔═╡ ef8b5e52-9e29-4180-962a-f89ec76fba80
plot(ants)

# ╔═╡ d671d9d9-ad11-4dcd-8699-ef1a51ceb34e
dists

# ╔═╡ 60627e57-5bb4-486f-b185-adbd812e9f36
"""
	getprobs(k, city_x, visited, pheromones, dists, n, α, β)

Uses information from pheromones to generate a cumulative probability array

Inputs:

	- k: an index
	- city_x: a city 
	- visited: boolean indicating whether city has been visited in the given trail
	- pheromones: pheromone value matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- n: number of cities the ants must visit (including the origin city)
	- α: pheromone update factor (default: 2)
	- β: pheromone update factor (default: 3)

Outputs:

	Cumulative probability array 
"""
function getprobs(k::Int, city_x::Int, visited, pheromones, dists, n::Int, α::Real=3.0, β::Real=2.0, MaxValue::Real=1.7976931348623157e+30)
	τη = zeros(n) #tau eta 
	sum = 0

	
	for i in 1:n
		if i == city_x
			τη[i] = 0.0 # prob of moving to self is zero

		elseif visited[i] == true
			τη[i] = 0.0 # prob of moving to a visited node is zero
	
		#otherwise calculate tau eta
		else 
      		τη[i] = (pheromones[city_x,i])^α * (1.0/(distance(city_x, i, dists))^β)
      		
			#if τη is very large or very small, re-assign 
			if τη[i] < 0.0001
				τη[i] = 0.0001 #lower bound

			elseif τη[i] > MaxValue/(n * 100)
        		τη[i] = MaxValue/(n * 100) #upper bound
			end

		end
			
		sum += τη[i]
	end
	
	probs = zeros(n)
	
	for i in 1:n
		probs[i] = τη[i] / sum
	end 
	
	return probs
end

# ╔═╡ 90386525-b4bb-4834-a59a-9673fb7a5780
"""
	nextcity(k, cityX, visited, pheromones, dists)

Selects the next city to visit in the trail based on drawing randomly from the probability distribution created from the pheromone matrix

Inputs:

	- k: an index
	- cityX: a city 
	- visited: boolean indicating whether city has been visited in the given trail
	- pheromones: pheromone value matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- a city to visit next in the trail
"""
function nextcity_exercise(k::Int, cityX::Int, visited, pheromones, dists, α::Real=3, β::Real=2)
	
	probs = getprobs(k::Int, cityX::Int, visited, pheromones, dists, n::Int)
	cumul = missing #initialize cumulative probability array 
	
	missing # complete the cumulative probability array

	p = missing# "roulette" selection: pick a random value between 0 and 1

	missing #find the interval p is in 

    return missing 

end 

# ╔═╡ c40fe82a-2dee-44d4-b768-25ff50ce746c
"""
	nextcity(k, cityX, visited, pheromones, dists)

Selects the next city to visit in the trail based on drawing randomly from the probability distribution created from the pheromone matrix

Inputs:

	- k: an index
	- cityX: a city 
	- visited: boolean indicating whether city has been visited in the given trail
	- pheromones: pheromone value matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- a city to visit next in the trail
"""
function nextcity(k::Int, cityX::Int, visited, pheromones, dists, α::Real=3, β::Real=2)
	
	probs = getprobs(k::Int, cityX::Int, visited, pheromones, dists, n::Int)
	cumul = zeros(length(probs)+1) #init cumulative probability array 
	
	for i in 1:length(probs)
		cumul[i+1] = cumul[i] + probs[i] #the previous sum + probability 
	end

	#enforce that cumulative probabilty is 1 in case of rounding errors
	cumul[length(cumul)] = 1.0

	# "roulette" selection
	p = rand() 
		if p == 0.0 #make sure we don't get 0.0
			p += rand()  #if 0 pick another random float
		end

	for i in 1:(length(cumul)-1)
    	if p >= cumul[i] && p < cumul[i + 1] #find the interval p is in
      		return i
		end
	end
	#return cumul
end 

# ╔═╡ 2df743f0-620f-43bc-bb51-17dc5e5c0be7
"""
	buildtrail(k::Int, start::Int, pheromones, dists, n::Int)

Builds a trail through all cities with the help of `nextcity` function. Returns a vector of boolean values indicating whether a city has already been visited in the current trail. 

Inputs:

	- k: an index
	- start: an integer representting start city (i.e. colony location) 
	- pheromones: pheromone value matrix  
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- n: number of cities the ants must visit (including the origin city)

Outputs:

	- trail: atrail whose length is n-1 , and starts at 'start' city
"""
function buildtrail(k::Int, start::Int, pheromones, dists, n::Int)
	trail = zeros(Int64, n)
	visited = falses(n)

	trail[1] = start 
	visited[start] = true 
	
	for i in 1:(n-1) #because if we go to n there is no next city
		cityX = Int64(trail[i])
		next_city = nextcity(k, cityX, visited, pheromones, dists)
		trail[i+1] = Int64(next_city)
		visited[next_city] = true 
	end
	
	return trail
end

# ╔═╡ d75d3f55-31fd-43e1-bd38-14ba07431a91
"""
	updateants(ants, pheromones, dists)

Build a new trail for each ant while taking pheromone values into account

Inputs:

	- ants: array of solution "ant" arrays
	- pheromones: pheromone matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- ants: updated array of ant (solution) arrays 
"""
function updateants(ants, pheromones, dists, start)
	n = Int64(size(dists,2)) #numCities
	num_ants = Int64(length(ants))
	for k in 1:num_ants
		#start = Int64(rand(1:n))
		newtrail = buildtrail(k, start, pheromones, dists, n)
		ants[k] = newtrail
	end
end

# ╔═╡ e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
"""
	is_edge(city_x city_y, trail)

Checks if city_xand city_y are adjacent to each other in trail

Inputs:

	- city_x: a city/location 
	- city_y: a city/location
	- trail: a solution 

Outputs:

	- a boolean value (true if city_x and city_y are adjacent, otherwise false)
"""
function is_edge(city_x::Int, city_y::Int, trail)
	
	#make sure city_x, city_y are ins
	city_x
	city_y
	lastIndex = length(trail) 
    idx = getidx(trail, city_x)

    #if X = 1st in trail, see if it's next to 2nd or last in trail
	if idx == 1 && trail[2] == city_y # (X, Y, ...)
    	return true #checked
           
    elseif idx == 1 && trail[lastIndex] == city_y #(X, ..., Y)
    	return true #checked
    
	elseif idx == 1
    	return false #checked
	end
	
	#if X is last in trail, see if its next to 2nd-to-last or 1st
	if idx == lastIndex && trail[lastIndex-1] == city_y
		return true
	
	elseif idx == lastIndex && trail[1] == city_y
		return true
	
	elseif idx == lastIndex
		return false

	#BELOW IS WORKING
	#if X is not 1st or last in list, just check left and right
	elseif trail[idx - 1] == city_y
		return true #checked 

	elseif trail[idx + 1] == city_y
   		return true #checked 

	else
		return false#checked 
	
	end
end 

# ╔═╡ a2aba49e-809f-4cdd-9bd5-d10b854a6628
"""
	updatepheromones(k, start, pheromones, dists, ρ)

Updates pheromone entry for any edge (i,j) in a pheromone matrix  

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of of ants, where each ant is a solution array
	- bestTrail: the index of the best solution in the ants array 
	- bestLength: the length of bestTrail
	- pheromones: the pheromone matrix 
	- numCities: number of cities the ants must visit (including the origin city)
	- numAnts: number of ants that will traverse the parameter space
	- k: numCities - 1

Outputs:

	- updated pheromone matrix 
"""
function updatepheromones(pheromones, ants, dists, ρ::Real=0.01, Q::Real=2.0)
	pher_rows = size(pheromones,1)
	pher_cols = size(pheromones,2) #is a square matrix 
	num_ants = length(ants)
	
	for i in 1:pher_rows
		for j in 1:pher_cols
			for k in 1:num_ants #number of ants
				trail_length = trailsum(ants[k], dists) #length of ant K trail
           		decrease = (1.0-ρ) * pheromones[i,j]
           		increase = 0.0
				
				if is_edge(i, j, ants[k]) == true
					increase = Q / trail_length
				end
    
				pheromones[i,j] = decrease + increase

                #if pheromones[i,j] < 0.0001
				#	pheromones[i,j] = 0.0001
                        
                #elseif pheromones[i,j] > 100000.0
                #	pheromones[i,j] = 100000.0
				#end
                        
                pheromones[j,i] = pheromones[i,j]

				pheromones.=clamp.(pheromones,1e-5,1e5)
			end #for k
		end # for j
	end #for i
end 

# ╔═╡ e05ce658-cbaf-4ac2-a426-c9741fbc37d2
"""
	aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)

Runs ACO k times and returns the shortest path and its length. 

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: array of solution "ant" arrays
	- best_T: best trail in ants
	- best_L: length of best_t
	- pheromones: pheromone matrix 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants 
	- k: an index

Outputs:

	- best_T: updated best trail
	- best_L: length of best_L
"""
function aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)

    i = 1
    currbest_T = zeros(Int64, n)
	currbest_L = 0

	while i < k
		updateants(ants, pheromones, dists, start)	
		updatepheromones(pheromones, ants, dists)

		currbest_T = best_trail(ants, dists)
		currbest_L = trailsum(currbest_T, dists)

		if currbest_L < best_L
			best_L = currbest_L
			best_T = currbest_T	
		end

		i += 1		
	
	end 
	
	return best_L, best_T
end

# ╔═╡ d3e47acd-e60f-492c-8fbb-72e03133e352
solution_length, solution =  aco(startCity, dists, ants, bestTrail, bestLength, pheromones, n, a)

# ╔═╡ cb527cb4-2555-4ddb-be17-02b9c223a0dc
solution

# ╔═╡ 58d5a45c-471b-41e8-960a-66d5fbe6d326
solution_length

# ╔═╡ a2c64a9b-639b-415b-83e2-7dece6070026
plot(solution)

# ╔═╡ d541900d-92ed-4d69-850a-861b805f2eb8
md"""
## References

https://towardsdatascience.com/the-inspiration-of-an-ant-colony-optimization-f377568ea03f  

https://people.idsia.ch//~luca/aco2004.pdf 

https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257317#sec001

https://www.researchgate.net/publication/2831286_The_Ant_Colony_Optimization_Meta-Heuristic

https://www.geeksforgeeks.org/introduction-to-ant-colony-optimization/

https://www.opentextbooks.org.hk/ditatopic/27149 

https://docs.microsoft.com/en-us/archive/msdn-magazine/2012/february/test-run-ant-colony-optimization

https://www.csd.uoc.gr/~hy583/papers/ch11.pdf 

http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms 

https://fypmm161a.wixsite.com/ant-nest/

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"

[compat]
Plots = "~1.25.7"
ShortCodes = "~0.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

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

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

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

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

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

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

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

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

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

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

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

[[Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

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

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7e4920a7d4323b8ffc3db184580598450bde8a8e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.7"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

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

[[ShortCodes]]
deps = ["Base64", "CodecZlib", "HTTP", "JSON3", "Memoize", "UUIDs"]
git-tree-sha1 = "866962b3cc79ad3fee73f67408c649498bad1ac0"
uuid = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
version = "0.3.2"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "2884859916598f974858ff01df7dfc6c708dd895"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.3"

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

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

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

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─69899fd8-3b3f-4220-8997-88208c6177ca
# ╠═45160a1e-cb93-48bf-b2b9-35c337780a73
# ╟─3a5e53ea-b36d-4e97-af88-75bee3180b2a
# ╟─6608e84a-fb31-492a-aced-70b32e3c6a14
# ╟─249340e4-c31a-46a3-a620-ceef9abaadb5
# ╟─a5078d2c-4ce0-4c9f-af45-e6b2dde62277
# ╟─67d95176-fc53-4daa-931f-1a7baa29e888
# ╟─4d3e3f09-ee88-47b5-a03f-93d034cbee45
# ╟─2395128d-9af8-460e-a36f-05b3aeb00afb
# ╟─139df66d-b0bf-4adb-891a-18c9fad6db87
# ╠═47c98bd7-f84d-455d-a417-5ffc93fa6fdd
# ╟─49b1e095-6ef7-43a0-8594-5fea87e21f9f
# ╠═525465ac-a5e0-4c98-baf6-29d60a33420a
# ╟─2e5ff5ca-04fa-47c0-b9d5-03130097df57
# ╠═82a213e4-3c70-48c5-8b82-f4ff6ea55603
# ╟─681ec771-af2c-41e1-8d6a-3067188c3d6e
# ╠═66ee64f3-1f1d-42b5-808a-fa0c5c017ba3
# ╟─dbb0ae04-589b-475d-ba59-95367fccd96b
# ╟─06009ce9-99a0-4568-814b-4f56cfd1815a
# ╟─1922c5e9-8275-4fbd-9d4b-af92d0ffb039
# ╠═43d58b74-9388-4b97-9a94-7191952f4184
# ╟─1ce28f18-368d-4a0c-84e6-129d7fed30a5
# ╟─4b715a6a-2015-4893-95a3-d866aa25a5e3
# ╠═e05ce658-cbaf-4ac2-a426-c9741fbc37d2
# ╟─faa44127-59c5-486e-9e2a-19c768830da0
# ╟─cf3cc491-25be-4dd4-86ab-c47e0bc23024
# ╟─97e31857-bb2a-4cca-bf04-9da7e74796b1
# ╠═c7e297b2-dd4c-4bba-9f79-0b7059191e95
# ╟─2706d829-7637-48b7-a0ca-317b18ca71b6
# ╠═d75d3f55-31fd-43e1-bd38-14ba07431a91
# ╟─87c58a34-5477-493c-ad9c-9a99b1d9206c
# ╠═6cfc4a6e-049d-48db-a4a5-5fb60ed32e7f
# ╟─52fe76d0-1b43-4100-b63f-4a4fd928149f
# ╠═306cd489-470c-45c5-bace-1624512087ab
# ╟─573dfc88-1d67-405a-8f7f-2763833283b9
# ╟─f451c468-b840-4843-b442-d792ebbf785d
# ╟─eed57c64-de54-473c-970e-d452715902fb
# ╠═888991d5-b77a-4ca8-a885-2ac10b028a72
# ╟─d916c673-ad4f-4475-8141-06d068f32efa
# ╠═a2aba49e-809f-4cdd-9bd5-d10b854a6628
# ╟─bf508a6c-425a-4da0-9143-8298f06988e3
# ╠═90386525-b4bb-4834-a59a-9673fb7a5780
# ╠═c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╟─f6de5186-e714-4962-801e-e1e52bef8af7
# ╟─2a9212c3-529f-4e13-90bf-f702498ceabc
# ╟─dc8cfbbc-53f0-405f-8d66-8134e4ac798c
# ╠═3e2075fb-44dd-4cbc-89dd-8b8df32ca4e7
# ╟─080072a9-97f0-486e-bc0f-c61cd3737d55
# ╠═d3e47acd-e60f-492c-8fbb-72e03133e352
# ╟─9a339baf-b98d-46d3-88e5-e535e007349c
# ╠═cb527cb4-2555-4ddb-be17-02b9c223a0dc
# ╠═58d5a45c-471b-41e8-960a-66d5fbe6d326
# ╟─14a24548-efb4-41a6-82e1-5c9a5ef0c7cb
# ╠═ef8b5e52-9e29-4180-962a-f89ec76fba80
# ╠═a2c64a9b-639b-415b-83e2-7dece6070026
# ╠═d671d9d9-ad11-4dcd-8699-ef1a51ceb34e
# ╟─64dae470-6b3b-487f-b663-25f10b7b9567
# ╟─31e6f16e-e12e-474f-9c27-5bff01c53310
# ╟─40785798-1223-4efe-870e-e37b0b761af1
# ╟─20cb8ca8-0f07-4afa-a380-c539cdff8871
# ╠═206fc0de-a6d3-4597-9ce3-f63bdd853d1c
# ╠═3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
# ╠═e45b3588-f8a7-439a-ac97-bafb9253f6a3
# ╠═ea9bcc44-9351-4156-bf61-3368c507d5cf
# ╠═97cf8701-7622-4537-8091-1a38acefa9dd
# ╠═edf145a2-ae6f-4e01-beb1-5be1d5c1250d
# ╠═3f3d611b-dbe2-420e-bf94-89229eca9ab9
# ╟─7a01418b-2543-433b-942e-92ce38a29496
# ╠═2df743f0-620f-43bc-bb51-17dc5e5c0be7
# ╠═60627e57-5bb4-486f-b185-adbd812e9f36
# ╠═c8de83fa-1519-48d0-b257-97bfeb4952ad
# ╠═e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
# ╟─d541900d-92ed-4d69-850a-861b805f2eb8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
