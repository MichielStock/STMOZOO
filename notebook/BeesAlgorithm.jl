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

# ╔═╡ 935e57b0-438f-11eb-0ed4-b3ad455bbd63
using STMOZOO.BeesAlgorithm

# ╔═╡ 0ca837e0-42ef-11eb-17fa-9335cb9a3997
using InteractiveUtils, Plots, PlutoUI

# ╔═╡ 86ed8530-43a5-11eb-2296-1b9ab2c87ea7
using Pkg; Pkg.add("Optim")

# ╔═╡ 91d40c30-43a5-11eb-1805-ef48b11c3a40
using Optim

# ╔═╡ eee523f0-436e-11eb-2e92-d59ed5c533e6
md" 	
# The Artificial Bee Algorithm - Tutorial

## Introduction
The artificial bee algorithm (ABC) is a swarm intelligence metaheuristics algorithm for solving optimization problems. In this tutorial, the module **BeesAlgorithm**, which implements the ABC algorithm for optimization of **continuous functions**, will be demonstrated. Several test functions such as the **Sphere, Ackley, Rosenbrock, Branin** and **Rastrigine** function will be minimized to illustrate the efficacy of the ABC algorithm. Visualizations are provided to show the convergence of the ABC algorithm.

## Concept
##### General
The ABC algorithm is inspired by the **foraging behaviour of honey bees**. Honey bees collect nectar from flower patches as a food source for the colony. Bees are send to explore different flower patches and they communicate the quality of these food sources through waggle dances. Good sites are continually exploited, while bees are sent out in search of additional promising sites.

##### Metaphor

As a methaphor for the foraging behaviour of bees, the ABC algorithm relies on 3 main components:

- **Food sources**, which can be considered as potential solutions of the optimization problem.

- **Employed foragers**. They exploit a food source, return to the colony to share their information with a certain probility, perform a waggle dance and recruit other bees, and then continue to forage at the food source.  

- **Unemployed foragers**. This category consists of 2 types of bees. On the one hand, the **onlooker bees** watch the waggel dances to become a recruit and start searching for a food source. On the other hand, the **scout bees** start searching for interesting flower patches around the nest spontaneously.


The fitness of a solution or food source is inversely related with the value of the objective function in this solution. Thus, a higher fitness corresponds to a lower objective value. In the optimization process, we want to **maximize fitness** and **minimize the objective function** to find the minimizer of a continous function. 



The following phases in the ABC algorithm can be distinguished:

**1) Employed bee phase**\
Employed bees try to identify better food source than the one they were associated previously. A new solution is generated using a partner solution. Thereafter, greedy selection is performed, meaning that a new solution only  will be accepted if it is better than the current solution. Every bee in the swarm will explores one food source. All solutions get an opportunity to generate a new solution in the employed bee phase.

**2) Onlooker bee phase**\
In the onlooker bee phase, a food source is selected for further exploitation with a probability related to the nectar amount, i.e. a solution with higher fitness will have a higher probability to be chosen. Fitter solutions may undergo multiple onlooker bee explorations. As in the employed bee phase, new solutions are generated using a partner solution and greedy selection is performed. In contrast to the employed bee phase, not every food source will be explored, since every onlooker bee will explore a certain food source with a certain probability (depending on nectar amount).

During the 2 phases above, a trial counter is registered for every foos source. Each time a food source fails to generate a solution with higher fitness, the trial counter is elevated by 1 unit.

The solution with highest fitness so far is kept apart in memory during the entire process and updated as better food sources are discovered.

**3) Scout bee phase**\
If the value of the trial counter for a certain solution is greater than fixed limit, then a solution can enter the scout phase. The latter food source is then considered as exhausted and will therefore be abandoned by the bees. After discarding the exhausted solution, a new random solution is generated and the trial counter of this solution is reset to zero.

 
 
"

# ╔═╡ 3c1c9be0-4373-11eb-1b1e-3d3f2e6afb19
md" 	
## Visualization of the ABC algorithm
#### Evolution of bee swarms during optimization 

Type *add https://github.com/kirstvh/STMOZOO.git* in the package manager of the Julia terminal to download the Bees Algorithm module.
"

# ╔═╡ 7a2fdff0-4373-11eb-337a-8fb102ef7b78
md"  **Loading the Bees Algorithm module** "


# ╔═╡ 16e1ad62-439c-11eb-1b3e-577f23587233
md" 
The explanation of the functions in the STMOZOO.BeesAlgorithm module can be retrieved from the documentation page or by using the help function."

# ╔═╡ 02f4f820-439c-11eb-0c6e-7509dfc20674
md"  **Loading the required packages for this tutorial** "

# ╔═╡ a9462a5e-4373-11eb-3b48-39a2596229a9
md" **Choose the test function** you want to minimize with the select button below."

# ╔═╡ 27f302ee-42ea-11eb-2d9e-49dffc0d983d
@bind functie Select(["ackley", "sphere","rosenbrock","branin","rastrigine"])

