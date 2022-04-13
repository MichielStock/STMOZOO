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

# ╔═╡ 45160a1e-cb93-48bf-b2b9-35c337780a73
using ShortCodes, Plots, Random, LinearAlgebra, PlutoUI, Images

# ╔═╡ 69899fd8-3b3f-4220-8997-88208c6177ca
md"""
*Natalie Thomas*\
*STMO Fall 2021*\
*Final version: Jan 31, 2022*
"""

# ╔═╡ 3a5e53ea-b36d-4e97-af88-75bee3180b2a
md"""
# Ant Colony Optimization
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/ant_chalkboard.jpg?raw=true)
#### So you want to learn about Ant Colony Optimization

*Target audience*: This notebook is intended for people with introductory knowledge of optimization problems and related terminology, and whom are relatively inexperienced with Julia. 
"""


# ╔═╡ 9d58ef2b-4c88-4c25-acbe-084dc1fc8842
md"##### *What will I learn in this notebook?*
click for answer: $(@bind showsol1 CheckBox())"

# ╔═╡ 5cf8234f-6d9f-4738-8232-13a5f6ba723c
if showsol1
	md"""
*After completing this notebook, the student will be able to answer the following questions*: 
- What is the point of Ant Colony Optimization? What problem does it try to solve?
- What is the biological behavior that inspires ACO? 
- How does ACO differ from other algorithms that solve the Travelling Salesman Problem? 
- In what way is ACO stochastic? In what way is ACO probabilistic? 
- How can ACO be implemented in Julia?
- What are some limitations of ACO?
- What user-set parameters affect the outcome of ACO?
	"""
end

# ╔═╡ ecd4e231-9030-438a-9068-e1f0d13f1b78
md"""

We begin with a review of some terminology, and an introduction to the Travelling Salesman Problem. 

#### Prerequisite terminology:
**Heuristic**: A problem-solving approach that does not guarantee an optimal solution but returns a sufficient enough approximation; typically employed when finding the optimal solution is impossible or inefficient.

**Metaheuristic**: From "meta" (above) and "heurisein" (to find). These methods begin from a null solution and build toward a complete solution, the goal being to escape being trapped in local optima. These methods could also comprise of a local search beginning with a complete solution and iteratively modifying it to search for a better one. 

**NP-problem**: A nondeterministic polynomial time problem. A solution for this problem can be reduced to a polynomial-time verification. The optimum solution of NP-problem often (but not always) requires an exhaustive search. 

**NP-hard problem**: A class of problem that is translatable into an NP-problem; it is at least as hard as an NP-problem. A problem is NP-hard if its algorithm can be translated into another algorithm for any other NP-hard problem.

**Pheromone**: A chemical produced and secreted into the environment by an animal which affects the behavior or physiology of other animals of that species. Pheromones can encode many different signals and may be sensed/smelled by other community members and (for example) trigger a social response. 

In this notebook, the terms **tour**, **trail**, and **route** are used interchangeably to describe the path of an ant to and from its colony, or the path of an ant through each of a number of "cities" and back to its colony.

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

#### Pseudocode: ACO overview
>*input*  starting city, distance matrix, intial ant solutions, best intial solution, length of best solution, initial pheromone matrix, number of cities, number of ants, and number of iterations. 
>\
>\
> *repeat* **k** times:\
>
>> 1. generate ant paths\
>> 2. calculate path scores\
>> 3. find best solution\
>> 4. update pheromone trail\
>*output* the length of the best trail, **trail_value**, and the trail itself, **best_ant**.

That's quite a long list of inputs, isn't it? Don't worry, we'll use an initialization function to generate most of these items for us. In reality, you just two things to run our version of ACO: (1) a list of the x,y-coordinates of the cities and (2) the number of ants to simulate.

#### Now let's create our algorithm.
An example implementation of ACO is demonstrated in the following sections. You will be provided opportunity to practice writing more interesting and ACO-relevant functions for the algorithm, while components such as initialization are some helper functions are provided directly. 
"""

# ╔═╡ 139df66d-b0bf-4adb-891a-18c9fad6db87
md"""
## Initialization
Before running the main ACO function, we need to initialize many objects. This is performed by the provided `init_aco` function. 


#### Function inputs: `init_aco(citycoords,a)`
- `citycoords`: an nx2 matrix providing the x,y coordinates for the n cities in the graph
- `a`: (optional) an integer determing the number of ants that travel the graph; if left unspecified the default value is 4

#### Function outputs:
- `start`: an integer representing start city (i.e. colony location) 
- `dists`: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
- `ants`: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
- `best_ant`: the best trail/solution array in `ants`
- `trail_value`: the total length of the best ant's trail

##### Example dataset: 4 cities
We will use an example dataset containing just 4 cities. The x,y-coordinates for these cities is stored in `coords4`.

We will run `init_aco` and store `init_aco` outputs in the following variables:
- `colony4`
- `dists4`
- `ants4`
- `bestroute4`
- `routelength4`
- `pheromones4`
- `n4`
- `a4`

Note that each variable namee is appended with the number 4 to associate it with this 4-city example.
"""

# ╔═╡ 09d67d88-a8f8-404d-820e-5a7cada6505d
md""" ###### **!** *Comprehension check*:
Does the optimal solution change if a different starting city (e.g. colony location) is selected from the dataset? Why or why not? 
"""

# ╔═╡ 2e5ff5ca-04fa-47c0-b9d5-03130097df57
md""" ###### **!** *Comprehension check*:
What is the initial pheromone value for any pair of cities? What reasoning might be behind this initialization?
"""

# ╔═╡ 82a213e4-3c70-48c5-8b82-f4ff6ea55603
#print the pheremone matrix here

# ╔═╡ 681ec771-af2c-41e1-8d6a-3067188c3d6e
md" ###### **!** *Comprehension check*: 
How can you tell that the distance matrix is symmetric? Why does it have that property? "

# ╔═╡ 3feacf51-4113-45eb-bf99-f01c8b3b9a16
#print the distance matrix here

# ╔═╡ dbb0ae04-589b-475d-ba59-95367fccd96b
md"""
##### **!** *Want to see more?*
The function definition for `init_aco(citycoords,a)` is available in the *Appendix* near the end of this notebook, along with definitions of its helper functions:

- `makegraphdists(n)`\
- `initants(start, a, n)`\
- `randomtrail(start, n)`\
- `best_trail(ants, dists)`\
- `initpheromones(n, dists)`

"""

# ╔═╡ 06009ce9-99a0-4568-814b-4f56cfd1815a
md"""
## Optimization: main body

After running initialization, we already have a solution to our problem. Of course, since the initialized ant paths are random, this solution is almost certainly garbage. Now we use Ant Colony Optimization to improve the solution by performing iterative runs of our algorithm.

Recall the pseudocode for the main ACO loop:
>*input* **start**, **dists**, **ants**, **best_ant**, **trail_value**, **pheromones**, **n**, **a** and optionally **k**
>\
>\
> *repeat* **k** times:\
>
>> 1. generate ant paths\
>> 2. calculate path scores\
>> 3. find best solution\
>> 4. update pheromone trail\
>*output* the length of the optimized trail, **trail_value**, and the trail itself, **best_ant**.

Rather than attempting to translate this pseudocode into one giant function, we create separate functions for each of the four tasks, along with some helper functions. In the end, the function `aco` makes use of all sub-functions to enact ACO as described in the pseudocode.

We will take a top-down approach to examine a few functions for this algorithm. First, you will try completing the `aco` function. After that you'll take a try at writing a few of the sub-functions used by `aco`, including `updateants` and `updatepheromones`, `trailsum`.
"""

# ╔═╡ faa44127-59c5-486e-9e2a-19c768830da0
md"""
*A top-down approach may seem counter-intuitive at first*: After all, writing `aco` will involve calling functions you haven't even written yet! 

###### **!** *Thought experiment*: Top-down writing
click to show: $(@bind showsol2 CheckBox())
"""

# ╔═╡ d31a5524-0f98-433f-8b23-79be9c08cf39
if showsol2
	md"""
Writing a function before actually defining the sub-functions that it calls is analogous to a boss delegating tasks. Imagine two modes as you work on these functions: **Boss Mode** and **Worker Mode**

**Boss Mode**: As the boss, your job is to maintain the "bigger picture" of the project. Making calls to sub-functions, for example, is comparable to off-loading tasks on assistants: you don't get involved in the particulars. You trust that the employees will report back with the work you've assigned, when you call on them.

**Worker Mode**: In this mode, you are handed a task, and the bigger purpose of that task may be unclear. You might ask questions like "Okay, but why do it like this?" In this mode, you have to trust that the boss has a good reason for their particular request.

There will be a few more exercises where you will finish writing incomplete functions. In some exercises you will work in **Boss Mode**, and in others you will be in **Worker Mode**.
	"""
end

# ╔═╡ 1922c5e9-8275-4fbd-9d4b-af92d0ffb039
md"""
###### **!** *Exercise*: Complete the `aco` function below. 
Learn by practice: A partially filled-in function is given below. Replace any line with the word missing with the necessary code. Comments are provided within the function body to guide you.

The following functions are provided for your use in this exercise:

- `updateants(ants, pheromones, dists, start)` : updates ant path solutions
- `updatepheromones(pheromones, ants, dists)` : updates pheromone matrix
- `best_trail(ants, dists)` : finds the best trail among `ants`
- `trailsum(trail, dists)` : finds the sum of a single ant trail
"""

