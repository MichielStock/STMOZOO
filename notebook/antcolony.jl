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
- What user-set parameters affect the outcome of ACO?

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
>*output* the solution (trail) and it's value (total length): **solutionpath** and **solutionlength**

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
- `start`: an integer representting start city (i.e. colony location) 
- `dists`: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
- `ants`: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
- `best_t`: the index of the best solution in the ants array 
- `best_l`: the total length of `best_t`

#### Example dataset: 4 cities
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

# ╔═╡ 2e5ff5ca-04fa-47c0-b9d5-03130097df57
md""" ###### **!** *Comprehension check*:
What is the initial pheromone value for any pair of cities? What is the reasoning behind this initialization?
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
>*input* **start**, **dists**, **ants**, **best_T**, **best_L**, **pheromones**, **n**, **a** and optionally **k**
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

# ╔═╡ faa44127-59c5-486e-9e2a-19c768830da0
md"""
###### **!** *Thought experiment*: Top-down writing

Writing a function before actually defining the sub-functions that it calls is analogous to a boss delegating tasks. Imagine two modes as you work on these functions: **Boss Mode** and **Worker Mode**

**Boss Mode**: As the boss, your job is to maintain the "bigger picture" of the project. Making calls to sub-functions, for example, is comparable to off-loading tasks on assistants: you don't get involved in the particulars. You trust that the employees will report back with the work you've assigned, when you call on them.

**Worker Mode**: In this mode, you are handed a task, and the bigger purpose of that task may be unclear. You might ask questions like "Okay, but why do it like this?" In this mode, you have to trust that the boss has a good reason for their particular request.

There will be a few more exercises where you will finish writing incomplete functions. In some exercises you will work in **Boss Mode**, and in others you will be in **Worker Mode**.
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

# ╔═╡ 48b6e748-2d0d-4e1d-805f-d1180ed44a04
md"""
### Intermezzo: solving the 4 cities example

Let's continue with our example dataset and run `aco`.

Run the main ACO function:
> `aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)`
- Variables returned by `init_aco` will be entered as paramteres for `aco`
- You can optionally specify `k`, the number of iterations of the loop, i.e. how many times the ants are sent to walk a tour 
- `aco` returns 2 values: the length of the shortest route (e.g. tour) found, and the route itself 
"""

# ╔═╡ 97e40099-12aa-41ab-b362-816bacd5995c
#Optionally specify k4
k4 = 10

# ╔═╡ 1541356f-d713-443b-94fe-2216b6630dc5
md"""
###### **!** *Exercise*
Does changing parameters *n* or *a* give a better (or worse) result? Why (or why not)?
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
Learn by practice: A partially filled-in function is given below. Replace any line with the word **missing** with the necessary code. Comments are provided within the function body to guide you.
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
### Step 3: find the shortest trail (the best solution)
The next step in the `aco` while loop is to find the best solution in the current batch of solutions. Actually, this is simple enough that we don't need to write a separate function for this: it is handled wihtin `aco`. (Scroll up and re-read the `aco` script to verify!)
"""

# ╔═╡ f451c468-b840-4843-b442-d792ebbf785d
md"""
### Step 4: update pheromone trails
The last step in the `aco` while loop is to update pheromone trails. This equates to calculating a value for each path segment (edge) created by any two cities in the graph. The more attractive a particular edge is, the higher the pheromone value it receives, and the more likely it is to be travelled by future ants.  

#### Equation for updating pheromones 
The particulars of the math and reasoning behind this function are outside the scope of this notebook, but if you're curious, you can read about it [here](http://www.scholarpedia.org/article/Ant_colony_optimization#Main_ACO_algorithms). 

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

(Note: this exercise is a great example of working in "Worker Mode", as described before!) 
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

*Answer*: 
The more attractive the city is, the bigger 'slice' it will have of the cumulative probability array. Then when a number is randomly drawn, more attactive cities will be more likely to be selected, although there is still a chance to pick an unattactive city. 

This is a pretty cool property of ACO because it means there is a measure of "free will" in the ant's decision-making! 
"""

# ╔═╡ f6152a42-bb18-4a17-94b3-b9885d6885d4
md"""
#### The `nextcity` function is given below.
As you read through the function code below, try to connect what you're seeing back to the theory above. 
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

# ╔═╡ f125718f-54f0-481c-a23d-98cce6e12a4f
md"""
## ACO in action
### 25 city example
Here's another example use of our `aco` algorithm. This time, we'll use the data in `coords25`, which holds x,y-coordinates of 25 cities.

#### Initialization step 

Run `init_aco(coords25, a)` below.
- `coords25` is a pre-defined list of 25 x,y-coordinate pairs. 
- You can choose a value for `a`, an integer that sets the number of ants. If you run `init_aco(coords25)`, $a=4$ by default.

*Suggestion*:
Append each variable name with the number 25 to associate it with this 25-city example, e.g. `colony25`: the starting city; `dists25`: the distance matrix; `ants25`: initial solutions for each ant; `bestroute25`: the best initial solution;
`routelength25`: the length of `bestroute25`; `pheromones25`: the initial pheromones matrix; `n25`: the number of cities in `coords25`; `a25`: the number of ants
"""

# ╔═╡ 93025b8d-6773-4cee-99c3-7da7498597de
md"""
#### Optimization  
Run the main ACO function:

`aco(start, dists, ants, best_T, best_L, pheromones, n, a, k::Int=10)`
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

# ╔═╡ 57baf53e-9bb1-4cf3-bae2-3ac5588a6d11
md"""
### Partial Totoro example
"""

# ╔═╡ 7bfda195-e39a-49c9-bbab-3eecd682eb48
ktoto = 4

# ╔═╡ 64dae470-6b3b-487f-b663-25f10b7b9567
md"""
### Epilogue and food for thought
ACO is a very promising solution method for TSP, and basic implementation is possible with minimal expertise. However, did you notice some inefficiencies in our implementation? 
- To begin, we initialize random paths for the ants. How could this be made more efficient? 
- We touched in brief on parameters $α$, $β$, and $ρ$, which effect pheromone computation. How might adjusting these parameters improve our solution quality or convergence rate? 

In fact, ACO is not always as good as other state-of-the-art solutions for TSP. It may suffer from slow convergence speed or may prematurely converge before finding the global optimum. At the same time, ACO is also promising in the way it can encode real world context. For example, adjusting the pheromone parameters can encode information about how influencable you want your ant agents to be to social pressure. Adjusting the pheromone evaporate rate can also control how long-lasting the effects of colony communication are, which is another unique property of ACO and other swarm algorithms. 

And do you remember the YouTube video at the beginning of this notebook? The identity of the optimal path changed as the donut disappeared (in other words, the food location or "city" located changed over time as the simulation ran). With this in mind, can you see applications for ACO algorithms that can adapt to real-time changes to TSP problem conditions? One real-world example of this can be found in the tourism industry. Imagine a tour-planning program that can account for real-time changes in weather conditions, a major factor the attractiveness of tourist destinations.

In general, ACO has the potential to drive the search for ever better TSP solutions and therefore remains an ongoing area of research. In fact, ["An improved ant colony optimization algorithm based on context for toursim route planning"](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0257317#sec001) was just publiched in September 2021. 

I hope you enjoyed this introduction to Ant Colony Optimization! For a complete list of references used to create this notebook, see the *References* section at the very end of this notebook.
"""

# ╔═╡ 31e6f16e-e12e-474f-9c27-5bff01c53310
md"""
![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/Elettes_cartoon.png?raw=true)
Cartoon by Elette, age 8
"""

