### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ cc9ac24c-9089-401b-88d3-c02b2a9ce64e
using Plots

# ╔═╡ bbf47e7e-73ac-406f-95a6-323898ccef00
function bellman_ford(graph, start_node)
	a = 0
	
	#initialize distance of source to every node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	distance[start_node] = 0
	N = length(distance)
	
	#update distance n - 1 times
	for _ in 1:N - 1
		#iterate over all nodes
		for v in keys(graph)
			#iterate over all neighbors of the current node
			for (w, n) in graph[v]
				#update distance if needed
				distance[n] = min(distance[n], distance[v] + w)
			end
		end
	end
	
	for v in keys(graph)
		for (w, n) in graph[v]
			#if improvement is still possible, there's a negative cycle
			if distance[v] + w < distance[n]
				a += 1
			end
		end
	end
	return a, distance
end

# ╔═╡ ffec900c-55e1-40a1-8019-0a5136e53ba7
#The improvement over the bellman ford algorithm is that instead of trying all vertices blindly, SPFA maintains a queue of candidate vertices and adds a vertex to the queue only if that vertex is relaxed. This process repeats until no more vertex can be relaxed.

function Shortest_Path_Faster_Algorithm(graph, start_node)
	a = 0
	final_node = start_node
	
	#initialize distance of source to every node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	count = Dict{String, Int16}(v => 0 for v in keys(graph))
	pre = Dict{String, String}(v => start_node for v in keys(graph))
	distance[start_node] = 0
	N = length(distance)
	Q = []

	#create a queue of nodes that are processed in a first in first out manner
	push!(Q, start_node)
	
    while length(Q) != 0
		#select the first node in the queue
		v = Q[1]
		deleteat!(Q, findall(x -> x == v, Q))
		for (w, n) in graph[v]
			#update distance if needed
			if distance[n] > distance[v] + w
				distance[n] = distance[v] + w
				pre[n] = v
				#add n to the queue if it's not in  there yet
				if !(n in Q)
                    push!(Q, n)
					count[n] += 1
					if count[n] >= N
						final_node = n
						a += 1
						Q = []
					end
				end
			end
		end
	end

	return a, distance, pre, final_node
end

# ╔═╡ 93f28f42-4f48-4445-9ab2-6ceda393de11
function recursion_part(v, visited, rec_stack, pre)
	visited[v] = true
	rec_stack[v] = true
	
	#next line needs to be generalized #for n in pre[v]
	n = pre[v]
	if visited[n] == false
		if recursion_part(n, visited, rec_stack, pre) == true
			return true
		end
	elseif rec_stack[n] == true
		return true
	end
	#end
	rec_stack[v] = false
	return false
end

# ╔═╡ 15b7ec32-8524-40f9-ac8f-6ef401d51ea0
#depth first search on pre graph
function detect_cycle(pre)
	visited = Dict{String, Bool}(v => false for v in keys(pre))
	rec_stack = Dict{String, Bool}(v => false for v in keys(pre))

	for v in keys(pre) ################################
		if visited[v] == false
			if recursion_part(v, visited, rec_stack, pre) == true
				return true
			end
		end
	end
    return False
end

# ╔═╡ 3a66c410-2da2-4591-9683-79ee56c5ff9e
#The improvement over the bellman ford algorithm is that instead of trying all vertices blindly, SPFA maintains a queue of candidate vertices and adds a vertex to the queue only if that vertex is relaxed. This process repeats until no more vertex can be relaxed.

function Shortest_Path_Faster_Algorithm_early_termination(graph, start_node)
	a = 0
	final_node = start_node
	
	#initialize distance of source to every node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	pre = Dict{String, String}(v => start_node for v in keys(graph))
	distance[start_node] = 0
	N = length(distance)
	Q = []
	iter = 0

	#create a queue of nodes that are processed in a first in first out manner
	push!(Q, start_node)
	
    while length(Q) != 0
		#select the first node in the queue
		v = Q[1]
		deleteat!(Q, findall(x -> x == v, Q))
		for (w, n) in graph[v]
			#update distance if needed
			if distance[n] > distance[v] + w
				distance[n] = distance[v] + w
				iter += 1
				if iter == N
                    iter = 0
                    if detect_cycle(pre)
						final_node = n
						a += 1
                        Q = []
					end
				end
				pre[n] = v
				#add n to the queue if it's not in  there yet
				if !(n in Q)
                    push!(Q, n)
				end
			end
		end
	end

	if detect_cycle(pre)
		#################################final_node = n
		a += 1
    end
	
	return a, distance, pre, final_node
