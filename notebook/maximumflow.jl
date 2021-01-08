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

# ╔═╡ 91553c30-3d37-11eb-2a33-2d6d4ee5e9b2
# Load needed packages:
using Plots, STMOZOO.MaximumFlow, PlutoUI, GraphRecipes

# ╔═╡ 814488a0-3d37-11eb-3dc9-a97e67207e93
md"""
# Maximum Flow Problems

**Exam project for the course Selected Topics in Mathematical Optimization**

Project by: Douwe De Vestele"""


# ╔═╡ 2dbacf30-4162-11eb-1dad-fb187c4f8ede
md"""
## Introduction

A maximum flow problem is a widely known example of an optimization problem. The goal is to find the maximum possible flow in a network where the connections between the nodes (the arcs or edges) have a limited capacity. It is a very recognizable situation, for instance a railway or highway network that leads trains or cars to connected cities, or channels transporting water to linked reservoirs. In fact, the problem was first formulated by Harris and Ross in the context of the military evaluation of a railway network capacity and the effectiveness of taking out one or more rail lines in order to stop hostile transports [^1]. Furthermore, many recurring problems are related to maximum flow problems and can thus be solved if a solution to the corresponding maximum flow problem exists.

It is clear that such a recognizable and applicable problem is studied thoroughly and multiple solution methods, algorithms and applications have been developed.
In this notebook first some definitions and terminology of the maximum flow problem are explained. Further one of the first solving methods, the Ford-Fulkerson method, is studied, implemented and illustrated on a toy example. At last some real-life applications are shown.


"""

# ╔═╡ 8362b6a0-49cd-11eb-188a-39028e89cbfb
md"""
## Definitions

To be able to completely understand the problem, some definitions and terminology are needed.

!!! terminology "Capacitated network"
    A capacitated network is a network ``G`` with nodes ``N`` and arcs ``A``, noted as ``G = (N,A)``, with a capacity ``u_{i,j}`` for the arc ``(i,j) \in A``. In this notebook the network is implemented as an ``n \times n`` adjacency matrix ``A``, with ``n`` the number of nodes in ``N`` and where ``A[i,j] = u_{i,j}``. Say an arc ``(i,j) \in A`` exists if ``A[i,j] > 0`` and the corresponding capacity is ``u_{i,j}``.

An example of a capacitated network is illustrated below.
"""


# ╔═╡ 17321b8e-4a24-11eb-286d-47e441d012e9
begin
		example = [0 8 2 0; 0 0 2 4;0 0 0 5;0 0 0 0];
		nodelabs = ["a","b","c","d"];
		x_loc = [0, 0.5, 0.5, 1];
		y_loc = [0.5,1,0,0.5];
end;

# ╔═╡ 8279cab0-4a24-11eb-13de-8f3a13d74c63
graphplot(example, x=x_loc, y=y_loc, nodeshape = :circle
, nodesize = 0.2, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = example, fontsize = 8, curves = false, arrows = true )

# ╔═╡ 0a9929a0-4a24-11eb-34ac-49fe1e92fefa
md"""
Two special nodes are highlighted, the source ``s`` and sink ``t``. The maximum flow problem can then formally be written as:

maximize ``v``, subject to:

```math
\sum_{(i,j) \in A} x_{i,j} \text{ -} \sum_{(i,j) \in A} x_{j,i} = \begin{cases} v & \text{for } i = s, \\ 0 & \text{for all } i \in N \setminus \{s,t\} \\ -v & \text{for } i = t. \end{cases}
```
and
```math
0 \leq x_{i,j} \leq u_{i,j}  \hspace{2em} \text{for each } (i,j) \in A
``` 
where ``x`` is a matrix with elements ``x_{i,j}`` called 'a flow' and ``v`` the value of the flow.

Furthermore the problem is subject to some assumptions:

* The network is directed
* All capacities are strictly positive integers
* There is no directed path from ``s`` to ``t`` existing of infinite capacity arcs, otherwise the maximum flow would be infinite
* If there is an arc ``(i,j)``, there can also be an arc ``(j,i)``
* There are no parallel arcs (an arc with the same source and sink node).

At last, a critical concept in the following algorithm is the residual network:
!!! terminology "Residual network"
    A residual network given a flow ``x``, ``G(x)``, exists of the residual capacities ``r_{i,j}`` from a network ``G``. The residual capacity of an arc ``(i,j) \in A`` is the maximal additional flow that can be sent from node ``i`` to ``j`` using the arcs ``(i,j)`` and ``(j,i)``, so ``r_{i,j} = u_{i,j} - x_{i,j} + x_{j,i}``. It consists of two parts: the unused capacity ``u_{i,j} - x_{i,j}`` of arc ``(i,j)`` and the current flow ``x_{j,i}`` using arc ``(j,i)``, which can be canceled to increase the flow ``x_{i,j}``.

The residual network of the example above, given flow 
``x = \begin{bmatrix} 0 & 3 & 1 & 0 \\ 0 & 0 & 1 & 2 \\ 0 & 0 & 0 & 2 \\ 0 &0&0&0 \end{bmatrix}`` is shown below.

"""

