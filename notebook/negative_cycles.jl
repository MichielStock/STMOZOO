### A Pluto.jl notebook ###
# v0.17.1

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

# ╔═╡ 50860473-05c4-4382-8586-b10499b64e81
using Graphs, Plots, GraphRecipes, CoinbasePro, DataFrames, PlutoUI

# ╔═╡ a888a245-08ba-4fcd-8f19-52a810f4f725
md"# Finding negative cycles using the Bellman–Ford algorithm
By Yari Van Laere
## Introduction
This notebook will explain how the Bellman-Ford algorithm works and how it can be used to find negative cycles. At the end, it will be used to find arbitrage opportunities."

# ╔═╡ c00e89d3-e0e5-455f-b5fe-2b7c037d14f7
md"## Bellman-Ford algorithm
The Bellman-Ford algorithm is a single-source shortest path algorithm that can detect negative cyles."

# ╔═╡ 2340a1ea-ff3e-40a2-b12c-b7d73199c573
md"Below, you see a directed graph with 5 nodes and 11 edges. The cost of moving from one node to another is displayed on the edges. Now we want to calculate the shortest distance from node D to all other nodes. One of the costs (node C -> node D) is negative, so the Dijkstra algorithm can't be used."

# ╔═╡ 9a77b32f-6cdf-4193-810f-236a84493390
md"The Bellman-Ford algorithm can be used instead. Set the initial distance to infinity for every node, except the source, where the distance is zero."

# ╔═╡ 2e77f688-9fef-45cf-9b7a-076b70a1df8d
md"Next, iterate through all nodes and relax all their outgoing edges. For any edge n -> v, with weight w, this means that if the sum of the distance value of node n and the weight of the edge is smaller than the distance value of the neighboring node v, the distance value of the neighboring node gets updated. So distance[v] = minimum(distance[v], distance[n] + weight[n][v])"

# ╔═╡ e8758cb2-f0e1-4725-83e1-557a1bb50980
md"In the above figure edge D -> E gets relaxed. The sum of the distance value of node D (= 0) and the weight of the edge (= 2) is smaller than the distance value of E (= Inf). As a result, the distance value of node E gets updated to 2."

# ╔═╡ c2c1802c-aeed-4fd1-b0e6-902e66e3a008
md"All edges need to get relaxed at most N - 1 times, with N being the amount of nodes. After these N - 1 iterations, the shortest distance from the source to every node is calculated."

# ╔═╡ eb204bf2-68fe-42cf-b5a1-6688315e0982
md"In the animation above, you can see how the Bellman-Ford algorithm finds the shortest distances from node D to all other nodes. The red node is the node that is currently selected, the algorithm tries to update the neighbors of the red node. If an update is possible, the edge between them becomes red as well. As you can see, the algorithm has already found the shortest paths after 2 iterations."

# ╔═╡ 140f6c46-75f9-49d1-a7bf-9d2c53c182bf
md"## Negative cycles
The Bellman-Ford algorithm can also be used to find negative cycles in graphs. By changing the weight of the D -> E edge to -2, a negative cycle has emerged: D -> E -> C."

# ╔═╡ 499a3ea5-a8b7-40a3-a757-6799910c23bd
md"This makes it impossible to calculate the shortest distance from the source to all the nodes, because the negative cycle will keep decreasing the distances. This means that the distances will keep getting updated, even after N - 1 iterations. So if there is still an update to the distances after N - 1 iterations, we know that a negative cycle is present."

# ╔═╡ 619d3b48-4104-4485-a294-c60b76416e4a
md"Updates in iteration N (here N = 5) happen in nodes that are part of a negative cycle or that are reacheable from a negative cycle. So, by keeping track of the predecessors of all nodes, the negative cycle can be found. The predecessors are the previous nodes in the path from the source to a specific node. So if node v gets updated because distance[v] > distance[n] + weight[n][v], then the predecessor of node v is node n."

# ╔═╡ 8b09540f-f6c6-4eac-839b-8b1d306cb891
md"When tracing back the predecessors of the last updated node, the nodes will start repeating themselves, these repeating nodes make up the negative cycle."

# ╔═╡ ab50352f-d01b-4070-bcc5-423f21eeb191
md"This animation shows how a negative cycle can be found using the Bellman-Ford algorithm."

# ╔═╡ c967f6e2-6d46-47ce-8b68-435c09a970a0
md"Below, you see a small graph with only a few currencies. As you can see, the sum of the edge weights between any two currencies is close to zero, but always positive. That's because the bid price is always slightly higher than the ask price, so there will be no negative cycles with only two nodes."

