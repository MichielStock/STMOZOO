### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 45160a1e-cb93-48bf-b2b9-35c337780a73
using ShortCodes # to use YouTube()

# ╔═╡ 82d25b0c-f900-4996-99c9-fdb1bbe7cae4
using Random # to use rand() 

# ╔═╡ a3a91caa-db4a-49da-bda9-1fffd9498ce8
using LinearAlgebra # to use Symmetric()

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
	- start
	- dists
	- ants
	- best_T
	- best_L
	- pheromones
	- n
	- a
	- k

Outputs:
	- best_T
	- best_L
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

Build a new trail for each ant while taking pheromone values into account.

Inputs:
	-ants
	-pheromones
	-dists
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
	- trail
	- dists

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
	missing = # initialize variables 

	
	for i in 1:missing #for each entry in pheromones matrix (for each i and j) 
		for j in 1:missing 
			for k in 1:missing #for each ant in ants, 
				missing  #compute length of Kth ant trail
           		decrease = missing #calculate decrease factor: (1-ρ) * τ_{i,j}  
				
				if missing #check for an edge in the trail: if there is an edge,
					increase = missing  #increase factor =  Q / path length  
				end
    
				pheromones[i,j] = missing # update the pheromone value 

				#bound pheromone value between 0.0001 and 100000.0
                if pheromones[i,j] < 0.0001
					pheromones[i,j] = 0.0001
                        
                elseif pheromones[i,j] > 100000.0
                	pheromones[i,j] = 100000.0
				end
                        
                pheromones[j,i] = missing  # maintain matrix symmetry 
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

Now you are ready to run `aco`! Run it below.
"""

# ╔═╡ dc8cfbbc-53f0-405f-8d66-8134e4ac798c
md"Initialization:"

# ╔═╡ 080072a9-97f0-486e-bc0f-c61cd3737d55
md"Optimization:"

# ╔═╡ 64dae470-6b3b-487f-b663-25f10b7b9567
md"""
### Different flavors of ACO & limitations

Actually not as good as other state-of-the-art solutions for TSP but can possibly drive the search of always better solutions for such problems. It is an ongoing method of research and teh journals.plot.ios (3rd reference) was only published in Sept 2021 on yet another possible improvement to APO  

Limitations
- Lack of pheromone in the initial stage
- Slow evolution speed
- May prematurely converge
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
	distance(cityX, cityY, graphDistances)

Returns the distance between cityX and cityY

Inputs:
	- cityX: a city/location 
	- cityY: a city/location
	- graphDistances: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j

Outputs:
	- the distance between cityX and cityY
"""
function distance(cityX::Int, cityY::Int, graphDistances)

	return graphDistances[cityX,cityY]
end

# ╔═╡ 306cd489-470c-45c5-bace-1624512087ab
"""
	trailsum(trail, dists) 

Calculates the sum of the entire path taken by the ant.  

Inputs:
	- trail
	- dists

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
	best_L = trailsum(ants[1], dists)
	idxBest = 1
	n = size(dists,2) 
	
	#check the rest of the trails
	for k in 2:length(ants)
		len = trailsum(ants[k], dists)
		if len < best_L
			best_L = len
			idxBest = k
		end
	end
	
	return ants[idxBest]
end

# ╔═╡ 206fc0de-a6d3-4597-9ce3-f63bdd853d1c
"""
	init_aco(n::Int=10, a::Int=4)

Initializes start city `start`, distance matrix `dists`, ant (solutions) `ants`, the solution `best_T`, and its value/length `best_L`. 

Inputs:
	- n: an integer determining the number of cities in the graph
	- a: an integer determing the number of ants that travel the graph	

Outputs:
	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
	- best_T: the index of the best solution in the ants array 
	- best_L: the total length of best_T
"""
function init_aco(n::Int=10, a::Int=4)
	
	start = Int64(rand(1:10))
	dists = makegraphdists(n)
	ants = initants(start, a, n)	
	
	best_T = best_trail(ants, dists)	
    best_L = trailsum(best_T, dists)		

    pheromones = initpheromones(n)		
	
	return start, dists, ants, best_T, best_L, pheromones, n, a
	
end

# ╔═╡ 3e2075fb-44dd-4cbc-89dd-8b8df32ca4e7
startCity, dists, ants, bestTrail, bestLength, pheromones, n, a = init_aco() 

# ╔═╡ 60627e57-5bb4-486f-b185-adbd812e9f36
"""
	getprobs(k, cityX, visited, pheromones, dists, n, α, β)

`what it does` 

Inputs:
	- k: an index
	- cityX: a city 
	- visited: boolean indicating whether city has been visited in the given trail
	- pheromones: pheromone value matrix 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- n: number of cities the ants must visit (including the origin city)
	- α: pheromone update factor (default: 2)
	- β: pheromone update factor (default: 3)

Outputs:
	Cumulative probability array 
	
"""
function getprobs(k::Int, cityX::Int, visited, pheromones, dists, n::Int, α::Real=3.0, β::Real=2.0, MaxValue::Real=1.7976931348623157e+30)
	τη = zeros(n) #tau eta 
	sum = 0

	
	for i in 1:n
		if i == cityX
			τη[i] = 0.0 # prob of moving to self is zero

		elseif visited[i] == true
			τη[i] = 0.0 # prob of moving to a visited node is zero
	
		#otherwise calculate tau eta
		else 
      		τη[i] = (pheromones[cityX,i])^α * (1.0/(distance(cityX, i, dists))^β)
      		
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
	- trail: a trail whose length is n-1 , and starts at 'start' city
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
	
	return trail#, visited
