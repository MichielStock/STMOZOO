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

The peculiarity of this method is that in the first step, the position of each new nest is chosen randomly from a Lévy distribution, mimicking the Lévy flight which is a fliying pattern observed in some bird species.

It's important to note that this implementation allows a single egg for each nest, hence the terms nest and egg are used interchangeably.

More details about the implementation are found in the documentation of the module `STMOZOO.Cuckoo`.
"""

# ╔═╡ 3c8f220e-4086-11eb-175b-f92b3e3e8253
md"""## A simple example"""

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
	x1lims_ackley = (-10, 10) #dimension 1
	x2lims_ackley= (-10, 10)  #dimension 2
end

# ╔═╡ 680883a2-493f-11eb-0d58-03d0b5b302e2
md"""The function can be run as easily as shown in the next block:"""

# ╔═╡ 7974813e-493f-11eb-34ca-bf62397015eb
begin
	#initialize population
	population = init_nests(15, x1lims_ackley, x2lims_ackley)
	
	#run method
	cuckoo!(ackley, population, x1lims_ackley, x2lims_ackley) 
end

# ╔═╡ f936c1f2-493f-11eb-2e6d-8bc27014712b
md"""### Visualization"""

# ╔═╡ dcd0b396-43af-11eb-1aa9-d3baa5317357
md"""Using the implemented function `plot_solution` it is possible to visualize how by starting from the initial population (green points) the method reaches the final solution (white point):"""

# ╔═╡ 279492ea-405b-11eb-2af7-13ec8531169a
function plot_solution_2D(f, x1lims, x2lims)	
	#initialize population
	population = init_nests(20, x1lims, x2lims)
	
	#draw function landscape
	heatmap(x1lims[1]:0.1:x1lims[2], x2lims[1]:0.1:x2lims[2], f)
	
	
	#plot initial population
	for nest in population 
    	scatter!([nest[1]], [nest[2]], color=:green, label="",
            markersize=3)
	end 
	
	#run method
	solution_stat = cuckoo!(f, population, x1lims, x2lims) 
	
	#plot the final solution
	s1=round(solution_stat[1][1],digits=1)	
	s2=round(solution_stat[1][2],digits=1)
	scatter!([solution_stat[1][1]],[solution_stat[1][2]], color=:white, 
		     label="Solution [$(s1),$(s2)]", markersize=4)
 
end

# ╔═╡ c9c0363e-493e-11eb-25c5-271196c1a76f
plot_solution_2D(ackley, x1lims_ackley, x2lims_ackley)

# ╔═╡ 3559598a-447a-11eb-38cf-ad3f603b7063
md"""We can also take a look at how the fitness improves at each round of optimization:"""

# ╔═╡ fd697cfc-405b-11eb-38c8-91a9ad3ba93a


# ╔═╡ 26deebee-446f-11eb-3390-4748fcdf5a36
begin 
	#initialize population
	fitness_population = init_nests(15, x1lims_ackley, x2lims_ackley)  
	
	fitness=Vector{Float64}(undef, 15)
	#run the method for one generation 15 times to plot the fitness
	for i=1:15
		solution=cuckoo!(ackley, fitness_population, x1lims_ackley, x1lims_ackley, gen=1)
		fitness[i]=solution[2]

	end  
	plot([fitness], label="", xlabel="Iteration Number", ylabel="Fitness")
	
end

# ╔═╡ 6a1c79aa-493d-11eb-09db-a10a40ca8094
md"""### Animation"""

# ╔═╡ 34675522-43b0-11eb-3d00-c12b0cf63781
md"""In this animation we see how the solutions are updated at every round of optimization to reach the optimal solution, where the best solution is denoted by the white dot at each iteration."""

# ╔═╡ 6ee961fc-407b-11eb-104c-4fd3d89b4790
begin 	
	#initialize population
	moving_population = init_nests(15, x1lims_ackley, x2lims_ackley)  
	
	#run the method for one generation 15 times to plot 15 population states
	anim = @animate for i=1:15
		solution=cuckoo!(ackley,moving_population,x1lims_ackley,x2lims_ackley, gen=1)
		
		#plot landscape
		heatmap(x1lims_ackley[1]:0.01:x1lims_ackley[2], 
				x2lims_ackley[1]:0.01:x2lims_ackley[2], 
				ackley)
		
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

# ╔═╡ 43539fba-493d-11eb-0430-fbb7c588cba9
md"""### Parameters and population size"""

# ╔═╡ 857d667e-43b0-11eb-02c4-f97345274afd
md"""The method allows to specify some parameters, namely:
* `gen`: number of generation. If the number is too small you may get a suboptimal solution due to the fact that the problem may have not yet converged to its optimal solution. 
* `alpha`: stepsize when transitioning to a new solution. By default it is 1.0 but can be varied depending on the dimension of the landscape.
* `Pa`: rate of cuckoo's egg discovery. This parameter allows to balance how much the method relies on exploring known solutions (default `Pa`=0.25) as compared to inspecting new solution through Lévy flights.
* `lambda`: exponent of the Lévy distribution used to sample stepsizes."""

# ╔═╡ 703cb04e-446e-11eb-2954-ebf4cd33851e
md"""Yet another element that strongly conditions the outcome of the method is the population size:"""