# ╔═╡ d63dc65a-f615-4ba9-80e7-c91207d60957
md"To see which cycle is the most lucrative, we can calculate the percentage of increase on the initial investment. As mentioned before, the cost of a cycle is: ``cost = log(1/a) + log(1/b) + log(1/c)``, which is equivalent to: ``-cost = log(a*b*c)``. The percentage increase on the initial investment is then: ``(a*b*c - 1)*100 = (exp(-cost) - 1)*100``"

# ╔═╡ f0e5f865-2a80-409b-9095-6de71b886706
md"Below, you can test a small subgraph and see if there is a negative cycle and how lucrative it is."

# ╔═╡ a335f698-5b54-4dae-8d7d-0be483753a3d


# ╔═╡ de497cc3-51f4-40a7-9dc7-ba9c39801221
md"If we make a graph with all the available currencies, it's possible that there are multiple negative cycles. To find multiple negative cycles, we can apply the Bellman-Ford algorithm multiple times. Every time a negative cycle is found one of the edges of the cycle gets removed, that way, we don't detect the same cycle twice."

# ╔═╡ b47f6352-9a02-4c26-ac8a-231acba1461d
md"Here you can see all negative cycles that were found on CoinbasePro, you can hit the button to reset them."

# ╔═╡ c53dbce4-b8ce-4848-be1d-fd446e68d988
@bind reset Button("Reset")

# ╔═╡ 34c5254a-b160-42e3-97b8-d0c7f5c88ad2
md"This notebook won't make you rich. It takes multiple seconds to get all the exchange rates. By the time the last ones are requisted, the first ones are already no longer correct. So the arbitrage opportunities that are calculated here possibly never actually existed."

# ╔═╡ 2cf6976f-f448-47db-ac22-2a396cb17259
md"## Appendix"

# ╔═╡ f338eeb1-2912-4b45-b898-a39d2344faa4
md"### Variables"

# ╔═╡ 31b058ab-a816-43ea-b50f-ea85ee05546e
md"The graph to demonstrate the Bellman-Ford algorithm."

# ╔═╡ ec6b3904-1ff2-46e1-a6ea-7822b9a2fc6c
#an illustrative, small graph
#every node is a key, the values (w, n) represent the weight and second node of every edge that departs from the first node
test_graph = Dict{String, Vector{Tuple{Float16, String}}}("A" => [(10, "B"), (2, "C")], "B" => [(6, "A"), (3, "C")], "C" => [(1, "A"), (3, "B"), (-2, "D")], "D" => [(2, "E"), (4, "B")], "E" => [(1, "C"), (7, "A")])

# ╔═╡ 6dd7e865-3931-4d81-9eae-bf300a611554
md"The graph to demonstrate how negative cycles are found."

# ╔═╡ 19b7a29a-6bf8-4f1b-923c-ed1d55ebb075
#graph with negative cycle
test_graph_neg_cycle =  Dict{String, Vector{Tuple{Float16, String}}}("A" => [(10, "B"), (2, "C")], "B" => [(6, "A"), (3, "C")], "C" => [(1, "A"), (3, "B"), (-2, "D")], "D" => [(-2, "E"), (4, "B")], "E" => [(1, "C"), (7, "A")])

# ╔═╡ 2be70005-1eca-4ab7-863b-9c626a2ae454
md"All currency pairs on Coinbase Pro."

# ╔═╡ c9bc2ab3-8809-4360-883a-228c886c296f
#get all pairs with enough information
pairs = filter(row -> (row.status == "online") & (row.status_message == ""), products())[!, "id"]

# ╔═╡ 988eca98-aa15-4ff3-8540-f8edff0b7c89
md"Exchange rate information."

# ╔═╡ 7575beac-392b-45d5-b097-de806d45fa25
begin
	#ticker information
	ticker_example = ticker("BTC-EUR")
	er_btc_eur = round(1/ticker_example[!, "ask"][], digits = 8)
	er_eur_btc = round(ticker_example[!, "bid"][], digits = 8)
end

# ╔═╡ 3792b2d7-9e7e-4508-bea4-fd5e0d53f585
#exchange rate dataframe
exchange_rates = DataFrame(from_currency = ["A", "B", "C"], to_currency = ["B", "C", "A"], exchange_rate = ["a = 0.83", "b = 0.52", "c = 2.37"])

# ╔═╡ b617a37b-7736-4ddc-a1d9-a17605245734
md"## Arbitrage opportunities
In finance, arbitrage involves the simultaneous purchase and sale of equivalent assets or of the same asset in multiple markets in order to exploit a temporary discrepancy in prices.