end

# ╔═╡ d75d3f55-31fd-43e1-bd38-14ba07431a91
"""
	updateants(ants, pheromones, dists)

Build a new trail for each ant while taking pheromone values into account.

Inputs:
	-ants
	-pheromones
	-dists
"""
function updateants(ants, pheromones, dists, start)
	n = Int64(size(dists,2)) #numCities
	num_ants = Int64(length(ants))
	for k in 1:num_ants
		#start = Int64(rand(1:n))
		newTrail = buildtrail(k, start, pheromones, dists, n)
		ants[k] = newTrail
	end
end

# ╔═╡ e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
"""
	is_edge(cityX, cityY, trail)

Checks if cityX and cityY are adjacent to each other in trail

Inputs:
	- cityX: a city/location 
	- cityY: a city/location
	- trail: a solution 
Outputs:
	- a boolean value (true if cityX and citY are adjacent, otherwise false)
"""
function is_edge(cityX::Int, cityY::Int, trail)
	
	#make sure cityX, cityY are ins
	cityX
	cityY
	lastIndex = length(trail) 
    idx = getidx(trail, cityX)

    #if X = 1st in trail, see if it's next to 2nd or last in trail
	if idx == 1 && trail[2] == cityY # (X, Y, ...)
    	return true #checked
           
    elseif idx == 1 && trail[lastIndex] == cityY #(X, ..., Y)
    	return true #checked
    
	elseif idx == 1
    	return false #checked
	end
	
	#if X is last in trail, see if its next to 2nd-to-last or 1st
	if idx == lastIndex && trail[lastIndex-1] == cityY
		return true
	
	elseif idx == lastIndex && trail[1] == cityY
		return true
	
	elseif idx == lastIndex
		return false

	#BELOW IS WORKING
	#if X is not 1st or last in list, just check left and right
	elseif trail[idx - 1] == cityY
		return true #checked 

	elseif trail[idx + 1] == cityY
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
				tLength = trailsum(ants[k], dists) #length of ant K trail
           		decrease = (1.0-ρ) * pheromones[i,j]
           		increase = 0.0
				
				if is_edge(i, j, ants[k]) == true
					increase = Q / tLength
				end
    
				pheromones[i,j] = decrease + increase

                if pheromones[i,j] < 0.0001
					pheromones[i,j] = 0.0001
                        
                elseif pheromones[i,j] > 100000.0
                	pheromones[i,j] = 100000.0
				end
                        
                pheromones[j,i] = pheromones[i,j]
			end #for k
		end # for j
	end #for i
end 

# ╔═╡ e05ce658-cbaf-4ac2-a426-c9741fbc37d2
"""
	aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)

Runs ACO k times and returns the shortest path and its length. 

Inputs:
	- start
	- dists
	- ants
	- best_T
	- best_L
	- pheromones
	- n
	- a
	- k::Int=10

Outputs:
	- bestT
	- best_L
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"

[compat]
ShortCodes = "~0.3.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[ShortCodes]]
deps = ["Base64", "CodecZlib", "HTTP", "JSON3", "Memoize", "UUIDs"]
git-tree-sha1 = "866962b3cc79ad3fee73f67408c649498bad1ac0"
uuid = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
version = "0.3.2"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

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

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
"""

# ╔═╡ Cell order:
# ╟─69899fd8-3b3f-4220-8997-88208c6177ca
# ╠═45160a1e-cb93-48bf-b2b9-35c337780a73
# ╠═82d25b0c-f900-4996-99c9-fdb1bbe7cae4
# ╠═a3a91caa-db4a-49da-bda9-1fffd9498ce8
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
# ╟─d75d3f55-31fd-43e1-bd38-14ba07431a91
# ╟─87c58a34-5477-493c-ad9c-9a99b1d9206c
# ╠═6cfc4a6e-049d-48db-a4a5-5fb60ed32e7f
# ╟─52fe76d0-1b43-4100-b63f-4a4fd928149f
# ╟─306cd489-470c-45c5-bace-1624512087ab
# ╟─573dfc88-1d67-405a-8f7f-2763833283b9
# ╟─f451c468-b840-4843-b442-d792ebbf785d
# ╟─eed57c64-de54-473c-970e-d452715902fb
# ╠═888991d5-b77a-4ca8-a885-2ac10b028a72
# ╟─d916c673-ad4f-4475-8141-06d068f32efa
# ╟─a2aba49e-809f-4cdd-9bd5-d10b854a6628
# ╟─bf508a6c-425a-4da0-9143-8298f06988e3
# ╠═90386525-b4bb-4834-a59a-9673fb7a5780
# ╠═c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╟─f6de5186-e714-4962-801e-e1e52bef8af7
# ╟─2a9212c3-529f-4e13-90bf-f702498ceabc
# ╟─dc8cfbbc-53f0-405f-8d66-8134e4ac798c
# ╠═3e2075fb-44dd-4cbc-89dd-8b8df32ca4e7
# ╟─080072a9-97f0-486e-bc0f-c61cd3737d55
# ╠═d3e47acd-e60f-492c-8fbb-72e03133e352
# ╠═cb527cb4-2555-4ddb-be17-02b9c223a0dc
# ╠═58d5a45c-471b-41e8-960a-66d5fbe6d326
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
