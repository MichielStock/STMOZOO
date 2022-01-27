### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 45160a1e-cb93-48bf-b2b9-35c337780a73
using ShortCodes # to use YouTube()

# ╔═╡ 82d25b0c-f900-4996-99c9-fdb1bbe7cae4
using Random # to use rand() 

# ╔═╡ a3a91caa-db4a-49da-bda9-1fffd9498ce8
using LinearAlgebra # to use Symmetric)

# ╔═╡ 69899fd8-3b3f-4220-8997-88208c6177ca
md"""
*Natalie Thomas*\
*STMO Fall 2021*\
*Target audience: This notebook is intended for people with basic (introductory) knowledge of optimization problems and related terminology, and whom are relatively inexperienced with Julia*. 
"""

# ╔═╡ 3a5e53ea-b36d-4e97-af88-75bee3180b2a
md"""
# Ant Colony Optimization

#### Prerequisite terminology:

**Heuristic**: A problem-solving approach that does not guarantee an optimal solution but returns a sufficient enough approximation; typically employed when finding the optimal solution is impossible or inefficient.

**Metaheuristic**: From "meta" (above) and "heurisein" (to find). These methods begin from a null solution and build toward a complete solution, the goal being to escape being trapped in local optima. These methods could also comprise of a local search beginning with a complete solution and iteratively modifying it to search for a better one. 

**NP-problem**: A nondeterministic polynomial time problem. A solution for this problem can be reduced to a polynomial-time verification. A problem is NP-hard its algorithm can be translated into another algorithm for any other NP-hard problem. The optimum solution of NP-problem often (but not always) requires an exhaustive search. 

**NP-hard problem**: A class of problem that is translatable into an NP-problem; it is at least as hard as an NP-problem. A problem is NP-hard if its algorithm can be translated into another algorithm for any other NP-hard problem.

**Pheromone**: A chemical produced and secreted into the environment by an animal that affects the behavior or physiology of others of its species. Pheromones can encode many different signals and may be smelled by other community memoirs and (for example) trigger a social response. 


## The Travelling Salesman Problem
**Ant Colony Optimization** (ACO) is an umbrella term for a group of algorithms used to solve the Travelling Salesman Problem (TSP).

> **Problem definition**: Given a list of cities and the distances between each pair of cities, find the shortest possible route that visits each city exactly once and returns to the origin city.

![](https://github.com/natclaret/Ant_Colony_Optimization.jl/blob/master/notebook/ACO_images/TSP_solution_200w.png?raw=true)

The solution to the TSP is a route that minimizes the distance a salesman must travel to complete their sales route and return to their home (or starting) city. Therein lies the challenge: the TSP is an NP-hard problem, so an exhaustive search of all possible solutions is not only unideal, it is often impossible due to combinatorial explosion. On the other hand, any proposed solution can be easily checked against another to see which is the shorter route. 

There are many flavors of optimization algorithms that give heuristic solutions to the TSP. Developing TSP algorithms is of interest because of the ubiqutiy of such problems. Planning vehicular/trucking routes is one of the more straightforward applications of TSP, but aside from planning and logistics, the TSP appears frequently in other industries such as computing and bioinformatics (for example: [DNA sequencing](http://www.cs.cmu.edu/afs/cs/academic/class/15210-s15/www/lectures/genome-notes.pdf) and [microchip manufactoring](https://www.emerald.com/insight/content/doi/10.1108/03056120910979512/full/html)).
"""

# ╔═╡ 6608e84a-fb31-492a-aced-70b32e3c6a14
md""" 
## Inspiration for ACO: ant foraging behavior

Ant Colony Optimization is a term for a group of metaheuristics that solve the TSP. It is based on ant foraging behavior. Simulates the process of any colony foraging and is established using the “internal information transmission mechanism of ant colony”.

Ants live in community nests or colonies. When a forager ant leaves its colony, it travels randomly until it finds a food source, then it carries as much food as possible back to its colony. Along the way, it deposits pheromones. Pheromones faciliate indirect communication to other ants and conveys information about the food the ant is carrying. Other ants can smell the pheromones and retrace the ant's path to the food. The higher the pheromone level, the greater probability that proceeding ants choose that path. This results in a positive-feedback loop: as more ants choose a particular path, they will in turn deposit more pheromones, ultimately converging on an optimal path between the food and the colony. 

#### Any colony simulation
The YouTube video below shows an ant colony foraging simulation. Pheromone trails are shown in white.
"""