# ╔═╡ 40785798-1223-4efe-870e-e37b0b761af1
md""" # Appendix"""

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
Additional functions used for plotting and other utilities
"""

# ╔═╡ b8a1320e-f7af-4598-b5ee-68b28f25dc47
md" #### The 4-city example"

# ╔═╡ 2fbf893e-5ced-4233-90a4-3dce09fb5ed0
coords4 = [1.0 1.5; 2.1 0.3; -0.3 1.2; -2.0 -2.3]

# ╔═╡ cffe3e0b-f1a8-423f-8c3a-c98f1bda82d7
md" #### The 25-city example"

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
md" #### The partial Totoro example"

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

# ╔═╡ ad027e48-419b-4aac-af3a-5e6d4acf7e94
md" #### Taken from STMO tsp.jl"

# ╔═╡ b2c4ecf1-e86c-42f7-b186-f7f3e528b902
#got_tsp() = TravelingSalesmanProblem(got_coords)

# ╔═╡ 67c91979-c561-4ac6-aa43-00ed552d109d
#totoro_tsp() = TravelingSalesmanProblem(totoro_coords)

# ╔═╡ d5679d24-9901-4b1c-8554-1981c532e4b8
got_coords = [947 1023;
939 1017;
1017 1017;
916 1016;
948 1016;
973 1016;
931 1015;
975 1015;
1022 1015;
872 1014;
1023 1014;
875 1013;
869 1012;
864 1011;
903 1011;
926 1010;
969 1010;
973 1010;
1000 1010;
877 1009;
883 1009;
914 1009;
962 1009;
1005 1009;
976 1008;
1000 1008;
1001 1008;
891 1007;
901 1007;
902 1007;
999 1007;
1001 1007;
1014 1007;
923 1006;
975 1006;
863 1005;
982 1005;
872 1004;
914 1004;
985 1003;
926 1002;
932 1002;
904 1001;
919 1001;
989 1001;
879 1000;
986 1000;
919 999;
925 999;
901 998;
1009 998;
869 997;
1016 996;
1004 995;
999 994;
1018 993;
995 992;
1005 991;
829 990;
908 990;
939 990;
1029 990;
940 989;
984 988;
1000 986;
829 985;
908 985;
961 983;
900 982;
928 982;
1011 980;
1003 978;
934 976;
986 976;
1002 976;
1026 976;
983 975;
993 975;
1036 975;
1094 975;
750 974;
846 974;
929 974;
1020 974;
1031 973;
1037 973;
1041 973;
835 972;
868 972;
939 971;
967 971;
1124 971;
1126 971;
1127 971;
957 970;
1040 970;
855 969;
945 969;
957 969;
745 968;
1077 968;
1078 968;
1092 968;
909 967;
931 967;
946 967;
1130 967;
925 966;
1096 966;
1129 966;
741 965;
939 965;
1026 964;
929 963;
933 963;
1010 963;
905 962;
930 962;
970 962;
1041 962;
897 961;
934 961;
1018 961;
1035 961;
1038 961;
1112 961;
1118 961;
758 960;
766 960;
874 960;
877 960;
1034 960;
741 959;
1000 959;
1082 959;
734 958;
914 958;
1036 958;
1071 958;
1140 958;
1012 957;
1073 957;
1161 957;
935 956;
1104 956;
1107 956;
897 955;
1091 954;
1102 954;
718 953;
893 953;
911 953;
1015 953;
1019 953;
1132 953;
722 952;
886 952;
906 952;
1096 952;
1098 952;
1134 952;
757 951;
901 951;
1023 951;
1026 951;
771 950;
1022 950;
875 949;
902 949;
903 949;
917 949;
1063 949;
1169 949;
766 948;
759 947;
1096 947;
872 946;
898 946;
1122 946;
713 945;
1063 945;
784 944;
815 944;
924 944;
927 944;
1147 944;
1150 944;
1062 943;
706 942;
1011 942;
1022 942;
1115 942;
1136 942;
1116 941;
1016 940;
1029 940;
929 939;
1059 939;
761 938;
703 937;
743 937;
768 937;
880 937;
923 937;
940 937;
1144 937;
697 936;
760 936;
772 936;
780 936;
798 936;
936 936;
1049 936;
699 935;
702 935;
796 935;
1052 935;
770 934;
1029 933;
768 932;
807 932;
721 931;
768 931;
1038 931;
677 930;
722 930;
674 929;
687 929;
689 929;
695 929;
794 929;
815 929;
1016 929;
1052 929;
672 928;
707 928;
747 928;
799 928;
814 928;
1187 928;
1046 927;
1156 927;
691 926;
758 926;
873 926;
700 925;
795 925;
802 925;
815 924;
1038 924;
1141 924;
761 922;
794 922;
822 922;
1112 922;
1135 922;
663 921;
739 921;
1183 921;
1202 921;
1205 921;
695 920;
721 920;
750 920;
1104 920;
1179 920;
1200 920;
666 919;
686 919;
695 919;
1134 919;
1199 919;
748 918;
1161 918;
1193 918;
1199 918;
1051 917;
1060 917;
1112 917;
749 916;
1154 916;
1221 916;
671 915;
789 915;
830 915;
1053 915;
1064 915;
1100 915;
1133 915;
1160 915;
670 914;
738 914;
780 914;
775 913;
782 913;
799 913;
1110 913;
1138 913;
693 912;
826 912;
1055 912;
1183 912;
793 911;
799 911;
688 910;
1008 909;
658 908;
667 908;
1042 908;
1150 908;
1161 907;
1221 907;
649 906;
782 906;
831 906;
1125 906;
1159 906;
1181 906;
767 905;
783 905;
1212 905;
682 904;
785 904;
1123 904;
1174 904;
728 903;
1026 903;
1036 903;
1191 902;
779 901;
815 901;
1153 901;
1232 901;
716 900;
818 900;
843 900;
1043 900;
703 899;
804 899;
823 899;
1127 899;
733 898;
737 898;
792 898;
1191 898;
826 897;
1037 897;
1239 897;
696 896;
833 896;
1061 896;
665 895;
667 895;
672 895;
718 895;
1016 895;
1044 895;
1114 895;
1191 895;
1207 895;
1215 895;
646 894;
697 894;
827 894;
846 894;
1042 894;
1204 894;
1219 894;
680 893;
729 893;
810 893;
821 893;
1018 893;
1037 892;
1041 892;
1044 892;
1108 892;
1204 892;
660 891;
799 891;
808 891;
833 891;
1058 891;
1111 891;
1196 891;
1209 891;
1236 891;
667 889;
670 889;
843 889;
1009 889;
1118 889;
1217 889;
1223 889;
1251 889;
842 888;
636 887;
654 887;
849 887;
1086 887;
1244 887;
812 886;
1047 886;
713 885;
828 885;
839 885;
1122 885;
1257 885;
642 884;
687 884;
1026 884;
1244 884;
997 883;
1026 883;
1036 883;
1208 883;
990 882;
1193 882;
1031 881;
1223 881;
692 880;
826 880;
642 879;
1080 879;
1106 879;
1259 879;
1114 878;
1186 878;
1244 878;
1271 878;
1098 877;
1100 877;
1255 877;
635 876;
1089 876;
1242 876;
646 875;
997 875;
1018 875;
1200 875;
1259 875;
648 874;
1098 874;
1191 874;
819 873;
981 873;
996 873;
1257 873;
626 872;
723 872;
654 871;
724 871;
804 871;
988 871;
1246 871;
684 870;
813 870;
844 870;
1032 870;
632 869;
800 869;
830 869;
1022 869;
1031 869;
1276 869;
662 868;
823 868;
1081 868;
624 867;
1093 867;
1205 867;
1222 867;
991 866;
697 864;
699 864;
857 864;
1028 864;
1118 864;
1258 864;
977 863;
1195 863;
1264 863;
1277 863;
826 860;
1249 860;
1269 860;
823 859;
963 859;
986 859;
1217 859;
1302 859;
836 858;
844 858;
1009 858;
1093 858;
624 857;
683 857;
816 857;
1004 857;
1110 857;
1218 857;
1258 857;
1261 857;
1215 856;
1280 856;
1185 855;
1197 855;
668 854;
859 854;
954 854;
984 854;
1186 854;
1215 854;
602 853;
608 853;
626 853;
652 853;
983 853;
685 852;
828 851;
831 851;
846 851;
1299 851;
843 850;
849 850;
974 850;
1111 850;
1117 850;
1284 850;
1291 850;
614 849;
1191 849;
845 848;
968 848;
973 848;
1091 848;
1096 848;
1203 848;
701 847;
1270 847;
845 846;
945 846;
947 846;
603 845;
684 845;
1261 845;
1262 845;
849 844;
930 844;
818 843;
939 843;
971 843;
1182 843;
1245 843;
922 842;
984 842;
983 841;
828 840;
941 840;
1262 840;
1001 839;
1007 839;
1134 839;
685 838;
805 838;
1258 838;
1305 838;
617 837;
670 837;
805 837;
848 837;
1135 837;
1168 837;
1177 837;
1261 837;
821 836;
922 836;
618 835;
658 835;
1129 835;
1205 835;
1286 835;
1296 835;
1305 835;
825 834;
927 834;
995 834;
1183 834;
660 833;
817 833;
919 833;
986 833;
1112 833;
1153 833;
1177 833;
676 832;
976 832;
914 831;
920 831;
1096 831;
1099 831;
1174 831;
1194 831;
828 830;
905 830;
942 830;
962 830;
1161 830;
1280 830;
1303 830;
817 829;
963 829;
1188 829;
1281 828;
959 827;
1154 827;
1300 827;
957 826;
1284 826;
825 825;
855 825;
1110 825;
1113 824;
914 823;
1186 823;
854 822;
667 821;
1117 821;
599 820;
660 820;
831 820;
953 820;
924 819;
1169 819;
1318 819;
921 818;
1304 818;
1311 818;
902 817;
1325 817;
845 816;
824 815;
829 815;
821 814;
838 814;
895 814;
957 814;
985 814;
1113 814;
1141 814;
817 813;
916 813;
983 813;
842 812;
857 812;
889 812;
1282 812;
1158 811;
1163 811;
1310 811;
840 810;
845 810;
1172 810;
914 809;
1295 809;
839 808;
907 808;
942 808;
1317 808;
893 807;
922 807;
941 807;
1158 807;
1174 807;
822 806;
833 806;
893 806;
914 806;
938 806;
1148 806;
1183 806;
845 804;
889 804;
914 804;
944 804;
1299 804;
807 803;
828 803;
876 803;
892 803;
950 803;
1132 803;
1170 803;
803 802;
882 802;
1138 802;
1346 802;
819 801;
954 801;
1338 801;
1340 801;
827 800;
881 800;
933 800;
1335 800;
1333 799;
828 798;
918 798;
830 796;
1343 796;
805 795;
832 794;
885 794;
924 794;
1085 794;
1093 793;
1109 793;
816 792;
818 792;
888 792;
1038 792;
1106 792;
1345 792;
911 791;
889 790;
905 790;
1065 789;
1120 789;
1311 789;
850 788;
873 788;
912 788;
1129 788;
826 787;
908 787;
1014 787;
1048 787;
1092 787;
1108 787;
1342 787;
866 786;
874 786;
880 786;
891 786;
903 786;
1056 786;
1090 786;
1112 786;
1305 786;
1330 786;
832 785;
854 784;
912 784;
1023 784;
1028 784;
1043 784;
1317 784;
1330 784;
921 783;
1061 783;
1065 783;
1079 783;
1334 783;
860 782;
1101 782;
1118 782;
1135 782;
1138 782;
1151 782;
1158 782;
1336 782;
839 781;
897 781;
1041 781;
1047 781;
1316 781;
548 780;
844 780;
1040 780;
1061 780;
1082 780;
1095 780;
1140 780;
813 779;
990 779;
1042 779;
1058 779;
818 778;
843 778;
988 778;
1051 778;
1127 778;
1177 778;
1329 778;
878 777;
1117 777;
1120 777;
1310 777;
1338 777;
1085 776;
1100 776;
1176 776;
1306 776;
1320 776;
1010 775;
1072 775;
1094 775;
1104 775;
855 774;
915 774;
1003 774;
1344 774;
666 773;
886 773;
903 773;
1167 773;
1189 773;
913 772;
1055 772;
1073 772;
1096 772;
1118 772;
1138 772;
1178 772;
1185 772;
1338 772;
1350 772;
807 771;
883 771;
889 771;
989 771;
1016 771;
1063 771;
1089 771;
1143 771;
1145 771;
841 770;
1124 770;
914 769;
1106 769;
1166 769;
1193 769;
653 768;
807 768;
812 768;
990 768;
1144 768;
1164 768;
1172 768;
1198 768;
1200 768;
1359 768;
586 767;
1085 767;
1326 767;
621 766;
831 766;
914 766;
1033 766;
1202 766;
1208 766;
1344 766;
543 765;
548 765;
805 765;
975 765;
1037 765;
1091 765;
1102 765;
1162 765;
581 764;
875 764;
985 764;
1129 764;
1176 764;
579 763;
611 763;
623 763;
639 763;
659 763;
678 763;
821 763;
876 763;
1063 763;
1066 763;
690 762;
871 762;
1027 762;
1101 762;
1211 762;
610 761;
1095 761;
809 760;
887 760;
1007 760;
1148 760;
1175 760;
1176 760;
1233 760;
691 759;
699 759;
811 759;
814 759;
1119 759;
1215 759;
1349 759;
814 758;
1024 758;
1028 758;
1116 758;
1122 758;
1181 758;
1198 758;
1339 758;
626 757;
634 757;
641 757;
808 757;
825 757;
994 757;
1107 757;
1175 757;
1190 757;
1349 757;
615 756;
817 756;
1068 756;
1102 756;
1187 756;
1204 756;
662 755;
993 755;
1343 755;
601 754;
636 754;
656 754;
663 754;
1011 754;
1137 754;
1186 754;
1204 754;
566 753;
630 753;
679 753;
826 753;
829 753;
832 753;
1024 753;
1086 753;
1191 753;
609 752;
869 752;
871 752;
874 752;
887 752;
1032 752;
1155 752;
1236 752;
1372 752;
724 751;
733 751;
869 751;
1062 751;
1198 751;
1325 751;
1348 751;
1354 751;
533 750;
573 750;
625 750;
832 750;
842 750;
1077 750;
1156 750;
1224 750;
1329 750;
882 749;
954 749;
1048 749;
1062 749;
1233 749;
1338 749;
565 748;
969 748;
1012 748;
1108 748;
1331 748;
1332 748;
533 747;
535 747;
633 747;
721 747;
743 747;
1180 747;
1192 747;
563 746;
611 746;
660 746;
704 746;
979 746;
999 746;
1112 746;
1115 746;
1121 746;
1327 746;
639 745;
669 745;
729 745;
747 745;
819 745;
978 745;
1025 745;
1026 745;
1067 745;
1068 745;
1370 745;
535 744;
592 744;
593 744;
712 744;
721 744;
727 744;
825 744;
852 744;
1133 744;
1224 744;
1261 744;
836 743;
845 743;
1035 743;
1067 743;
1113 743;
1114 743;
1116 743;
1131 743;
1181 743;
566 742;
617 742;
668 742;
712 742;
995 742;
1028 742;
1256 742;
1342 742;
536 741;
698 741;
838 741;
1071 741;
1102 741;
1167 741;
1268 741;
1370 741;
707 740;
978 740;
990 740;
1029 740;
1069 740;
1081 740;
1121 740;
1132 740;
672 739;
678 739;
827 739;
841 739;
1079 739;
1102 739;
1206 739;
579 738;
605 738;
650 738;
681 738;
986 738;
1033 738;
1168 738;
535 737;
674 737;
679 737;
824 737;
885 737;
1015 737;
1112 737;
1139 737;
695 736;
714 736;
866 736;
1032 736;
1055 736;
1192 736;
1362 736;
528 735;
610 735;
640 735;
728 735;
826 735;
980 735;
1032 735;
1066 735;
1120 735;
1166 735;
1255 735;
528 734;
530 734;
808 734;
870 734;
978 734;
1078 734;
1082 734;
1156 734;
1159 734;
857 733;
975 733;
1079 733;
1340 733;
632 732;
662 732;
804 732;
814 732;
1028 732;
1256 732;
1353 732;
1373 732;
557 731;
562 731;
643 731;
690 731;
992 731;
1012 731;
1015 731;
1103 731;
1126 731;
1129 731;
1221 731;
1392 731;
680 730;
1176 730;
1177 730;
1192 730;
1196 730;
1232 730;
1237 730;
1271 730;
610 729;
984 729;
994 729;
1111 729;
1368 729;
555 728;
587 728;
806 728;
811 728;
841 728;
1003 728;
1128 728;
1369 728;
1378 728;
611 727;
667 727;
809 727;
1002 727;
1205 727;
1391 727;
650 726;
1011 726;
1150 726;
1368 726;
634 725;
733 725;
806 725;
1049 725;
525 724;
742 724;
761 724;
812 724;
1161 724;
1188 724;
1205 724;
538 723;
627 723;
733 723;
751 723;
994 723;
1119 723;
1383 723;
651 722;
683 722;
717 722;
1175 722;
1189 722;
1207 722;
1236 722;
1247 722;
1249 722;
642 721;
644 721;
815 721;
833 721;
1104 721;
585 720;
611 720;
837 720;
1044 720;
1074 720;
1384 720;
530 719;
533 719;
562 719;
568 719;
730 719;
1025 719;
1031 719;
1126 719;
1139 719;
1180 719;
1253 719;
1365 719;
1373 719;
737 718;
758 718;
813 718;
1042 718;
1133 718;
525 717;
736 717;
828 717;
830 717;
863 717;
1114 717;
521 716;
691 716;
751 716;
851 716;
1017 716;
1044 716;
1055 716;
1139 716;
1243 716;
1251 716;
1272 716;
1305 716;
542 715;
1172 715;
1207 715;
1299 715;
1370 715;
1396 715;
690 714;
750 714;
824 714;
1008 714;
1093 714;
1115 714;
1143 714;
547 713;
605 713;
1032 713;
1054 713;
1110 713;
1143 713;
1161 713;
1211 713;
1243 713;
724 712;
799 712;
848 712;
864 712;
1089 712;
1118 712;
1128 712;
1250 712;
1301 712;
596 711;
760 711;
1050 711;
1103 711;
1266 711;
1275 711;
543 710;
568 710;
727 710;
1090 710;
1135 710;
1243 710;
1257 710;
1358 710;
734 709;
1011 709;
1122 709;
1168 709;
712 708;
1043 708;
1129 708;
874 707;
1177 707;
1211 707;
1213 707;
1275 707;
1285 707;
1310 707;
1353 707;
1369 707;
523 706;
828 706;
838 706;
853 706;
1163 706;
1210 706;
514 705;
795 705;
861 705;
1014 705;
1055 705;
1241 705;
1362 705;
1369 705;
1373 705;
1393 705;
703 704;
855 704;
875 704;
1033 704;
1116 704;
1184 704;
1260 704;
1283 704;
533 703;
537 703;
1128 703;
1173 703;
1196 703;
1208 703;
1183 702;
525 701;
833 701;
856 701;
857 701;
1004 701;
1029 701;
1086 701;
1092 701;
1377 701;
523 700;
549 700;
739 700;
741 700;
743 700;
844 700;
853 700;
994 700;
1215 700;
1250 700;
1313 700;
1359 700;
1391 700;
527 699;
579 699;
1048 699;
1186 699;
1228 699;
739 698;
759 698;
787 698;
791 698;
861 698;
1063 698;
1082 698;
1124 698;
1244 698;
1256 698;
1274 698;
1278 698;
1374 698;
581 697;
729 697;
738 697;
779 697;
1129 697;
1187 697;
1231 697;
1240 697;
1309 697;
1310 697;
1364 697;
529 696;
534 696;
716 696;
824 696;
849 696;
1119 696;
1192 696;
1411 696;
535 695;
571 695;
850 695;
860 695;
1038 695;
1060 695;
1088 695;
1105 695;
562 694;
815 694;
1059 694;
1114 694;
1115 694;
1228 694;
1293 694;
562 693;
1048 693;
1079 693;
1265 693;
1272 693;
1373 693;
827 692;
1012 692;
1191 692;
1292 692;
1280 691;
501 690;
534 690;
557 690;
578 690;
580 690;
785 690;
861 690;
1200 690;
1389 690;
746 689;
763 689;
1048 689;
1248 689;
1390 689;
500 688;
570 688;
762 688;
783 688;
833 688;
1112 688;
1268 688;
504 687;
543 687;
789 687;
832 687;
1037 687;
1108 687;
1374 687;
1402 687;
836 686;
842 686;
1064 686;
1208 686;
1231 686;
1331 686;
1406 686;
526 685;
565 685;
586 685;
794 685;
828 685;
1009 685;
1020 685;
1212 685;
1219 685;
1300 685;
551 684;
561 684;
801 684;
815 684;
1035 684;
1116 684;
1296 684;
1413 684;
571 683;
773 683;
780 683;
784 683;
831 683;
1000 683;
1013 683;
1034 683;
1328 683;
507 682;
587 682;
744 682;
778 682;
787 682;
821 682;
830 682;
1003 682;
1037 682;
1133 682;
1201 682;
1213 682;
1257 682;
1274 682;
1335 682;
527 681;
743 681;
1024 681;
1065 681;
1221 681;
1302 681;
1387 681;
790 680;
1335 680;
560 679;
768 679;
850 679;
1033 679;
1050 679;
1340 679;
503 678;
793 678;
795 678;
868 678;
1044 678;
1285 678;
558 677;
733 677;
834 677;
1005 677;
1048 677;
1247 677;
1333 677;
508 676;
814 676;
831 676;
1000 676;
1057 676;
1065 676;
1066 676;
1237 676;
1240 676;
1383 676;
497 675;
737 675;
753 675;
1239 675;
1319 675;
508 674;
524 674;
549 674;
1006 674;
1218 674;
1243 674;
514 673;
566 673;
803 673;
816 673;
1258 673;
1304 673;
1395 673;
499 672;
775 672;
1031 672;
1040 672;
1255 672;
1408 672;
774 671;
835 671;
1018 671;
1019 671;
1312 671;
1395 671;
1407 671;
991 670;
1272 670;
1294 670;
503 669;
1213 669;
1250 669;
1287 669;
552 668;
801 668;
743 667;
846 667;
851 667;
1003 667;
1006 667;
1019 667;
1396 667;
755 666;
770 666;
845 666;
1293 666;
1323 666;
1347 666;
1380 666;
506 665;
554 665;
757 665;
785 665;
800 665;
849 665;
872 665;
1037 665;
1238 665;
805 664;
807 664;
1047 664;
1391 664;
505 663;
768 663;
812 663;
874 663;
1030 663;
758 662;
1298 662;
1316 662;
542 661;
1221 661;
1225 661;
1233 661;
1227 660;
1236 660;
1237 660;
1256 660;
1260 660;
1287 660;
1402 660;
506 659;
996 659;
1023 659;
1310 659;
1333 659;
1391 659;
761 658;
765 658;
990 658;
1023 658;
1030 658;
1285 658;
787 657;
834 657;
1000 657;
1011 657;
1273 657;
744 656;
767 656;
1034 656;
842 655;
1002 655;
1049 655;
1317 655;
1339 655;
1408 655;
1022 654;
541 653;
760 653;
761 653;
771 653;
807 653;
810 653;
823 653;
1277 653;
836 652;
1042 652;
1228 652;
1306 652;
747 651;
1014 651;
1298 651;
1393 651;
510 650;
838 650;
848 650;
1016 650;
1041 650;
1065 650;
501 649;
774 649;
782 649;
826 649;
848 649;
1011 649;
1042 649;
1229 649;
1299 649;
1428 649;
790 648;
1020 648;
1165 648;
1288 648;
1303 648;
512 647;
848 647;
1002 647;
514 646;
774 646;
788 646;
528 644;
1159 644;
1347 644;
501 643;
883 643;
1158 643;
1428 643;
505 642;
764 642;
798 642;
843 642;
1186 642;
1295 642;
784 641;
1168 641;
1424 641;
510 640;
846 640;
880 640;
885 640;
1013 640;
1028 640;
1289 640;
1307 640;
1329 640;
1331 640;
529 639;
826 639;
850 639;
892 639;
1327 639;
806 638;
997 638;
998 638;
1007 638;
774 637;
824 637;
857 637;
872 637;
894 637;
1031 637;
1046 637;
1182 637;
1360 637;
1416 637;
756 636;
827 636;
887 636;
1173 636;
497 635;
525 635;
547 635;
1431 635;
546 634;
841 634;
900 634;
1026 634;
1356 634;
774 633;
870 633;
1018 633;
546 632;
549 632;
809 632;
854 632;
873 632;
1170 632;
1318 632;
1347 632;
556 631;
769 631;
770 631;
823 631;
859 631;
933 631;
984 631;
1015 631;
1158 631;
1297 631;
1308 631;
549 630;
819 630;
1165 630;
1355 630;
499 629;
888 629;
1016 629;
1031 629;
1169 629;
1184 629;
1326 629;
1346 629;
1410 629;
799 628;
829 628;
1159 628;
1433 628;
766 627;
963 627;
983 627;
1189 627;
872 626;
900 626;
979 626;
1173 626;
1353 626;
497 625;
788 625;
797 625;
826 625;
894 625;
967 625;
1200 625;
1209 625;
1320 625;
556 624;
838 624;
1161 624;
1174 624;
1190 624;
1207 624;
1299 624;
927 623;
1409 623;
555 622;
777 622;
817 622;
875 622;
885 622;
1199 622;
1326 622;
1370 622;
1399 622;
710 621;
867 621;
868 621;
874 621;
972 621;
989 621;
1212 621;
1351 621;
549 620;
564 620;
831 620;
995 620;
1146 620;
1374 620;
555 619;
877 619;
909 619;
912 619;
930 619;
964 619;
1366 619;
497 618;
869 618;
874 618;
895 618;
946 618;
1024 618;
1151 618;
1309 618;
1347 618;
815 617;
904 617;
914 617;
968 617;
1179 617;
1315 617;
1368 617;
1420 617;
767 616;
1036 616;
776 615;
855 615;
928 615;
961 615;
1175 615;
1191 615;
1410 615;
1412 615;
810 614;
857 614;
1001 614;
1006 614;
1316 614;
491 613;
541 613;
965 613;
1323 613;
1341 613;
666 612;
779 612;
816 612;
677 611;
812 611;
843 611;
903 611;
1201 611;
501 610;
666 610;
678 610;
722 610;
998 610;
1172 610;
663 609;
773 609;
801 609;
920 609;
933 609;
992 609;
1004 609;
1420 609;
662 608;
714 608;
879 608;
884 608;
944 608;
1409 608;
557 607;
657 607;
699 607;
774 607;
819 607;
1201 607;
1329 607;
555 606;
819 606;
847 606;
852 606;
932 606;
1344 606;
541 605;
665 605;
789 605;
877 605;
907 605;
957 605;
1189 605;
1212 605;
505 604;
920 604;
1004 604;
1011 604;
1026 604;
1074 604;
1430 604;
491 603;
493 603;
693 603;
843 603;
859 603;
864 603;
949 603;
955 603;
1132 603;
1150 603;
1210 603;
1320 603;
968 602;
984 602;
1138 602;
673 601;
725 601;
791 601;
1311 601;
1416 601;
487 600;
1223 600;
1324 600;
1410 600;
826 599;
833 599;
857 599;
945 599;
963 599;
1037 599;
1055 599;
1195 599;
524 598;
695 598;
993 598;
1010 598;
1021 598;
1048 598;
1067 598;
1077 598;
1148 598;
1229 598;
1416 598;
524 597;
714 597;
734 597;
861 597;
914 597;
983 597;
1359 597;
874 596;
1351 596;
1357 596;
1436 596;
498 595;
707 595;
923 595;
972 595;
1010 595;
1055 595;
1142 595;
1310 595;
800 594;
810 594;
1045 594;
1118 594;
1192 594;
1229 594;
559 593;
928 593;
931 593;
991 593;
1158 593;
550 592;
985 592;
994 592;
1082 592;
1217 592;
1332 592;
729 591;
818 591;
830 591;
875 591;
915 591;
942 591;
1059 591;
1307 591;
920 590;
1057 590;
1122 590;
1133 590;
1136 590;
1175 590;
1188 590;
1419 590;
717 589;
788 589;
832 589;
886 589;
896 589;
911 589;
944 589;
971 589;
1315 589;
1366 589;
1416 589;
834 588;
913 588;
1138 588;
1425 588;
557 587;
564 587;
803 587;
871 587;
900 587;
948 587;
1016 587;
1057 587;
1146 587;
1344 587;
1378 587;
558 586;
670 586;
853 586;
985 586;
1002 586;
680 585;
795 585;
823 585;
958 585;
1034 585;
1168 585;
1335 585;
486 584;
656 584;
947 584;
1030 584;
1038 584;
1123 584;
1167 584;
1225 584;
1360 584;
911 583;
919 583;
1024 583;
1147 583;
1202 583;
1240 583;
673 582;
688 582;
856 582;
561 581;
956 581;
1020 581;
1186 581;
1237 581;
1351 581;
1364 581;
1430 581;
806 580;
810 580;
929 580;
1009 580;
1055 580;
1316 580;
1366 580;
1379 580;
725 579;
733 579;
792 579;
917 579;
962 579;
1062 579;
1078 579;
1146 579;
1149 579;
1174 579;
634 578;
700 578;
856 578;
946 578;
1182 578;
1336 578;
649 577;
674 577;
996 577;
1083 577;
1125 577;
1213 577;
1361 577;
1371 577;
787 576;
814 576;
835 576;
850 576;
927 576;
959 576;
1035 576;
1118 576;
1125 576;
1226 576;
1313 576;
819 575;
885 575;
917 575;
918 575;
1188 575;
1207 575;
1316 575;
1355 575;
1393 575;
638 574;
682 574;
720 574;
725 574;
821 574;
966 574;
987 574;
1016 574;
1060 574;
1098 574;
1111 574;
1136 574;
1204 574;
1342 574;
919 573;
925 573;
991 573;
1036 573;
1126 573;
1163 573;
1192 573;
1205 573;
1238 573;
1426 573;
693 572;
694 572;
733 572;
993 572;
1084 572;
1087 572;
1123 572;
1187 572;
1318 572;
1345 572;
636 571;
704 571;
722 571;
985 571;
1014 571;
1029 571;
1032 571;
1151 571;
1376 571;
810 570;
837 570;
894 570;
963 570;
1000 570;
1127 570;
1250 570;
648 569;
796 569;
817 569;
837 569;
888 569;
895 569;
914 569;
971 569;
1013 569;
1106 569;
1134 569;
1233 569;
1247 569;
734 568;
833 568;
843 568;
863 568;
908 568;
910 568;
930 568;
937 568;
960 568;
1048 568;
1061 568;
1342 568;
708 567;
720 567;
809 567;
882 567;
1050 567;
1085 567;
1164 567;
1428 567;
705 566;
816 566;
869 566;
942 566;
964 566;
1059 566;
1063 566;
1146 566;
1313 566;
1343 566;
673 565;
866 565;
881 565;
892 565;
907 565;
939 565;
943 565;
947 565;
985 565;
1068 565;
1109 565;
1157 565;
1168 565;
1174 565;
1313 565;
1346 565;
1387 565;
666 564;
792 564;
853 564;
869 564;
891 564;
1011 564;
1013 564;
1023 564;
1101 564;
1138 564;
1173 564;
1211 564;
1348 564;
1389 564;
856 563;
1031 563;
1071 563;
1077 563;
1145 563;
1154 563;
1199 563;
1383 563;
712 562;
1028 562;
1067 562;
1119 562;
1120 562;
1195 562;
1258 562;
1345 562;
975 561;
1026 561;
1128 561;
1132 561;
1325 561;
691 560;
829 560;
904 560;
995 560;
1040 560;
1063 560;
1147 560;
1197 560;
516 559;
983 559;
1114 559;
1136 559;
1223 559;
1328 559;
892 558;
914 558;
1162 558;
1175 558;
670 557;
674 557;
714 557;
732 557;
846 557;
867 557;
1146 557;
1383 557;
670 556;
697 556;
787 556;
860 556;
878 556;
1049 556;
1082 556;
1121 556;
1227 556;
1253 556;
1426 556;
657 555;
713 555;
874 555;
876 555;
884 555;
1024 555;
1048 555;
1086 555;
1125 555;
1258 555;
683 554;
853 554;
875 554;
911 554;
1004 554;
1067 554;
1138 554;
1174 554;
1237 554;
1369 554;
797 553;
886 553;
994 553;
1054 553;
1055 553;
1094 553;
1255 553;
1379 553;
678 552;
830 552;
832 552;
918 552;
1056 552;
1060 552;
1089 552;
1129 552;
1134 552;
1193 552;
1341 552;
1366 552;
1432 552;
504 551;
667 551;
738 551;
1018 551;
1107 551;
1137 551;
1144 551;
1377 551;
691 550;
728 550;
870 550;
1019 550;
1131 550;
1148 550;
1161 550;
1342 550;
1385 550;
1431 550;
503 549;
927 549;
963 549;
996 549;
1198 549;
681 548;
689 548;
873 548;
899 548;
1011 548;
1117 548;
1118 548;
1156 548;
1167 548;
1177 548;
1351 548;
1392 548;
825 547;
830 547;
891 547;
965 547;
1023 547;
1104 547;
1117 547;
1136 547;
1266 547;
1314 547;
1357 547;
500 546;
938 546;
1022 546;
1069 546;
1086 546;
1208 546;
1369 546;
1388 546;
496 545;
719 545;
854 545;
893 545;
966 545;
1434 545;
680 544;
837 544;
893 544;
1084 544;
1351 544;
1390 544;
703 543;
918 543;
948 543;
961 543;
974 543;
1190 543;
1194 543;
1213 543;
1267 543;
923 542;
967 542;
1021 542;
1081 542;
1146 542;
1209 542;
1210 542;
1220 542;
1354 542;
1400 542;
687 541;
703 541;
989 541;
1127 541;
1151 541;
1350 541;
1369 541;
736 540;
838 540;
870 540;
1048 540;
1119 540;
1121 540;
1144 540;
1148 540;
1162 540;
1249 540;
1346 540;
1358 540;
1377 540;
1384 540;
884 539;
915 539;
943 539;
1027 539;
1198 539;
1258 539;
1435 539;
737 538;
865 538;
900 538;
1021 538;
1111 538;
1393 538;
690 537;
707 537;
729 537;
839 537;
860 537;
862 537;
939 537;
1055 537;
1095 537;
1100 537;
1230 537;
904 536;
944 536;
1010 536;
1071 536;
1390 536;
863 535;
930 535;
1040 535;
1222 535;
1360 535;
858 534;
983 534;
992 534;
1129 534;
1133 534;
1149 534;
868 533;
1074 533;
1097 533;
1163 533;
1399 533;
740 532;
819 532;
876 532;
934 532;
1124 532;
1189 532;
1358 532;
706 531;
713 531;
862 531;
918 531;
926 531;
1038 531;
1178 531;
1194 531;
1219 531;
843 530;
940 530;
967 530;
1047 530;
1083 530;
1100 530;
1355 530;
840 529;
1194 529;
1252 529;
1366 529;
1404 529;
711 528;
712 528;
995 528;
1130 528;
716 527;
908 527;
1046 527;
1354 527;
705 526;
832 526;
872 526;
1351 526;
1360 526;
1048 525;
1082 525;
1272 525;
1359 525;
1368 525;
737 524;
824 524;
1041 524;
1049 524;
1149 524;
1194 524;
1222 524;
1377 524;
841 523;
863 523;
922 523;
949 523;
978 523;
1203 523;
1352 523;
1372 523;
1393 523;
1408 523;
740 522;
1031 522;
1062 522;
1107 522;
1236 522;
1271 522;
490 521;
826 521;
828 521;
893 521;
977 521;
1084 521;
1149 521;
1399 521;
937 520;
984 520;
1004 520;
1192 520;
1391 520;
880 519;
961 519;
1107 519;
1145 519;
947 518;
1021 518;
1173 518;
1227 518;
1253 518;
1265 518;
895 517;
1147 517;
1196 517;
1205 517;
1229 517;
1248 517;
1269 517;
1358 517;
1395 517;
1400 517;
506 516;
725 516;
853 516;
878 516;
885 516;
944 516;
1108 516;
1197 516;
1207 516;
1240 516;
1355 516;
603 515;
734 515;
1013 515;
1056 515;
1158 515;
1204 515;
1256 515;
750 514;
850 514;
885 514;
919 514;
970 514;
1014 514;
1065 514;
1098 514;
491 513;
590 513;
717 513;
848 513;
885 513;
959 513;
1027 513;
1094 513;
710 512;
838 512;
889 512;
955 512;
1060 512;
1065 512;
1075 512;
1083 512;
1103 512;
1112 512;
1166 512;
1240 512;
1252 512;
1366 512;
1396 512;
741 511;
848 511;
850 511;
1057 511;
1065 511;
1145 511;
1249 511;
591 510;
936 510;
966 510;
1000 510;
1053 510;
1168 510;
1172 510;
1403 510;
502 509;
870 509;
1038 509;
1068 509;
1179 509;
1376 509;
1059 508;
1079 508;
1120 508;
1217 508;
1230 508;
483 507;
486 507;
862 507;
891 507;
1200 507;
1409 507;
596 506;
731 506;
745 506;
1009 506;
1033 506;
1035 506;
1041 506;
1365 506;
1379 506;
1410 506;
497 505;
551 505;
723 505;
862 505;
875 505;
971 505;
1124 505;
887 504;
934 504;
969 504;
1011 504;
1062 504;
1064 504;
1177 504;
1209 504;
1271 504;
1273 504;
1379 504;
908 503;
998 503;
1085 503;
1249 503;
1384 503;
485 502;
871 502;
880 502;
903 502;
1067 502;
1164 502;
1175 502;
1230 502;
1402 502;
636 501;
742 501;
906 501;
990 501;
1093 501;
1203 501;
1258 501;
1373 501;
507 500;
558 500;
728 500;
752 500;
856 500;
972 500;
1001 500;
1120 500;
1125 500;
1203 500;
1204 500;
1396 500;
558 499;
623 499;
736 499;
909 499;
949 499;
1080 499;
1109 499;
1174 499;
1204 499;
1210 499;
1267 499;
490 498;
573 498;
740 498;
901 498;
914 498;
1018 498;
1066 498;
1192 498;
575 497;
720 497;
1104 497;
1404 497;
602 496;
752 496;
888 496;
951 496;
1030 496;
1072 496;
1079 496;
1092 496;
1124 496;
1214 496;
1215 496;
1226 496;
1235 496;
1377 496;
1378 496;
503 495;
640 495;
714 495;
1092 495;
1102 495;
506 494;
545 494;
641 494;
642 494;
731 494;
941 494;
960 494;
1011 494;
1156 494;
1404 494;
556 493;
650 493;
741 493;
895 493;
1097 493;
1157 493;
1264 493;
1364 493;
1365 493;
1371 493;
566 492;
603 492;
639 492;
874 492;
892 492;
895 492;
989 492;
997 492;
1047 492;
1048 492;
1053 492;
1058 492;
1118 492;
1219 492;
1229 492;
582 491;
882 491;
890 491;
966 491;
1065 491;
1170 491;
1198 491;
1267 491;
909 490;
1071 490;
1274 490;
1294 490;
539 489;
741 489;
985 489;
996 489;
1007 489;
1051 489;
1226 489;
1383 489;
1390 489;
537 488;
717 488;
898 488;
1044 488;
1048 488;
1198 488;
1248 488;
1373 488;
1380 488;
1410 488;
924 487;
1026 487;
1104 487;
1114 487;
1137 487;
1255 487;
1398 487;
609 486;
1019 486;
1111 486;
1412 486;
612 485;
718 485;
892 485;
925 485;
1056 485;
1063 485;
1106 485;
1191 485;
1250 485;
916 484;
1074 484;
1377 484;
558 483;
746 483;
1032 483;
1103 483;
1172 483;
1196 483;
897 482;
1066 482;
1120 482;
584 481;
623 481;
646 481;
912 481;
923 481;
937 481;
1011 481;
1077 481;
1091 481;
1214 481;
1266 481;
554 480;
563 480;
624 480;
739 480;
943 480;
981 480;
1114 480;
1411 480;
497 479;
594 479;
627 479;
740 479;
1015 479;
1184 479;
495 478;
560 478;
625 478;
974 478;
1021 478;
1135 478;
1243 478;
573 477;
734 477;
870 477;
940 477;
961 477;
1002 477;
1097 477;
622 476;
650 476;
893 476;
901 476;
1105 476;
1152 476;
1172 476;
1217 476;
1270 476;
1284 476;
1385 476;
559 475;
1020 475;
1044 475;
1169 475;
540 474;
578 474;
871 474;
896 474;
952 474;
1058 474;
1368 474;
1395 474;
501 473;
552 473;
630 473;
777 473;
908 473;
1146 473;
1267 473;
1298 473;
1407 473;
973 472;
975 472;
1183 472;
1207 472;
1231 472;
1244 472;
1278 472;
510 471;
728 471;
1207 471;
1257 471;
561 470;
717 470;
885 470;
936 470;
1029 470;
1185 470;
1389 470;
732 469;
777 469;
970 469;
1168 469;
1224 469;
627 468;
633 468;
719 468;
783 468;
917 468;
1019 468;
1026 468;
1043 468;
1082 468;
1169 468;
1236 468;
947 467;
1133 467;
1374 467;
774 466;
1057 466;
1112 466;
659 465;
673 465;
961 465;
1046 465;
1056 465;
1178 465;
1194 465;
565 464;
713 464;
726 464;
767 464;
961 464;
1081 464;
1128 464;
1407 464;
508 463;
758 463;
776 463;
871 463;
944 463;
954 463;
964 463;
998 463;
1035 463;
1252 463;
633 462;
643 462;
707 462;
1011 462;
1071 462;
1098 462;
1126 462;
1215 462;
1230 462;
1235 462;
546 461;
892 461;
1105 461;
1144 461;
1246 461;
1399 461;
642 460;
764 460;
884 460;
897 460;
1115 460;
1166 460;
510 459;
549 459;
878 459;
913 459;
928 459;
1035 459;
1043 459;
1152 459;
1223 459;
1373 459;
1375 459;
491 458;
640 458;
722 458;
981 458;
999 458;
1077 458;
1139 458;
1173 458;
1179 458;
1191 458;
1275 458;
1392 458;
1413 458;
539 457;
555 457;
715 457;
736 457;
972 457;
1021 457;
1053 457;
1156 457;
1276 457;
1390 457;
512 456;
871 456;
942 456;
995 456;
1039 456;
1167 456;
1211 456;
495 455;
546 455;
716 455;
734 455;
795 455;
1009 455;
1146 455;
1215 455;
1228 455;
1253 455;
1378 455;
507 454;
518 454;
790 454;
891 454;
966 454;
1053 454;
1114 454;
1117 454;
1149 454;
1407 454;
515 453;
538 453;
718 453;
950 453;
1064 453;
1173 453;
1255 453;
491 452;
889 452;
940 452;
1190 452;
1228 452;
1274 452;
926 451;
1003 451;
1026 451;
1073 451;
1077 451;
1081 451;
1084 451;
1130 451;
1164 451;
1225 451;
1306 451;
1366 451;
544 450;
656 450;
778 450;
971 450;
1037 450;
1066 450;
1145 450;
1204 450;
1228 450;
963 449;
985 449;
990 449;
1225 449;
1364 449;
491 448;
721 448;
801 448;
908 448;
987 448;
994 448;
1253 448;
1297 448;
501 447;
872 447;
989 447;
1101 447;
1169 447;
1257 447;
1366 447;
536 446;
794 446;
951 446;
1050 446;
510 445;
661 445;
926 445;
1053 445;
1171 445;
1396 445;
516 444;
535 444;
810 444;
991 444;
1263 444;
1369 444;
916 443;
920 443;
936 443;
1035 443;
1385 443;
532 442;
668 442;
784 442;
902 442;
1117 442;
655 441;
809 441;
906 441;
1000 441;
1156 441;
1225 441;
1400 441;
511 440;
513 440;
909 440;
1232 440;
1412 440;
507 439;
787 439;
967 439;
1116 439;
1129 439;
1156 439;
1241 439;
1258 439;
1308 439;
655 438;
715 438;
717 438;
790 438;
806 438;
982 438;
1167 438;
1279 438;
648 437;
779 437;
1153 437;
1253 437;
1263 437;
667 436;
822 436;
1018 436;
1175 436;
512 435;
795 435;
874 435;
891 435;
944 435;
1120 435;
1131 435;
1142 435;
1241 435;
1374 435;
1409 435;
532 434;
937 434;
1000 434;
1019 434;
1286 434;
497 433;
507 433;
649 433;
665 433;
899 433;
901 433;
971 433;
979 433;
1044 433;
1114 433;
1142 433;
1174 433;
1233 433;
1243 433;
1402 433;
716 432;
877 432;
1002 432;
1098 432;
519 431;
523 431;
669 431;
922 431;
950 431;
1032 431;
1201 431;
1246 431;
529 430;
531 430;
834 430;
1116 430;
1136 430;
1254 430;
1265 430;
1375 430;
1390 430;
718 429;
1191 429;
1236 429;
882 428;
948 428;
1030 428;
1048 428;
1055 428;
1059 428;
1391 428;
653 427;
828 427;
996 427;
1006 427;
1012 427;
1049 427;
1084 427;
1122 427;
1168 427;
528 426;
661 426;
999 426;
1015 426;
1076 426;
1269 426;
1405 426;
655 425;
796 425;
915 425;
917 425;
993 425;
1203 425;
1403 425;
509 424;
667 424;
1129 424;
794 423;
889 423;
919 423;
990 423;
1127 423;
1176 423;
1195 423;
1203 423;
1305 423;
1363 423;
1380 423;
679 422;
881 422;
896 422;
1106 422;
1114 422;
1159 422;
1205 422;
1277 422;
1286 422;
537 421;
796 421;
838 421;
1018 421;
1150 421;
1169 421;
1250 421;
1259 421;
655 420;
658 420;
816 420;
877 420;
900 420;
916 420;
919 420;
920 420;
1001 420;
1013 420;
1107 420;
1129 420;
1248 420;
1260 420;
1367 420;
1386 420;
1398 420;
835 419;
921 419;
982 419;
1018 419;
1158 419;
1167 419;
1257 419;
1258 419;
654 418;
662 418;
684 418;
892 418;
1052 418;
1171 418;
1244 418;
1270 418;
1384 418;
1410 418;
992 417;
1093 417;
1114 417;
1355 417;
520 416;
682 416;
854 416;
1037 416;
1123 416;
1205 416;
888 415;
905 415;
924 415;
937 415;
1028 415;
1087 415;
1200 415;
1383 415;
681 414;
878 414;
965 414;
1029 414;
1134 414;
1142 414;
1185 414;
1309 414;
1366 414;
1381 414;
516 413;
537 413;
838 413;
929 413;
968 413;
998 413;
1047 413;
1064 413;
1072 413;
1077 413;
1081 413;
1102 413;
1145 413;
1295 413;
1353 413;
1354 413;
1406 413;
804 412;
815 412;
841 412;
859 412;
917 412;
1041 412;
1051 412;
1128 412;
501 411;
540 411;
667 411;
1005 411;
1046 411;
1132 411;
1163 411;
1396 411;
658 410;
853 410;
864 410;
901 410;
1023 410;
1266 410;
501 409;
535 409;
648 409;
908 409;
1306 409;
1388 409;
1409 409;
512 408;
540 408;
976 408;
992 408;
1006 408;
1024 408;
1058 408;
1148 408;
1206 408;
1367 408;
869 407;
916 407;
1042 407;
1105 407;
1152 407;
1162 407;
1253 407;
1305 407;
1405 407;
674 406;
873 406;
921 406;
963 406;
1004 406;
1047 406;
1138 406;
1158 406;
1164 406;
1245 406;
1249 406;
1254 406;
1294 406;
1379 406;
988 405;
993 405;
1056 405;
1067 405;
1081 405;
1083 405;
1162 405;
1182 405;
679 404;
889 404;
980 404;
1052 404;
1155 404;
511 403;
985 403;
1270 403;
1362 403;
1366 403;
647 402;
660 402;
850 402;
852 402;
855 402;
913 402;
962 402;
1043 402;
1288 402;
1358 402;
847 401;
908 401;
1073 401;
1090 401;
527 400;
653 400;
904 400;
1029 400;
1163 400;
1182 400;
1189 400;
1270 400;
516 399;
889 399;
1000 399;
1008 399;
1038 399;
1060 399;
1277 399;
508 398;
824 398;
837 398;
970 398;
1127 398;
1145 398;
1263 398;
840 397;
870 397;
887 397;
922 397;
1026 397;
1060 397;
1168 397;
1268 397;
1348 397;
856 396;
967 396;
1016 396;
1154 396;
1287 396;
1368 396;
510 395;
537 395;
855 395;
913 395;
979 395;
1291 395;
1294 395;
828 394;
886 394;
998 394;
1042 394;
1047 394;
1105 394;
1165 394;
533 393;
681 393;
829 393;
1074 393;
1091 393;
1170 393;
1235 393;
842 392;
851 392;
882 392;
1001 392;
1070 392;
1178 392;
1193 392;
1296 392;
1361 392;
645 391;
657 391;
837 391;
969 391;
1013 391;
1050 391;
1128 391;
1130 391;
1386 391;
1397 391;
641 390;
1047 390;
1245 390;
1253 390;
1264 390;
1275 390;
527 389;
852 389;
865 389;
981 389;
1011 389;
1131 389;
1242 389;
1251 389;
1299 389;
1310 389;
1378 389;
908 388;
1106 388;
867 387;
1021 387;
1047 387;
1080 387;
1090 387;
1254 387;
1264 387;
1385 387;
1022 386;
1039 386;
1084 386;
1139 386;
849 385;
859 385;
1088 385;
1102 385;
539 384;
1159 384;
1267 384;
536 383;
890 383;
1092 383;
1158 383;
1257 383;
1386 383;
523 382;
537 382;
865 382;
1266 382;
1314 382;
515 381;
550 381;
905 381;
1079 381;
1157 381;
1255 381;
1313 381;
1386 381;
1392 381;
668 380;
890 380;
901 380;
973 380;
988 380;
1050 380;
1138 380;
1398 380;
851 379;
859 379;
878 379;
988 379;
996 379;
1127 379;
1174 379;
1178 379;
1042 378;
1089 378;
1117 378;
1165 378;
1131 377;
1151 377;
1283 377;
1306 377;
528 376;
556 376;
652 376;
966 376;
1079 376;
1091 376;
1170 376;
1266 376;
1389 376;
632 375;
862 375;
1270 375;
1376 375;
545 374;
628 374;
906 374;
907 374;
1185 374;
1371 374;
661 373;
995 373;
545 372;
868 372;
996 372;
1023 372;
1031 372;
1046 372;
1265 372;
1293 372;
557 371;
657 371;
980 371;
1060 371;
1258 371;
890 370;
895 370;
903 370;
1070 370;
1154 370;
1165 370;
1249 370;
1306 370;
1390 370;
576 369;
665 369;
899 369;
1015 369;
1148 369;
1197 369;
603 368;
622 368;
548 367;
580 367;
595 367;
901 367;
1025 367;
1055 367;
1073 367;
1075 367;
1179 367;
1257 367;
1383 367;
597 366;
1006 366;
1080 366;
1097 366;
1151 366;
1384 366;
551 365;
627 365;
1045 365;
1050 365;
1092 365;
1182 365;
541 364;
910 364;
997 364;
1121 364;
1258 364;
525 363;
594 363;
888 363;
900 363;
914 363;
979 363;
1306 363;
644 362;
902 362;
974 362;
1003 362;
1091 362;
1252 362;
1303 362;
1370 362;
1381 362;
624 361;
973 361;
1003 361;
1121 361;
1127 361;
1286 361;
1075 360;
1111 360;
1276 360;
1393 360;
517 359;
539 359;
577 359;
591 359;
619 359;
629 359;
1076 359;
1253 359;
1270 359;
1296 359;
1395 359;
527 358;
545 358;
635 358;
893 358;
1032 358;
1132 358;
1240 358;
1244 358;
1269 358;
1295 358;
1391 358;
557 357;
560 357;
1007 357;
1030 357;
1040 357;
1095 357;
1180 357;
1394 357;
771 356;
1012 356;
1129 356;
1135 356;
1174 356;
1263 356;
1268 356;
1290 356;
1391 356;
594 355;
990 355;
995 355;
1179 355;
1292 355;
1012 354;
1123 354;
1301 354;
533 353;
549 353;
1046 353;
1152 353;
1246 353;
761 352;
1047 352;
1057 352;
1164 352;
622 351;
778 351;
1013 351;
1015 351;
1021 351;
1066 351;
1094 351;
1139 351;
1171 351;
1368 351;
574 350;
1038 350;
1298 350;
582 349;
611 349;
1033 349;
1104 349;
1142 349;
1177 349;
1238 349;
1266 349;
1267 349;
777 348;
1008 348;
1108 348;
1390 348;
789 347;
976 347;
1138 347;
1174 347;
1294 347;
552 346;
892 346;
1030 346;
1097 346;
1238 346;
1241 346;
1245 346;
778 345;
990 345;
1026 345;
1065 345;
780 344;
893 344;
1021 344;
1032 344;
1172 344;
1227 344;
1290 344;
526 343;
530 343;
783 343;
985 343;
997 343;
1023 343;
1038 343;
1119 343;
1145 343;
979 342;
982 342;
1150 342;
1259 342;
537 341;
1057 341;
1135 341;
1189 341;
1246 341;
1133 340;
1143 340;
1166 340;
1258 340;
541 339;
884 339;
537 338;
554 338;
1037 338;
1046 338;
1113 338;
1252 338;
1257 338;
1309 338;
529 337;
534 337;
782 337;
1291 337;
1122 336;
1164 336;
1177 336;
1027 335;
1134 335;
1141 335;
538 334;
784 334;
988 334;
1019 334;
1159 334;
1173 333;
1185 333;
1291 333;
543 332;
1003 332;
1018 332;
1104 332;
1053 331;
1130 331;
773 330;
1035 330;
1272 330;
1367 330;
541 329;
736 329;
741 329;
791 329;
792 329;
1014 329;
1047 329;
1177 329;
734 328;
764 328;
1055 328;
1102 328;
545 327;
784 327;
990 327;
1018 327;
1096 327;
1098 327;
1142 327;
1177 327;
1291 327;
1002 326;
1025 326;
1028 326;
1369 326;
781 325;
1029 325;
1261 325;
1379 325;
781 324;
786 324;
1094 324;
1107 324;
1167 324;
1185 324;
774 323;
1028 323;
1145 323;
1191 323;
1261 323;
1377 323;
758 322;
788 322;
794 322;
1021 322;
1023 322;
1045 322;
1276 322;
725 321;
1051 320;
1130 320;
1267 320;
1272 320;
1297 320;
800 319;
1105 319;
1137 319;
1152 319;
1184 319;
1025 318;
1286 318;
567 317;
779 317;
1002 317;
1094 317;
1102 317;
1286 317;
1052 316;
1056 316;
1095 316;
1171 316;
1107 315;
991 314;
1037 314;
1139 314;
1162 314;
1192 314;
1304 314;
556 313;
749 312;
750 312;
766 312;
769 312;
1002 312;
1146 312;
1149 312;
1157 312;
1144 311;
1147 311;
1156 311;
1286 311;
1295 311;
759 310;
796 310;
801 310;
999 310;
1298 310;
1358 310;
1192 309;
783 308;
1022 308;
1108 308;
1119 308;
812 307;
1111 307;
1140 307;
552 306;
555 306;
1165 306;
773 305;
1173 305;
1273 305;
565 304;
577 304;
1192 304;
1269 304;
785 303;
1036 303;
1132 303;
1136 303;
574 302;
785 302;
1135 302;
1165 302;
1293 302;
762 301;
990 301;
1149 301;
1160 301;
1257 301;
572 300;
794 300;
799 300;
1366 300;
546 299;
1141 299;
1158 299;
1278 299;
826 298;
1190 298;
573 297;
1113 297;
1144 297;
578 296;
769 296;
828 296;
1022 296;
1034 296;
1043 296;
1138 295;
1298 295;
780 294;
1029 294;
1036 294;
1143 294;
1261 294;
1007 293;
1013 293;
1193 293;
567 292;
985 292;
1153 292;
1294 292;
1281 291;
566 290;
779 290;
1045 290;
1107 290;
1247 290;
553 289;
579 289;
734 289;
1025 289;
1053 289;
1056 289;
1094 289;
1141 289;
776 288;
590 287;
1258 287;
773 286;
776 286;
841 286;
1037 286;
1153 286;
772 285;
848 285;
1029 285;
1041 285;
1153 285;
1158 285;
1253 285;
862 284;
959 284;
1104 284;
1259 284;
735 283;
939 283;
966 283;
985 283;
1104 283;
927 282;
1095 282;
1102 282;
1167 282;
1015 281;
1269 281;
1354 281;
887 280;
965 280;
1013 280;
1017 280;
1022 280;
1059 280;
1087 280;
1243 280;
804 279;
866 279;
1123 279;
1157 279;
1357 279;
725 278;
798 278;
1253 278;
1275 278;
834 277;
1046 277;
1261 277;
1348 277;
585 276;
729 276;
760 276;
854 276;
901 276;
914 276;
970 276;
1150 276;
592 275;
793 275;
800 275;
837 275;
976 275;
977 275;
1032 275;
831 274;
835 274;
1027 274;
1147 274;
1249 274;
1253 274;
583 273;
814 273;
928 273;
998 273;
742 272;
744 272;
845 272;
867 272;
1040 272;
1260 272;
848 271;
915 271;
958 271;
988 271;
1017 271;
1144 271;
1244 271;
1281 271;
906 270;
1048 270;
1252 270;
584 269;
812 269;
923 269;
996 269;
1026 269;
1029 269;
579 268;
588 268;
930 268;
989 268;
1028 268;
1035 268;
1155 268;
1350 268;
1125 267;
1145 267;
1231 267;
566 266;
585 266;
606 266;
944 266;
952 266;
955 266;
988 266;
599 265;
822 265;
936 265;
1108 265;
1114 265;
1225 265;
821 264;
928 264;
939 264;
943 264;
967 264;
1045 264;
1115 264;
1244 264;
721 263;
968 263;
1011 263;
1094 263;
1113 263;
1138 263;
1248 263;
608 262;
609 262;
1010 262;
1018 262;
1024 262;
1101 262;
854 260;
871 260;
921 260;
929 260;
937 260;
961 260;
1089 260;
1151 260;
944 259;
1263 259;
815 258;
1276 258;
857 257;
876 257;
920 257;
1019 257;
1054 257;
1094 257;
1170 257;
1338 257;
833 256;
955 256;
969 256;
1045 256;
1119 256;
1237 256;
1248 256;
1264 256;
836 255;
871 255;
1014 255;
1088 255;
1170 255;
931 254;
942 254;
1237 254;
920 253;
955 253;
598 252;
923 252;
936 251;
939 251;
968 251;
1126 251;
969 250;
1130 250;
616 249;
1095 249;
1137 249;
1138 249;
1236 249;
1245 249;
1276 249;
1334 249;
1110 248;
834 247;
1160 247;
601 246;
1083 246;
1225 245;
1324 245;
837 244;
1121 244;
1142 244;
1218 244;
1094 243;
608 242;
1113 242;
1218 242;
1228 242;
1253 242;
1321 242;
1207 240;
1077 239;
1216 239;
1239 238;
1137 237;
838 236;
1217 236;
1265 236;
1130 235;
1245 235;
1317 235;
1043 234;
1070 234;
1220 234;
1260 234;
1316 234;
1068 233;
1198 233;
635 232;
1087 232;
624 231;
630 231;
844 231;
1076 231;
616 230;
622 230;
1093 230;
1313 230;
641 229;
1234 229;
1118 228;
1122 228;
1125 227;
1070 226;
1252 226;
1264 226;
828 225;
1076 225;
1071 224;
1074 224;
1094 224;
1196 224;
1076 223;
1122 223;
600 222;
603 222;
842 222;
603 221;
1076 221;
1108 221;
1125 221;
1240 221;
647 220;
1081 220;
1082 220;
1093 220;
843 219;
1088 219;
1101 218;
644 217;
1057 217;
830 216;
831 216;
1112 216;
1211 215;
1231 215;
1305 215;
1120 214;
1209 214;
1212 214;
634 213;
824 213;
1054 213;
830 212;
1096 212;
1129 212;
1248 212;
623 211;
1108 211;
1209 211;
658 210;
1055 210;
1079 210;
1128 210;
1249 210;
840 209;
1085 208;
1233 208;
1116 207;
1212 207;
1243 207;
622 206;
1090 206;
1219 206;
617 205;
620 205;
845 205;
662 204;
1107 204;
1238 204;
657 203;
1083 203;
1061 202;
1202 202;
1230 202;
1237 202;
1291 201;
680 200;
1069 200;
1242 200;
649 198;
674 198;
680 197;
1078 197;
1079 197;
1058 196;
1209 195;
841 194;
1102 194;
1037 193;
1071 193;
1231 193;
1243 193;
1033 192;
1280 192;
1034 191;
1085 191;
659 190;
1046 190;
824 189;
1061 189;
1279 189;
685 188;
1057 187;
1056 186;
1209 186;
686 185;
700 185;
1025 185;
1075 185;
1080 185;
1094 185;
654 184;
680 184;
686 184;
1047 184;
1053 184;
1076 184;
1090 184;
678 183;
1068 183;
1228 183;
702 182;
1214 182;
1054 180;
1216 180;
1232 180;
1093 179;
1197 179;
699 178;
1228 178;
1230 178;
1231 178;
1190 177;
1213 177;
1223 177;
686 176;
719 176;
1059 176;
685 175;
700 175;
1075 175;
1190 175;
662 174;
1192 174;
1263 174;
688 172;
708 172;
1197 172;
1064 171;
1063 170;
670 169;
690 169;
699 169;
1007 169;
1032 169;
1085 169;
1190 169;
703 168;
729 167;
985 167;
1195 167;
705 166;
982 166;
1212 166;
1182 165;
726 164;
1182 164;
1217 164;
683 163;
750 163;
1015 163;
1037 163;
1178 163;
1216 163;
689 162;
1015 161;
1173 161;
1212 161;
694 160;
737 160;
760 160;
986 160;
1009 160;
1044 160;
700 159;
765 159;
964 158;
1026 158;
1165 158;
960 157;
1044 157;
1174 157;
1180 157;
714 155;
737 155;
709 154;
724 154;
703 153;
984 153;
1014 153;
1187 153;
978 152;
993 152;
1037 152;
1179 152;
717 151;
954 151;
942 150;
1158 150;
1162 150;
775 149;
981 149;
719 148;
752 148;
1034 148;
717 147;
749 147;
765 147;
789 147;
1018 147;
1182 147;
730 146;
970 146;
995 146;
1131 146;
1158 146;
732 145;
924 145;
995 145;
1009 145;
716 144;
778 144;
1140 144;
713 143;
731 143;
848 143;
1102 143;
1148 143;
770 142;
980 142;
1097 142;
1144 142;
1159 142;
726 141;
755 141;
770 141;
780 141;
967 141;
1006 141;
1095 141;
1137 141;
1162 141;
778 140;
1131 140;
732 139;
827 139;
847 139;
1004 139;
1148 139;
1150 139;
737 138;
754 138;
824 138;
835 138;
920 138;
999 138;
1107 138;
1137 138;
806 137;
808 137;
826 137;
850 137;
1012 137;
1037 137;
753 136;
774 136;
900 136;
953 136;
957 136;
1162 136;
925 135;
997 135;
1108 135;
1122 135;
1157 135;
741 134;
856 134;
871 134;
903 134;
1031 134;
1100 134;
1144 134;
738 133;
776 133;
918 133;
962 133;
971 133;
1141 133;
762 132;
829 132;
951 132;
817 131;
944 131;
773 130;
861 130;
867 130;
969 130;
790 129;
816 129;
916 129;
925 129;
779 128;
836 128;
756 127;
806 127;
823 127;
987 127;
1130 127;
798 126;
900 126;
769 125;
856 125;
905 125;
959 125;
1112 125;
761 124;
835 124;
930 124;
1103 124;
1153 124;
867 123;
878 123;
880 123;
969 123;
1116 123;
831 122;
884 122;
777 121;
818 121;
984 120;
1098 120;
837 119;
856 119;
932 119;
977 119;
1125 119;
940 118;
954 118;
975 118;
1120 118;
1124 118;
1144 118;
923 117;
1109 117;
1116 117;
877 116;
1130 115;
1133 115;
769 114;
818 114;
855 114;
1128 114;
795 113;
892 113;
1115 113;
1120 113;
1133 113;
818 112;
897 112;
965 112;
1119 112;
750 111;
835 111;
940 111;
963 111;
1105 111;
850 110;
868 110;
982 110;
788 109;
833 109;
866 109;
882 109;
926 109;
894 108;
967 108;
1108 108;
1117 108;
785 107;
858 107;
877 107;
886 107;
932 107;
1109 107;
780 106;
1130 106;
771 105;
802 105;
923 105;
1115 105;
831 103;
1091 103;
1128 102;
858 101;
846 100;
898 100;
1084 100;
908 99;
912 99;
1116 99;
820 98;
825 98;
858 96;
1079 96;
896 95;
1077 95;
897 94;
1088 94;
920 93;
1076 93;
906 92;
1078 92;
1063 90;
1102 89;
1104 87;
1049 85;
1057 85;
1085 83;
1058 82;
1022 80;
1033 80;
1063 79;
1022 77;
1056 76;
1007 75;
1027 74;
1015 73;
1058 73;
998 69;
990 63;
905 62;
916 62;
925 62;
929 60;
908 58]


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
	n = Int64(size(dists,2)) 
	num_ants = Int64(length(ants)) #a
	for k in missing #for each of k ants

		missing #build a new trail
		missing #update the ants vector by assigning the new trail to the kth ant 
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
	n = Int64(size(dists,2))
	probs = getprobs(k::Int, cityX::Int, visited, pheromones, dists, n::Int)
	cumul = zeros(length(probs)+1) #init cumulative probability array 
	
	for i in 1:length(probs)
		cumul[i+1] = cumul[i] + probs[i] #cumul = the previous sum + next prob 
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
	trail = zeros(Int64, n+1)
	visited = falses(n+1)

	trail[1] = start 
	visited[start] = true 
	trail[n+1] = start
	
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
		newtrail = buildtrail(k, start, pheromones, dists, n)
		ants[k] = newtrail
	end
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
	chrono_trail = 1:(n) |> collect #chronological trail 
	
	trail = shuffle(chrono_trail)

	idx = getidx(trail, start)
	temp = trail[1]  #Julia starts at 1 indexing
	trail[1] = trail[idx] #swap the start city with the 
	trail[idx] = temp 
	append!(trail,start) #cycle back to the "colony" or origin city
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
		t = randomtrail(start, n)	 # changed from n+1 today 
		push!(ants,t)
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

	- citycoords: an nx2 matrix providing the x,y coordinates for the n cities in the graph
	- a: an integer determing the number of ants that travel the graph	

Outputs:

	- start: an integer representting start city (i.e. colony location) 
	- dists: symmetric distance matrix for which any entry (i,j) represents the distance between two cities i and j
	- ants: an array of arrays, where the number of arrays is equal to the number of ants, and each any array is a solution (ordered trail) 
	- best_t: the index of the best solution in the ants array 
	- best_l: the total length of best_t
"""
function init_aco(citycoords, a::Int=4)
	n = Int64(size(citycoords,1)) 
	start = Int64(rand(1:n))
	dists = dist(citycoords,citycoords)
	ants = initants(start, a, n)	
	
	best_t = best_trail(ants, dists)	
    best_l = trailsum(best_t, dists)		

    pheromones = initpheromones(n)		
	
	return start, dists, ants, best_t, best_l, pheromones, n, a