An example of this can be found on foreign exchange markets. On these markets, currencies can be traded. Because of slight inefficiencies in these markets, it's sometimes possible to, for example, trade euros for dollars, then trade those dollars for yen and trade the yen back for euros (almost) simultaneously and make a profit.

These kinds of opportunities can be found as negative cycles in a graph, so they can be found with the Bellman-Ford algorithm. This will be demonstrated with cryptocurrencies on the CoinbasePro exchange.

First we have to represent the asset information as a graph. Every currency gets a node. The weight of the edges is derived from the exchange rate between the currencies.

Below you see some information about the bitcoin-euro exchange. The ask column shows the current lowest price (in euros per bitcoin) someone is willing to sell bitcoin at. The bid price is the current highest price (in euros per bitcoin) someone is willing to buy bitcoin at. So if you want to instantly buy bitcoin, you have to match the ask price, if you want to instantly sell bitcoin, you have to match the bid price.

$ticker_example

So the exchange rate from euro to bitcoin is 1/ask = $er_btc_eur (this is the amount of bitcoin you buy with 1 euro) and the exchange rate from bitcoin to euro is bid = $er_eur_btc (this is the amount of euro you buy with 1 bitcoin).

Now imagine the following exchange rates:

$exchange_rates

If we start with one unit of currency A, then trade it for B, then for C and back to A, we can calculate how much of currency A we end up with. By multiplying these exchange rates: ``a*b*c = 1.02 > 1``. We see that this cycle yields a profit.

Now we want to convert this multiplication to an addition, because that is easier to represent in a graph. We can use a logarithmic function for this, because ``log(a*b*c) = log(a) + log(b) + log(c)``. So this inequality: ``a*b*c > 1`` can be rewritten as ``log(a) + log(b) + log(c) > log(1)``. 

With the Bellman-Ford algorithm, we can find negative cycles, so we need to modify the inequality so that an arbitrage opportunity is negative. This is easily done by multiplying both sides with -1. This results in the following inequality: ``- log(a) - log(b) - log(c) < 0`` which is equivalent to: ``log(1/a) + log(1/b) + log(1/c) < 0``. 

So in this example, the edge weight of edge A -> B would be ``log(1/a)``. Which means the cost of the full cycle is: ``cost = log(1/a) + log(1/b) + log(1/c)``"

# ╔═╡ e8547de6-23ef-4fb5-8fad-623ba8abb11a
md"The small currency graph." 

# ╔═╡ 32af74c5-0f0c-4147-8a70-b4ff50399044
md"custom arbitrage graph."

# ╔═╡ 24801a5a-313d-4311-952d-bd714121ac59
md"The full arbitrage graph."

# ╔═╡ e31936be-b9fd-41c8-87c0-513aded62e83
md"### Functions"

# ╔═╡ f01c84aa-395e-4aca-baee-6098916f76c5
"""
    plot_graph(graph, node_value, title, color, updated_edges)

Plot a graph

Inputs:
	- `graph`: a dictionary representing a directed graph on which the Bellman-Ford 
             algorithm will be applied
    - `node_value`: a dictionary with a value for every node
	- `title`: a title for the plot
	- `color`: a color for the updated edges
	- `updated_edges`: a vector of tuples with nodes that make up edges that get colored

Outputs:
    - `p`: a plot of the graph
"""
function plot_graph(graph, node_value, title, color, updated_edges; current_node = "")
	
	#get the nodes
	nodes = collect(keys(graph))

	#initialize
	edge_weight = Dict()
	edge_color = Dict()
	edge_width = Dict()
	node_label = []
	node_color = []

	#create a directed graph with the required amount of nodes
	g = SimpleDiGraph(length(nodes))

	#iterate over all edges to get the information in the correct shape
	for v in nodes
		for (w, n) in graph[v]

			#get the corresponding integer for every node
			v_ind = findall(x -> x == v, nodes)[]
			n_ind = findall(x -> x == n, nodes)[]

			#add the edge to the graph
			add_edge!(g, v_ind, n_ind)

			#add the weight
			edge_weight[(v_ind, n_ind)] = round(w, digits = 4)

			#if the edge is an updated edge, add a different color and edge width
			if (v, n) in updated_edges
				edge_color[(v_ind, n_ind)] = color
				edge_width[(v_ind, n_ind)] = 3
			else
				edge_color[(v_ind, n_ind)] = :black
				edge_width[(v_ind, n_ind)] = 1
			end
		end
		
		#add a node label
		if node_value[v] != ""
			push!(node_label, v * ": " * string(round(node_value[v], digits = 1)))
		else
			push!(node_label, v)
		end
		
		#add a colored node
		if v == current_node
			push!(node_color, :red)
		else
			push!(node_color, :lightblue)
		end
	end

	#create a plot of the graph
	p = graphplot(g, names = node_label, edgelabel = edge_weight, edgewidth = 
        edge_width, title = title, edgecolor = edge_color, method = :spectral, 
        nodesize = 0.1, nodeshape = :circle, nodecolor = node_color)
	return p