# ╔═╡ 249340e4-c31a-46a3-a620-ceef9abaadb5
YouTube("3YXikOL_3l0", 0, 15) 

# ╔═╡ 533aad3f-fd08-4004-b93f-60f056d05791
md"""
*Reflect on the video*:
- How do the paths converge (or not) over time?
- Does the path convergence rate seem to be steady, grow, or decay over time?
- Do the pheromone trails stay steady or fade over time?
- Why do some ants seem to ignore the pheromone trail all together?

"""

# ╔═╡ 67d95176-fc53-4daa-931f-1a7baa29e888
md"""
### ACO algorithm
"Ants" are agents that locate solutions by moving through a parameter space representative of all possible solutions. To begin, ants traverse the space randomly and individually. Each ant's solution is scored (i.e. it's path length is calculated). The shorter the path, the higher the solution quality. Ants lay down pheromones along their paths that are proportional to the quality of their respective solutions. 

After initial (random) paths and path scores are calculated, the ants are deployed again. This time, pheromone information informs path decisions taken by the ants. After each successive run (or iteration), path scores are re-calculated and pheromones are adjusted accordingly. The algorithm stops after a fixed number of iterations. 

#### Important features of ACO:
- ACO is a **probabilistic** technique in that it makes use of *a priori* information about the structure of possible good solutions to produce new ones. This is communicated by pheromones, which attract ants to more attractive paths.  
- ACO has an element of **randomness** or stochasticity. Path decisions are made by randomly selecting a value from a cumulative probability array constructed according to pheromone information (the selected value corresponds to deciding where to go next). This means ants retain some "individualism" and can forge or follow a path that does not adhere to the (current) best solution. 
- **Pheromones evaporate** over time, which helps avoid getting stuck in local optima.
- ACO can run **continuously** and can therefore adadpt to environmental conditions in real time. 

"""

# ╔═╡ 4d3e3f09-ee88-47b5-a03f-93d034cbee45
md"""
## ACO parameters 

- numCities
- numAnts
- maxTime
- α
- β
- MaxValue
- ρ

"""

# ╔═╡ bc7b209a-32e9-4e60-a79b-46a404cc2a7e
md"""
#### Pseudocode

>*input* number of ants **numAnts** and number of cities **numCities** (both integers)\
>\
>*initialize* **start, dists, ants, bestTrail, bestLength, pheromones**\
>\
> **repeat**\
>
>> 1. generate ant paths\
>> 2. calculate path scores\
>> 3. find best solution\
>> 4. update pheromone trail\
>**output bestPath, bestPathLength**
"""

# ╔═╡ 2395128d-9af8-460e-a36f-05b3aeb00afb
md" ### initialize the run"

# ╔═╡ 02cdf94d-d9b5-4767-89a0-89d927e899fb
md" ### run optimization"

# ╔═╡ 9c76a78c-7718-44a8-9399-f66c8683e97b
#SOLUTION

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
md""" ### Under the hood"""

# ╔═╡ 7a01418b-2543-433b-942e-92ce38a29496
md"""

A list of functions and their parameters is given below. Indention denotes function calling. For example:
	
	function1(A,B)
	
		function2(C,D)

... means funtion1 calls function2. 

Initialization functions:

	InitColonyOptimization(numCities::Int=10, numAnts::Int=4)

		makeGraphDistances(numCities) 

		initAnts(numAnts, numCities)

			randomTrail(start, numCities) 

				indexOfTarget(trail, target) 

		initPheromones(numCities)

		trailSum(trail, dists) #Length()

		bestTrail(ants, dists)


Main functions:

	AntColonyOptimization(start, dists, ants, bestTrail, bestLength, pheromones, numCities, numAnts, maxTime::Int=10)

	updateAnts(ants, pheromones, dists)

			buildTrail(k, start, pheromones, dists)

					nextCity(k, cityX, visited, pheromones, dists) 

						moveProbs(k, cityX, visited, pheromones, dists)

							Distance(cityX, cityY, dists) 

					Distance(cityX, cityY, dists) 

		updatePheromones(pheromones, ants, dists)

			edgeInTrail(nodeX, nodeY, trail) 
"""