end

# ╔═╡ 47c98bd7-f84d-455d-a417-5ffc93fa6fdd
colony4, dists4, ants4, bestroute4, routelength4, pheromones4, n4, a4 = init_aco(coords4)

# ╔═╡ a14949b9-77b2-4f32-89f7-d2316736e803
#run initialization here (optionally specify the number of ants)
colony25, dists25, ants25, bestroute25, routelength25, pheromones25, n25, a25 = init_aco(coords25, 20) 

# ╔═╡ 0f903495-cfbf-4ce2-9851-a49aba684e6a
starttoto, diststoto, antstoto, best_tourtoto, tour_lengthtoto, pheromonestoto, ntoto, atoto = init_aco(some_totoro_coords, 6) 

# ╔═╡ dcf0c148-2f9a-4083-9739-89a891574eda
begin
	acycletotoro = randomtrail(starttoto, ntoto)
	atourtotoro = acycletotoro[1:ntoto]
	acosttotoro = round(trailsum(acycletotoro, diststoto), digits = 3)
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
    currbest_T = zeros(Int64, n+1)
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
tour_lengthTotoro, best_tourTotoro = aco(starttoto, diststoto, antstoto, best_tourtoto, tour_lengthtoto, pheromonestoto, ntoto, atoto, ktoto) 

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
# ╟─139df66d-b0bf-4adb-891a-18c9fad6db87
# ╠═47c98bd7-f84d-455d-a417-5ffc93fa6fdd
# ╟─2e5ff5ca-04fa-47c0-b9d5-03130097df57
# ╠═82a213e4-3c70-48c5-8b82-f4ff6ea55603
# ╟─681ec771-af2c-41e1-8d6a-3067188c3d6e
# ╠═3feacf51-4113-45eb-bf99-f01c8b3b9a16
# ╟─dbb0ae04-589b-475d-ba59-95367fccd96b
# ╟─06009ce9-99a0-4568-814b-4f56cfd1815a
# ╟─faa44127-59c5-486e-9e2a-19c768830da0
# ╟─1922c5e9-8275-4fbd-9d4b-af92d0ffb039
# ╠═43d58b74-9388-4b97-9a94-7191952f4184
# ╟─1ce28f18-368d-4a0c-84e6-129d7fed30a5
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
# ╟─f6152a42-bb18-4a17-94b3-b9885d6885d4
# ╟─c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╟─f6de5186-e714-4962-801e-e1e52bef8af7
# ╟─f125718f-54f0-481c-a23d-98cce6e12a4f
# ╠═a14949b9-77b2-4f32-89f7-d2316736e803
# ╟─93025b8d-6773-4cee-99c3-7da7498597de
# ╠═4d97ef57-3a6c-4850-afa3-1b2bf83ab146
# ╠═07f1ae73-ef20-4be4-81a2-99c7e9651e02
# ╟─855e5ce1-d143-4af5-841d-331add7c3880
# ╟─9f55aa64-cbcf-4148-91b1-e8d5f7df299f
# ╟─89ad5ab5-8676-45d7-9506-7321a5cd8e44
# ╟─a4741762-a76d-4626-8acd-26ac22e9d6cd
# ╟─9faf5ebd-1c73-4ddf-876c-b1b042389290
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
# ╟─b8a1320e-f7af-4598-b5ee-68b28f25dc47
# ╟─2fbf893e-5ced-4233-90a4-3dce09fb5ed0
# ╟─554154af-0a61-4b4f-b363-bc856bfc32f4
# ╟─cffe3e0b-f1a8-423f-8c3a-c98f1bda82d7
# ╟─8f3b6386-2a28-4433-bcef-f4f2250072a0
# ╟─195eb6d1-1d67-4c08-bdb7-a27dbe5d6d84
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
# ╠═b2c4ecf1-e86c-42f7-b186-f7f3e528b902
# ╠═67c91979-c561-4ac6-aa43-00ed552d109d
# ╟─d5679d24-9901-4b1c-8554-1981c532e4b8
# ╟─017fd37b-e872-405c-8ab2-a713cecb9a8d
# ╟─cdc1c7d3-c230-4a39-80b6-fdea2d6fb66f
# ╟─d541900d-92ed-4d69-850a-861b805f2eb8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
