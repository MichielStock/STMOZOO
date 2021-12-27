### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ c0cc29a4-66cf-11ec-251f-d7772ca48f43
md"""
# Final Project:

## Color transfer using optimal transportation done right

Student name: Ju Hyung Lee
"""

# ╔═╡ 03ad0574-699b-4046-863e-611e1a058d82
md"""
##

In chapter 6, we learned the concept of **optimal transportation**, and saw that **color transfer** is one of its application.

In the course, we saw an example of exchanging the color scheme between two images.
"""

# ╔═╡ 22a77c67-a0ed-434a-9db4-993cdce0c93b
function sinkhorn(C, a, b; λ=1.0, ε=1e-8)
	n, m = size(C)    
	@assert n == length(a) && m == length(b) throw(DimensionMismatch("a and b do not match"))    
	@assert sum(a) ≈ sum(b) "a and b don't have equal sums"    
	u, v = copy(a), copy(b)    
	M = exp.(-λ .* (C .- maximum(C)))  # substract max for stability    
	
	# normalize this matrix    
	while maximum(abs.(a .- Diagonal(u) * (M * v))) > ε
        u .= a ./ (M * v)        
		v .= b ./ (M' * u)      
	end    
	return Diagonal(u) * M * Diagonal(v)  
end

# ╔═╡ Cell order:
# ╟─c0cc29a4-66cf-11ec-251f-d7772ca48f43
# ╟─03ad0574-699b-4046-863e-611e1a058d82
# ╠═22a77c67-a0ed-434a-9db4-993cdce0c93b
