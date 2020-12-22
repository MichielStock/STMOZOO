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

To abstract this concept to a computational method the phenomenon is simplified into three main rules:
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
md"""We specify a lower and an upper limit for each dimension of the problem we want to solve."""

# ╔═╡ 6cfa745e-408c-11eb-345c-29b71c84aa90
begin
	x1lims = (-10, 10) #dimension 1
	x2lims = (-10, 10) #dimension 2
end

# ╔═╡ dcd0b396-43af-11eb-1aa9-d3baa5317357
md"""In the following block, it is shown how to run the method and how starting from the initial population (green points) the method reaches the final solution (white point):"""

# ╔═╡ 279492ea-405b-11eb-2af7-13ec8531169a
begin	
	#initialize population
	population = init_nests(15, x1lims, x2lims)
	
	#draw function landscape
	heatmap(-10:0.01:10, -10:0.01:10, ackley)
	
	#plot initial population
	for nest in population 
    	scatter!([nest[1]], [nest[2]], color=:green, label="",
            markersize=3)
	end 
	
	#run method
	solution_stat = cuckoo!(ackley, population,x1lims,x2lims) 
	
	#plot the final solution
	scatter!([solution_stat[1][1]],[solution_stat[1][2]], color=:white, 
		     label="Solution", markersize=4)
end

# ╔═╡ fd697cfc-405b-11eb-38c8-91a9ad3ba93a


# ╔═╡ 34675522-43b0-11eb-3d00-c12b0cf63781
md"""In this animation we see how the solutions are updated at every round of optimization to reach the optimal solution, where the best solution is denoted by the white dot at each iteration."""

# ╔═╡ 6ee961fc-407b-11eb-104c-4fd3d89b4790
begin
	xlims1=(-10,10)
	xlims2=(-10,10)
	
	#initialize population
	moving_population = init_nests(15, xlims1, xlims2)  
	
	#run the method for one generation 15 times to plot 15 population states
	anim = @animate for i=1:15
		solution=cuckoo!(ackley,moving_population,x1lims,x2lims, gen=1)
		
		heatmap(-10:0.01:10, -10:0.01:10, ackley)
		for nest in moving_population
			#population at iteration i
			scatter!([nest[1]], [nest[2]], color=:green, label="",
					markersize=3)
		end
		#best solution at iteration i
		scatter!([solution[1][1]], [solution[1][2]], color=:white, label="", markersize=4)

		

	end 

gif(anim, fps = 1)
end

# ╔═╡ 3559598a-447a-11eb-38cf-ad3f603b7063
md"""We can also take a look at how the fitness improves at each round of iteration:"""

# ╔═╡ 26deebee-446f-11eb-3390-4748fcdf5a36
begin 
	#initialize population
	fitness_population = init_nests(15, xlims1, xlims2)  
	
	fitness=Vector()
	#run the method for one generation 15 times to plot the fitness
	for i=1:15
		solution=cuckoo!(ackley, fitness_population, x1lims, x2lims, gen=1)
		push!(fitness, solution[2])

	end  
	plot([fitness], label="", xlabel="Iteration Number", ylabel="Fitness")
	
end

# ╔═╡ 857d667e-43b0-11eb-02c4-f97345274afd
md"""The method allows to specify some parameters, namely:
* `gen`: number of generation. If the number is too small you may get a suboptimal solution due to the fact that the problem may have not yet converged to its optimal solution. 
* `alpha`: stepsize when transitioning to a new solution. By default it is 1 but can be varied depending on the dimension of the landscape.
* `Pa`: rate of cuckoo's egg discovery. This parameter allows to balance how much the method relies on exploring known solutions (default `Pa`=0.25) as compared to inspecting new solution through Lévy flights
* `lambda`: exponent of the Lévy distribution used to sample stepsizes."""

# ╔═╡ 703cb04e-446e-11eb-2954-ebf4cd33851e
md"""Another element that strongly conditions the  outcome of the method is the population size:"""

# ╔═╡ 238232a4-4470-11eb-36b9-dfd43cc99640
begin
	plot()
	populations = [2,5,10,20] 
	
	for x = 1:length(populations) 
		fitness=Vector()			
		fitness_population = init_nests(populations[x], x1lims, x2lims)  
		#run the method for one generation 15 times to plot the fitness
		for i=1:15
			solution=cuckoo!(ackley, fitness_population, x1lims, x2lims, gen=1)	
			push!(fitness, solution[2])
		end  
		plot!([fitness], label="Population size: $(populations[x])", xlabel="Number of iterations", ylabel="Fitness")
	end
	current()
end

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
# ╠═6cfa745e-408c-11eb-345c-29b71c84aa90
# ╟─dcd0b396-43af-11eb-1aa9-d3baa5317357
# ╠═279492ea-405b-11eb-2af7-13ec8531169a
# ╟─fd697cfc-405b-11eb-38c8-91a9ad3ba93a
# ╟─34675522-43b0-11eb-3d00-c12b0cf63781
# ╠═6ee961fc-407b-11eb-104c-4fd3d89b4790
# ╟─3559598a-447a-11eb-38cf-ad3f603b7063
# ╠═26deebee-446f-11eb-3390-4748fcdf5a36
# ╟─857d667e-43b0-11eb-02c4-f97345274afd
# ╟─703cb04e-446e-11eb-2954-ebf4cd33851e
# ╠═238232a4-4470-11eb-36b9-dfd43cc99640