# ╔═╡ 238232a4-4470-11eb-36b9-dfd43cc99640
begin
	plot()
	populations = [2,5,10,20] 
	
	for x = 1:length(populations) 
		fitness=Vector{Float64}(undef, 15)			
		fitness_population = init_nests(populations[x], x1lims_ackley, x2lims_ackley)  
		#run the method for one generation 15 times to plot the fitness
		for i=1:15
			solution=cuckoo!(ackley, fitness_population, x1lims_ackley, x2lims_ackley, gen=1)	
			fitness[i]= solution[2]
		end  
		plot!([fitness], label="Population size: $(populations[x])", xlabel="Number of iterations", ylabel="Fitness")
	end
	current()
end

# ╔═╡ 9f1bb16c-4941-11eb-2db4-87331f69ca7f
md"""### Using more than 2 dimensions"""

# ╔═╡ 6464ddae-4942-11eb-32ab-c55e665f41c6
md"""The method can take a problem of any dimension, assumed that the accurate number of limits is provided. Here the 3-dimensional ackley function, having as global minimizer (0, 0, 0) is solved: """

# ╔═╡ 24b5909a-4942-11eb-2768-a1586788bff2
begin 
	x1lims_3D = (-10, 10) #dimension 1
	x2lims_3D= (-10, 10)  #dimension 2
 	x3lims_3D= (-10, 10)  #dimension 3
	
	#initialize population
	population_3D = init_nests(15, x1lims_3D, x2lims_3D, x3lims_3D)
	
	#run method
	cuckoo!(ackley, population_3D, x1lims_3D, x2lims_3D, x3lims_3D) 
end

# ╔═╡ 9a9b2b30-493d-11eb-2db1-f39a0782c896
md"""### More complex functions"""

# ╔═╡ cb3d1354-493b-11eb-29af-4d36cb31f4e4
begin
	rosenbrock((x1, x2); a=1, b=5) = (a-x1)^2 + b*(x2-x1^2)^2
    rosenbrock(x1, x2; kwargs...) = rosenbrock((x1, x2); kwargs...)
end

# ╔═╡ 93c7588c-4eb1-11eb-1e5a-a7bedb46fefd
md"""**Rosenbrock function** global minimum: (1,1)"""

# ╔═╡ f1110a4e-493c-11eb-234d-ddc38917505c
begin
	x1lims_rastrigine = (-2.048, 2.048) #dimension 1
	x2lims_rastrigine= (-2.048, 2.048)  #dimension 2
	plot_solution_2D(rosenbrock, x1lims_rastrigine, x2lims_rastrigine)
end

# ╔═╡ a946be48-4eaf-11eb-1e20-a152a2278921
begin
	function branin((x1, x2); a=1, b=5.1/(4pi^2), c=5/pi, r=6, s=10, t=1/8pi)
    	return a * (x2 - b * x1^2 + c * x1 - r)^2 + s * (1 - t) * cos(x1) + s
	end

	branin(x1, x2; kwargs...) = branin((x1, x2); kwargs...)
end

# ╔═╡ 362f0eae-4eb1-11eb-26a2-15c63cfa9cf0
md""" **Branin function** global minima: 
* (-3.14, 12.275)
* (3.14, 2.275)
* (9.42,2.475)"""

# ╔═╡ b64b72c2-4eb0-11eb-2434-1b0824d7fa17
begin
	x1lims_branin = (-5, 10) #dimension 1
	x2lims_branin= (0, 15)  #dimension 2
	plot_solution_2D(branin, x1lims_branin, x2lims_branin)
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
# ╟─680883a2-493f-11eb-0d58-03d0b5b302e2
# ╠═7974813e-493f-11eb-34ca-bf62397015eb
# ╟─f936c1f2-493f-11eb-2e6d-8bc27014712b
# ╟─dcd0b396-43af-11eb-1aa9-d3baa5317357
# ╠═c9c0363e-493e-11eb-25c5-271196c1a76f
# ╟─279492ea-405b-11eb-2af7-13ec8531169a
# ╟─3559598a-447a-11eb-38cf-ad3f603b7063
# ╟─fd697cfc-405b-11eb-38c8-91a9ad3ba93a
# ╟─26deebee-446f-11eb-3390-4748fcdf5a36
# ╟─6a1c79aa-493d-11eb-09db-a10a40ca8094
# ╟─34675522-43b0-11eb-3d00-c12b0cf63781
# ╟─6ee961fc-407b-11eb-104c-4fd3d89b4790
# ╟─43539fba-493d-11eb-0430-fbb7c588cba9
# ╟─857d667e-43b0-11eb-02c4-f97345274afd
# ╟─703cb04e-446e-11eb-2954-ebf4cd33851e
# ╟─238232a4-4470-11eb-36b9-dfd43cc99640
# ╟─9f1bb16c-4941-11eb-2db4-87331f69ca7f
# ╟─6464ddae-4942-11eb-32ab-c55e665f41c6
# ╠═24b5909a-4942-11eb-2768-a1586788bff2
# ╟─9a9b2b30-493d-11eb-2db1-f39a0782c896
# ╟─cb3d1354-493b-11eb-29af-4d36cb31f4e4
# ╟─93c7588c-4eb1-11eb-1e5a-a7bedb46fefd
# ╟─f1110a4e-493c-11eb-234d-ddc38917505c
# ╟─a946be48-4eaf-11eb-1e20-a152a2278921
# ╟─362f0eae-4eb1-11eb-26a2-15c63cfa9cf0
# ╠═b64b72c2-4eb0-11eb-2434-1b0824d7fa17