end

# ╔═╡ 7838c794-88e0-4d8a-9ab5-7f90bc3a7293
"""
    bellman_ford_animated(graph, start_node)

Create an animation of how the Bellman-Ford algorithm works.

Inputs:
    - `graph`: a dictionary representing a directed graph on which the Bellman-Ford 
             algorithm will be applied 
    - `start_node`: starting point

Outputs:
    - `animation`: an animation of the Bellman-Ford algorithm, applied to the input 
                 graph
"""
function bellman_ford_animated(graph, start_node)
	
	#initialize distance from start node to every other node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	#distance of the start node is 0
	distance[start_node] = 0
	#amount of nodes
	N = length(distance)

	#initialize predecessors, keeps track of the predecessor of every node
	predecessor = Dict{String, String}(v => "" for v in keys(graph))
	#the last updated node
	last_updated = ""

	#create an animation and add the initial state of the graph as a first frame
	animation = Animation()
	p = plot_graph(graph, distance, "start", :black, [])
	frame(animation, p)
	
	#update distance N - 1 times
	for i in 1:N - 1
		#store edges that get updated this iteration
		updated_edges = []
		
		#iterate over all nodes
		for v in keys(graph)
			#iterate over all neighbors of the current node
			for (w, n) in graph[v]
				
				#if a shorter distance is possible, update the distance
				if distance[n] > distance[v] + w
					########distance[n] = min(distance[n], distance[v] + w)
					distance[n] = distance[v] + w
					push!(updated_edges, (v, n))

					#update predecessor
					predecessor[n] = v
				end

				#add a frame to the animation
				p = plot_graph(graph, distance, "iteration: " * string(i), :red, 
					updated_edges, current_node = v)
				frame(animation, p)
			end
		end
	end

	#nth iteration
	updated_edges = []
	for v in keys(graph)
		for (w, n) in graph[v]
			
			#if improvement is still possible, there's a negative cycle
			if distance[v] + w < distance[n]
				distance[n] = min(distance[n], distance[v] + w)
				push!(updated_edges, (v, n))

				#add a frame to the animation
				p = plot_graph(graph, distance, "iteration: N", :blue, updated_edges, 
                    current_node = v)
				frame(animation, p)

				#update predecessor and last updated node
				predecessor[n] = v
				last_updated = n
			end
		end
	end

	#check if there is a negative circle
	trace_edges = []
	if last_updated == ""
		println("no negative cycles found from " * start_node)

	#find the negative circle
	else
		#lies in negative cycle or is reachable from it
		y = last_updated 

		#trace the last updated node back to the negative cycle
		for j in 1:N
			y = predecessor[y]
			push!(trace_edges, (predecessor[y], y))

			#add a frame to the animation
			p = plot_graph(graph, distance, "trace back", :green, 
                trace_edges, current_node = y)
			frame(animation, p)
		end

		cur = y
		path = []
		#keep tracing back untill you find node y again
		for k in 1:N
			push!(path, cur)
			cur = predecessor[cur]
			if (cur == y) & (size(path)[1] > 1)
				break
			end
		end
	end
	return animation
end

# ╔═╡ 13e6bb3e-57c5-496a-b3b0-5484d0e410c3
begin
	#create animation of the graph with negative edge
	node_value = Dict{String, Float64}(v => Inf for v in keys(test_graph))
	node_value["D"] = 0
	test_graph_animation = bellman_ford_animated(test_graph, "D")
end

# ╔═╡ 5837516e-a034-4739-95a9-15a5d46d9d8f
plot_graph(test_graph, node_value, "directed graph", :black, [])

# ╔═╡ 04cb87db-08bf-4969-acd1-ad0aceefdb66
begin
	node_value["E"] = 2
	plot_graph(test_graph, node_value, "relaxation of edge D -> E", :red, [("D", "E")], current_node = "D")
end

# ╔═╡ 9ff259ee-8ad7-4ac0-b9c5-8fc2aff0c498
gif(test_graph_animation, "test_graph_animation.gif", fps = 1)