# ╔═╡ 3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
"""
	makeGraphDistances(numCities) 

Generates an nxn symmetric matrix with 0s on the diagonal 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- a simulated graph
"""
function makeGraphDistances(numCities::Int)
	n = numCities
	m = rand(1:10, n, n)  
	matrix = Symmetric(m)

	for i in 1:n
		matrix[i,i] = 0
	end

	return matrix#, n
	
end

# ╔═╡ c8de83fa-1519-48d0-b257-97bfeb4952ad
#CHECKED
"""
	Distance(cityX, cityY, graphDistances)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- the distance between cityX and cityY. 
"""
function Distance(cityX::Int, cityY::Int, graphDistances)

	return graphDistances[cityX,cityY]
end

# ╔═╡ 60627e57-5bb4-486f-b185-adbd812e9f36
"""
	moveProbs(k, cityX, visited, pheromones, dists, numCities, α, β)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	
"""
function moveProbs(k::Int, cityX::Int, visited, pheromones, dists, numCities::Int, α::Real=3.0, β::Real=2.0, MaxValue::Real=1.7976931348623157e+30)
	τη = zeros(numCities) #tau eta 
	sum = 0

	
	for i in 1:numCities
		if i == cityX
			τη[i] = 0.0 # prob of moving to self is zero

		elseif visited[i] == true
			τη[i] = 0.0 # prob of moving to a visited node is zero
	
		#otherwise calculate tau eta
		else 
      		τη[i] = (pheromones[cityX,i])^α * (1.0/(Distance(cityX, i, dists))^β)
      		
			#if τη is very large or very small, re-assign 
			if τη[i] < 0.0001
				τη[i] = 0.0001 #lower bound

			elseif τη[i] > MaxValue/(numCities * 100)
        		τη[i] = MaxValue/(numCities * 100) #upper bound
			end

		end
			
		sum += τη[i]
	end
	
	probs = zeros(numCities)
	
	for i in 1:numCities
		probs[i] = τη[i] / sum
	end 
	
	return probs
end

# ╔═╡ ea9b2871-ad78-4525-9cce-dff962b44807
#Delete ??? 
"""
	makeGraphDistances(numCities) 

Generates an nxn symmetric matrix with 0s on the diagonal 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- a simulated graph
"""
function makeGraphFloatDistances(numCities::Int)
	n = numCities
	m = rand(1:10, n, n)  
	half = Int64(floor(n/2))
	
	for i in 1:half
		for j in 1:half
			m[i,j] =  10*rand()
		end
	end
	
	
	#matrix = Symmetric(m)

#	#set diagonals to 0: a city's distance from itself is 0 
	#for i in 1:n
	#	matrix[i,i] = 0
	#end


	return m#, n
	
end

# ╔═╡ 3f3d611b-dbe2-420e-bf94-89229eca9ab9
#CHECKED
"""
	InitPheromones(numCities, graphDistances)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- pheromones array 
"""
function InitPheromones(numCities::Int)
  	pheromones = zeros(numCities,numCities)
	fill!(pheromones, 0.01)
  return pheromones
end

# ╔═╡ 97cf8701-7622-4537-8091-1a38acefa9dd
#CHECKED
"""
	indexOfTarget(trail, target)

helper for RandomTrail 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- ???
"""
function indexOfTarget(trail,target::Int)
	for i in 1:(length(trail))
		if trail[i] == target
			return i 
		end
	end
end

# ╔═╡ ea9bcc44-9351-4156-bf61-3368c507d5cf
#CHECKED
"""
	randomTrail(start, numCities)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- a random trail whose length is numCities-1 , and starts at 'start' city
"""
function randomTrail(start::Int, numCities::Int)
	n = numCities
	
	#Allocate a 'basic' trail [1,2,3,4,5...n-1
	chrono_trail = 1:(n-1) |> collect #chronological trail 
	
	trail = shuffle(chrono_trail)

	idx = indexOfTarget(trail, start)
	temp = trail[1]  #Julia starts at 1 indexing
	trail[1] = trail[idx] #swap the start city with the 
	trail[idx] = temp 
	return trail
end

# ╔═╡ e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
#CHECKED
"""
	edgeInTrail(cityX, cityY, trail)

Are cityX and cityY adjacent to each other in trail?

Inputs:
	-`thing` : `what thing is`

Outputs:
	- 
"""
function edgeInTrail(cityX::Int, cityY::Int, trail)
	
	#make sure cityX, cityY are ins
	cityX
	cityY
	lastIndex = length(trail) 
    idx = indexOfTarget(trail, cityX)

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