# ╔═╡ 03b26e12-4a26-11eb-32ae-5b3dca2e4708
begin
	example_flow = [0 3 1 0; 0 0 1 2; 0 0 0 2; 0 0 0 0]
	res_net = res_network(example,example_flow)
end;

# ╔═╡ 3641b2a0-4a26-11eb-037b-856bede74976
begin
	l = @layout [a b c] 
	p1 = graphplot(example, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = example, fontsize = 8, curves = false, arrows = true, title = "original network" )
	p2 = graphplot(example_flow, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = example_flow, fontsize = 8, curves = false, arrows = true, title = "flow" )
	p3 = graphplot(res_net, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = res_net, fontsize = 8, curves = true, arrows = true, title = "residual network" )
	plot(p1,p2,p3,layout = l)
end

# ╔═╡ 0a8c4af0-4169-11eb-2d4d-6d8a9f515b94
md"""
## Ford-Fulkerson method [^2]

### Method

The Ford-Fulkerson method is the first method that was developed to solve this kind of problem and is rather intuitive. It is a greedy method, also known as the augmenting path algorithm and guarantees to find a maximum flow if the network consists of arcs with integer, finite capacities.

It starts with calculating the residual network of a capacitated network given a flow (which is initially zero) as described above. Then it searches this residual network for existing augmenting paths, that is a path from source to sink of which all residual capacities are larger than zero. The residual capacity of an augmenting path is defined as the minimum residual capacity of the arcs in the path. If such a path exists, the residual capacity is by definition positive, so it can be added to the flow along each arc in the augmenting path. This proces is repeated until no augmenting paths can be found.

Note that it is not mentioned how the augmenting paths can be found, therefore it is called a **method** instead of an algorithm. A frequently used search algorithm to find these augmenting paths is the breadth-first search, which finds a shortest path in a network (in terms of number of arcs in the path). When this search algorithm is used in the Ford-Fulkerson method, the algorithm is called the Edmonds-Karp algorithm and it solves the maximum flow problem in maximally ``\mathcal{O}(na^2)`` time, where ``n`` and ``a`` are the number of nodes and arcs respectively. It works as follows.
The distinction is made between labeled and unlabeled nodes, where a labeled node is already visited and an unlabeled not. Further a queue is used, containing the nodes of which the neighboring nodes still have to be explored. Starting with the source, which is labeled and added to the queue, all the unlabeled nodes connected to it with an arc with a larger than zero residual capacity, are labeled and added at the back of the queue. Subsequently the source is removed from the queue and the first node in the queue is further explored. The algorithm stops if the sink gets labeled, or if all the nodes are labeled and there are no nodes left in the queue, which means there is no augmenting path. Because for each labeled node it is memorised which parent node led to it's labeling, the path can be reconstructed using backtracking.

### Pseudocode 

The pseudocode of both algorithms is shown below and implemented in respectively `augmenting_path` and `bfs`.

#### Augmenting path algorithm
1. Initialize zero flow.
2. Calculate the residual network.
3. Search the residual network for an augmenting path.
4. If such a path exists:
    * Define the minimum residual capacity of the arcs in the path
    * Add this to the flow along each arc in the path
    * Repeat steps 2 - 3.
5. If not, stop the algorithm.

#### Breadth-first search
1. Unlabel all nodes and initialize an empty queue and an empty parent array.
2. Label the source and add it to the queue.
3. As long as the sink is not labeled and the queue is not empty:
    * Remove the first node from the queue and explore all the nodes connected to it with a non-zero residual capacity arc.
        * If the neighboring node is unlabeled, label it and add it at the end of the queue. 
        * Save the node that is currently being explored as the parent node.
        * If it is already labeled, go on to the next neighboring node.
4. If the sink is labeled, a path is found, otherwise an augmenting path does not exist.

### Example
The example above is used to illustrate the augmenting path algorithm. First the original network is shown. Below you can see the different steps at each iteration of the algorithm. The augmenting path in the residual network is indicated by orange nodes.
"""