end

# ╔═╡ e041d702-c061-438c-928c-e323b388bdb4
function trace(pre, n)
	S = []
    while !(n in S)
        push!(S, n)
        n = pre[n]
	end
    cycle = [n]
    while last(S) != n
        push!(cycle, last(S))
		deleteat!(S, findall(x -> x == last(S), S))
	end
    push!(cycle, n)
    return cycle
end

# ╔═╡ a1881b99-61e4-4d29-ab47-6dd4e35d541c
#an example graph
#keys are nodes
#values are neighboring nodes and weights

graph = Dict{String, Vector{Tuple{Float16, String}}}("a" => [(10, "b"), (5, "c")], "b" => [(10, "a"), (3, "c")], "c" => [(5, "a"), (3, "b")])

# ╔═╡ 90f00636-f609-4cb7-824e-afc189f7b013
#the ticket to ride graph, altered to have a negative cycle
#duluth => chicago = 6.651361758904873

ttr_graph = Dict("Chicago" => [(-9, "Duluth"), (8.33630341615925, "Omaha"), (8.427006242662463, "Toronto"), (7.77193838450812, "Pittsburgh"), (4.122208769330801, "Saint Louis")], "Omaha" => [(16.958907444561092, "Helena"), (9.173562790412005, "Denver"), (2.5724723453698295, "Kansas City"), (6.703989886060554, "Duluth"), (8.33630341615925, "Chicago")], "Washington" => [(3.3238629287371855, "Pittsburgh"), (3.5598393617362576, "New York"), (3.502616612013469, "Raleigh")], "San Francisco" => [(7.772429977571004, "Portland"), (11.020582210307548, "Salt Lake City"), (5.628319410694537, "Los Angeles")], "Kansas City" => [(10.442216859614872, "Denver"), (4.665730931339962, "Oklahoma City"), (2.5724723453698295, "Omaha"), (4.459674790015858, "Saint Louis")], "Saint Louis" => [(4.122208769330801, "Chicago"), (10.301257633157055, "Pittsburgh"), (4.459674790015858, "Kansas City"), (4.148394464608018, "Nashville"), (4.41926434610606, "Little Rock")], "Miami" => [(10.668170826088692, "New Orleans"), (9.01159199318291, "Atlanta"), (7.017911224044257, "Charleston")], "Dallas" => [(9.752368529115898, "El Paso"), (3.3386818769205804, "Houston"), (2.791230138692293, "Oklahoma City"), (4.919057442971587, "Little Rock")], "El Paso" => [(11.955571131557361, "Los Angeles"), (5.811453875853011, "Phoenix"), (3.9166247637116998, "Santa Fe"), (11.32120576594185, "Houston"), (9.752368529115898, "Dallas"), (9.70189546877094, "Oklahoma City")], "Duluth" => [(19.911802796307814, "Helena"), (5.925817172426331, "Winnipeg"), (6.703989886060554, "Omaha"), (6.651361758904873, "Chicago"), (13.114207651345454, "Toronto"), (7.809025347441716, "Sault Ste. Marie")], "Sault Ste. Marie" => [(13.280608192721058, "Winnipeg"), (7.809025347441716, "Duluth"), (10.758803662987315, "Montreal"), (5.706988122304973, "Toronto")], "Las Vegas" => [(3.746782803410391, "Los Angeles"), (5.637945175863857, "Salt Lake City")], "Houston" => [(11.32120576594185, "El Paso"), (3.3386818769205804, "Dallas"), (5.399641442570204, "New Orleans")], "Portland" => [(2.1118128775488723, "Seattle"), (11.784854957802366, "Salt Lake City"), (7.772429977571004, "San Francisco")], "Santa Fe" => [(6.534869288423131, "Phoenix"), (4.162732827937639, "Denver"), (3.9166247637116998, "El Paso"), (8.423465177038857, "Oklahoma City")], "New Orleans" => [(5.399641442570204, "Houston"), (5.251294601035569, "Little Rock"), (6.70828469876545, "Atlanta"), (10.668170826088692, "Miami")], "Charleston" => [(3.2634160642574384, "Raleigh"), (4.55260311692471, "Atlanta"), (7.017911224044257, "Miami")], "Raleigh" => [(3.502616612013469, "Washington"), (4.83227102759629, "Pittsburgh"), (6.099275842819131, "Atlanta"), (8.144209998426817, "Nashville"), (3.2634160642574384, "Charleston")], "Vancouver" => [(1.8331030717922907, "Seattle"), (9.227156870741855, "Calgary")], "Helena" => [(15.22747966355316, "Winnipeg"), (4.89944570284048, "Calgary"), (10.343492662442204, "Seattle"), (5.827520539398859, "Salt Lake City"), (19.911802796307814, "Duluth"), (9.833289565446643, "Denver"), (16.958907444561092, "Omaha")], "Salt Lake City" => [(11.784854957802366, "Portland"), (11.020582210307548, "San Francisco"), (5.637945175863857, "Las Vegas"), (6.981802421079518, "Denver"), (5.827520539398859, "Helena")], "Phoenix" => [(6.196866607632182, "Los Angeles"), (5.811453875853011, "El Paso"), (6.534869288423131, "Santa Fe"), (9.480337892644433, "Denver")], "New York" => [(3.3502185200416275, "Boston"), (4.7813966713936615, "Montreal"), (6.011418225407591, "Pittsburgh"), (3.5598393617362576, "Washington")], "Little Rock" => [(4.41926434610606, "Saint Louis"), (5.277702051447833, "Oklahoma City"), (4.919057442971587, "Dallas"), (5.6940526333158035, "Nashville"), (5.251294601035569, "New Orleans")], "Calgary" => [(9.227156870741855, "Vancouver"), (16.93443509438875, "Winnipeg"), (4.89944570284048, "Helena"), (8.958280708358826, "Seattle")], "Pittsburgh" => [(7.77193838450812, "Chicago"), (3.289662001819938, "Toronto"), (6.011418225407591, "New York"), (3.3238629287371855, "Washington"), (4.83227102759629, "Raleigh"), (10.301257633157055, "Saint Louis"), (8.009747546870363, "Nashville")], "Toronto" => [(13.114207651345454, "Duluth"), (6.063785450464935, "Montreal"), (8.427006242662463, "Chicago"), (3.289662001819938, "Pittsburgh"), (5.706988122304973, "Sault Ste. Marie")], "Montreal" => [(10.758803662987315, "Sault Ste. Marie"), (4.042976620217085, "Boston"), (4.7813966713936615, "New York"), (6.063785450464935, "Toronto")], "Seattle" => [(1.8331030717922907, "Vancouver"), (2.1118128775488723, "Portland"), (10.343492662442204, "Helena"), (8.958280708358826, "Calgary")], "Winnipeg" => [(16.93443509438875, "Calgary"), (13.280608192721058, "Sault Ste. Marie"), (15.22747966355316, "Helena"), (5.925817172426331, "Duluth")], "Nashville" => [(4.148394464608018, "Saint Louis"), (5.6940526333158035, "Little Rock"), (3.392264545466067, "Atlanta"), (8.009747546870363, "Pittsburgh"), (8.144209998426817, "Raleigh")], "Denver" => [(9.480337892644433, "Phoenix"), (6.981802421079518, "Salt Lake City"), (9.833289565446643, "Helena"), (9.173562790412005, "Omaha"), (10.442216859614872, "Kansas City"), (4.162732827937639, "Santa Fe"), (8.600346350157364, "Oklahoma City")], "Atlanta" => [(6.70828469876545, "New Orleans"), (3.392264545466067, "Nashville"), (6.099275842819131, "Raleigh"), (4.55260311692471, "Charleston"), (9.01159199318291, "Miami")], "Boston" => [(4.042976620217085, "Montreal"), (3.3502185200416275, "New York")], "Los Angeles" => [(5.628319410694537, "San Francisco"), (3.746782803410391, "Las Vegas"), (6.196866607632182, "Phoenix"), (11.955571131557361, "El Paso")], "Oklahoma City" => [(8.423465177038857, "Santa Fe"), (8.600346350157364, "Denver"), (9.70189546877094, "El Paso"), (2.791230138692293, "Dallas"), (4.665730931339962, "Kansas City"), (5.277702051447833, "Little Rock")])