# ╔═╡ 3235a8d2-42ea-11eb-1fe1-6d91eca83dad
begin
	if functie == "ackley"
		f_optimize = ackley;
	end	
	if functie == "sphere"
		f_optimize = sphere;
	end	
	if functie == "rosenbrock"
		f_optimize = rosenbrock;
	end 	
	if functie == "branin"
		f_optimize = branin;
	end 	
	if functie == "rastrigine"
		f_optimize = rastrigine;
	end 	
end

# ╔═╡ 085c34e0-4374-11eb-1ba7-7fb1af1d38a4
md" Choose the **swarm size S** (even number). \
 "



# ╔═╡ 0388b3ce-4374-11eb-03f4-9b4c74bd5ff0
S = 24

# ╔═╡ 6bd962e0-439c-11eb-0ce9-c348bd45b225
md"  
The **number of decision variables D** (determining the dimension of the optimization problem) is fixed to 2 in this tutorial for  visualization purposes. The **limit** is fixed to a convenient value of D*(S/2). "

# ╔═╡ 350644d0-4375-11eb-2b68-8fb8f4bd7c2a
D = 2

# ╔═╡ c7c64720-437f-11eb-15a2-477ab2fe0792
limit = D * (S/2)

# ╔═╡ caa5b6d0-4373-11eb-0cdd-1961e6698727
md" Appropriate parameters for the chosen test function are defined. Next, the **ABC algorithm executes the searching procedure** for finding the global minimum of the test function."

# ╔═╡ f347e610-42a3-11eb-2116-ef50f1246cf3
begin 

	if functie == "sphere"
		T = 35
		bounds_lower = [-100,-100];  
		bounds_upper = [100,100];
	end
	
	if functie == "ackley"
		T = 50
		bounds_lower = [-30,-30];  
		bounds_upper = [30,30];
	end
	
	if functie == "rosenbrock"
		T = 1000
		bounds_lower = [-100, -100];  
		bounds_upper = [100,100];
	end
	
	if functie == "branin"
		T = 50
		bounds_lower = [-5,0];  
		bounds_upper = [10,15];
	end
	
	if functie == "rastrigine"
		T = 50
		bounds_lower = [-5,-5];  
		bounds_upper = [5,5];	
	end
end

# ╔═╡ 54c02380-42a4-11eb-0240-7b2d895cb337
begin
	optimal_solution,populations, best_fitness_tracker = ArtificialBeeColonization(D, bounds_lower, bounds_upper, S, T, limit, f_optimize)
	optimal_solution 
end

# ╔═╡ 9bb28f50-4374-11eb-2b10-e5effcbc8438
md" Below a **contour plot** and **surface plot** of the test function can be seen. Move the slider to see how the location of bees changes over time during the optimization procedure. "

# ╔═╡ b81d7f30-42a5-11eb-27ce-f1cc849ffdc5
@bind step Slider(1:T; show_value=true)

# ╔═╡ 9e2b4e60-42ee-11eb-0d7f-c1faa8426796
begin
		x = []; y = []; z = []
		for bee in populations[step]
			append!(x,bee[1]); append!(y, bee[2]); append!(z, 0)
		end
	 
	
		if functie == "sphere"
			x2=range(bounds_lower[1],bounds_upper[1], step=1)
			y2=range(bounds_lower[2],bounds_upper[2], step=1)
			f(x2,y2) = (x2^2+y2^2)
		end
	
		if functie == "ackley"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.75)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.75)
		    d = 2
			c=2*3.14
			a=20
			b=0.2
		    f(x2,y2) = -a * exp(-b*sqrt((x2^2+y2^2)/d))-exp((cos(c*x2)+cos(c*y2))/d) + a + exp(1)  
		
		end
		
		if functie == "rosenbrock"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			a=1
			b=5
		    f(x2,y2) = (a-x2)^2 + b*(y2-x2^2)^2
		end	
	
		if functie == "branin"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			a=1 
			b=5.1/(4pi^2)
			c=5/pi
			r=6
			s=10
			t=1/8pi
		    f(x2,y2) = a * (y2 - b * x2^2 + c * x2 - r)^2 + s * (1 - t) * cos(x2) + s
		end	
	
		if functie == "rastrigine"
			x2=range(bounds_lower[1],bounds_upper[1], step=0.5)
			y2=range(bounds_lower[2],bounds_upper[2], step=0.5)
			A=10
			d=2
		    f(x2,y2) = d*A + x2^2-A*cos(2pi*x2) + y2^2-A*cos(2pi*y2)
		end	
end

# ╔═╡ 581a22f0-42af-11eb-1d59-df5f1efa5732
begin

	plot(x2,y2,f,st=:contour,
		label="Objective function",
		xlims=(bounds_lower[1],bounds_upper[1]),
		ylims=(bounds_lower[2],bounds_upper[2]),
		legend=:outerbottom) 
	
	scatter!(x, y,  
		xlabel="x1", 
		ylabel="x2",
		zlabel="x3",
		title="Evolution of populations over time",
		titlefont = font(15),
		c="blue", 
		markershape=  :circle,
		label="Position of bees after iteration "*string(step),
		legend = :outerbottom)
end