# ╔═╡ a5a053b7-9f5d-4e4e-995d-98cf2a796c4c
begin
	#create animation of the graph with negative cycle
	node_value_neg_cycle = Dict{String, Float64}(v => Inf for v in keys(test_graph))
	node_value_neg_cycle["D"] = 0
	test_graph_neg_cycle_animation = bellman_ford_animated(test_graph_neg_cycle, "D")
end

# ╔═╡ 72710e96-8a46-46cf-b7bc-66cf68483f18
plot_graph(test_graph_neg_cycle, node_value_neg_cycle, "graph with negative cycle", :green, [("D", "E"), ("E", "C"), ("C", "D")])

# ╔═╡ e68ff2ee-98a0-4189-83b1-5cbd7ef84450
gif(test_graph_neg_cycle_animation, "test_graph_neg_cycle_animation.gif", fps = 2)

# ╔═╡ 0fbf0be0-12b7-47e5-9d9c-e7fd57549f77
"""
    create_currency_graph(pairs)

create a graph of all available currencies

Inputs:
    - `pairs`: vector with all currency pairs to put in the graph

Outputs:
    - `graph`: a dictionary that represents a graph with currencies as nodes
"""
function create_currency_graph(pairs)
	graph = Dict()
	for pair in pairs
		#get ticker information
		prices = ticker(pair)

		#get prices for both currencies and turn it into an edge weight
		weight_1 = log(1/prices[!, "bid"][])
		weight_2 = log(prices[!, "ask"][])

		#split the pair to get separate ticker symbols
		ticker_symbol_1, ticker_symbol_2 = split(pair, "-")

		#add the edge weight to the graph
		if !haskey(graph, ticker_symbol_1)
			graph[ticker_symbol_1] = [(weight_1, ticker_symbol_2)]
		else
			push!(graph[ticker_symbol_1],(weight_1, ticker_symbol_2))
		end
		if !haskey(graph, ticker_symbol_2)
			graph[ticker_symbol_2] = [(weight_2, ticker_symbol_1)]
		else
			push!(graph[ticker_symbol_2],(weight_2, ticker_symbol_1))
		end
	end
	return graph
end

# ╔═╡ b8d794ba-6c68-433d-846b-6ef348619cf6
begin
	#create a small currency graph with ETH, BTC, EUR and USD
	test_arbitrage_pairs = ["ETH-BTC", "ETH-EUR", "ETH-USD", "BTC-EUR", "BTC-USD"]
	test_arbitrage_graph = create_currency_graph(test_arbitrage_pairs)
	node_value_test_arbitrage = Dict(v => "" for v in keys(test_arbitrage_graph))
end

# ╔═╡ ffe2b3ff-2af6-4ddd-b8dc-692a115d221c
plot_graph(test_arbitrage_graph, node_value_test_arbitrage, "currency graph", :black, [])

# ╔═╡ ca6c579e-0ae2-46b7-af08-9b26958c19ee
begin
	#create an arbitrage graph with all currencies
	reset
	arbitrage_graph = create_currency_graph(pairs)
end

# ╔═╡ f8cacc84-9416-4f2d-af36-bd08d12b0bba
#get all currencies
nodes = collect(keys(arbitrage_graph))

# ╔═╡ 4385445e-642f-4880-bc14-3ea464302982
@bind currency_1 Select(nodes, default = "EUR")

# ╔═╡ aa7a4c7a-dfdc-403e-a274-6f8e951bd7d6
@bind currency_2 Select(nodes, default = "BTC")

# ╔═╡ 7a1db177-da08-4b6a-a85c-d1cf96e189b4
@bind currency_3 Select(nodes, default = "ETH")

# ╔═╡ 39c8f61d-c93c-4bd0-b823-c392b9c5dcfe
@bind currency_4 Select(nodes, default = "USD")