# ╔═╡ 476e6b6e-4f32-11eb-0465-133b96d6fbe2
graphplot(example, x= x_loc, y = y_loc, nodeshape = :circle, nodesize = 0.2, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = example, fontsize = 8, curves = false, arrows = true, title = "original network" )

# ╔═╡ 981e1540-4ea9-11eb-1d1b-9167a3e9e4d7
example_sol, example_mflow, example_t =  augmenting_path(example,1,4,track = true);

# ╔═╡ 29f78920-4ea9-11eb-3edf-015742b50e29
@bind teller Slider(1:length(example_t))

# ╔═╡ 09f10790-4eaa-11eb-2f8c-97431d5516ba
md"Use the slider to scroll through the steps. You are currently viewing step $teller."

# ╔═╡ a80d9420-4c57-11eb-396c-8743eb36b0ca
let
	colors = ["red","lightblue","lightblue","red"]
	colors[example_t[teller][3]] .= "orange"; 
	or_flow = example_t[teller][1];
	res_nw = example_t[teller][2];
	if teller == length(example_t)
		update_flow = example_sol;
	else
		update_flow = example_t[teller+1][1]
	end
	l2 = @layout [a b c]
	f1 = graphplot(example, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = or_flow, fontsize = 8, curves = false, arrows = true, title = "original flow" )
	f2 = graphplot(res_nw, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = colors, names = nodelabs, edgelabel = res_nw, fontsize = 8, curves = true, arrows = true, title = "residual network \n with augmenting path" )
	f3 = graphplot(update_flow, x=x_loc, y=y_loc, nodeshape = :circle, nodesize = 0.25, nodecolor = ["red", "lightblue","lightblue","red"], names = nodelabs, edgelabel = update_flow, fontsize = 8, curves = false, arrows = true, title = "updated flow" )
	plot(f1,f2,f3,layout = l2)
end

# ╔═╡ ac2efd2e-4aec-11eb-2036-79f16f99e91f
md"""
## Applications
At last two real-life applications of the maximum flow problem are shown to prove its practical abilities.

### Feasible flow [^2]
The first application is the most physically interpretable. The goal is to send a defined amount of flow from one or multiple sources to one or multiple sinks. If this is not possible given the capacitated network, the flow is not feasible. An extra constraint can be the amount of flow the sink(s) need(s) to receive, in case this is known. To illustrate this problem, the following setting is used:

Suppose it is the day of *De Ronde van Vlaanderen* (the Tour of Flanders), a famous road cycling race in the UCI World Tour. The finish is in Oudenaarde, a small city in the Flemish Ardens surrounded by challenging climbs. Of course a lot of cycling fans want to see their hero crossing the finish line first and they are taking the train from their home city to Oudenaarde. The following network represents a simplified railway map from the SNCB with some (major) cities in Flanders [^3]. The capacities are illustrative and represent the capacities of the trains riding between 2 cities on a normal day.

"""

# ╔═╡ 609aeeb0-4169-11eb-2f61-a984c918f598
begin
	# set up graph
	train_nw = [0 800 0 0 0 0 1000 0 0 0; 0 0 800 400 0 0 0 0 0 0; 0 0 0 800 0 600 0 0 0 0; 0 0 0 0 800 0 0 0 0 0; 0 0 0 0 0 800 0 0 0 0;0 0 0 0 0 0 0 0 0 0; 0 0 0 0 400 0 0 400 0 0; 0 0 0 0 0 600 0 0 0 0; 0 0 0 0 0 0 800 0 0 0; 0 0 0 0 0 0 1000 200 600 0];
	nodelabs_trains = ["Bruges","Lichtervelde","Kortrijk","Deinze","De Pinte","Oudenaarde","Ghent","Zottegem","Antwerp","Brussels"];
	#x_loc = [0.1,0,0.2,0.4,0.75,0.65,1,1.2,2,1.85];
	#y_loc = [0,0.5,1,0.63,0.55,0.9,0.4,0.85,-0.05,0.95];
	x_loc_train= [0.2,0,0.4,0.65,1.2,1.1,1.5,2,2.7,2.7];
	y_loc_train = [2,1.1,0,0.8,1,0.2,1.4,0.3,1.8,0.2];
end;

# ╔═╡ 233f5860-4f3f-11eb-2c9e-d73523e1ca8a
graphplot(train_nw, x = x_loc_train, y = y_loc_train, names = nodelabs_trains, nodesize = 0.22, nodecolor = "lightblue", nodeshape = :rect, edgelabel = train_nw, arrows = true, curves = true, title = "Simplified map of the SNCB railway network")