# ╔═╡ 71321ef0-42eb-11eb-0635-b1ce95226c75
begin
	plot(x2,y2,f,st=:surface,
		label="Objective function",
		# camera=(-30,30),
		xlims=(bounds_lower[1],bounds_upper[1]),
		ylims=(bounds_lower[2],bounds_upper[2]),
		zlims=zlims,
		legend=:outerbottom) #,c=my_cg) #,camera=(-30,30))
	
	scatter!(x, y, z, 
		xlabel="x1", 
		ylabel="x2",
		# title="Evolution of populations over time",
		# titlefont = font(15),
		c="blue", 
		markershape=  :circle,
		label="Position of bees after iteration "*string(step),
		legend = :outerbottom)
end

# ╔═╡ 65bf09be-4377-11eb-2415-3b8be310a065
md" With the chosen parameters, the **Sphere, Ackley** and **Rastrigine** function have a minimizer at (0,0). 

The **Rosenbrock** function has a minimum value of zero at (0,0) and the **Branin** function has 3 global minima: (-pi, 12.275), (pi, 2.275) and (9.425, 2.475).  " 

# ╔═╡ 4219c780-4381-11eb-2289-316eb02b282f
md" 


#### Evolution of fitness during optimization


Below, for each iteration the **fitness** value for the best food source so far at that iteration is plotted."

# ╔═╡ 076d2e10-4381-11eb-3e12-6f9d9abe7f9a
plot(best_fitness_tracker,label="Fitness",	xlabel="iteration", 
		ylabel="fitness", title="Evolution of fitness", legend=:outerbottom)

# ╔═╡ 749ca5a0-43a5-11eb-3ad6-453463f18aed


# ╔═╡ 4ef00630-43a5-11eb-2095-b3cde3592af9
md"#### Comparison with optim package
Below, the performance of the ABC algorithm is compared with the optim package."

# ╔═╡ df912bb0-43a5-11eb-3bd2-ebc17c073757
starting_solution = float(initialize_population(D, bounds_lower, bounds_upper, S/2)[1])

# ╔═╡ 8f7a52d0-43a7-11eb-3351-eb765609e56e
@time begin optimize(f_optimize, starting_solution) end

# ╔═╡ 0c78a8b0-4379-11eb-20dc-3dd46dc183d3
md" ## References
Karaboga, D., & Basturk, B. (2007). A powerful and efficient algorithm for numerical function optimization: artificial bee colony (ABC) algorithm. Journal of global optimization, 39(3), 459-471.

"

# ╔═╡ Cell order:
# ╟─eee523f0-436e-11eb-2e92-d59ed5c533e6
# ╟─3c1c9be0-4373-11eb-1b1e-3d3f2e6afb19
# ╟─7a2fdff0-4373-11eb-337a-8fb102ef7b78
# ╠═935e57b0-438f-11eb-0ed4-b3ad455bbd63
# ╟─16e1ad62-439c-11eb-1b3e-577f23587233
# ╟─02f4f820-439c-11eb-0c6e-7509dfc20674
# ╠═0ca837e0-42ef-11eb-17fa-9335cb9a3997
# ╟─a9462a5e-4373-11eb-3b48-39a2596229a9
# ╟─27f302ee-42ea-11eb-2d9e-49dffc0d983d
# ╠═3235a8d2-42ea-11eb-1fe1-6d91eca83dad
# ╟─085c34e0-4374-11eb-1ba7-7fb1af1d38a4
# ╠═0388b3ce-4374-11eb-03f4-9b4c74bd5ff0
# ╟─6bd962e0-439c-11eb-0ce9-c348bd45b225
# ╠═350644d0-4375-11eb-2b68-8fb8f4bd7c2a
# ╟─c7c64720-437f-11eb-15a2-477ab2fe0792
# ╟─caa5b6d0-4373-11eb-0cdd-1961e6698727
# ╠═f347e610-42a3-11eb-2116-ef50f1246cf3
# ╠═54c02380-42a4-11eb-0240-7b2d895cb337
# ╟─9bb28f50-4374-11eb-2b10-e5effcbc8438
# ╟─b81d7f30-42a5-11eb-27ce-f1cc849ffdc5
# ╟─9e2b4e60-42ee-11eb-0d7f-c1faa8426796
# ╟─581a22f0-42af-11eb-1d59-df5f1efa5732
# ╟─71321ef0-42eb-11eb-0635-b1ce95226c75
# ╟─65bf09be-4377-11eb-2415-3b8be310a065
# ╟─4219c780-4381-11eb-2289-316eb02b282f
# ╠═076d2e10-4381-11eb-3e12-6f9d9abe7f9a
# ╟─749ca5a0-43a5-11eb-3ad6-453463f18aed
# ╟─4ef00630-43a5-11eb-2095-b3cde3592af9
# ╠═86ed8530-43a5-11eb-2296-1b9ab2c87ea7
# ╠═91d40c30-43a5-11eb-1805-ef48b11c3a40
# ╠═df912bb0-43a5-11eb-3bd2-ebc17c073757
# ╠═8f7a52d0-43a7-11eb-3351-eb765609e56e
# ╟─0c78a8b0-4379-11eb-20dc-3dd46dc183d3