# ╔═╡ 9e1ee6df-bd49-45cd-9b0b-d3bf9cfb6670
ttr_graph_nodes_coordinates = Dict("Atlanta" => (-84.3901849, 33.7490987),
                               "Boston" => (-71.0595678, 42.3604823),
                               "Calgary" => (-114.0625892, 51.0534234),
                               "Charleston" => (-79.9402728, 32.7876012),
                               "Chicago" => (-87.6244212, 41.8755546),
                               "Dallas" => (-96.7968559, 32.7762719),
                               "Denver" => (-104.9847034, 39.7391536),
                               "Duluth" => (-92.1251218, 46.7729322),
                               "El Paso" => (-106.501349395577, 31.8111305),
                               "Helena" => (-112.036109, 46.592712),
                               "Houston" => (-95.3676974, 29.7589382),
                               "Kansas City" => (-94.5630298, 39.0844687),
                               "Las Vegas" => (-115.149225, 36.1662859),
                               "Little Rock" => (-92.2895948, 34.7464809),
                               "Los Angeles" => (-118.244476, 34.054935),
                               "Miami" => (-80.1936589, 25.7742658),
                               "Montreal" => (-73.6103642, 45.4972159),
                               "Nashville" => (-86.7743531, 36.1622296),
                               "New Orleans" => (-89.9750054503052, 30.03280175),
                               "New York" => (-73.9866136, 40.7306458),
                               "Oklahoma City" => (-97.5170536, 35.4729886),
                               "Omaha" => (-95.9378732, 41.2587317),
                               "Phoenix" => (-112.0773456, 33.4485866),
                               "Pittsburgh" => (-79.99, 40.42),
                               "Portland" => (-122.6741949, 45.5202471),
                               "Raleigh" => (-78.6390989, 35.7803977),
                               "Saint Louis" => (-90.12954315, 38.60187637),
                               "Salt Lake City" => (-111.8904308, 40.7670126),
                               "San Francisco" => (-122.49, 37.75),
                               "Santa Fe" => (-105.9377997, 35.6869996),
                               "Sault Ste. Marie" => (-84.320068, 46.52391),
                               "Seattle" => (-122.3300624, 47.6038321),
                               "Toronto" => (-79.387207, 43.653963),
                               "Vancouver" => (-123.1139529, 49.2608724),
                               "Washington" => (-77.0366456, 38.8949549),
                               "Winnipeg" => (-97.168579, 49.884017))