# ╔═╡ 7423da20-4f40-11eb-3699-ab27e5529056
md"
Say the huge cycling fans live in Bruges, Kortrijk, Antwerp and Brussels. These cities are considered sources and of course Oudenaarde is the sink. This means that in the other cities, no extra people can get on the train. Furthermore it is known how many fans want to get from the source cities to the finish. In Bruges there are 600 fans, in Kortrijk 500, in Antwerp 300 and in Brussels 800.

The feasible flow problem translates into the question: **Is it possible to let all the passengers go from their home city to their desired destination?**
This can be solved by adding a node in the network with arcs to each source. The capacities of these arcs are the number of passengers that have to get on the train in each home city. Calculating the maximum flow in this extended network gives the answer on the question. This is implemented in the function `augmenting_path` by giving an extra argument `send`.

!!! note
	The trick of adding an extra node in front and/or at the end of the network can 	also be used to solve a maximum flow problem with multiple sources and/or sinks, 	 by giving the arcs from the extra node(s) to the sources and/or sinks unlimited 	 capacities (practically implemented as very large integers).
"

# ╔═╡ 5ccbf0f0-4f41-11eb-0a1f-cf4fcf14a8ab
train_flow,train_mflow,tracker = augmenting_path(train_nw,[1,3,9,10],6,send = [600,500,300,800]);

# ╔═╡ 211123c0-4fad-11eb-3077-79eedeb5352f
md"
Here an annoying side-effect of the use of multiple sources comes up. Normally there won't be any flow going to a source (this would be useless and inefficient) because it will be canceled by outgoing flow originating in the source. But because in the algorithm with multiple sources an extra node is added to serve as the temporary source, the real sources are handled like normal nodes and thus can serve as a connecting node in a path. Here this is the case for a path from Brussels to Oudernaarde that passes through Bruges. To make the flow more efficient, an auxiliary function `clean!` can be used to clean up the resulting flow.
"

# ╔═╡ 92ed34d0-5010-11eb-050e-9d1c445ac620
md"Press the button to clean the flow."

# ╔═╡ 9b519a40-500f-11eb-2e0d-79d0cf1f43f9
@bind clean Button("Clean")

# ╔═╡ 70c0e390-4f41-11eb-0e54-81257dd84014
let
	clean
	graphplot(train_flow, x = x_loc_train, y = y_loc_train, names = nodelabs_trains, 	nodesize = 0.22, nodecolor = "lightblue", nodeshape = :rect, edgelabel = 		train_flow, arrows = true, curves = true, title = "Maximum flow = $train_mflow")
end

# ╔═╡ 57eec750-500f-11eb-04e7-49545c4d7945
let
	clean
	clean!(train_flow)
end;

# ╔═╡ 055c6830-4f42-11eb-3367-b701c612cbfa
md"
It seems that the network is quickly saturated by the limited capacities of the trains going to Oudenaarde. It can be visually checked if the flow is feasible by looking to the flow originating in each source city and comparing this to the wanted flow, or by using the function `isfeasible`. 
"

# ╔═╡ 0f5c4240-4f4e-11eb-0a5f-31c50912560b
isfeasible(train_flow,s=[1,3,9,10],t=6, send= [600,500,300,800])

# ╔═╡ 08cb80d0-4f4e-11eb-2d93-d1d6812076b8
md"
Apparently there are 200 fans from Brussels that can't reach their destination.
But because it is a special day, the SNCB is willing to add extra railway carriages to improve the capacities of the lines.

As an expert in maximum flow problems, you can advise the SNCB on which line they should allow a suggested number of extra passengers to make it possible that everyone can attend the finish.
"

# ╔═╡ 6fdc9080-51d2-11eb-013f-abfd6d72ba2d
md"""
Add $(@bind extra NumberField(0:1000, default=100)) from $(@bind node_A html"<select><option value=1>Bruges</option><option value=2>Lichtervelde</option><option value=3>Kortrijk</option><option value=4>Deinze</option><option value=5>De Pinte</option><option value=6>Oudenaarde</option><option value=7>Ghent</option><option value=8>Zottegem</option><option value=9>Antwerp</option><option value=10>Brussels</option></select>") to $(@bind node_B html"<select><option value=1>Bruges</option><option value=2>Lichtervelde</option><option value=3>Kortrijk</option><option value=4>Deinze</option><option value=5>De Pinte</option><option value=6>Oudenaarde</option><option value=7>Ghent</option><option value=8>Zottegem</option><option value=9>Antwerp</option><option value=10>Brussels</option></select>").
"""

# ╔═╡ d2758df0-51d7-11eb-16ea-c1259ecb643e
(@bind change Button("Try changes"))  

# ╔═╡ 830b3e30-51d8-11eb-054b-6ba598d098ba
(@bind revert Button("Undo changes"))