# ╔═╡ 306cd489-470c-45c5-bace-1624512087ab
#CHECKED
"""
	trailSum(trail, dists) # THE EXAMPLE PROGRAM CALLS THIS Length(trail, dists)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
- sum of trail from begin to end but not back to start again 
"""
function trailSum(trail, dists) # total length of a trail (sum of distances)

	result = 0.0
	
	for  i in 1:(length(trail)-1)
		result += Distance(trail[i], trail[i+1], dists) 
		         #Distance(cityX, cityY, graphDistances)
	end
	#add Distance(trail[i], trail[1], dists) ???? 
	return result
end

# ╔═╡ a2aba49e-809f-4cdd-9bd5-d10b854a6628
#WORKS but not 'checked'
"""
	updatePheromones(k, start, pheromones, dists, ρ)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- 
"""
function updatePheromones(pheromones, ants, dists, ρ::Real=0.01, Q::Real=2.0)
	pher_rows = size(pheromones,1)
	pher_cols = size(pheromones,2) #is a square matrix 
	num_ants = length(ants)
	
	for i in 1:pher_rows
		for j in 1:pher_cols
			for k in 1:num_ants #number of ants
				tLength = trailSum(ants[k], dists) #length of ant K trail
           		decrease = (1.0-ρ) * pheromones[i,j]
           		increase = 0.0
				
				if edgeInTrail(i, j, ants[k]) == true
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

# ╔═╡ edf145a2-ae6f-4e01-beb1-5be1d5c1250d
#Works but not 'checked'
"""
	BestTrail(ants, dists)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- 
      
"""
function BestTrail(ants,  dists)
	
	#set 1st ant trail as best 
	bestLength = trailSum(ants[1], dists)
	idxBest = 1
	n = size(dists,2) #numCities
	
	#check the rest of the trails
	for k in 2:length(ants)
		len = trailSum(ants[k], dists)
		if len < bestLength
			bestLength = len
			idxBest = k
		end
	end
	
	#bestTrail = copy(ants[idxBest])
	return ants[idxBest]
end

# ╔═╡ e45b3588-f8a7-439a-ac97-bafb9253f6a3
#CHECKED
"""
	initAnts(start, numAnts, numCities)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- an array of arrays (random initial trail for each ant) 
"""
function initAnts(start::Int, numAnts::Int, numCities::Int)
	
	ants = [] # init array that will hold trail arrays 
	
	for k in 1:numAnts
		t = randomTrail(start, numCities)	
		push!(ants,t)
	end
  
  return ants
		
end

# ╔═╡ 206fc0de-a6d3-4597-9ce3-f63bdd853d1c
"""
stuff
"""
function InitColonyOptimization(numCities::Int=10, numAnts::Int=4)
	
	start = Int64(rand(1:10))
	dists = makeGraphDistances(numCities)
	ants = initAnts(start, numAnts, numCities)	
	
	bestTrail = BestTrail(ants, dists)	
    bestLength = trailSum(bestTrail, dists)		

    pheromones = InitPheromones(numCities)		
	
	return start, dists, ants, bestTrail, bestLength, pheromones, numCities, numAnts
	
end

# ╔═╡ c8d9c937-e531-4e11-a58b-82120cbd924b
start, dists, ants, bestTrail, bestLength, pheromones, numCities, numAnts = InitColonyOptimization()

# ╔═╡ c40fe82a-2dee-44d4-b768-25ff50ce746c
"""
	nextCity(k, cityX, visited, pheromones, dists)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- `stuff`
"""
function nextCity(k::Int, cityX::Int, visited, pheromones, dists, α::Real=3, β::Real=2)
	
	probs = moveProbs(k::Int, cityX::Int, visited, pheromones, dists, numCities::Int)
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
	buildTrail(k::Int, start::Int, pheromones, dists, numCities::Int)

`BuildTrail maintains an array of Boolean visited, so that the trail created doesn’t contain duplicate cities. The value at trail[0] is seeded with a start city, then each city is added in turn by helper method NextCity` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- a random trail whose length is numCities-1 , and starts at 'start' city
"""
function buildTrail(k::Int, start::Int, pheromones, dists, numCities::Int)
	trail = zeros(Int64, numCities)
	visited = falses(numCities)

	trail[1] = start 
	visited[start] = true 
	
	for i in 1:(numCities-1) #because if we go to numCities there is no nextCity
		cityX = Int64(trail[i])
		nextcity = nextCity(k, cityX, visited, pheromones, dists)
		trail[i+1] = Int64(nextcity)
		visited[nextcity] = true 
	end
	
	return trail#, visited
end

# ╔═╡ d12126fd-c9a3-4dbf-b9ea-866db0b26ab7
"""
	updateAnts(ants, pheromones, dists)