# ╔═╡ 43d58b74-9388-4b97-9a94-7191952f4184
"""
	aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

Runs ACO k times and returns the shortest path and its length. 

Inputs:

	- start: an integer representing start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: array of solution "ant" arrays
	- best_ant: best trail in ants
	- trail_value: length of best_ant
	- pheromones: pheromone matrix 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants 
	- k: number of times the while loop iterates

Outputs:

	- best_ant: updated best trail
	- trail_value: length of best_ant
"""
function aco_exercise(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

	i = 1 #loop counter
	
    currbest_ant = zeros(Int64, n) #init currbest_ant = the best trail 
	currtrail_value = 0 		   #init currtrail_value = sum of best trail
	
	while missing # termination condition 
		
		missing # update ant paths (hint: use provided function)
		missing	# update pheromone matrix (hint: use provided function)

		missing # find best of the current ant trails (hint: use provided function)
		missing # find length of current best trail (hint: use provided function)

		if missing  # check whether current best trail is global best
			missing # what should happen if the program finds a new global best?
		end

		missing 	# increment loop count	
	
	end 
	
	return trail_value, best_ant
end

# ╔═╡ 4b715a6a-2015-4893-95a3-d866aa25a5e3
md"""**Solution**: see hidden cell for completed `aco` code.\

It is not expected that your solution for this or any other function is identical to the one provided. The purpose is only to practice implementing the ideas, and to think about why the structure of any function (and the overall program organization) is designed as it is.
"""

# ╔═╡ 48b6e748-2d0d-4e1d-805f-d1180ed44a04
md"""
### Intermezzo: solving the 4 cities example

Let's continue with our example dataset and run `aco`.

Run the main ACO function:
> `aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)`
- Variables returned by `init_aco` will be entered as paramteres for `aco`
- You can optionally specify `k`, the number of iterations of the loop, i.e. how many times the ants are sent to walk a tour 
- `aco` returns 2 values: the length of the shortest route (e.g. tour) found, and the route itself 
"""

# ╔═╡ 97e40099-12aa-41ab-b362-816bacd5995c
#optionally specify k4 (number of iterations through while loop)
k4 = 10

# ╔═╡ 1541356f-d713-443b-94fe-2216b6630dc5
md"""
###### **!** *Exercise*
Does changing parameters *n* or *a* above give a better (or worse) result? Why (or why not)?
"""

# ╔═╡ bccd27de-3da5-4c4a-aa49-3382bf10228f
md"""
#### Solution plots
Our example is complete! Now, compare the following solutions plotted below: the first plot is a randomly selected tour. The second plot shows the solution returned by `aco`. 
"""

# ╔═╡ aea42e4b-1c8c-47b6-b38c-4b10710b1698
md"""
###### **!** *Thought experiment*
How does the example dataset size make it easy (or easier) to understand how ACO solves the TSP?\
In what way(s) does the dataset size cloud your understanding?

"""

# ╔═╡ 62e446f5-9714-4f12-9146-01c9281b30a6
md"""
### End intermezzo
Now that we've seen ACO in action, let's flesh out some of the functions we use in `aco`.
"""

# ╔═╡ cf3cc491-25be-4dd4-86ab-c47e0bc23024
md"""
## Optimization: inside the `aco` while loop
We've seen what `aco` does, now let's look deeper at some of the functions it uses to deliver a solution. Remember that the main body of `aco` is a while loop that consists of 4 steps:
 1. generate ant paths
 2. calculate path scores
 3. find best solution
 4. update pheromone trail

Next, we'll examine each of these steps in turn.
"""

# ╔═╡ 97e31857-bb2a-4cca-bf04-9da7e74796b1
md"""
### Step 1: generate ant paths
*Learn by practice*: A partially filled-in function is given below. Replace any line with the word **missing** with the necessary code. Comments are provided within the function body to guide you.
###### **!** *Exercise*: Complete the `updateants` function below. 

The following function is already provided for your use in `updateants`:

- `buildtrail(k, start, pheromones, dists, n)` : updates a single path solution while taking pheromone information into account

"""


# ╔═╡ 2706d829-7637-48b7-a0ca-317b18ca71b6
md"Solution:"

# ╔═╡ 87c58a34-5477-493c-ad9c-9a99b1d9206c
md"""
### Step 2: calculate path scores
The next step in the `aco` while loop is to calculate the score of each ant path. A path score is the same as the sum of the distances between each of the path segments between pairs of cities.
##### **!** *Exercise*: Complete the `trailsum` function below. 
A partially filled-in function is given below. Replace any line with the word missing with the necessary code. Comments are provided within the function body to guide you.
You can call the following function:

- `distance(city_x, city_y, dists)` : returns the distance between `city_x` and `city_y` according to the distance matrix `dists`
"""

# ╔═╡ 6cfc4a6e-049d-48db-a4a5-5fb60ed32e7f
"""
	trailsum(trail, dists) 

Calculates the sum of the ant trail.  

Inputs:

	- trail: a solution (completed path)
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- result: sum of trail from begin to end but not back to start again 
"""
function trailsum_exercise(trail, dists) # total length of a trail (sum of distances)

	result = 0.0 #initialize a result variable
	
	missing # find the sum of the trail

	return missing
end

# ╔═╡ 52fe76d0-1b43-4100-b63f-4a4fd928149f
md"Solution:"

# ╔═╡ 573dfc88-1d67-405a-8f7f-2763833283b9
md"""
### Step 3: find the shortest trail (the best solution)
The next step in the `aco` while loop is to find the best solution in the current batch of solutions. Actually, this is simple enough that we don't need to write a separate function for this: it is handled wihtin `aco`. (Scroll up and re-read the `aco` script to verify!)
"""

# ╔═╡ f451c468-b840-4843-b442-d792ebbf785d
md"""
### Step 4: update pheromone trails
The last step in the `aco` while loop is to update pheromone trails based on the most recent ant solutions. This equates to calculating a value for each path segment (edge) created by any two cities in the graph. The more attractive a particular edge is, the higher the pheromone value it receives, and the more likely it is to be travelled by future ants.  Remember that pheromone signals also fade over time, so a pheromone decrease factor must also be taken into account. 

#### Equation for updating pheromones 
An exhaustive explanatin of the following function is outside the scope of this notebook, but if you're curious, you can read about it [here](http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms). 

 $τ_{i,j}$ is the amount of pheromone on any edge $(i,j)$\. Pheromone amounts are updated according to the following equation:\

> $τ_{i,j} ← (1-ρ)τ_{i,j} + ∑_k Δτ_{i,j}^k$\
where $(1-ρ)τ_{i,j}$ is a pheromone decrease factor and $∑_k Δτ_{i,j}^k$, a pheromone increase factor, with: 

-  $ρ$: the rate of pheromone evaporation 
-  $∑_k Δτ_{i,j}^k$: the amount of pheromone to deposit 

##### **!** *Exercise*: Complete the `updatepheromones` function below. 
A partially filled-in function is given below. Replace any line with the word **missing** with the necessary code. Comments are provided within the function body to guide you.
The following functions are already provided for your use in writing `updatepheromones`:

- `trailsum(ants[k], dists)`: Calculates the sum of the entire path taken by the ant
- `is_edge(i, j, ants[k])`: Checks if two cities *i* and *j* are adjacent to each other in the *k*th trail in `ants`, (the *k*th trail is a trail solution associated to a particular ant)

**Note**: in `updatepheromones`, $∑_k Δτ_{i,j}^k = q/l$ , where $q$ is an arbitrary numerator value (default = $2$) and $l$ is the length of the $k$th ant's trail. 

**Note**: the pheromone increase factor for an edge $(i,j)$ need only be calculated if the ant walks directly from city $i$ to city $j$ (i.e. if the ant doesn't walk over edge $(i,j)$, it isn't possible to leave pheromones there).
"""

# ╔═╡ d916c673-ad4f-4475-8141-06d068f32efa
md"Solution:"

# ╔═╡ bf508a6c-425a-4da0-9143-8298f06988e3
md"""
### We've run through the `aco` while loop, now what? 

The first pass through the main loop of `aco` is trivial. Random ant paths are generated, the path scores are calculated and the best path is identified, and then the pheromone values are updated. After updating the pheromones matrix, the program continues by returning back to the first step, which is to update the ant trails. This time, the ant trails aren't random because they use pheromone information to inform their trail choices. 

**How is the ant's decision-making encoded?** 
Selecting the next city is accomplished by creating a cumulative probability array that reflects the attractiveness of going to any particular city next (remember that attractiveness is determined by pheromone presence). By definition, the total probability of going to any (unvisited) city is $1.0$, meaning that the ant cannot stay where it is and it cannot re-visit a city (other than when it completes its route and returns to its colony). 

The ant "chooses" its next city by picking a random number $p$ between $0$ and $1$. The interval of the cumulative probability in which $p$ lies indicates which city to go to next. 

**For example**: the table below shows the probability of travelling to cities $0,1,2,3$ or $4$. (Note: we are not looking at cumulative probability yet!)

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/probs_array.PNG?raw=true)

Note that City $2$ has the highest probability by far.

Now, a value $p$ is randomly chosen between $0$ and $1$. Let's say $p = 0.538$. Where does this value lie in the cumulative probability distribution? 

The cumulative probability array is: 

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/cumul_array.PNG?raw=true)

 You can see that $p$ lies in the interval $(0.09,0.87)$, corresponding to City $2$. The ant will travel to City $2$ next. 

###### **!** *Comprehension check*: 
**How does drawing randomly from the cumulative probability distribution translate into using pheromone information?**

###### Show answer:  $(@bind showsol4 CheckBox())
"""

# ╔═╡ 96a41671-0557-44d8-bfbd-291d396fccf5
if showsol4
	md"""
The more attractive the city is, the bigger 'slice' it will have of the cumulative probability array. Then when a number is randomly drawn, more attactive cities will be more likely to be selected, although there is still a chance to pick an unattactive city. 

This is a pretty cool property of ACO because it means there is a measure of "free will" in the ant's decision-making! 
	"""
end

# ╔═╡ f6152a42-bb18-4a17-94b3-b9885d6885d4
md"""
#### The `nextcity` function is given below.
As you read through the function code below, try to connect what you're seeing back to the theory above. 
"""

# ╔═╡ f6de5186-e714-4962-801e-e1e52bef8af7
md"""
##### **!** *Want to see more?*
The function definition for the following main loop helper functions are available in the notebook appendix:

- `buildtrail(k, start, pheromones, dists)`
- `getprobs(k, city_x, visited, pheromones, dists)`
- `distance(city_x, city_y, dists)`
- `is_edge(city_x, city_y, trail)`
"""

# ╔═╡ f125718f-54f0-481c-a23d-98cce6e12a4f
md"""
## ACO in action
### 25 city example
Let's try our `aco` algorithm on a bigger dataset. This time, we'll use the data in `coords25`, which holds x,y-coordinates of 25 cities.

#### Initialization step 

Run `init_aco(coords25,a)` below.
- `coords25` is a pre-defined list of 25 x,y-coordinate pairs. 
- You can optionally choose a value for `a` (number of ants). If you run `init_aco(coords25)` with no value for `a`, $4$ ants are used by default.

*Suggestion*:
Append each variable name with the number 25 to associate it with this 25-city example, e.g. `colony25`: the starting city; `dists25`: the distance matrix; `ants25`: initial solutions for each ant; `bestroute25`: the best initial solution;
`routelength25`: the length of `bestroute25`; `pheromones25`: the initial pheromones matrix; `n25`: the number of cities in `coords25`; `a25`: the number of ants
"""

# ╔═╡ 93025b8d-6773-4cee-99c3-7da7498597de
md"""
#### Ant Colony Optimization  
Run the main ACO function:

`aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)`
- Use the variables you saved from `init_aco` as parameters for `aco`
- You can optionally specify `k`, the number of iterations of the loop, i.e. how many times the ants are sent to walk a tour 
- `aco` returns 2 values: the length of the shortest tour found, and the tour itself 
"""

# ╔═╡ 4d97ef57-3a6c-4850-afa3-1b2bf83ab146
#Optionally specify k25, the number of iterations through the aco while loop
k25 = 20

# ╔═╡ 855e5ce1-d143-4af5-841d-331add7c3880
md"""
#### Solution plots: 25 cities example
Compare a random solution (first plot) with the solution you found using `aco` (second plot).
###
"""

# ╔═╡ 9faf5ebd-1c73-4ddf-876c-b1b042389290
md"""
##### **!** *Exercises*
1. How do you think your `aco` solution will change if you re-run it using the same values for *a* and *k*? 
2. Re-run `aco` and look at the new solution plot. How is the plot different? Is this what you expected?
3. How does the random solution compare to the `aco` solution? What might happen if we generate another random solution?
4. Re-run `aco` a few times, changing `k` each time. How much of an impact does this have on the solution? How does it impact `aco` run time?
5. Re-run `aco` a few times, changing `a` each time. How much of an impact does this have on the solution? How does it impact `aco` run time?
6. How do you think you can find the values for `a` and `k` that will give the most consistent (reproducible) and highest quality solution?
"""

# ╔═╡ 49293ec8-5ccb-4a9d-aaeb-1b23cb0835c5
md"""
### How do individual ant solutions evolve over time?
Instead of looking at a static final solution, let's follow an ant throughout it's $k$ trips through the 25 cities.
"""

# ╔═╡ 6bbf4d81-9db1-4308-aebb-bf0a8a5a6701
md"""
##### **!** *Exercises*
- Compare the plot above with the optimized solution, below. 
- Is the evolution of the ant's path over its trips as you expected? Why or why not?
- Adjust the sliders for `k` and `a`. What parameter settings seem to yield the best solution? 
"""

# ╔═╡ 64dae470-6b3b-487f-b663-25f10b7b9567
md"""
### Epilogue and food for thought
ACO is a very promising solution method for TSP, and basic implementation is possible with minimal expertise. However, did you notice some inefficiencies in our implementation? 
- To begin, we initialize random paths for the ants. How could this be made more efficient? Is there any advantage to using completely randomized paths at the beginning?
- We touched in brief on parameters $α$, $β$, and $ρ$, which effect pheromone computation. How might adjusting these parameters improve our solution quality or convergence rate? 

In fact, ACO is not always as good as other state-of-the-art solutions for TSP. It may suffer from slow convergence speed or may prematurely converge before finding the global optimum. At the same time, ACO is also promising in the way it can encode real world context. For example, adjusting the pheromone parameters can encode information about how influencable you want your ant agents to be to social pressure. Adjusting the pheromone evaporate rate can also control how long-lasting the effects of colony communication are, which is another unique property of ACO and other swarm algorithms. 

And do you remember the YouTube video at the beginning of this notebook? The identity of the optimal path changed as the donut disappeared (in other words, the food location or "city" located changed over time as the simulation ran). With this in mind, can you see applications for ACO algorithms that can adapt to real-time changes to TSP problem conditions? One real-world example of this can be found in the tourism industry. Imagine a tour-planning program that can account for real-time changes in weather conditions, a major factor the attractiveness of tourist destinations.

In general, ACO has the potential to drive the search for ever better TSP solutions and therefore remains an ongoing area of research. In fact, ["An improved ant colony optimization algorithm based on context for toursim route planning"](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257317#sec001) was just publiched in September 2021. 

I hope you enjoyed this introduction to Ant Colony Optimization! For a complete list of references used to create this notebook, see the *References* section at the very end of this notebook.
"""

# ╔═╡ 31e6f16e-e12e-474f-9c27-5bff01c53310
md"""
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/elette_ants_v2_2.png?raw=true)
Cartoon by my niece Elette, age 10
"""

# ╔═╡ 40785798-1223-4efe-870e-e37b0b761af1
md""" # Appendix"""

# ╔═╡ 20cb8ca8-0f07-4afa-a380-c539cdff8871
md"""
### Initialization functions
The script for `init_aco` and its helper functions is given below. 

Function relationships:

	init_aco(n::Int=10, a::Int=4)

		makegraphdists(n)* 

		initants(a, n)

			randomtrail(start, n) 

				getidx(trail, target) 

		initpheromones(n)

		trailsum(trail, dists) 

		best_trail(ants, dists)
*Note*: indention denotes one function calling another. For example, `randomtrail` calls `getidx`. 

*`makegraphdists` was not used in the preceding examples, but it can be used in the case that you would like to randomly generate a dataset of n cities.
"""

# ╔═╡ 3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
"""
	makegraphdists(n) 

Randomly generates an nxn symmetric matrix with 0s on the diagonal, i.e. a random distance matrix

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

	aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, maxTime::Int=10)

		updateants(ants, pheromones, dists)

				buildtrail(k, start, pheromones, dists)

						nextcity(k, city_x, visited, pheromones, dists) 

							getprobs(k, city_x, visited, pheromones, dists)

								distance(city_x, city_y, dists) 

						distance(city_x, city_y, dists) 

			updatepheromones(pheromones, ants, dists)

				is_edge(city_x, city_y, trail) 
"""

# ╔═╡ c8de83fa-1519-48d0-b257-97bfeb4952ad
"""
	distance(city_x, city_y, graphDistances)

Returns the distance between `city_x` and `city_y`

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

# ╔═╡ 04e007ac-c582-4510-a053-052e5037e57c
md"""
### Misc. items for plotting
Additional functions and variables used for plotting
"""

# ╔═╡ 86b7067f-5f85-48c3-b78d-3d2e5ed0af3f
md"##### Ant path evolution example"

# ╔═╡ b8a1320e-f7af-4598-b5ee-68b28f25dc47
md" ###### The 4-city example"

# ╔═╡ 2fbf893e-5ced-4233-90a4-3dce09fb5ed0
coords4 = [1.0 1.5; 2.1 0.3; -0.3 1.2; -2.0 -2.3]

# ╔═╡ cffe3e0b-f1a8-423f-8c3a-c98f1bda82d7
md"######  The 25-city example"

# ╔═╡ 8f3b6386-2a28-4433-bcef-f4f2250072a0
coords25 = [1 2;
3 4;
5 1; 
1 5; 
10 20;
30 10;
12 10;
21 31;
12 35;
76 1;
42 32;
23 24;
56 11;
35 12;
56 15;
65 64;
45 24;
65 23;
46 26;
75 82;
64 39;
58 52;
48 39; 
45 49;
13 23]

# ╔═╡ 1c0844ba-5451-4fd8-921b-0f82ecb7e4ff
md" ######  The partial Totoro example"

# ╔═╡ 0056b890-3ff8-47aa-92a0-58b89c7e2078
some_totoro_coords = [484 800;
441 796;
485 794;
480 793;
522 791;
465 789;
419 787;
406 785;
474 785;
520 785;
540 784;
466 783;
519 782;
429 781;
464 781;
459 780;
480 779;
462 777;
583 774;
426 771;
456 771;
394 770;
579 770;
384 768;
511 768;
601 768;
464 767;
446 766;
493 766;
509 766;
571 766;
609 765;
587 764;
589 764;
410 763;
521 763;
575 763;
464 761;
580 761;
543 760;
594 760;
530 759;
414 758;
448 757;
430 756;
617 756;
626 756;
497 755;
507 755;
410 754;
497 754;
504 754;
506 754;
507 754;
533 754;
566 754;
437 753;
543 752;
563 752;
601 752;
610 752;
454 751;
513 750;
559 750;
566 750;
603 750;
465 748;
546 748;
413 747;
488 747;
491 747;
583 747;
500 746;
401 745;
528 745;
646 744;
454 743;
600 743;
444 742;
631 742;
486 739;
532 739;
490 738;
494 738;
546 738;
652 738;
545 737;
600 737;
437 736;
440 736;
631 736;
433 735;
508 735;
583 734;
613 734;
490 733;
562 733;
443 732;
503 731;
666 731;
168 102;
183 102;
369 102;
229 101;
334 101;
111 100;
231 100;
353 100;
162 98;
262 98;
104 96;
273 96;
352 96;
260 94;
267 94;
308 94;
225 93;
117 91;
153 91;
253 91;
298 91;
344 91;
135 90;
159 90;
149 87;
317 87;
90 85;
217 85;
286 85;
99 84;
201 83;
259 83;
299 83;
322 82;
239 81;
257 81;
265 81;
159 79]

# ╔═╡ 57baf53e-9bb1-4cf3-bae2-3ac5588a6d11
md"""
#### "Partial" Totoro example
"""

# ╔═╡ 7bfda195-e39a-49c9-bbab-3eecd682eb48
ktoto = 4 # 4 loops

# ╔═╡ ad027e48-419b-4aac-af3a-5e6d4acf7e94
md" ##### Taken from STMO tsp.jl"

# ╔═╡ 017fd37b-e872-405c-8ab2-a713cecb9a8d
totoro_coords=[484 800;
441 796;
485 794;
480 793;
522 791;
465 789;
419 787;
406 785;
474 785;
520 785;
540 784;
466 783;
519 782;
429 781;
464 781;
459 780;
480 779;
462 777;
583 774;
426 771;
456 771;
394 770;
579 770;
384 768;
511 768;
601 768;
464 767;
446 766;
493 766;
509 766;
571 766;
609 765;
587 764;
589 764;
410 763;
521 763;
575 763;
464 761;
580 761;
543 760;
594 760;
530 759;
414 758;
448 757;
430 756;
617 756;
626 756;
497 755;
507 755;
410 754;
497 754;
504 754;
506 754;
507 754;
533 754;
566 754;
437 753;
543 752;
563 752;
601 752;
610 752;
454 751;
513 750;
559 750;
566 750;
603 750;
465 748;
546 748;
413 747;
488 747;
491 747;
583 747;
500 746;
401 745;
528 745;
646 744;
454 743;
600 743;
444 742;
631 742;
486 739;
532 739;
490 738;
494 738;
546 738;
652 738;
545 737;
600 737;
437 736;
440 736;
631 736;
433 735;
508 735;
583 734;
613 734;
490 733;
562 733;
443 732;
503 731;
666 731;
566 730;
629 730;
451 728;
437 727;
567 727;
618 727;
541 726;
671 726;
454 725;
553 725;
600 725;
449 724;
477 724;
556 724;
574 724;
474 723;
499 723;
584 723;
584 722;
672 722;
588 721;
470 720;
471 720;
510 719;
523 719;
562 719;
665 717;
671 717;
520 716;
580 716;
620 715;
626 715;
667 715;
683 715;
585 714;
567 713;
497 712;
554 712;
559 712;
544 711;
549 711;
622 709;
674 709;
644 708;
595 707;
620 707;
519 706;
542 706;
603 706;
653 705;
593 703;
533 701;
547 701;
528 700;
518 699;
625 699;
609 697;
638 697;
696 697;
509 695;
604 695;
636 694;
666 694;
684 694;
526 693;
565 693;
619 693;
634 693;
669 692;
658 691;
677 690;
697 690;
570 688;
576 688;
607 688;
649 687;
678 687;
694 685;
534 684;
567 683;
671 683;
622 682;
665 682;
671 682;
682 682;
631 681;
573 680;
681 679;
650 675;
577 674;
593 673;
631 672;
602 670;
533 669;
619 669;
645 667;
620 665;
691 665;
659 662;
530 660;
701 659;
705 658;
664 657;
327 654;
331 648;
170 639;
328 639;
155 636;
158 636;
328 634;
181 632;
336 632;
519 630;
346 628;
174 627;
331 627;
149 626;
324 626;
178 625;
327 625;
334 625;
307 624;
167 622;
309 620;
185 618;
180 615;
154 614;
171 611;
319 609;
192 607;
325 607;
142 606;
145 606;
302 606;
335 606;
310 605;
178 601;
187 601;
345 600;
180 598;
146 597;
174 597;
180 597;
297 594;
152 591;
295 591;
330 591;
188 590;
330 590;
505 588;
318 587;
502 587;
157 584;
168 579;
159 577;
163 574;
312 574;
332 573;
187 572;
307 572;
151 571;
324 570;
142 569;
151 569;
180 568;
184 568;
180 566;
190 566;
176 565;
324 565;
188 563;
145 560;
157 560;
186 560;
192 560;
227 560;
182 559;
192 559;
300 559;
308 559;
159 558;
226 558;
266 558;
175 557;
206 557;
237 557;
159 555;
280 554;
159 553;
187 551;
240 551;
278 551;
311 551;
226 550;
490 550;
251 549;
273 549;
159 547;
165 547;
180 547;
188 546;
245 546;
310 546;
206 544;
236 544;
271 544;
159 542;
217 542;
161 541;
178 541;
192 541;
229 540;
273 540;
293 540;
307 540;
157 539;
239 538;
261 538;
296 537;
297 537;
287 534;
485 534;
173 533;
203 532;
227 532;
321 532;
248 531;
216 529;
245 529;
286 529;
154 527;
197 527;
477 527;
314 526;
136 523;
218 523;
282 523;
288 523;
472 522;
312 521;
248 519;
256 519;
194 518;
217 518;
221 518;
160 517;
206 517;
240 516;
162 514;
245 514;
209 513;
236 513;
237 513;
143 512;
131 511;
135 511;
153 510;
491 510;
454 509;
242 508;
284 508;
142 507;
249 507;
331 506;
340 506;
271 505;
293 505;
347 505;
466 505;
121 504;
332 504;
346 504;
213 503;
486 503;
277 501;
489 501;
487 500;
200 499;
240 498;
275 498;
489 498;
438 497;
45 496;
141 496;
280 496;
121 495;
344 495;
352 495;
135 494;
145 493;
294 493;
458 493;
64 492;
346 492;
255 491;
429 491;
481 491;
90 490;
121 489;
171 489;
335 489;
421 489;
486 488;
218 487;
442 487;
150 486;
422 486;
488 486;
256 485;
337 484;
106 483;
216 483;
123 482;
139 482;
186 482;
413 482;
478 482;
110 481;
112 481;
254 480;
352 480;
183 479;
304 479;
467 479;
217 478;
428 478;
272 477;
209 476;
218 476;
324 476;
227 475;
236 475;
336 475;
355 475;
266 474;
297 474;
222 473;
225 473;
248 473;
253 473;
281 473;
439 473;
102 472;
149 472;
236 472;
284 472;
310 472;
494 472;
405 471;
207 470;
470 470;
36 469;
54 469;
84 469;
102 469;
103 469;
126 469;
166 469;
213 469;
313 469;
466 469;
476 469;
124 468;
185 468;
273 468;
363 468;
270 467;
108 465;
285 465;
359 465;
488 465;
233 464;
252 464;
270 464;
432 464;
279 463;
313 463;
104 462;
175 462;
201 462;
212 462;
391 462;
474 462;
396 461;
146 460;
148 460;
397 460;
332 459;
364 459;
101 458;
370 458;
342 457;
369 453;
439 453;
109 452;
402 452;
438 451;
471 451;
478 451;
371 450;
365 449;
477 449;
479 449;
353 447;
381 447;
395 447;
27 446;
32 445;
129 445;
373 445;
154 443;
380 443;
93 442;
130 441;
94 440;
424 439;
335 438;
97 437;
180 437;
354 437;
128 436;
367 436;
145 435;
148 435;
366 434;
380 434;
428 434;
173 433;
87 432;
117 432;
440 432;
163 431;
191 431;
406 431;
209 430;
315 430;
292 429;
126 428;
363 428;
467 428;
301 427;
361 427;
274 426;
246 425;
324 425;
329 425;
445 425;
123 422;
452 422;
164 421;
384 421;
439 421;
263 420;
291 420;
329 420;
368 420;
73 419;
310 419;
154 418;
369 418;
376 418;
434 418;
360 417;
456 417;
288 416;
440 416;
373 415;
438 415;
174 414;
254 414;
331 414;
338 414;
347 414;
63 413;
246 412;
384 412;
65 411;
395 411;
128 410;
373 410;
387 410;
80 409;
340 409;
91 408;
80 407;
82 407;
367 407;
394 406;
431 406;
444 406;
61 405;
382 405;
123 403;
320 403;
326 403;
103 402;
81 401;
58 400;
149 400;
376 399;
115 398;
380 398;
332 397;
359 397;
99 396;
361 396;
449 396;
115 395;
122 395;
400 395;
451 395;
138 394;
116 393;
377 392;
382 392;
423 392;
82 391;
52 389;
90 389;
133 389;
413 387;
61 385;
360 385;
106 384;
357 384;
55 383;
78 382;
379 382;
385 382;
60 380;
121 380;
390 380;
391 380;
67 379;
379 378;
76 377;
99 376;
405 376;
406 376;
386 375;
99 373;
231 373;
387 373;
59 372;
427 372;
427 371;
95 370;
100 370;
403 369;
439 369;
370 368;
401 368;
245 367;
378 366;
61 364;
104 364;
215 363;
46 362;
90 362;
416 362;
422 360;
382 359;
414 359;
41 358;
28 357;
386 357;
424 357;
64 356;
426 356;
428 356;
39 354;
42 354;
59 354;
155 353;
300 353;
396 353;
430 353;
72 352;
298 352;
327 351;
139 350;
422 350;
95 349;
62 348;
41 347;
44 346;
137 344;
76 342;
57 341;
59 341;
67 341;
350 341;
388 341;
405 341;
101 339;
400 336;
46 333;
89 332;
45 331;
98 331;
395 331;
407 330;
60 329;
63 328;
269 326;
40 325;
50 324;
86 324;
262 320;
32 319;
32 318;
75 317;
290 317;
291 316;
191 315;
353 315;
99 314;
252 313;
81 311;
259 311;
71 310;
75 310;
372 310;
96 309;
288 309;
44 308;
359 308;
338 307;
355 305;
21 303;
40 303;
57 303;
25 302;
111 302;
112 302;
346 302;
105 301;
129 301;
53 300;
31 299;
103 299;
173 299;
112 298;
114 298;
126 298;
97 297;
114 297;
5 296;
59 295;
56 294;
97 294;
133 294;
6 293;
70 293;
118 292;
129 292;
135 292;
410 292;
384 291;
11 287;
58 287;
59 287;
66 287;
93 287;
19 285;
56 282;
60 282;
74 279;
415 277;
82 276;
52 274;
28 269;
72 268;
27 267;
52 267;
77 266;
63 265;
41 264;
21 263;
410 259;
18 257;
3 255;
415 255;
1 249;
37 248;
47 248;
417 247;
47 243;
24 242;
87 241;
18 240;
36 240;
72 235;
33 233;
40 233;
55 233;
8 232;
11 228;
36 228;
88 228;
49 225;
83 223;
31 220;
412 220;
29 218;
91 217;
84 212;
80 208;
84 208;
36 206;
22 205;
68 204;
78 204;
20 203;
32 201;
42 201;
62 201;
77 201;
50 199;
92 199;
78 198;
39 196;
406 196;
48 191;
46 189;
32 188;
60 187;
82 187;
26 186;
49 186;
61 186;
56 183;
31 182;
31 180;
45 177;
35 175;
393 175;
104 173;
68 172;
40 171;
405 170;
407 170;
79 169;
82 169;
38 165;
50 164;
39 161;
108 160;
57 159;
132 158;
47 156;
87 154;
101 154;
55 152;
81 152;
122 150;
125 150;
94 147;
125 147;
55 146;
58 145;
67 145;
372 142;
78 141;
149 141;
368 140;
121 137;
149 137;
366 137;
102 136;
143 136;
90 135;
99 134;
136 134;
142 133;
67 132;
149 131;
169 130;
390 130;
82 129;
160 129;
383 127;
104 126;
118 125;
99 123;
360 123;
146 120;
97 119;
112 118;
361 117;
376 117;
96 116;
61 115;
185 115;
69 114;
135 114;
150 112;
371 112;
117 110;
62 109;
165 109;
203 107;
366 107;
93 106;
190 106;
215 105;
341 105;
354 105;
326 104;
132 103;
146 103;
345 103;
115 102;
168 102;
183 102;
369 102;
229 101;
334 101;
111 100;
231 100;
353 100;
162 98;
262 98;
104 96;
273 96;
352 96;
260 94;
267 94;
308 94;
225 93;
117 91;
153 91;
253 91;
298 91;
344 91;
135 90;
159 90;
149 87;
317 87;
90 85;
217 85;
286 85;
99 84;
201 83;
259 83;
299 83;
322 82;
239 81;
257 81;
265 81;
159 79;
281 79;
140 78;
163 78;
170 77;
99 75;
140 75;
212 75;
295 75;
202 74;
317 74;
162 73;
167 73;
140 72;
161 72;
203 72;
311 71;
203 70;
293 70;
185 68;
266 68;
132 67;
195 67;
239 66;
263 65;
292 65;
311 65;
311 64;
296 62;
124 61;
312 61;
154 58;
149 57;
281 57;
307 57;
179 56;
223 55;
309 55;
278 54;
133 50;
294 50;
191 49;
246 49;
265 49;
283 46;
147 45;
260 45;
189 44;
254 43;
268 43;
285 42;
184 40;
164 39;
182 36;
167 35;
199 34;
258 34;
165 33;
256 33;
167 32;
202 31;
172 30;
225 30;
264 30;
269 29;
274 29;
280 27;
166 25;
175 25;
147 22;
252 22;
168 20;
283 17;
274 15;
270 12]


# ╔═╡ cdc1c7d3-c230-4a39-80b6-fdea2d6fb66f
begin
	myblue = "#304da5"
	mygreen = "#2a9d8f"
	myyellow = "#e9c46a"
	myorange = "#f4a261"
	myred = "#e76f51"
	myblack = "#50514F"

	mycolors = [myblue, myred, mygreen, myorange, myyellow]
end;

# ╔═╡ f565bbd4-9046-4870-9c41-f86a08ca14e1
begin
	struct TravelingSalesmanProblem{Tc}
	    coordinates::Matrix{Tc}
	    distance::Matrix{Float64}
	end
	
	TravelingSalesmanProblem(coordinates) = TravelingSalesmanProblem(coordinates,
	                                dist(coordinates, coordinates))
	
	"""Returns the number of cities."""
	Base.length(tsp::TravelingSalesmanProblem) = size(tsp.coordinates, 1)
	
	"""Returns the coordinates of the cities."""
	coordinates(tsp::TravelingSalesmanProblem) = tsp.coordinates
	
	"""Returns the cities"""
	cities(tsp::TravelingSalesmanProblem) = collect(1:length(tsp))
	
	"""Returns the distance matrix of the cities."""
	dist(tsp::TravelingSalesmanProblem) = tsp.distance
	
	"""Returns the distance (or cost) of going from city `ci` to city `cj`"""
	dist(tsp::TravelingSalesmanProblem, ci, cj) = dist(tsp)[ci,cj]
	
	Base.isvalid(tsp::TravelingSalesmanProblem, tour) = length(tour) == length(tsp) &&
	    Set(tour) == Set(cities(tsp))
	
	"""
	    computecost(tsp::TravelingSalesmanProblem, tour)
	
	Computes the cost of travessing a tour.
	"""
	function computecost(tsp::TravelingSalesmanProblem, tour)
	    !isvalid(tsp, tour) && throw(AssertionError("invalid tour provided"))
	    c = 0.0
	    for (i, j) in zip(tour[1:end-1], tour[2:end])
	        c += dist(tsp, i, j)
	    end
	    # complete tour
	    c += dist(tsp, tour[end], tour[1])
	    return c
	end
	
	split_coord(X) = X[:,1], X[:,2]
	
	plot_cities(tsp::TravelingSalesmanProblem; kwargs...) = scatter(split_coord(coordinates(tsp))...,
	                color=myblue, markersize=1, label="", aspect_ratio=:equal; kwargs...)
	
	plot_cities!(tsp::TravelingSalesmanProblem; kwargs...) = scatter!(split_coord(coordinates(tsp))...,
	                color=myblue, markersize=1, label=""; kwargs...)
	
	coords_tour(tsp, tour) = [coordinates(tsp)[tour,:];coordinates(tsp)[[tour[1]],:]]
	
	plot_tour(tsp::TravelingSalesmanProblem, tour; kwargs...) = plot(
	                split_coord(coords_tour(tsp, tour))...,
	                color=myred, label="", aspect_ratio=:equal; kwargs...)
	
	plot_tour!(tsp::TravelingSalesmanProblem, tour; kwargs...) = plot!(
	                split_coord(coords_tour(tsp, tour))...,
	                color=myred, label=""; kwargs...)
	
	
	"""
	    deltaswapcost(tsp, tour, i, j)
	
	Compute the change in tour cost if the cities at positions `i` and `j` are
	swapped.
	"""
	function deltaswapcost(tsp, tour, i, j)
	    n = length(tsp)
	    i == j && return 0.0
	    # put in order
	    i, j = i < j ? (i, j) : (j, i)
	    # choose indices respecting cyclic  invariance
	    i₋₁ = i == 1 ? n : i - 1
	    i₊₁ = i == n ? 1 : i + 1
	    j₋₁ = j == 1 ? n : j - 1
	    j₊₁ = j == n ? 1 : j + 1
	    ci₋₁, ci, ci₊₁, cj₋₁, cj, cj₊₁ = tour[[i₋₁, i, i₊₁, j₋₁, j, j₊₁]]
	    if j - i == 1  # i and j are neighbors
	        Δc = ((dist(tsp, ci₋₁, cj) + dist(tsp, ci, cj₊₁)) -
	                    (dist(tsp, ci₋₁, ci) + dist(tsp, cj, cj₊₁)))
	    elseif (i==1 && j==n)
	        Δc = ((dist(tsp, tour[end-1], tour[1]) + dist(tsp, tour[end], tour[2])) -
	                    (dist(tsp, tour[end-1], tour[end]) + dist(tsp, tour[1], tour[2])))
	    else
	        Δc = ((dist(tsp, ci₋₁, cj) + dist(tsp, cj, ci₊₁) +
	                    dist(tsp, cj₋₁, ci) + dist(tsp, ci, cj₊₁)) -
	                    (dist(tsp, ci₋₁, ci) + dist(tsp, ci, ci₊₁) +
	                    dist(tsp, cj₋₁, cj) + dist(tsp, cj, cj₊₁)))
	    end
	    return Δc
	end
	
	"""
	    swap!(tour, i, j)
	
	Swaps the cities at positions `i` and `j` in `tour`.
	"""
	function swap!(tour, i, j)
	    tour[i], tour[j] = tour[j], tour[i]
	    return tour
	end
	
	"""
	    deltaflipcost(tsp, tour, i, j)
	
	Compute the change in tour cost if the subtour between the `i`th and `j`th city
	are flipped.
	"""
	function deltaflipcost(tsp, tour, i, j)
	    i == j && return 0.0
	    n = length(tsp)
	    # put in order
	    i, j = i < j ? (i, j) : (j, i)
	    (i, j) == (1, n) && return 0.0
	    # choose indices respecting cyclic  invariance
	    i₋₁ = i == 1 ? n : i - 1
	    i₊₁ = i == n ? 1 : i + 1
	    j₋₁ = j == 1 ? n : j - 1
	    j₊₁ = j == n ? 1 : j + 1
	    ci₋₁, ci, ci₊₁, cj₋₁, cj, cj₊₁ = tour[[i₋₁, i, i₊₁, j₋₁, j, j₊₁]]
	    Δc = - (dist(tsp, ci₋₁, ci) + dist(tsp, cj, cj₊₁))
	    Δc += dist(tsp, ci₋₁, cj) + dist(tsp, ci, cj₊₁)
	    return Δc
	end
	
	function flip!(tour, i, j)
	    i, j = i < j ? (i, j) : (j, i)
	    reverse!(@view tour[i:j])
	    return tour
	end
	"""
	Compute Euclidean distance between two vectors.
	"""
	dist(x::AbstractVector, y::AbstractVector) = sqrt(sum((x .- y).^2))
	"""
	Compute Euclidean distance matrix between two matrices.
	"""
	dist(X::AbstractMatrix, Y::AbstractMatrix) = [dist(X[i,:], Y[j,:]) for i in 1:size(X,1), j in 1:size(Y,1)]
	"""
	Compute Euclidean distance matrix.
	"""
	dist(X::AbstractMatrix) = dist(X::AbstractMatrix, X::AbstractMatrix)	
end;

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
	n = Int64(size(dists,2)) 		# n = the number of cities 
	num_ants = Int64(length(ants))  # num_ants = the number of ants
	for a in missing # for each of i ants

		missing 	 # build a new trail (hint: use provided functino)
		missing 	 # update kth ant in `ants` 
	end
end

# ╔═╡ 306cd489-470c-45c5-bace-1624512087ab
"""
	trailsum(trail, dists) 

Calculates the sum of the entire path taken by the ant.  

Inputs:

	- trail: a solution (completed path)
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- result: sum of trail from begin to end 
"""
function trailsum(trail, dists) 

	result = 0.0 #init result
	
	# cumulative sum of trail segments
	for  i in 1:(length(trail)-1)  
		result += distance(trail[i], trail[i+1], dists)        
	end
	return result
end

# ╔═╡ c40fe82a-2dee-44d4-b768-25ff50ce746c
"""
	nextcity(k, city_x, visited, pheromones, dists)

Selects the next city to visit in the trail based on drawing randomly from the probability distribution created from the pheromone matrix

Inputs:

	- k: an index
	- city_x: a city 
	- visited: boolean indicating whether city has been visited in the given trail
	- pheromones: pheromone value matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- a city to visit next in the trail
"""
function nextcity(k::Int, city_x::Int, visited, pheromones, dists, α::Real=3, β::Real=2)
	n = Int64(size(dists,2)) #n = number of cities 

	#get probabilities using getprobs function
	probs = getprobs(k::Int, city_x::Int, visited, pheromones, dists, n::Int)
	
	cumul = zeros(length(probs)+1) #init cumulative probability array 
	
	#fill values in cumul 
	for i in 1:length(probs)
		cumul[i+1] = cumul[i] + probs[i] 
	end

	#enforce that cumulative probabilty is 1 (in case of small rounding errors)
	cumul[length(cumul)] = 1.0

	# "roulette" selection
	p = rand() #pick a random number p between 0 and 1 
		if p == 0.0 #in the slight chance we get 0... 
			p += rand()     #... pick again
		end

	for i in 1:(length(cumul)-1)
    	if p >= cumul[i] && p < cumul[i + 1] #find the interval p is in
      		return i #return the index of the city the ant visits next 
		end
	end
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
	#init an empty trail and a boolean vector of equal length
	trail = zeros(Int64, n+1)
	visited = falses(n+1)

	trail[1] = start  	  # the first element in 'trail' is the start city
	visited[start] = true # set the corresponding index in 'visited' to true
	trail[n+1] = start    # just a placeholder

	#look at each city in the trail and set the corresponding index in 'visited' as true
	for i in 1:(n-1)
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
	n = Int64(size(dists,2)) # n = the number of cities 
	num_ants = Int64(length(ants))  # a = the number of ants
	for a in 1:num_ants      #for each ant, build a new trail
		newtrail = buildtrail(a, start, pheromones, dists, n)
		ants[a] = newtrail   
	end
end

# ╔═╡ 97cf8701-7622-4537-8091-1a38acefa9dd
"""
	getidx(trail, target)

A helper function for randomtrail; returns the index of a 'target' city in a trail

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
	chrono_trail = 1:(n) |> collect # build a trail 
	
	trail = shuffle(chrono_trail) # randomly shuffle the trail

	#Modify the trail so that the 1st city in the trail is the start city 
	idx = getidx(trail, start) 
	temp = trail[1]  
	trail[1] = trail[idx] #swap the start city with the 
	trail[idx] = temp 
	append!(trail,start) #the start city is also the end city
	
	return trail
end

# ╔═╡ e45b3588-f8a7-439a-ac97-bafb9253f6a3
"""
	initants(start, a, n)

Returns an array of random ant paths (random solutions)

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants that will traverse the parameter space

Outputs:

	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
"""
function initants(start::Int, a::Int, n::Int)
	
	ants = [] # init array that will hold trail arrays 
	
	for k in 1:a # for each ant, make a random trail
		t = randomtrail(start, n)	
		push!(ants,t) # save the kth ant's trail in ants
	end
  
  return ants
		
end

# ╔═╡ edf145a2-ae6f-4e01-beb1-5be1d5c1250d
"""
	best_trail(ants, dists)

Calculates the best trail in ants array and returns its index. 

Inputs:

	- ants: an array of of ants, where each ant is a solution array
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:

	- the index of the best ant (solution) in the ants array 
"""
function best_trail(ants, dists)
	
	#set 1st ant trail as best 
	best_l = trailsum(ants[1], dists)
	idxbest = 1
	n = size(dists,2) 
	
	#check the rest of the trails and compare to find the best 
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

Initializes start city `start`, distance matrix `dists`, ant (solutions) `ants`, the solution `best_ant`, and its value/length `trail_value`. 

Inputs:

	- citycoords: an nx2 matrix providing the x,y coordinates for the n cities in the graph
	- a: an integer determing the number of ants that travel the graph	

Outputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
	- best_ant: the best solution `ants`  
	- trail_value: the total length of best_ant
"""
function init_aco(citycoords, a::Int=4)
	n = Int64(size(citycoords,1)) 
	start = Int64(rand(1:n))
	dists = dist(citycoords,citycoords)
	ants = initants(start, a, n)	
	
	best_ant = best_trail(ants, dists)	
    trail_value = trailsum(best_ant, dists)		

    pheromones = initpheromones(n)		
	
	return start, dists, ants, best_ant, trail_value, pheromones, n, a
end

# ╔═╡ 47c98bd7-f84d-455d-a417-5ffc93fa6fdd
colony4, dists4, ants4, bestroute4, routelength4, pheromones4, n4, a4 = init_aco(coords4)

# ╔═╡ 81dc269f-5145-4e9f-80e3-86c70879e462
bestroute4

# ╔═╡ a14949b9-77b2-4f32-89f7-d2316736e803
#run initialization here (optionally specify the number of ants)
colony25, dists25, ants25, bestroute25, routelength25, pheromones25, n25, a25 = init_aco(coords25, 20) 

# ╔═╡ 2c6733ca-c300-4bc3-9d31-103d7b2cbd6c
md"""
Use sliders to select `k`, the number of times an ant walks the graph, and `a`, number of ants in the colony.

k:
$(@bind k Slider(1:1:k25,default=4,show_value=true))

a:
$(@bind a Slider(1:1:a25,default=10,show_value=true))

The plot below will display the solutions for the *i*th ant. Select the *i*th ant using the slider:

$(@bind kth_ant Slider(1:1:a,default=1,show_value=true))
"""

# ╔═╡ 0f903495-cfbf-4ce2-9851-a49aba684e6a
#Beware, may take several seconds
starttoto, diststoto, antstoto, best_tourtoto, tour_lengthtoto, pheromonestoto, ntoto, atoto = init_aco(some_totoro_coords, 10) 

# ╔═╡ dcf0c148-2f9a-4083-9739-89a891574eda
begin
	acycletotoro = randomtrail(starttoto, ntoto)
	atourtotoro = acycletotoro[1:ntoto]
	acosttotoro = round(trailsum(acycletotoro, diststoto), digits = 3)
end

# ╔═╡ e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
"""
	is_edge(city_x city_y, trail)

Checks if `city_x` and `city_y` are adjacent to each other in `trail`, signifying that an ant travels directly between the two cities, traversing edge (i.j) 

Inputs:

	- city_x: a city/location 
	- city_y: a city/location
	- trail: a solution 

Outputs:

	- a boolean value (true if city_x and city_y are adjacent in `trail`)
"""
function is_edge(city_x::Int, city_y::Int, trail)
	
	lastIndex = length(trail)  
	
    idx = getidx(trail, city_x) #get index of city_x in trail

    #if X = 1st in trail, see if it's next to 2nd or last in trail
	if idx == 1 && trail[2] == city_y # if (X, Y, ...)
    	return true 
           
	elseif idx == 1 && trail[lastIndex] == city_y #if (X, ..., Y)
    	return true 
    
	elseif idx == 1 #if X = 1st, and Y is not 2nd or last, there's no edge
    	return false 
	end
	
	#if X is last in trail, see if Y is 2nd-to-last or 1st
	if idx == lastIndex && trail[lastIndex-1] == city_y # if (.... Y, X)
		return true
	
	elseif idx == lastIndex && trail[1] == city_y # if (Y,...., X)
		return true
	
	elseif idx == lastIndex #if X is last and Y isnt 1st or, 2nd-to-last, no edge
		return false

	#if X is not 1st or last in list, just check left and right of it
	elseif trail[idx - 1] == city_y # if (...Y,X,...)
		return true 

	elseif trail[idx + 1] == city_y # if (...X,Y,...)
   		return true 

	else
		return false # if Y isn't directly left or right of X, there's no edge
	
	end
end 

# ╔═╡ 888991d5-b77a-4ca8-a885-2ac10b028a72
"""
	updatepheromones(k, start, pheromones, dists, ρ)

Updates pheromone entry for any edge (i,j) in a pheromone matrix  

Inputs:

	- pheromones: the pheromone matrix 
	- ants: an array of of ants, where each ant is a solution array
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ρ: pheromone evaporation rate 
	- q: pheromone increase parameter (arbitrary)


Outputs:

	- updated pheromone matrix 
"""
function updatepheromones_exercise(pheromones, ants, dists, ρ::Real=0.01, q::Real=2.0)
	# initialize variables
	pher_rows = size(pheromones,1)
	pher_cols = size(pheromones,2)
	num_ants = length(ants)
	
	for i in 1:pher_rows
		for j in 1:pher_cols    
			for k in 1:num_ants    
				missing  		       # compute length of Kth ant trail
           		decrease = missing     # decrease factor = (1-ρ) * τ_{i,j}  

				increase = 0.0 		   # init increase factor 
				
	# increase factor for (i,j) only need be calculated if ant travels on it, so
				# check for edge (i,j) in the ant's path
				if is_edge(i, j, ants[k]) == true 
					increase = missing # increase factor  = q / Kth ant trail length 
				end
    
				pheromones[i,j] = missing # update the pheromone value 
 
                pheromones[j,i] = missing  # maintain matrix symmetry
				
				# bound pheromone value between 1e-5 and 1e5
				pheromones .= clamp.(pheromones,1e-5,1e5)
			end 
		end 
	end
end 

# ╔═╡ a2aba49e-809f-4cdd-9bd5-d10b854a6628
"""
	updatepheromones(k, start, pheromones, dists, ρ)

Updates pheromone entry for any edge (i,j) in a pheromone matrix  

Inputs:

	- pheromones: the pheromone matrix 
	- ants: an array of of ants, where each ant is a solution array
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ρ: pheromone evaporation rate 
	- q: pheromone increase parameter (arbitrary)


Outputs:

	- updated pheromone matrix 
"""
function updatepheromones(pheromones, ants, dists, ρ::Real=0.01, q::Real=2.0)
	pher_rows = size(pheromones,1)
	pher_cols = size(pheromones,2)  
	num_ants = length(ants)
	
	for i in 1:pher_rows
		for j in 1:pher_cols
			for k in 1:num_ants
				trail_length = trailsum(ants[k], dists) #length of ant K trail
           		decrease = (1.0-ρ) * pheromones[i,j] # pher decrease factor 
           		
				increase = 0.0 # init increase factor

				#computing increase on edge (i,j) only needed if ant walks over (i,j)
				if is_edge(i, j, ants[k]) == true
					increase = q / trail_length # compute increase factor 
				end
    
				pheromones[i,j] = decrease + increase # update the pheromone value 

				pheromones[j,i] = pheromones[i,j] # maintain matrix symmetry
				
				# bound pheromone value between 1e-5 and 1e5
				pheromones.=clamp.(pheromones,1e-5,1e5)
			end
		end
	end 
end 

# ╔═╡ e05ce658-cbaf-4ac2-a426-c9741fbc37d2
"""
	aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

Runs ACO k times and returns the shortest path and its length. 

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: array of solution "ant" arrays
	- best_ant: best trail in ants
	- trail_value: length of best_ant
	- pheromones: pheromone matrix 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants 
	- k: number of times the while loop iterates

Outputs:

	- best_ant: updated best trail
	- trail_value: length of best_ant
"""
function aco(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

    i = 1
    currbest_ant = zeros(Int64, n+1)
	currtrail_value = 0

	while i < k  # until we loop k times
		updateants(ants, pheromones, dists, start)	# update ant solutions
		updatepheromones(pheromones, ants, dists)   # update pheromone matrix 

		currbest_ant = best_trail(ants, dists)		# find the best 'ant' (trail)
		currtrail_value = trailsum(currbest_ant, dists) #calculate best trail sum

		if currtrail_value< trail_value # check if best ant from this pass beats 													previous best 
			trail_value = currtrail_value # if so, update best trail length
			best_ant = currbest_ant              #and best ant 
		end

		i += 1		
	
	end 
	
	return trail_value, best_ant
end

# ╔═╡ d0e27503-80c1-4dd7-aacd-fda306414005
tour_length4, best_tour4 = aco(colony4, dists4, ants4, bestroute4, routelength4, pheromones4, n4, a4, k4)

# ╔═╡ cfc9018b-784a-48f3-912d-09a88db3216a
begin
	acycle4= [3,4,1,2,3]
	atour4 = acycle4[1:n4]
	tour4 = best_tour4[1:n4]
	acost4 = round(trailsum(acycle4, dists4), digits = 3)
end

# ╔═╡ 07f1ae73-ef20-4be4-81a2-99c7e9651e02
#run aco here
tour_length25, best_tour25 = aco(colony25, dists25, ants25, bestroute25, routelength25, pheromones25, n25, a25, k25)

# ╔═╡ 9f55aa64-cbcf-4148-91b1-e8d5f7df299f
begin
	acycle25 = randomtrail(colony25, n25)
	atour25 = acycle25[1:n25]
	tour25 = best_tour25[1:n25]
	acost25 = round(trailsum(acycle25, dists25), digits = 3)
end

# ╔═╡ 679c1c38-f926-4492-ada5-aafa5af25fd2
#Beware: may take several minutes
tour_lengthTotoro, best_tourTotoro = aco(starttoto, diststoto, antstoto, best_tourtoto, tour_lengthtoto, pheromonestoto, ntoto, atoto, ktoto) 

# ╔═╡ abbf326e-4617-483c-b956-33db2b666fbc
"""
	aco_savetheants(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

Identical to `aco` function except it also returns all solution arrays for all ants in all iterations. 

Inputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: array of solution "ant" arrays
	- best_ant: best trail in ants
	- trail_value: length of best_ant
	- pheromones: pheromone matrix 
	- n: number of cities the ants must visit (including the origin city)
	- a: number of ants 
	- k: number of times the while loop iterates

Outputs:

	- best_ant: updated best trail
	- trail_value: length of best_ant
"""
function aco_savetheants(start, dists, ants, best_ant, trail_value, pheromones, n, a, k::Int=10)

    i = 1
    currbest_ant = zeros(Int64, n+1)
	currtrail_value = 0
	all_ants = []
	append!(all_ants,ants) 
	while i < k  # until we loop k times
		updateants(ants, pheromones, dists, start)	# update ant solutions
		append!(all_ants,ants) 
		updatepheromones(pheromones, ants, dists)   # update pheromone matrix 

		currbest_ant = best_trail(ants, dists)		# find the best 'ant' (trail)
		currtrail_value = trailsum(currbest_ant, dists) #calculate best trail sum

		if currtrail_value< trail_value # check if best ant from this pass beats 													previous best 
			trail_value = currtrail_value # if so, update best trail length
			best_ant = currbest_ant              #and best ant 
		end

		i += 1		
	
	end 
	
	return all_ants, best_ant, trail_value
end

# ╔═╡ 5d929be0-d406-440a-bd0f-2bfe5d26c94a
all_ants_custom, best_ant_c, trail_c = aco_savetheants(colony25, dists25, ants25, bestroute25, routelength25, pheromones25, n25, a, k)

# ╔═╡ 554154af-0a61-4b4f-b363-bc856bfc32f4
tsp4 = TravelingSalesmanProblem(coords4)

# ╔═╡ e53c2dd6-4eb3-4a34-a35f-2a4f5b6185b6
begin
	plot_tour(tsp4, atour4)
	plot_cities!(tsp4)
	title!("A random tour with a route length of $acost4")
end

# ╔═╡ e7a3cd0f-0532-4cfa-9b13-f60f5b51fab8
begin
	tourlen4 = round(tour_length4, digits = 3)
	plot_tour(tsp4, tour4)
	plot_cities!(tsp4)
	title!(" ACO: $a4 ants make $k4 tours, shortest route: $tourlen4")
end

# ╔═╡ 195eb6d1-1d67-4c08-bdb7-a27dbe5d6d84
tsp25 = TravelingSalesmanProblem(coords25)

# ╔═╡ 89ad5ab5-8676-45d7-9506-7321a5cd8e44
begin
	plot_tour(tsp25, atour25)
	plot_cities!(tsp25)
	title!("A random tour with a route length of $acost25")
end

# ╔═╡ a4741762-a76d-4626-8acd-26ac22e9d6cd
begin
	tourlen25 = round(tour_length25, digits = 3)
	plot_tour(tsp25, tour25)
	plot_cities!(tsp25)
	title!(" ACO: $a25 ants make $k25 tours, shortest route: $tourlen25")
end

# ╔═╡ 01a5011f-f6ae-4a13-8641-7b213487d65d
begin
	tournum = 1
	num_solutions = k*a
	animation1 = @animate for i in range(kth_ant,num_solutions, step = a) 
		plot_tour(tsp25, all_ants_custom[i][1:25])
		title!("Ant number $kth_ant's trip number #$tournum")
		tournum +=1
	end
	gif(animation1, fps=2)
end

# ╔═╡ 7b1506d2-02e3-4a13-a277-9ec99bbad91c
begin
	tourcost = round(trail_c, digits = 3)
	plot_tour(tsp25, best_ant_c[1:25])
	plot_cities!(tsp25)
	title!(" ACO: Optimal solution using $a ants and $k iterations,
shortest route: $tourcost")
end

# ╔═╡ 909583cd-c5cb-4009-8e55-29c88dcb4828
tsptotoro = TravelingSalesmanProblem(some_totoro_coords)

# ╔═╡ d8677753-6d19-492a-86a8-a4e75d2ca193
begin
	plot_tour(tsptotoro, atourtotoro)
	plot_cities!(tsptotoro)
	title!("A random tour with a route length of $acosttotoro")
end

# ╔═╡ 80696f29-ea1e-45b3-9e3b-3038e01cd9b7
begin
	tourlentoto = round(tour_lengthtoto, digits = 3)
	plot_cities!(tsptotoro)
	title!(" ACO: $atoto ants make $ktoto tours, shortest route: $tourlentoto")
end

# ╔═╡ d541900d-92ed-4d69-850a-861b805f2eb8
md"""
## References

Basu, Pratik. [Introduction to Ant Colony Optimization](https://www.geeksforgeeks.org/introduction-to-ant-colony-optimization/)

Dorigo, Marco. [Ant colony optimization](http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms) 

Dorigo, Marco & Di Caro, Gianni. [The Ant Colony Optimization Meta-Heuristic](https://www.researchgate.net/publication/2831286_The_Ant_Colony_Optimization_Meta-Heuristic)

Dorigo, Marco. [Ant colony optimization]
(http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms) 

Glass Games Studios. [Ant Interactive Education Simulation](https://fypmm161a.wixsite.com/ant-nest/)

Gambardella, Luca Maria & de Luigi, Fabio & Maniezzo, Vittorio. [Ant Colony Optimization](https://people.idsia.ch//~luca/aco2004.pdf)

Liang, Shengbin & Tongtong, Jiao & Wencai, Du & Qu, Shenming. [An improved ant colony optimization algorithm based on context for tourism route planning](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257317#sec001)

McCaffrey, James. [Test Run - Ant Colony Optimization](https://docs.microsoft.com/en-us/archive/msdn-magazine/2012/february/test-run-ant-colony-optimization)

Rahman, Awan-Ur. [Introduction to Ant colony optimization(ACO)](https://towardsdatascience.com/the-inspiration-of-an-ant-colony-optimization-f377568ea03f)

University of Crete. [The Traveling Salesman Problem](https://www.csd.uoc.gr/~hy583/papers/ch11.pdf)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"

[compat]
Images = "~0.25.1"
Plots = "~1.25.7"
PlutoUI = "~0.7.32"
ShortCodes = "~0.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "ffc6588e17bcfcaa79dfa5b4f417025e755f83fc"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "4.0.1"

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
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

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

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

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
git-tree-sha1 = "d7ab55febfd0907b285fbf8dc0c73c0825d9d6aa"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.3.0"

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
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "d727758173afef0af878b29ac364a0eca299fc6b"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.5.1"

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
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "816fc866edd8307a6e79a575e6585bfab8cef27f"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.0"

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
git-tree-sha1 = "7668b123ecfd39a6ae3fc31c532b588999bdc166"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.1"

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
git-tree-sha1 = "42fe8de1fe1f80dab37a39d391b6301f7aeaa7b8"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.4"

[[Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "11d268adba1869067620659e7cdf07f5e54b6c76"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.1"

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
git-tree-sha1 = "bcb31db46795eeb64480c89d854615bc78a13289"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.19"

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

[[Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

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
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

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
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

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
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7e4920a7d4323b8ffc3db184580598450bde8a8e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.7"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

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

[[QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

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
git-tree-sha1 = "37c1631cb3cc36a535105e6d5557864c82cd8c2b"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

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

[[Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "405148000e80f70b31e7732ea93288aecb1793fa"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.2.0"

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

[[Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

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
git-tree-sha1 = "e6bf188613555c78062842777b116905a9f9dd49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "b4912cd034cdf968e06ca5f943bb54b17b97793a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.5.1"

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

[[libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78736dab31ae7a53540a6b752efc61f77b304c5b"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.8.6+1"

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
# ╟─9d58ef2b-4c88-4c25-acbe-084dc1fc8842
# ╟─5cf8234f-6d9f-4738-8232-13a5f6ba723c
# ╟─ecd4e231-9030-438a-9068-e1f0d13f1b78
# ╟─6608e84a-fb31-492a-aced-70b32e3c6a14
# ╟─249340e4-c31a-46a3-a620-ceef9abaadb5
# ╟─a5078d2c-4ce0-4c9f-af45-e6b2dde62277
# ╟─67d95176-fc53-4daa-931f-1a7baa29e888
# ╟─139df66d-b0bf-4adb-891a-18c9fad6db87
# ╠═47c98bd7-f84d-455d-a417-5ffc93fa6fdd
# ╠═81dc269f-5145-4e9f-80e3-86c70879e462
# ╟─09d67d88-a8f8-404d-820e-5a7cada6505d
# ╟─2e5ff5ca-04fa-47c0-b9d5-03130097df57
# ╠═82a213e4-3c70-48c5-8b82-f4ff6ea55603
# ╟─681ec771-af2c-41e1-8d6a-3067188c3d6e
# ╠═3feacf51-4113-45eb-bf99-f01c8b3b9a16
# ╟─dbb0ae04-589b-475d-ba59-95367fccd96b
# ╟─06009ce9-99a0-4568-814b-4f56cfd1815a
# ╟─faa44127-59c5-486e-9e2a-19c768830da0
# ╟─d31a5524-0f98-433f-8b23-79be9c08cf39
# ╟─1922c5e9-8275-4fbd-9d4b-af92d0ffb039
# ╠═43d58b74-9388-4b97-9a94-7191952f4184
# ╟─4b715a6a-2015-4893-95a3-d866aa25a5e3
# ╟─e05ce658-cbaf-4ac2-a426-c9741fbc37d2
# ╟─48b6e748-2d0d-4e1d-805f-d1180ed44a04
# ╠═97e40099-12aa-41ab-b362-816bacd5995c
# ╠═d0e27503-80c1-4dd7-aacd-fda306414005
# ╟─1541356f-d713-443b-94fe-2216b6630dc5
# ╟─bccd27de-3da5-4c4a-aa49-3382bf10228f
# ╟─cfc9018b-784a-48f3-912d-09a88db3216a
# ╟─e53c2dd6-4eb3-4a34-a35f-2a4f5b6185b6
# ╟─e7a3cd0f-0532-4cfa-9b13-f60f5b51fab8
# ╟─aea42e4b-1c8c-47b6-b38c-4b10710b1698
# ╟─62e446f5-9714-4f12-9146-01c9281b30a6
# ╟─cf3cc491-25be-4dd4-86ab-c47e0bc23024
# ╟─97e31857-bb2a-4cca-bf04-9da7e74796b1
# ╠═c7e297b2-dd4c-4bba-9f79-0b7059191e95
# ╟─2706d829-7637-48b7-a0ca-317b18ca71b6
# ╟─d75d3f55-31fd-43e1-bd38-14ba07431a91
# ╟─87c58a34-5477-493c-ad9c-9a99b1d9206c
# ╠═6cfc4a6e-049d-48db-a4a5-5fb60ed32e7f
# ╟─52fe76d0-1b43-4100-b63f-4a4fd928149f
# ╟─306cd489-470c-45c5-bace-1624512087ab
# ╟─573dfc88-1d67-405a-8f7f-2763833283b9
# ╟─f451c468-b840-4843-b442-d792ebbf785d
# ╠═888991d5-b77a-4ca8-a885-2ac10b028a72
# ╟─d916c673-ad4f-4475-8141-06d068f32efa
# ╟─a2aba49e-809f-4cdd-9bd5-d10b854a6628
# ╟─bf508a6c-425a-4da0-9143-8298f06988e3
# ╟─96a41671-0557-44d8-bfbd-291d396fccf5
# ╟─f6152a42-bb18-4a17-94b3-b9885d6885d4
# ╠═c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╟─f6de5186-e714-4962-801e-e1e52bef8af7
# ╟─f125718f-54f0-481c-a23d-98cce6e12a4f
# ╠═a14949b9-77b2-4f32-89f7-d2316736e803
# ╟─93025b8d-6773-4cee-99c3-7da7498597de
# ╠═4d97ef57-3a6c-4850-afa3-1b2bf83ab146
# ╠═07f1ae73-ef20-4be4-81a2-99c7e9651e02
# ╟─855e5ce1-d143-4af5-841d-331add7c3880
# ╟─89ad5ab5-8676-45d7-9506-7321a5cd8e44
# ╟─a4741762-a76d-4626-8acd-26ac22e9d6cd
# ╟─9faf5ebd-1c73-4ddf-876c-b1b042389290
# ╟─49293ec8-5ccb-4a9d-aaeb-1b23cb0835c5
# ╟─2c6733ca-c300-4bc3-9d31-103d7b2cbd6c
# ╟─01a5011f-f6ae-4a13-8641-7b213487d65d
# ╟─6bbf4d81-9db1-4308-aebb-bf0a8a5a6701
# ╟─7b1506d2-02e3-4a13-a277-9ec99bbad91c
# ╟─64dae470-6b3b-487f-b663-25f10b7b9567
# ╟─31e6f16e-e12e-474f-9c27-5bff01c53310
# ╟─40785798-1223-4efe-870e-e37b0b761af1
# ╟─20cb8ca8-0f07-4afa-a380-c539cdff8871
# ╟─206fc0de-a6d3-4597-9ce3-f63bdd853d1c
# ╟─3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
# ╟─e45b3588-f8a7-439a-ac97-bafb9253f6a3
# ╟─ea9bcc44-9351-4156-bf61-3368c507d5cf
# ╟─97cf8701-7622-4537-8091-1a38acefa9dd
# ╟─edf145a2-ae6f-4e01-beb1-5be1d5c1250d
# ╟─3f3d611b-dbe2-420e-bf94-89229eca9ab9
# ╟─7a01418b-2543-433b-942e-92ce38a29496
# ╟─2df743f0-620f-43bc-bb51-17dc5e5c0be7
# ╟─60627e57-5bb4-486f-b185-adbd812e9f36
# ╟─c8de83fa-1519-48d0-b257-97bfeb4952ad
# ╟─e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
# ╟─04e007ac-c582-4510-a053-052e5037e57c
# ╟─86b7067f-5f85-48c3-b78d-3d2e5ed0af3f
# ╟─abbf326e-4617-483c-b956-33db2b666fbc
# ╟─5d929be0-d406-440a-bd0f-2bfe5d26c94a
# ╟─b8a1320e-f7af-4598-b5ee-68b28f25dc47
# ╟─2fbf893e-5ced-4233-90a4-3dce09fb5ed0
# ╟─554154af-0a61-4b4f-b363-bc856bfc32f4
# ╟─cffe3e0b-f1a8-423f-8c3a-c98f1bda82d7
# ╟─8f3b6386-2a28-4433-bcef-f4f2250072a0
# ╟─195eb6d1-1d67-4c08-bdb7-a27dbe5d6d84
# ╟─9f55aa64-cbcf-4148-91b1-e8d5f7df299f
# ╟─1c0844ba-5451-4fd8-921b-0f82ecb7e4ff
# ╟─0056b890-3ff8-47aa-92a0-58b89c7e2078
# ╟─909583cd-c5cb-4009-8e55-29c88dcb4828
# ╟─57baf53e-9bb1-4cf3-bae2-3ac5588a6d11
# ╠═7bfda195-e39a-49c9-bbab-3eecd682eb48
# ╠═0f903495-cfbf-4ce2-9851-a49aba684e6a
# ╠═679c1c38-f926-4492-ada5-aafa5af25fd2
# ╠═dcf0c148-2f9a-4083-9739-89a891574eda
# ╠═d8677753-6d19-492a-86a8-a4e75d2ca193
# ╠═80696f29-ea1e-45b3-9e3b-3038e01cd9b7
# ╟─ad027e48-419b-4aac-af3a-5e6d4acf7e94
# ╟─f565bbd4-9046-4870-9c41-f86a08ca14e1
# ╟─017fd37b-e872-405c-8ab2-a713cecb9a8d
# ╟─cdc1c7d3-c230-4a39-80b6-fdea2d6fb66f
# ╟─d541900d-92ed-4d69-850a-861b805f2eb8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