# ╔═╡ 895559b0-51d8-11eb-0eea-4f062f228107
(@bind restart Button("Restart"))

# ╔═╡ 8d1dfa70-51d8-11eb-1860-133da534f773
md"(Undo the changes will substract the capacity in the number box from the line between the two selected cities, restart will discard all the changes you've made and restart from zero.)"

# ╔═╡ 09299d02-51d8-11eb-1a7f-e1e122105b05
begin
	restart
	train_nw_adapt = copy(train_nw)
end;

# ╔═╡ a388a070-4f45-11eb-1484-0989c534c0c5
begin
	change
	revert
	graphplot(train_nw_adapt, x = x_loc_train, y = y_loc_train, names = nodelabs_trains, nodesize = 0.22, nodecolor = "lightblue", nodeshape = :rect, edgelabel = train_nw_adapt, arrows = true, curves = true, title = "Adapted network with increased capacities")
end

# ╔═╡ 7e366620-4f7e-11eb-3ea8-cd394bc381b5
md"
And the solution to the problem is:
"

# ╔═╡ d146ade0-4f45-11eb-3990-5fefde1996af
begin
	change
	revert
	restart
	train_flow_adapt,train_mflow_adapt = augmenting_path(train_nw_adapt,[1,3,9,10],6,send= [600,500,300,800]);
	clean!(train_flow_adapt)
	graphplot(train_flow_adapt, x = x_loc_train, y = y_loc_train, names = nodelabs_trains, nodesize = 0.22, nodecolor = "lightblue", nodeshape = :rect, edgelabel = train_flow_adapt, arrows = true, curves = true, title = "Maximum flow = $train_mflow_adapt")
end

# ╔═╡ 84c50e10-4f65-11eb-2cc5-df589ae2048d
isfeasible(train_flow_adapt,s = [1,3,9,10],t = 6,send = [600,500,300,800])

# ╔═╡ ea074bd0-51d6-11eb-3bae-d7c05e869be5
if isfeasible(train_flow_adapt,s = [1,3,9,10],t = 6,send = [600,500,300,800])
	md"
Good job! Your suggestions for the railway network proved useful! Now every cycling fan can see the finish!"
else
	md"
Hmm, maybe you should try another adaptation to the network!
	"
end

# ╔═╡ 362b54c0-51d7-11eb-1434-a5e34e89afed


# ╔═╡ 3c232d30-4f48-11eb-254e-99f2c19894f0
md"
At last it is possible that the organization of the Tour of Flanders limits the number of spectators that can attend the finish. If there is for instance only place for 2000 spectators in Oudenaarde, the network can be extended with a new sink node, receiving the maximum number of visitors allowed as the arc capacity from the original sink (note that inhabitants of Oudenaarde, or people who do not come by train are not counted). This is illustrated below.
"

# ╔═╡ 583a8020-4f7c-11eb-3ab5-179f606feca0
train_flow_limit,train_mflow_limit = augmenting_path(train_nw_adapt,[1,3,9,10],[6],send= [600,500,300,800],desired = [2000]);

# ╔═╡ 94a88330-4f7d-11eb-3578-7148fb635b32
begin
	clean!(train_flow_limit)
	graphplot(train_flow_limit, x = x_loc_train, y = y_loc_train, names = nodelabs_trains, nodesize = 0.22, nodecolor = "lightblue", nodeshape = :rect, edgelabel = train_flow_limit, arrows = true, curves = true, title = "Maximum flow = $train_mflow_limit")
end

# ╔═╡ a1147c40-4f7e-11eb-15fa-b751ce27d0eb
md"
Because the number of allowed visiters is lower than the number of fans willing to attend the finish, this is not a feasible flow. The organization will have to accept more spectators to satisfy all the cycling fans.
"

# ╔═╡ 82e23060-4f7d-11eb-3b7e-139f5554e87e
isfeasible(train_flow_adapt,s = [1,3,9,10],t = 6,send = [600,500,300,800],desired = [2000])

# ╔═╡ 3a70f830-502b-11eb-049d-190bafb36c7f


# ╔═╡ cb847020-4f7e-11eb-2ecb-4b51f41f4c8a
md"
### Distributed computing on a two-processor computer [^4]

Suppose you have a computer with two (not necessarily identical) processors on which you want to run a rather complex program consisting of four modules. Each module ``i`` can be allocated to one of the two processors, resulting in a computing cost ``\alpha_i`` or ``\beta_i`` if it is allocated to processor 1 or 2 respectively. The modules can be run on a different processor, but some modules need to communicate with each other. If two modules ``i`` and ``j`` need to communicate, but are allocated to two different processors, an extra cost ``c_{i,j}`` needs to be accounted for. The goal is to minimize the computational cost by distributing the different modules of the program over the two processors in an optimal way.

