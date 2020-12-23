### A Pluto.jl notebook ###
# v0.12.4

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
#Loading needed packages:
using Plots, GraphPlot, STMOZOO.MaximumFlow, LightGraphs, PlutoUI

# ╔═╡ 814488a0-3d37-11eb-3dc9-a97e67207e93
md"""
# Maximum Flow Problems

**Exam project for the course Selected Topics on Mathematical Optimization**

Project by: Douwe De Vestele"""


# ╔═╡ 2dbacf30-4162-11eb-1dad-fb187c4f8ede
md"""
## Introduction

A maximum flow problem is a widely known example of an optimization problem. The goal is to find the maximum possible flow rate in a network where the connections between the nodes have a limited capacity. It is a very recognizable situation, for instance a railway or highway network that leads trains or cars to connecting cities, or channels transporting water to linked reservoirs. In fact, the problem was first formulated by Harris and Ross in the context of the military evaluation of a railway network capacity and the effectiveness of taking out one or more rail lines in order to stop hostile transports. [^1]
It is clear that such a recognizable and applicable problem is studied thoroughly and multiple solution methods, algorithms and applications have been developed.
In this notebook one of the first solving methods, the Ford-Fulkerson method, is studied, implemented and executed on some toy examples.


"""

# ╔═╡ 0a8c4af0-4169-11eb-2d4d-6d8a9f515b94
md"""
## Ford-Fulkerson method

### Method

The Ford-Fulkerson method is the first method that was posed to solve this kind of problems and is rather intuitive [^2]. 

### Implementation

#### Pseudocode


### Examples
In this notebook, three simple toy examples are provided to illustrate the maximum flow problem. Select a box (one at a time) to explore one of the networks. They are ordered in increasing complexity.

* Simple example with 4 nodes:  $(@bind a CheckBox())
* Distribution of cyclist fans on trains to Oudenaarde:  $(@bind b CheckBox())
* Example c : $(@bind c CheckBox()) 
"""

# ╔═╡ 609aeeb0-4169-11eb-2f61-a984c918f598
begin
	mf_a = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0]; # case
	mf_b = [0 7 0 3 0; 0 0 2 0 2; 0 0 0 0 4; 0 0 1 0 2; 0 0 0 0 0]; # case
	mf_c = [0 4 4 4 4 4 0 0 0 0; 0 0 0 0 0 0 7 0 0 5; 0 0 0 3 0 0 2 1 0 0;
			0 0 0 0 0 3 1 5 3 2];
	a && (example = mf_a);
	b && (example = mf_b);
	c && (example = mf_c);
end;

# ╔═╡ 385ec1c0-41cc-11eb-1bb3-2f8ea2511e2d
#example 
if a	 
	 md""" This simple example illustrates that..."""
elseif b
	md""" This is an example of a train scheduling problem..."""
else
	md""" Select an example to discover the practical implementation and application of the maximum flow problem!"""
end

# ╔═╡ 90a799a0-3d90-11eb-25a0-1ff2f43d01ba
begin
	g = SimpleDiGraph(example) # package lightgraphs
	e_labs = cap(example)
	gplot(g,nodelabel = 1:size(example,1), edgelabel = e_labs, nodefillc = "lightblue") #graphplot package
end

# ╔═╡ d3875bb0-44a8-11eb-1a3d-091bf735bd92
md""" Solution:"""

# ╔═╡ db1bd180-44a8-11eb-3fb7-0927767945c5
begin
	flow, mflow = augmenting_path(example,1,size(example,1))
	e_labs_sol = cap(example,flow)
	gplot(g,nodelabel = 1:size(example,1), edgelabel = e_labs_sol, nodefillc = "lightblue")
end

# ╔═╡ 99cbf8ae-44ab-11eb-3734-35cea9fbe881
md"""
The maximum flow is $mflow.
"""

# ╔═╡ 37063510-4168-11eb-0501-53062fc78345
md"""
## References

[^1]: T.E. Harris and F.S. Ross,  *Fundamentals of a method for evaluating rail net capacities*. Santa Monica, CA: RAND Corp, 1955.

[^2]: R.K. Ahuja, T.L. Magnanti and J.B. Orlin, *Network flows. Theory, Algorithms, and Applications*. Prentice Hall, Englewood Cliffs, NJ, 1993.

[^newalgorithm]: R.K. Ahuja, T.L. Magnanti, J.B. Orlin and M.R. Reddy, *Applications of network optimization*. Elsevier, 1995.
"""

# ╔═╡ Cell order:
# ╟─814488a0-3d37-11eb-3dc9-a97e67207e93
# ╠═91553c30-3d37-11eb-2a33-2d6d4ee5e9b2
# ╟─2dbacf30-4162-11eb-1dad-fb187c4f8ede
# ╟─0a8c4af0-4169-11eb-2d4d-6d8a9f515b94
# ╟─609aeeb0-4169-11eb-2f61-a984c918f598
# ╟─385ec1c0-41cc-11eb-1bb3-2f8ea2511e2d
# ╟─90a799a0-3d90-11eb-25a0-1ff2f43d01ba
# ╟─d3875bb0-44a8-11eb-1a3d-091bf735bd92
# ╟─db1bd180-44a8-11eb-3fb7-0927767945c5
# ╟─99cbf8ae-44ab-11eb-3734-35cea9fbe881
# ╟─37063510-4168-11eb-0501-53062fc78345