# ╔═╡ 4b8a8924-308b-483f-8918-0b783042b42e
#create random coordinates and a list with tuples that represent edges for graphs that don't have this

function plot_prep(graph)
	#generate random coordinates for all nodes for plotting.
	graph_nodes_coordinates = Dict()
	for key in keys(graph)
		graph_nodes_coordinates[key] = (rand(), rand())
	end
	
	#generate tuples with weight and involved nodes for every edge
	graph_edges = []
	for v in keys(graph)
		for (w, n) in graph[v]
			push!(graph_edges, (w, n, v))
		end
	end
	return graph_nodes_coordinates, graph_edges
end

# ╔═╡ a89e6eb9-8e14-4011-9d4a-419b71f298ee
_, ttr_graph_edges = plot_prep(ttr_graph)

# ╔═╡ 49e2c723-50e8-4f1c-8c52-babe11c810f9
#creates a visualisation of the bellman ford algorithm, takes 3 minutes for me

#ani, a, dist = bellman_ford_animated(ttr_graph, "New York", ttr_graph_nodes_coordinates, ttr_graph_edges)

# ╔═╡ 5ebea0f6-21d9-4b71-b088-09189020711e
a3, dist3 = bellman_ford(ttr_graph, "New York")
#O(V*E)

# ╔═╡ 1c36742d-5a31-4cfb-a5fe-cf687472cbd7
a2, distance2, pre2, final_node2 = Shortest_Path_Faster_Algorithm(ttr_graph, "New York")
#worst case: O(V*E)
#average: O(E)