The computing cost of module ``i`` run by processor 1 or 2 is given in this table:

|``i`` | a | b | c | d |
|--- | --- | --- | --- | --- |
|``\alpha_i`` | 6 | 5 | 10 | 4 |
|``\beta_i`` | 4 | 10 | 3 | 8 |

The communication cost between the different modules is given in this matrix:

```math
\{c_{i,j}\} = 
\begin{bmatrix}
0 & 5 & 0 & 0 \\
5 & 0 & 6 & 2 \\
0 & 6 & 0 & 1 \\
0 & 2 & 1 & 0
\end{bmatrix}
```

This problem can be translated to a network as follows. The matrix above is used as a network representing the flow between the modules. Further the source ``s`` and sink ``t`` nodes are added, representing processor 1 and 2 respectively. From the source there is an arc with capacity ``\beta_i`` to each module. Moreover there is an arc from each module to the sink with capacity ``\alpha_i``. The resulting network with modules ``a``, ``b``, ``c`` and ``d`` and processors 1 and 2 is shown below.
"

# ╔═╡ efd3baf2-4fa9-11eb-3ab5-016a3af98589
#set up example
begin
	processor_nw = [0 4 10 3 8 0; 0 0 5 0 0 6; 0 5 0 6 2 5; 0 0 6 0 1 10;0 0 2 1 0 4; 0 0 0 0 0 0]
	processor_x = [0, 0.5, 0.5, 0.4,0.55,1]
	processor_y = [0.5, 1, 0.66, 0.33,0,0.5]
	processor_names = ["1","a","b","c","d","2"]
end;

# ╔═╡ 31ca4922-4fa9-11eb-2b3d-3d204532629c
graphplot(processor_nw,x = processor_x, y = processor_y,
names = processor_names, nodeshape = :circle, nodecolor = "lightblue", nodesize = 0.2, edgelabel = processor_nw, curves = false, arrows = true, title = "distributed computing network")

# ╔═╡ 28964c4e-5026-11eb-1ff2-c3a416bfcdbe
md"""
To solve the problem, first some extra concepts in graph theory are needed.

!!! terminology "s-t cut"
    A cut is a partition of the node set ``N`` into two subsets ``S`` and ``\bar{S} = N\setminus S``. If `` s \in S`` and ``t \in \bar{S}`` it is called an s-t cut. Arcs ``(i,j)`` with ``i \in S`` and ``j \in \bar{S}`` are called forward arcs of the cut and if ``j \in S`` and ``i \in \bar{S}``, arc ``(i,j)`` is called a backward arc.

!!! terminology "Capacity of an s-t cut"
    The capacity of an s-t cut is the sum of the capacities of the forward arcs in the cut.

!!! terminology "Minimum cut"
    A minimum cut is an s-t cut whose capacity is minimum among all the s-t cuts in a network.

From these definitions it is clear that thanks to the specific construction of the network, the total computational cost of an assignment of modules to different processors is given by the capacity of an s-t cut and the problem is in fact a **min-cut problem**. This can be illustrated with the following example cut. Let ``S = \{a,b\}`` and ``\bar{S} = \{c,d\}``. In the table above, it can be seen that the computational cost of running module ``a`` on processor 1 is equal to 6 and this is equal to the capacity of the upper right edge that is cut by the red line. This can be checked for each module. Further ``c`` and ``d`` have to communicate with ``b``, so two additional costs of 6 and 2 respectively are added (note that double arcs are counted only once). The total cost of this cut is ``8+3+6+2+5+6 = 30``.
"""

# ╔═╡ 0d32c91e-502b-11eb-2ef4-97528999fb37
begin
	graphplot(processor_nw,x = processor_x, y = processor_y,
	names = processor_names, nodeshape = :circle, nodecolor = "lightblue", nodesize = 0.2, edgelabel = processor_nw, curves = false, arrows = true, title = "example cut (cost = 30)")
	cut_x = 0:1
	cut_y = 0.7*cut_x .+ 0.15
	plot!(cut_x,cut_y, color = "red", linewidth = 2)
end