# ╔═╡ 2408e409-24d1-4ae7-8dd3-a2349b573363
"""
    bellman_ford_all_cycles(graph, start_node)

The Bellman-Ford algorithm adapted to return the necessary information to find a negative cycle

Inputs:
    - `graph`: a dictionary representing a directed graph on which the Bellman-Ford 
             algorithm will be applied 
    - `start_node`: starting point

Outputs:
    - `last_updated`: the last updated node in the nth iteration, returns "" if no node 
                    was updated
	- `N`: the amount of nodes
	- `predecessor`: a dictionary where the value of each key is its predecessor
"""
function bellman_ford_all_cycles(graph, start_node)
	
	#initialize distance from start node to every other node as inf
	distance = Dict{String, Float64}(v => Inf for v in keys(graph))
	#distance of the start node is 0
	distance[start_node] = 0
	#amount of nodes
	N = length(distance)

	#initialize predecessors, keeps track of the predecessor of every node
	predecessor = Dict{String, String}(v => "" for v in keys(graph))
	#the last updated node
	last_updated = ""
	
	#update distance N times
	for _ in 1:N
		last_updated = ""
		
		#iterate over all nodes
		for v in keys(graph)
			#iterate over all neighbors of the current node
			for (w, n) in graph[v]
				
				#update distance if needed
				if distance[v] + w < distance[n]
					distance[n] = min(distance[n], distance[v] + w)

					#update predecessor and last updated
					predecessor[n] = v
					last_updated = n
				end
			end
		end
	end
	return last_updated, N, predecessor
end
		

# ╔═╡ 5c61831e-122d-4a68-b16e-c674d9aa6e36
"""
    cycle_cost(graph, graph)

Calculate the cost of a cycle

Inputs:
	- `path`: a vector with nodes of a cycle
    - `graph`: a dictionary representing a directed graph on which the Bellman-Ford 
             algorithm will be applied 

Outputs:
    - `cost`: the cost of the cycle
"""
function cycle_cost(path, graph)
	cost = 0
	
	#iterate over the first l-1 nodes, with l the amount of nodes in the cycle
	for l in 1:length(path) - 1
		#find the correct edge
		for (w, n) in graph[path[l]]
			if n == path[l + 1]
				#add the cost of the edge
				cost += w
			end
		end
	end

	#find the cost of the edge between the last and the first node of the cycle
	for (w, n) in graph[path[length(path)]]
		if n == path[1]
			cost += w
		end
	end
	return cost
end

# ╔═╡ 63afbb82-509e-4eda-802b-f54349bc1e6b
"""
    find_cycles(graph, start_node)

find as many negative cycles in a graph as possible

Inputs:
    - `graph`: a dictionary representing a directed graph on which the Bellman-Ford 
             algorithm will be applied 
    - `start_node`: starting point

Outputs:
    - `paths`: a vector of vectors that contain the nodes of negative cycles
"""
function find_cycles(graph, start_node)
	#a boolean to keep the search for cycles going as long as there are cycles to be 
    #found
	cycles = true
	paths = []
	
	while cycles
		#use the Bellman-Ford algorithm to look for a cycle
		last_updated, N, predecessor = bellman_ford_all_cycles(graph, start_node)

		#if there were no updates in the last iteration, there are no cycles
		if last_updated == ""
			cycles = false

		#if there are updates in the last iteration, find the cycle
		else
			#the last updated node lies in the negative cycle or can be reached by it
			y = last_updated
			cost = 0

			#find a node that's definitaly in the cycle by moving back 
			for j in 1:N
				y = predecessor[y] 
			end
			
			current_node = y
			path = []
			#store nodes as part of the cycle untill a node is encountered twice
			for k in 1:N
				current_node = predecessor[current_node]
				push!(path, current_node)

				#if a node is encountered twice, break the loop
				if (current_node == y) & (size(path)[1] > 1)
					path = reverse(path)
					#calculate the cost of the cycle
					cost = cycle_cost(path, graph)

					#remove one of the edges of the negative cycle
					neighbours = graph[predecessor[current_node]]
					for (w, n) in graph[predecessor[current_node]]
						if n == current_node
							neighbours = deleteat!(neighbours, findall(x->x==(w, n), 
                                         neighbours))
							#push!(neighbours, (Inf, n))
							graph[predecessor[current_node]] = neighbours
						end
					end
					break
				end
			end

			#store the negative cycle
			if cost >= 0
				cycles = false
			else
				push!(paths, (path, cost))
			end
		end
	end
	return paths
end

# ╔═╡ 604bf714-e7ac-4100-8a57-fb421392a7d1
#create a custom arbitrage graph
begin
	#find all currency pairs between the custom currencies
	source = currency_1
	currencies = [currency_1, currency_2, currency_3, currency_4]
	custom_pairs = []
	
	for pair in pairs
		ticker_symbol_1, ticker_symbol_2 = split(pair, "-")
		if (ticker_symbol_1 in currencies) & (ticker_symbol_2 in currencies)
			push!(custom_pairs, pair)
		end
	end

	#create a graph with the custom currency pairs
	custom_arbitrage_graph = create_currency_graph(custom_pairs)
	custom_paths = find_cycles(deepcopy(custom_arbitrage_graph), source)

	#get the best negative cycle
	best_profit = 0
	best_path = []
	for (path, cost) in custom_paths
		profit = round((exp(-cost) - 1)*100, digits = 6)
		if profit > best_profit
			best_profit = profit
			best_path = path
		end
	end
	best_path = join(best_path, "-")
	profit_percentage = best_profit

	#animate the graph
	custom_arbitrage_graph_animation = bellman_ford_animated(custom_arbitrage_graph, source)