`what it does` 

Inputs:
	-`thing` : `what thing is`

Outputs:
	- 
      
"""
function updateAnts(ants, pheromones, dists, start)
	n = Int64(size(dists,2)) #numCities
	num_ants = Int64(length(ants))
	for k in 1:num_ants
		#start = Int64(rand(1:n))
		newTrail = buildTrail(k, start, pheromones, dists, n)
		ants[k] = newTrail
	end
end

# ╔═╡ e05ce658-cbaf-4ac2-a426-c9741fbc37d2
"""
stuff
"""
function AntColonyOptimization(start, dists, ants, bestTrail, bestLength, pheromones, numCities, numAnts, maxTime::Int=10)

    time = 1
    currBestTrail = zeros(Int64, numCities)
	currBestLength = 0
	
	while time < maxTime
		updateAnts(ants, pheromones, dists, start)	
		updatePheromones(pheromones, ants, dists)

		currBestTrail = BestTrail(ants, dists)
		currBestLength = trailSum(currBestTrail, dists)

		if currBestLength < bestLength
			bestLength = currBestLength	
			bestTrail = currBestTrail	
		end

		time += 1		
	
	end 
	
	return currBestTrail, currBestLength
end

# ╔═╡ 88706d87-5a3b-454a-a1eb-f1b110246a28
shortest_trail, trail_length = AntColonyOptimization(start, dists, ants, bestTrail, bestLength, pheromones, numCities, numAnts)

# ╔═╡ 312181f2-54d6-4b69-8015-27232689c0e3
shortest_trail

# ╔═╡ 2f9540ad-9323-45a2-934e-e29f941aa147
trail_length

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
# ╟─533aad3f-fd08-4004-b93f-60f056d05791
# ╟─67d95176-fc53-4daa-931f-1a7baa29e888
# ╠═4d3e3f09-ee88-47b5-a03f-93d034cbee45
# ╟─bc7b209a-32e9-4e60-a79b-46a404cc2a7e
# ╟─2395128d-9af8-460e-a36f-05b3aeb00afb
# ╠═206fc0de-a6d3-4597-9ce3-f63bdd853d1c
# ╟─c8d9c937-e531-4e11-a58b-82120cbd924b
# ╟─02cdf94d-d9b5-4767-89a0-89d927e899fb
# ╠═e05ce658-cbaf-4ac2-a426-c9741fbc37d2
# ╠═88706d87-5a3b-454a-a1eb-f1b110246a28
# ╠═9c76a78c-7718-44a8-9399-f66c8683e97b
# ╠═312181f2-54d6-4b69-8015-27232689c0e3
# ╠═2f9540ad-9323-45a2-934e-e29f941aa147
# ╠═ea9bcc44-9351-4156-bf61-3368c507d5cf
# ╠═60627e57-5bb4-486f-b185-adbd812e9f36
# ╠═c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╠═2df743f0-620f-43bc-bb51-17dc5e5c0be7
# ╠═e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
# ╠═a2aba49e-809f-4cdd-9bd5-d10b854a6628
# ╠═d12126fd-c9a3-4dbf-b9ea-866db0b26ab7
# ╠═64dae470-6b3b-487f-b663-25f10b7b9567
# ╟─31e6f16e-e12e-474f-9c27-5bff01c53310
# ╟─40785798-1223-4efe-870e-e37b0b761af1
# ╟─7a01418b-2543-433b-942e-92ce38a29496
# ╠═3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
# ╠═c8de83fa-1519-48d0-b257-97bfeb4952ad
# ╠═edf145a2-ae6f-4e01-beb1-5be1d5c1250d
# ╠═ea9b2871-ad78-4525-9cce-dff962b44807
# ╠═3f3d611b-dbe2-420e-bf94-89229eca9ab9
# ╠═97cf8701-7622-4537-8091-1a38acefa9dd
# ╠═306cd489-470c-45c5-bace-1624512087ab
# ╠═e45b3588-f8a7-439a-ac97-bafb9253f6a3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