# ╔═╡ 042adb3e-502d-11eb-2702-413da0439d26
md"""
To make the link with the maximum flow problem, the Max-Flow Min-Cut Theorem is used [^5].

!!! terminology "Max-Flow Min-Cut Theorem"
    The maximal flow value obtainable in a capacitated network G is the minimum cut among all s-t cuts.

This means that every min-cut problem can be transformed to a maximum flow problem. Thus by calculating the maximum flow of the above network, we can determine the minimum computational cost. 

We can derive the allocation of the modules to the ``S`` or ``\bar{S}`` partition using the residual network given the maximum flow, ``G(x_{max})``. A node is part of ``S`` if it is reachable from ``s`` in ``G(x_{max})``, otherwise it is in ``\bar{S}``.
"""

# ╔═╡ 24b62e60-4f96-11eb-367d-cbe8af57dcdd
processor_flow, processor_mflow = augmenting_path(processor_nw,1,6);

# ╔═╡ 27d8be90-4fab-11eb-03eb-c1ce034225e7
processor_res = res_network(processor_nw,processor_flow);

# ╔═╡ c21893ae-4fa9-11eb-0920-a187a80c97f9
let
	l3 = @layout [a b]
	p1 = graphplot(processor_res, x = processor_x, y = processor_y,names = 		     processor_names, nodeshape = :circle, nodecolor = "lightblue", nodesize = 0.2, curves = false, arrows = true, title = "residual network")
	p2 = graphplot(processor_nw,x = processor_x, y = processor_y, names = processor_names, nodeshape = :circle, nodecolor = "lightblue", nodesize = 0.2, edgelabel = processor_nw, curves = false, arrows = true, title = "minimum cut (cost = $processor_mflow)")
	cut_x = 0:1
	cut_y = -1*cut_x .+ 0.65
	plot!(cut_x,cut_y, color = "red", linewidth = 2)
	plot(p1,p2,layout = l3)
end

# ╔═╡ 076320e0-5043-11eb-3aa8-670cdd2b7e20
md"
It appears that the optimal approach to run this program is to run module ``d`` on processor 1 and the other modules on processor 2.
"

# ╔═╡ 37063510-4168-11eb-0501-53062fc78345
md"""
## References

[^1]: T.E. Harris and F.S. Ross,  *Fundamentals of a method for evaluating rail net capacities*. Santa Monica, CA: RAND Corp, 1955.

[^2]: R.K. Ahuja, T.L. Magnanti and J.B. Orlin, *Network flows. Theory, Algorithms, and Applications*. Prentice Hall, Englewood Cliffs, NJ, 1993.

[^3]: "Map of the entire SNCB railway network", *belgiantrain.be*, 1 September 2020. [Online]. Available: https://www.belgiantrain.be/en/travel-info/prepare-for-your-journey/leaflets/global-map-train-belgium. [Consulted on 25 December 2020].

[^4]: R.K. Ahuja, T.L. Magnanti, J.B. Orlin and M.R. Reddy, "Applications of network optimization" in *Handbooks in OR & MS*, Vol. 7. M.O. Ball et al., Eds. Elsevier, 1995, ch. 1, pp.1-83.

[^5]: L. R. Ford and D. R. Fulkerson, *Maximal Flow Through a Network*. Canadian Journal of Mathematics, vol. 8, pp. 399–404, 1956.
"""

# ╔═╡ 8b33a180-51d6-11eb-3c53-3dbe26e87a64
md"
## Extra functions
"

# ╔═╡ b20c3012-51d1-11eb-1e1b-61dbdcacd512
"""
	function add_capacity!(nw::AbstractMatrix{Int},node_A::Int,node_B::Int,extra::Int)
Add `extra` capacity on the railway line from `node_A` to `node_B` in the network `nw`.
"""
function add_capacity!(nw::AbstractMatrix{Int},node_A::Int,node_B::Int,extra::Int)
	@assert node_A != node_B "You have to chose different nodes!"
	@assert nw[node_A,node_B] + extra >= 0 "Now there is an impossible negative capacity. You should do something else!"
	@assert nw[node_A,node_B] != 0 "You can't create extra lines, sorry!"
	nw[node_A,node_B] += extra
end

# ╔═╡ 3f5291d0-51d2-11eb-23c5-9d148db01ce5
begin
	change
	add_capacity!(train_nw_adapt,parse(Int,node_A),parse(Int,node_B),extra)
end;

# ╔═╡ 4957e3c2-51d6-11eb-05f1-bfa622cee664
begin
	revert
	add_capacity!(train_nw_adapt,parse(Int,node_A),parse(Int,node_B),-extra)
end;