end

# ╔═╡ 24cc281e-0fc6-4871-9717-d9b211f5b9d9
gif(custom_arbitrage_graph_animation, "custom_arbitrage_graph_animation.gif", fps = 3)

# ╔═╡ eefb7444-f586-48b0-9c98-b9b6c78371c7
md"There is/are $(length(custom_paths)) arbitrage opportunity/apportunities in this subgraph. The highest percentage increase on investment is $profit_percentage% in this cycle: $best_path."

# ╔═╡ 08fb2d9d-7402-493c-be73-893318adec4d
#find all negative cycles
paths = find_cycles(deepcopy(arbitrage_graph), "EUR")

# ╔═╡ d281a1a9-3e89-4069-9da3-99673ec50dd2
begin
	path_string = []
	path_profit = []
	for (path, cost) in paths
		push!(path_string, join(path, "-"))
		push!(path_profit, round((exp(-cost) - 1)*100, digits = 6))
	end
end

# ╔═╡ 133aaf8d-3476-4386-84d9-afbcba75cdec
DataFrame(cycle = path_string, profit = path_profit)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CoinbasePro = "3632ec16-99db-4259-aa88-30b9105699f8"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GraphRecipes = "bd48cda9-67a9-57be-86fa-5b3c104eda73"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CoinbasePro = "~0.1.3"
DataFrames = "~1.3.2"
GraphRecipes = "~0.5.9"
Graphs = "~1.5.1"
Plots = "~1.25.7"
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

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
git-tree-sha1 = "54fc4400de6e5c3e27be6047da2ef6ba355511f8"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.6"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CoinbasePro]]
deps = ["DataFrames", "Dates", "HTTP", "JSON", "TimesDates"]
git-tree-sha1 = "fe630d2db2602fe63ce38916fa019c556c6f6e11"
uuid = "3632ec16-99db-4259-aa88-30b9105699f8"
version = "0.1.3"

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

[[CompoundPeriods]]
deps = ["Dates"]
git-tree-sha1 = "88b8763730e30994a0d6a13b3973ffdcd1a654fe"
uuid = "a216cea6-0a8c-5945-ab87-5ade47210022"
version = "0.4.1"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

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

