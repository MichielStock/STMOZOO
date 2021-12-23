### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ a3a91caa-db4a-49da-bda9-1fffd9498ce8
using LinearAlgebra # to use Symmetric matrix 

# ╔═╡ 82d25b0c-f900-4996-99c9-fdb1bbe7cae4
using Random # to make random matrix 

# ╔═╡ 2395128d-9af8-460e-a36f-05b3aeb00afb
md" ### initialize the run"

# ╔═╡ 02cdf94d-d9b5-4767-89a0-89d927e899fb
md" ### run optimization"

# ╔═╡ 9c76a78c-7718-44a8-9399-f66c8683e97b
#SOLUTION

# ╔═╡ ac1fb55f-709d-44dd-952d-b1d2d8deb817
md"""
list of functions    

Initialition:

	InitColonyOptimization(numCities::Int=10, numAnts::Int=4)

		makeGraphDistances(numCities) 

		initAnts(numAnts, numCities)

			randomTrail(start, numCities) 

				indexOfTarget(trail, target) 

		initPheromones(numCities)

		trailSum(trail, dists) #Length()

		bestTrail(ants, dists)
    
Run the optimization:
    
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
#CHECKED
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

# ╔═╡ ea9b2871-ad78-4525-9cce-dff962b44807
#CHECKED
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

# ╔═╡ 81644476-a43e-4ae5-94a4-9e1bc5e885dc
round(rand()*10,2)

# ╔═╡ 2e6633b7-b5ca-4270-b964-66932490e7c3
distz = makeGraphFloatDistances(10)

# ╔═╡ 7f2aa588-3714-47e7-8818-fbc2ff31f4cc
m = rand(1:10, 3, 3)  

# ╔═╡ f09c3a5b-b3b5-4cd9-9f67-7446b93b937a
m

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

# ╔═╡ 1f71e700-0d13-4cdc-9e5d-a9d27a0d03c7
dists

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
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
"""

# ╔═╡ Cell order:
# ╠═a3a91caa-db4a-49da-bda9-1fffd9498ce8
# ╠═82d25b0c-f900-4996-99c9-fdb1bbe7cae4
# ╟─2395128d-9af8-460e-a36f-05b3aeb00afb
# ╠═206fc0de-a6d3-4597-9ce3-f63bdd853d1c
# ╠═c8d9c937-e531-4e11-a58b-82120cbd924b
# ╠═1f71e700-0d13-4cdc-9e5d-a9d27a0d03c7
# ╟─02cdf94d-d9b5-4767-89a0-89d927e899fb
# ╠═e05ce658-cbaf-4ac2-a426-c9741fbc37d2
# ╠═88706d87-5a3b-454a-a1eb-f1b110246a28
# ╠═9c76a78c-7718-44a8-9399-f66c8683e97b
# ╠═312181f2-54d6-4b69-8015-27232689c0e3
# ╠═2f9540ad-9323-45a2-934e-e29f941aa147
# ╟─ac1fb55f-709d-44dd-952d-b1d2d8deb817
# ╠═3fc17fc7-e345-4e3d-8e77-78e374dd0bfc
# ╠═ea9b2871-ad78-4525-9cce-dff962b44807
# ╠═81644476-a43e-4ae5-94a4-9e1bc5e885dc
# ╠═2e6633b7-b5ca-4270-b964-66932490e7c3
# ╠═7f2aa588-3714-47e7-8818-fbc2ff31f4cc
# ╠═f09c3a5b-b3b5-4cd9-9f67-7446b93b937a
# ╠═c8de83fa-1519-48d0-b257-97bfeb4952ad
# ╠═e45b3588-f8a7-439a-ac97-bafb9253f6a3
# ╠═97cf8701-7622-4537-8091-1a38acefa9dd
# ╠═ea9bcc44-9351-4156-bf61-3368c507d5cf
# ╠═3f3d611b-dbe2-420e-bf94-89229eca9ab9
# ╠═60627e57-5bb4-486f-b185-adbd812e9f36
# ╠═c40fe82a-2dee-44d4-b768-25ff50ce746c
# ╠═2df743f0-620f-43bc-bb51-17dc5e5c0be7
# ╠═e3e2ca54-c6c6-4a84-a70f-2d5cfaefd9ba
# ╠═306cd489-470c-45c5-bace-1624512087ab
# ╠═a2aba49e-809f-4cdd-9bd5-d10b854a6628
# ╠═edf145a2-ae6f-4e01-beb1-5be1d5c1250d
# ╠═d12126fd-c9a3-4dbf-b9ea-866db0b26ab7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