# ╔═╡ Cell order:
# ╟─814488a0-3d37-11eb-3dc9-a97e67207e93
# ╠═91553c30-3d37-11eb-2a33-2d6d4ee5e9b2
# ╟─2dbacf30-4162-11eb-1dad-fb187c4f8ede
# ╟─8362b6a0-49cd-11eb-188a-39028e89cbfb
# ╟─17321b8e-4a24-11eb-286d-47e441d012e9
# ╟─8279cab0-4a24-11eb-13de-8f3a13d74c63
# ╟─0a9929a0-4a24-11eb-34ac-49fe1e92fefa
# ╟─03b26e12-4a26-11eb-32ae-5b3dca2e4708
# ╟─3641b2a0-4a26-11eb-037b-856bede74976
# ╟─0a8c4af0-4169-11eb-2d4d-6d8a9f515b94
# ╟─476e6b6e-4f32-11eb-0465-133b96d6fbe2
# ╠═981e1540-4ea9-11eb-1d1b-9167a3e9e4d7
# ╟─09f10790-4eaa-11eb-2f8c-97431d5516ba
# ╟─29f78920-4ea9-11eb-3edf-015742b50e29
# ╟─a80d9420-4c57-11eb-396c-8743eb36b0ca
# ╟─ac2efd2e-4aec-11eb-2036-79f16f99e91f
# ╟─609aeeb0-4169-11eb-2f61-a984c918f598
# ╟─233f5860-4f3f-11eb-2c9e-d73523e1ca8a
# ╟─7423da20-4f40-11eb-3699-ab27e5529056
# ╠═5ccbf0f0-4f41-11eb-0a1f-cf4fcf14a8ab
# ╟─70c0e390-4f41-11eb-0e54-81257dd84014
# ╟─211123c0-4fad-11eb-3077-79eedeb5352f
# ╟─92ed34d0-5010-11eb-050e-9d1c445ac620
# ╟─9b519a40-500f-11eb-2e0d-79d0cf1f43f9
# ╟─57eec750-500f-11eb-04e7-49545c4d7945
# ╟─055c6830-4f42-11eb-3367-b701c612cbfa
# ╠═0f5c4240-4f4e-11eb-0a5f-31c50912560b
# ╟─08cb80d0-4f4e-11eb-2d93-d1d6812076b8
# ╟─6fdc9080-51d2-11eb-013f-abfd6d72ba2d
# ╟─d2758df0-51d7-11eb-16ea-c1259ecb643e
# ╟─830b3e30-51d8-11eb-054b-6ba598d098ba
# ╟─895559b0-51d8-11eb-0eea-4f062f228107
# ╟─8d1dfa70-51d8-11eb-1860-133da534f773
# ╟─3f5291d0-51d2-11eb-23c5-9d148db01ce5
# ╟─4957e3c2-51d6-11eb-05f1-bfa622cee664
# ╟─09299d02-51d8-11eb-1a7f-e1e122105b05
# ╟─a388a070-4f45-11eb-1484-0989c534c0c5
# ╟─7e366620-4f7e-11eb-3ea8-cd394bc381b5
# ╟─d146ade0-4f45-11eb-3990-5fefde1996af
# ╠═84c50e10-4f65-11eb-2cc5-df589ae2048d
# ╟─ea074bd0-51d6-11eb-3bae-d7c05e869be5
# ╟─362b54c0-51d7-11eb-1434-a5e34e89afed
# ╟─3c232d30-4f48-11eb-254e-99f2c19894f0
# ╠═583a8020-4f7c-11eb-3ab5-179f606feca0
# ╟─94a88330-4f7d-11eb-3578-7148fb635b32
# ╟─a1147c40-4f7e-11eb-15fa-b751ce27d0eb
# ╠═82e23060-4f7d-11eb-3b7e-139f5554e87e
# ╟─3a70f830-502b-11eb-049d-190bafb36c7f
# ╟─cb847020-4f7e-11eb-2ecb-4b51f41f4c8a
# ╟─efd3baf2-4fa9-11eb-3ab5-016a3af98589
# ╟─31ca4922-4fa9-11eb-2b3d-3d204532629c
# ╟─28964c4e-5026-11eb-1ff2-c3a416bfcdbe
# ╟─0d32c91e-502b-11eb-2ef4-97528999fb37
# ╟─042adb3e-502d-11eb-2702-413da0439d26
# ╠═24b62e60-4f96-11eb-367d-cbe8af57dcdd
# ╠═27d8be90-4fab-11eb-03eb-c1ce034225e7
# ╟─c21893ae-4fa9-11eb-0920-a187a80c97f9
# ╟─076320e0-5043-11eb-3aa8-670cdd2b7e20
# ╟─37063510-4168-11eb-0501-53062fc78345
# ╟─8b33a180-51d6-11eb-3c53-3dbe26e87a64
# ╟─b20c3012-51d1-11eb-1e1b-61dbdcacd512