# ╔═╡ 2ada9368-05a6-4ee2-80fc-a802141151f8
trace(pre2, final_node2)

# ╔═╡ 421e3f34-4d3f-47b6-b103-98d4b20192f8
a4, dist4, pre4, final_node4 = Shortest_Path_Faster_Algorithm_early_termination(ttr_graph, "New York")

# ╔═╡ 8e4afe7c-9fa6-4534-ab83-97efd0eb2e29
trace(pre4, final_node4)

# ╔═╡ 68bd6aef-4cf9-4d25-a5fe-213119966339
#numerical error

# ╔═╡ adc4365c-cee6-419d-bbbf-d8fb6a253f67
gif(ani, "tutorial_anim_fps30.gif", fps = 2)

#maybe have relaxation in one color and minimal spanning tree in another.
#properly visualise negative cycles

# ╔═╡ 3b955a9d-3f4a-4aa5-98ce-11807f0645ed
#plot graph, width of line represents weight (needs to change)
function plot_graph(iteration, graph_nodes_coordinates, graph_edges, dist)
	p = plot(title = iteration)

	# add edges
	for (w, n1, n2) in graph_edges
		x1, y1 = graph_nodes_coordinates[n1]
		x2, y2 = graph_nodes_coordinates[n2]
		plot!(p, [x1, x2], [y1, y2], color = "lightgrey", alpha = 0.8,
			lw = 1, label = "")
	end
	
	# plot nodes
	for (node, (x, y)) in graph_nodes_coordinates
		w = dist[node]
		#println("$city: $x, $y")
		scatter!(p, [x], [y], label="", color="orange", markersize=10, alpha=0.8
		, annotations=[(x, y, round(w, digits = 2), 8)]  # comment this for clarity
		)
	end
	p
end

# ╔═╡ c76aa110-57f9-11ec-3cde-8dc46e37ffdd
#bellman ford with visualisation

function bellman_ford_animated(graph, start_node, graph_nodes_coordinates, graph_edges)
	a = 0
	
	#initialize distance of source to every node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	distance[start_node] = 0
	N = length(distance)

	anim = Animation()
	
	#update distance n - 1 times
	for i in 1:N - 1
		#reset plot
		#p = plot_graph(graph_nodes_coordinates, graph_edges, distance)
		xs = []
		ys = []
		#iterate over all nodes
		for v in keys(graph)
			#iterate over all neighbors of the current node
			for (w, n) in graph[v]
				#update distance if needed
				#distance[n] = min(distance[n], distance[v] + w)

				#if there is an update to a weight, display it
				if distance[n] > distance[v] + w
					distance[n] = min(distance[n], distance[v] + w)
					x1, y1 = graph_nodes_coordinates[v]
					x2, y2 = graph_nodes_coordinates[n]
					push!(xs, [x1, x2])
					push!(ys, [y1, y2])

					#update distances on plot
					p = plot_graph(i, graph_nodes_coordinates, graph_edges, distance)

					#add edges
					for j in 1:length(xs)
						#println(i)
						#println(xs[i])
						plot!(p, xs[j], ys[j], color = "red", alpha = 0.8,
						lw = 1, label = "")
					end
					frame(anim, p)
				end
			end
		end
	end
	p = plot_graph("loops", graph_nodes_coordinates, graph_edges, distance)
	for v in keys(graph)
		for (w, n) in graph[v]
			#if improvement is still possible, there's a negative cycle
			if distance[v] + w < distance[n]
				a += 1
				x1, y1 = graph_nodes_coordinates[v]
				x2, y2 = graph_nodes_coordinates[n]
				plot!(p, [x1, x2], [y1, y2], color = "blue", alpha = 0.8,
						lw = 1, label = "")
				frame(anim, p)
			end
		end
	end
	return anim, a, distance
end

# ╔═╡ 7bf91157-bbf7-4043-b24f-958e5f852387
#distance of n -> Inf in final check
# https://www.youtube.com/watch?v=lyw4FaxrwHg 10:00

# ╔═╡ cc1024e7-18cd-4cd6-840d-c04940e5ad05
#moore