[[ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

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

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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

[[GeometryTypes]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "d796f7be0383b5416cd403420ce0af083b0f9b28"
uuid = "4d00f742-c7ba-57c2-abde-4428a4b178cb"
version = "0.8.5"

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

[[GraphRecipes]]
deps = ["AbstractTrees", "GeometryTypes", "Graphs", "InteractiveUtils", "Interpolations", "LinearAlgebra", "NaNMath", "NetworkLayout", "PlotUtils", "RecipesBase", "SparseArrays", "Statistics"]
git-tree-sha1 = "1735085e3a8dd0e14020bdcbf8da9893a5508a3f"
uuid = "bd48cda9-67a9-57be-86fa-5b3c104eda73"
version = "0.5.9"

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

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

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

[[Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "29714d0a7a8083bba8427a4fbfb00a540c681ce7"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "cac8fc7ba64b699c678094fa630f49b80618f625"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.4"

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

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

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

[[TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "0f1017f68dc25f1a0cb99f4988f78fe4f2e7955f"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.7.1"

[[TimesDates]]
deps = ["CompoundPeriods", "Dates", "TimeZones"]
git-tree-sha1 = "b56fad6f36724a4261db450baa69074037846289"
uuid = "bdfc003b-8df8-5c39-adcd-3a9087f5df4a"
version = "0.2.6"

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
# ╟─a888a245-08ba-4fcd-8f19-52a810f4f725
# ╟─c00e89d3-e0e5-455f-b5fe-2b7c037d14f7
# ╟─2340a1ea-ff3e-40a2-b12c-b7d73199c573
# ╟─9a77b32f-6cdf-4193-810f-236a84493390
# ╟─5837516e-a034-4739-95a9-15a5d46d9d8f
# ╟─2e77f688-9fef-45cf-9b7a-076b70a1df8d
# ╟─04cb87db-08bf-4969-acd1-ad0aceefdb66
# ╟─e8758cb2-f0e1-4725-83e1-557a1bb50980
# ╟─c2c1802c-aeed-4fd1-b0e6-902e66e3a008
# ╟─9ff259ee-8ad7-4ac0-b9c5-8fc2aff0c498
# ╟─eb204bf2-68fe-42cf-b5a1-6688315e0982
# ╟─140f6c46-75f9-49d1-a7bf-9d2c53c182bf
# ╟─72710e96-8a46-46cf-b7bc-66cf68483f18
# ╟─499a3ea5-a8b7-40a3-a757-6799910c23bd
# ╟─619d3b48-4104-4485-a294-c60b76416e4a
# ╟─8b09540f-f6c6-4eac-839b-8b1d306cb891
# ╟─e68ff2ee-98a0-4189-83b1-5cbd7ef84450
# ╟─ab50352f-d01b-4070-bcc5-423f21eeb191
# ╟─b617a37b-7736-4ddc-a1d9-a17605245734
# ╟─c967f6e2-6d46-47ce-8b68-435c09a970a0
# ╟─ffe2b3ff-2af6-4ddd-b8dc-692a115d221c
# ╟─d63dc65a-f615-4ba9-80e7-c91207d60957
# ╟─f0e5f865-2a80-409b-9095-6de71b886706
# ╟─4385445e-642f-4880-bc14-3ea464302982
# ╟─aa7a4c7a-dfdc-403e-a274-6f8e951bd7d6
# ╟─7a1db177-da08-4b6a-a85c-d1cf96e189b4
# ╟─39c8f61d-c93c-4bd0-b823-c392b9c5dcfe
# ╟─a335f698-5b54-4dae-8d7d-0be483753a3d
# ╟─24cc281e-0fc6-4871-9717-d9b211f5b9d9
# ╟─eefb7444-f586-48b0-9c98-b9b6c78371c7
# ╟─de497cc3-51f4-40a7-9dc7-ba9c39801221
# ╟─b47f6352-9a02-4c26-ac8a-231acba1461d
# ╟─133aaf8d-3476-4386-84d9-afbcba75cdec
# ╟─c53dbce4-b8ce-4848-be1d-fd446e68d988
# ╟─34c5254a-b160-42e3-97b8-d0c7f5c88ad2
# ╟─2cf6976f-f448-47db-ac22-2a396cb17259
# ╠═50860473-05c4-4382-8586-b10499b64e81
# ╟─f338eeb1-2912-4b45-b898-a39d2344faa4
# ╟─31b058ab-a816-43ea-b50f-ea85ee05546e
# ╠═ec6b3904-1ff2-46e1-a6ea-7822b9a2fc6c
# ╠═13e6bb3e-57c5-496a-b3b0-5484d0e410c3
# ╟─6dd7e865-3931-4d81-9eae-bf300a611554
# ╠═19b7a29a-6bf8-4f1b-923c-ed1d55ebb075
# ╠═a5a053b7-9f5d-4e4e-995d-98cf2a796c4c
# ╟─2be70005-1eca-4ab7-863b-9c626a2ae454
# ╠═c9bc2ab3-8809-4360-883a-228c886c296f
# ╟─988eca98-aa15-4ff3-8540-f8edff0b7c89
# ╠═7575beac-392b-45d5-b097-de806d45fa25
# ╠═3792b2d7-9e7e-4508-bea4-fd5e0d53f585
# ╟─e8547de6-23ef-4fb5-8fad-623ba8abb11a
# ╠═b8d794ba-6c68-433d-846b-6ef348619cf6
# ╟─32af74c5-0f0c-4147-8a70-b4ff50399044
# ╠═f8cacc84-9416-4f2d-af36-bd08d12b0bba
# ╠═604bf714-e7ac-4100-8a57-fb421392a7d1
# ╟─24801a5a-313d-4311-952d-bd714121ac59
# ╠═ca6c579e-0ae2-46b7-af08-9b26958c19ee
# ╠═08fb2d9d-7402-493c-be73-893318adec4d
# ╠═d281a1a9-3e89-4069-9da3-99673ec50dd2
# ╟─e31936be-b9fd-41c8-87c0-513aded62e83
# ╟─f01c84aa-395e-4aca-baee-6098916f76c5
# ╟─7838c794-88e0-4d8a-9ab5-7f90bc3a7293
# ╟─0fbf0be0-12b7-47e5-9d9c-e7fd57549f77
# ╟─2408e409-24d1-4ae7-8dd3-a2349b573363
# ╟─63afbb82-509e-4eda-802b-f54349bc1e6b
# ╟─5c61831e-122d-4a68-b16e-c674d9aa6e36
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
