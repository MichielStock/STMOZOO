### A Pluto.jl notebook ###
# v0.12.11

using Markdown
using InteractiveUtils

# ╔═╡ 694cf0e0-405a-11eb-08f9-bd9a2e0c6232
using STMOZOO.Cuckoo, Plots

# ╔═╡ d03cf1ca-4059-11eb-3339-99c511eba3c8
md"""# Cuckoo search method"""

# ╔═╡ db128a7a-4085-11eb-08b9-5b5199efecc3
md"""This notebook is meant to show the functioning of the cuckoo search method to solve a minimization problem.
The method is based on the parasitism of some cuckoo species that exploit the resources of other bird species by laying eggs into their nests.

To abstract this concept to a computational method the phenomenon is simplified by three main rules:
* Each cuckoo lays one egg at a time into a randomly chosen nest
* The nests containing the best eggs are carried over (elitist selection) to the next generation
* The number of available host nests is fixed and at each generation the alien cuckoo egg can be discovered with a certain probability. At this point the nest is abandoned and a new nest is generated.

It's important to note that this implementation allows a single egg for each nest, hence the terms nest and egg are used interchangeably.
"""

# ╔═╡ 3c8f220e-4086-11eb-175b-f92b3e3e8253
md"""## Example"""

# ╔═╡ 56c0a760-4086-11eb-1c5f-45828eb40989
md"""To show the functioning of the method we use the Ackley function in its 2-dimensional form which has its global minimum at (0,0)."""

# ╔═╡ be3ef176-4086-11eb-365c-e1747053c12d
begin
	function ackley(x; a=20, b=0.2, c=2π) 
		d = length(x) 
		return -a * exp(-b*sqrt(sum(x.^2)/d)) -exp(sum(cos.(c .* x))/d) 
	end 
	
	ackley(x...; kwargs...) = ackley(x; kwargs...)
end

# ╔═╡ e9040d5a-4087-11eb-03a6-51e941460bc5
md"""This is the landscape of the function: """

# ╔═╡ e0165c02-405a-11eb-296f-05e437e873e3
pobj = heatmap(-10:0.01:10, -10:0.01:10, ackley)

# ╔═╡ 2607802e-4088-11eb-1a50-bbabd9cbeaee
md"""We start by initializing a random population of 15 nests. We specify a lower and an upper limit for each dimension of the problem we want to solve."""

# ╔═╡ 0ae52afc-4089-11eb-0d6f-bd95eef05f1d
md"""This is the initial position of the nests in the landscape:"""

# ╔═╡ 6cfa745e-408c-11eb-345c-29b71c84aa90
begin
	x1lims = (-10, 10)
	x2lims = (-10, 10)
end

# ╔═╡ 279492ea-405b-11eb-2af7-13ec8531169a
begin	 
	population = init_nests(15, x1lims, x2lims)
	
	heatmap(-10:0.01:10, -10:0.01:10, ackley)
	for nest in population 
    	scatter!([nest[1]], [nest[2]], color=:green, label="",
            markersize=3)
	end 
	
	solution_stat = cuckoo!(ackley, population,x1lims,x2lims) 
	scatter!([solution_stat[1][1]],[solution_stat[1][2]], color=:white, 
		     label="Solution", markersize=4)
end

# ╔═╡ fd697cfc-405b-11eb-38c8-91a9ad3ba93a


# ╔═╡ 6ee961fc-407b-11eb-104c-4fd3d89b4790
begin
	xlims1=(-10,10)
	xlims2=(-10,10)
	moving_population = init_nests(15, xlims1, xlims2)  
	anim = @animate for i=1:10
		solution=cuckoo!(ackley,moving_population,x1lims,x2lims, gen=1)
		heatmap(-10:0.01:10, -10:0.01:10, ackley)
		for nest in moving_population
			scatter!([nest[1]], [nest[2]], color=:green, label="",
					markersize=3)
			scatter!([solution[1][1]], [solution[1][2]], color=:white, label="", markersize=4)

		end 

	end 

gif(anim, fps = 1)
end

# ╔═╡ 7bd1e760-4083-11eb-0aeb-3be9872e2779
begin
rastrigine(x; A=10) = length(x) * A + sum(x.^2 .+ A .* cos.(2pi .* x))
rastrigine(x...; A=10) = rastrigine(x; A=A)
end

# ╔═╡ 8d93188e-4083-11eb-0058-2d9434ab0234
rast = heatmap(-20:0.01:20, -20:0.01:20, rastrigine)

# ╔═╡ cf84a048-4083-11eb-1b0d-919c731ce6d3
#cuckoo!(rastrigine, updt_population, (-20,20), (-20,20)) 

# ╔═╡ Cell order:
# ╟─d03cf1ca-4059-11eb-3339-99c511eba3c8
# ╟─db128a7a-4085-11eb-08b9-5b5199efecc3
# ╟─3c8f220e-4086-11eb-175b-f92b3e3e8253
# ╠═694cf0e0-405a-11eb-08f9-bd9a2e0c6232
# ╟─56c0a760-4086-11eb-1c5f-45828eb40989
# ╟─be3ef176-4086-11eb-365c-e1747053c12d
# ╟─e9040d5a-4087-11eb-03a6-51e941460bc5
# ╠═e0165c02-405a-11eb-296f-05e437e873e3
# ╟─2607802e-4088-11eb-1a50-bbabd9cbeaee
# ╟─0ae52afc-4089-11eb-0d6f-bd95eef05f1d
# ╠═6cfa745e-408c-11eb-345c-29b71c84aa90
# ╠═279492ea-405b-11eb-2af7-13ec8531169a
# ╟─fd697cfc-405b-11eb-38c8-91a9ad3ba93a
# ╠═6ee961fc-407b-11eb-104c-4fd3d89b4790
# ╠═7bd1e760-4083-11eb-0aeb-3be9872e2779
# ╠═8d93188e-4083-11eb-0058-2d9434ab0234
# ╠═cf84a048-4083-11eb-1b0d-919c731ce6d3