# ╔═╡ 6cab5216-24a5-401b-917c-b756d3a4e0fa
#disconnected graph

# ╔═╡ 1ec56f6d-90dc-4953-8b5a-6616cace8066
#Floyd-Warshall not for directed graphs
function floyd_warshall(graph)

	#initialize distance matrix
	dist = fill(Inf, (length(graph), length(graph)))
	for v in keys(graph)
		dist[v, v] = 0
		for (w, n) in graph[v]
			dist[v, n] = w
		end
	end

	#update distance matrix
	for i in 1:length(graph)
		for j in 1:length(graph)
			for k in 1:length(graph)
				if dist[j, k] > dist[j, i] + dist[i, k]
					dist[j, k] = dist[j, i] + dist[i, k]
				end
			end
		end
	end
	return dist
end

# ╔═╡ 4be23d79-eee2-42fb-8790-ed0cd4846d6f
floyd_warshall(ttr_graph)

# ╔═╡ 2cb2a271-a1af-45da-97e4-eb4c99c7a1be
"
let dist be a |V| × |V| array of minimum distances initialized to ∞ (infinity)
for each edge (u, v) do
    dist[u][v] ← w(u, v)  // The weight of the edge (u, v)
for each vertex v do
    dist[v][v] ← 0 					#necessary?
for k from 1 to |V|
    for i from 1 to |V|
        for j from 1 to |V|
            if dist[i][j] > dist[i][k] + dist[k][j] 
                dist[i][j] ← dist[i][k] + dist[k][j]
            end if
"

# ╔═╡ 4a882f33-4ef2-445e-8ce7-021da7076b2a
#Yen's improvement

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"

[compat]
Plots = "~1.25.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

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
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

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
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

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
git-tree-sha1 = "7eda8e2a61e35b7f553172ef3d9eaa5e4e76d92e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.3"

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
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
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
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

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
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

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
# ╠═cc9ac24c-9089-401b-88d3-c02b2a9ce64e
# ╠═bbf47e7e-73ac-406f-95a6-323898ccef00
# ╠═ffec900c-55e1-40a1-8019-0a5136e53ba7
# ╠═3a66c410-2da2-4591-9683-79ee56c5ff9e
# ╠═15b7ec32-8524-40f9-ac8f-6ef401d51ea0
# ╠═93f28f42-4f48-4445-9ab2-6ceda393de11
# ╠═e041d702-c061-438c-928c-e323b388bdb4
# ╠═c76aa110-57f9-11ec-3cde-8dc46e37ffdd
# ╠═a1881b99-61e4-4d29-ab47-6dd4e35d541c
# ╠═90f00636-f609-4cb7-824e-afc189f7b013
# ╠═9e1ee6df-bd49-45cd-9b0b-d3bf9cfb6670
# ╠═4b8a8924-308b-483f-8918-0b783042b42e
# ╠═a89e6eb9-8e14-4011-9d4a-419b71f298ee
# ╠═49e2c723-50e8-4f1c-8c52-babe11c810f9
# ╠═5ebea0f6-21d9-4b71-b088-09189020711e
# ╠═1c36742d-5a31-4cfb-a5fe-cf687472cbd7
# ╠═2ada9368-05a6-4ee2-80fc-a802141151f8
# ╠═421e3f34-4d3f-47b6-b103-98d4b20192f8
# ╠═8e4afe7c-9fa6-4534-ab83-97efd0eb2e29
# ╠═68bd6aef-4cf9-4d25-a5fe-213119966339
# ╠═adc4365c-cee6-419d-bbbf-d8fb6a253f67
# ╠═3b955a9d-3f4a-4aa5-98ce-11807f0645ed
# ╠═7bf91157-bbf7-4043-b24f-958e5f852387
# ╠═cc1024e7-18cd-4cd6-840d-c04940e5ad05
# ╠═6cab5216-24a5-401b-917c-b756d3a4e0fa
# ╠═1ec56f6d-90dc-4953-8b5a-6616cace8066
# ╠═4be23d79-eee2-42fb-8790-ed0cd4846d6f
# ╠═2cb2a271-a1af-45da-97e4-eb4c99c7a1be
# ╠═4a882f33-4ef2-445e-8ce7-021da7076b2a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
