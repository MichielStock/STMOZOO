### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ d2d007b8-20f8-11eb-0ddd-1181d4565a85
using Plots

# ╔═╡ 54286c74-5015-11eb-214e-352bbdb7e252
using STMOZOO.EulerianPath

# ╔═╡ 15e64cfe-5029-11eb-2e66-09f62c94cc65
using GraphRecipes, LightGraphs, SimpleWeightedGraphs, GraphPlot

# ╔═╡ 171fee18-20f6-11eb-37e5-2d04caea8c35
md"""
# Eulerian Path

By Ke Zhang

## Introduction
An **Eulerian path** (or Eulerian trail) is a trail in a finite graph that visits every edge only once, allowing for revisiting nodes.

An **Eulerian circuit** (or Eulerian cycle) is an Eulerian path that starts and ends on the same node.

Euler proved that the necessary condition for the existance of Eulerian circuits is that all the nodes have an even degree.

**Euler's Theorem** : A connected graph has an Euler cycle if and only if every node has even degree. 

"""

# ╔═╡ fb4aeb8c-20f7-11eb-0444-259de7b76883
md"""

## Properties
- An undirected graph has an Eulerian trail if and only if exactly zero or two vertices have odd degree, and all of its vertices with nonzero degree belong to a single connected component.

- An undirected graph can be decomposed into edge-disjoint cycles if and only if all of its vertices have even degree. So, a graph has an Eulerian cycle if and only if it can be decomposed into edge-disjoint cycles and its nonzero-degree vertices belong to a single connected component.

- A directed graph has an Eulerian cycle if and only if every vertex has equal in degree and out degree, and all of its vertices with nonzero degree belong to a single strongly connected component. 
  
- Equivalently, a directed graph has an Eulerian cycle if and only if it can be decomposed into edge-disjoint directed cycles and all of its vertices with nonzero degree belong to a single strongly connected component.
"""

# ╔═╡ ecf20b6a-5018-11eb-3b6d-6fab71836faa
md"""
## Illustration

Let's start with a list of lists, for each list inside indicates two nodes that have edges between them. For example, node1 has edges with node5, node2, node4 and node3 according to the *adjacent_list* infomation.

"""

# ╔═╡ 025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
adjacent_list = [[1, 5], [1, 2], [1, 4], [1, 3], [5, 2], [2, 3], [2, 4], [3, 4], [3, 6], [4, 6]]

# ╔═╡ 5e98cb66-5017-11eb-28d8-65a7aec77180
md"""
First we need to create a dictionary whose key is each node, and the value returns a list of nodes that have edges to this node.
"""

# ╔═╡ 43f93fc8-5019-11eb-1b59-a1da4675ae81
adj_dict = create_adj_list(adjacent_list)

# ╔═╡ bd8b2422-502e-11eb-32c1-bfb30c1e3db1
md"""
### Visulize nodes and edges
"""

# ╔═╡ 4704748c-502b-11eb-3f96-b97746afd8d1
begin
	g = SimpleWeightedGraph(length(adj_dict))
	for node in keys(adj_dict)
		for node_end in adj_dict[node]
			add_edge!(g, node, node_end, 0.5)
		end
	end
gplot(g, nodelabel=1:length(adj_dict))
end

# ╔═╡ 77a637fe-5019-11eb-3c4b-7962e4e8ac3d
md"""
After convert into dictionary, we can check if this dictionary of nodes has eulerian cycle or not, based on the theory: 

**An undirected graph has an Eulerian cycle if and only if exactly zero or two vertices have odd degree, and all of its vertices with nonzero degree belong to a single connected component.**

So here we check for each key, the length of the value is odd or even. If all of the lengths are even, the nodes has an eulerian cycle.

"""

# ╔═╡ 3c4b4a72-501a-11eb-1de4-aff349f00abc
has_eulerian_cycle(adj_dict)

# ╔═╡ 4916fbfc-501a-11eb-246f-0fc3bf6544cd
md"""
For eulerian path, its condition is different from has\_eulerian\_cycle condition. If there are 0 **or** two nodes have even degree, an eulerian path can be created.

"""

# ╔═╡ bd367d32-501a-11eb-1010-9b8f044407a5
has_eulerian_path(adj_dict)

# ╔═╡ 3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
md"""
## References:
[https://en.wikipedia.org/wiki/Eulerian_path#Applications](https://en.wikipedia.org/wiki/Eulerian_path#Applications)

[https://www.youtube.com/watch?v=8MpoO2zA2l4](https://www.youtube.com/watch?v=8MpoO2zA2l4)

[https://github.com/gaviral/Algorithms/blob/0e2d564ef27411a461800dc10160ba21a0e52336/5_Graphs/eulerian_cycle_path.py](https://github.com/gaviral/Algorithms/blob/0e2d564ef27411a461800dc10160ba21a0e52336/5_Graphs/eulerian_cycle_path.py)

[https://nbviewer.jupyter.org/github/JuliaGraphs/JuliaGraphsTutorials/blob/master/Basics.ipynb](https://nbviewer.jupyter.org/github/JuliaGraphs/JuliaGraphsTutorials/blob/master/Basics.ipynb)
"""

# ╔═╡ Cell order:
# ╟─171fee18-20f6-11eb-37e5-2d04caea8c35
# ╠═d2d007b8-20f8-11eb-0ddd-1181d4565a85
# ╠═54286c74-5015-11eb-214e-352bbdb7e252
# ╠═15e64cfe-5029-11eb-2e66-09f62c94cc65
# ╟─fb4aeb8c-20f7-11eb-0444-259de7b76883
# ╟─ecf20b6a-5018-11eb-3b6d-6fab71836faa
# ╠═025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
# ╟─5e98cb66-5017-11eb-28d8-65a7aec77180
# ╠═43f93fc8-5019-11eb-1b59-a1da4675ae81
# ╟─bd8b2422-502e-11eb-32c1-bfb30c1e3db1
# ╠═4704748c-502b-11eb-3f96-b97746afd8d1
# ╟─77a637fe-5019-11eb-3c4b-7962e4e8ac3d
# ╠═3c4b4a72-501a-11eb-1de4-aff349f00abc
# ╟─4916fbfc-501a-11eb-246f-0fc3bf6544cd
# ╠═bd367d32-501a-11eb-1010-9b8f044407a5
# ╟─3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
