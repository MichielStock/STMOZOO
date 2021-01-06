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

# ╔═╡ 0f9a6600-48a6-11eb-2b1f-59ab11633adc
using STMOZOO.ODEGenProg, Plots, PlutoUI

# ╔═╡ 0487a66e-4175-11eb-3839-79ff040436c4
md"""### Genetic programming to solve differential equations"""

# ╔═╡ bc79c4b0-4eeb-11eb-1347-2994621dd40c
md""" This project is an attempt at solving differential equations analytically or approximating the solution by using genetic programming. The inspiration for the general approach and test cases comes mostly from two papers (Burgess, 1999; Tsoulos and Lagaris, 2006)."""

# ╔═╡ d110df2e-4ef5-11eb-18fe-491213fbaacd
md""" Genetic programming is an evolutionary algorithm where genotypes are represented as trees instead of bit strings (as can be the case in classical genetic algorithms). Using trees that allow for a hierarchical structure is an elegant way to respresent for example functions. Representing functions is what we are after when we try to solve differential equations analytically. A general introduction to genetic programming can be found on wikipedia: https://en.wikipedia.org/wiki/Genetic_programming.
"""

# ╔═╡ 77a04130-4ef4-11eb-1b0e-6d8916bf8388
md""" The trees (genotypes) represent expressions that belong to a certain grammar. A grammar specifies the specific constraints (i.e. rules that have to be followed) on the space of possible expressions that we are interested in, i.e. that make sense for the problem at hand. 

The grammar is defined using the very convenient package ExprRules.jl. For first order linear differential equations (with one variable x) it inclused all intigers from 1 to 9, basic functions/operations that can be expected in the solution of and ODE and the variable x. It is as follows:"""

# ╔═╡ 9659f610-3b2c-11eb-132c-cfe5fbcbb7c1
#general grammar used for solving ODE's
global grammar = @grammar begin
	R = |(1:9)
	R = R + R
	R = R - R
	R = R / R
	R = R * R
	R = x ^ R
	R = sin(R)
	R = cos(R)
	R = exp(R)
	R = x
end

# ╔═╡ 66366810-3b31-11eb-37b1-132e3837fe02
S = SymbolTable(grammar)

# ╔═╡ 08fdb830-4efd-11eb-3f3d-d18ec22bf313
md""" Next is a simple example to illuminate the usage of grammars to construct trees. 
This tree represents the function f(x)=x+2. The tree structure should be visible in the REPL."""

# ╔═╡ ee453bb0-4ef9-11eb-148a-514618b54711
tree = (RuleNode(10, [RuleNode(2), RuleNode(18)]))

# ╔═╡ 3fca38a0-4efa-11eb-3b0e-8d2ccafe2772
get_executable(tree, grammar)

# ╔═╡ 15826632-4efa-11eb-3b23-abe491db2b75
print_tree(tree)

# ╔═╡ 59e439a0-505a-11eb-3334-eddf62db2840
md"""It can also be plotted with the GraphRecipes package. Node 10 corresponds to the + operator, here summing 2 (node 2) and x (node 18)."""

# ╔═╡ f8a66d22-5059-11eb-041b-f1e31f7c2418
begin
	#(size=(200, 200))
	plot(TreePlot(tree), method=:tree, fontsize=10, nodeshape=:ellipse)
end

# ╔═╡ be2c55b0-4ef6-11eb-0bb0-b725aa483399
md"""Similar to genetic algorithms, a genetic program starts from a population that is initialized randomly. This population is allowed to evolve over a certain number of generations. Methods like crossover and mutation are applied to create stochastic variation in the population. Subsequently an appropriate fitness function associates each genotype with a numeric fitness value. This individual fitness is used for a selection method that aims at increasing the mean fitness of the population each generation."""

# ╔═╡ 1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
md""" For the concenience of this project, the fitness functions I used are what I would call hardcoded fitness functions, i.e. every differential equation has its own fitness function. It is important to note that differential equations are in standard form: f(x,y,y',y'',...) = 0, that the boundary conditions are specified and that we try to construct a solution on an interval that makes sense (i.e. in the interval of existence where the solution can be defined). As an example is the simple differential equation f'(x) - f(x) = 0, with boundary condition f(0) = 1 on the interval [0:1]. The expected analytic solution is f(x) = exp(x).

To make it more concrete, the steps for the fitness evaluation of the population are the following:
Each expression tree in the population is conceptualized as a solution (i.e. a function) to the differential equation we want to solve. This expression is plugged into the differential equation and is evaluated for N equidistant points in a defined interval. Since the differential equation is in standard form (an given expression that equals to 0) a mean squared error can be calculated for each point and summed to calculate the total fitness. For the example this would give (f'(x) - f(x))^2 for N different values of x. In the same way deviation from the boundary conditions can be penalized. For the example that would give: λ*(f(0) - 1)^2 (boundary conditions are
weighted by factor λ (default = 100) in accordance with Tsoulos and Lagaris (2006). It is thus to be noted that in this case the aim will be to minimize the fitness. 
"""

# ╔═╡ ac7a2a00-505d-11eb-3a07-95b08b1fef2b
md"""Below I show the general outline of the method for the ODE f'(x) - f(x) = 0. I start from a randomly generated population of expression trees."""

# ╔═╡ 517c7490-3b2d-11eb-2470-1f864bb57d95
population = [rand(RuleNode, grammar, :R, 5) for i in 1:1000] #limits max depth to 5

# ╔═╡ ceb98f22-505d-11eb-32b7-fd601b0f8cf9
md""" Subsequently the fitness for each expression tree of this population can be calculated with the fitness function.""" 

# ╔═╡ 42ac5de0-4c71-11eb-3855-4db90448a8e3
fitness_basic.(population)

# ╔═╡ 64b70a20-400a-11eb-1561-b32b24c92788
sort(fitness_basic.(population))

# ╔═╡ 1ce96da0-505e-11eb-0c0b-bfa9f83610e6
begin
	scatter(fitness_basic.(population),label = false, title = "Fitness of starting population")
	xlabel!("genotype")
	ylabel!("fitness")
	ylims!((0.,500.))
end

# ╔═╡ 6ea07710-505e-11eb-2e5b-c587005d5000
md""" Subsequently the population will undergo selection, crossing over and mutation as shown below. I sticked to tournament selection with tournament size `S`, where each
parent is the fittest out of `S` randomly chosen expression trees of the population. I refer to the documentation for the specifics of these functions."""

# ╔═╡ 8ca83b30-4c67-11eb-39df-cd1c840e847c
parents = tournament_selection(fitness_basic.(population), 2)

# ╔═╡ 0b708cc0-4c67-11eb-1810-5be9ab23eb05
children = [crossover(0.3, population[p[1]], population[p[2]], 5) for p in parents]

# ╔═╡ 04a27430-4c67-11eb-34fd-0fd565c829ab
populationP = permutate.(children, 0.3)

# ╔═╡ 79e43510-5065-11eb-16fc-f58c5e10c3e3
populationM = mutate.(children, 0.3)

# ╔═╡ c44ee7a0-4c67-11eb-1cf6-abfa18225908
fittest = populationP[argmin(fitness_basic.(populationP))]

# ╔═╡ d5ba4930-4c67-11eb-1bad-89b269317466
fittest_expr = get_executable(fittest, grammar)

# ╔═╡ dcffb4a0-4c67-11eb-03bd-91f02ea44521
fitness_basic(fittest)

# ╔═╡ 5ef5f700-506c-11eb-3f9c-3fa6eff67552
md""" Previous steps are combined into a single genetic program algorithm. In this case it is run for 50 generations."""

# ╔═╡ 85a04e50-4a40-11eb-1a8b-7d5e3e9b122c
gp_anim = genetic_program(fitness_basic, population, 50, 2,  0.3, 0.3, 5)

# ╔═╡ 40f4e050-4c65-11eb-25a9-07ad6a2c3876
gp_anim.fit_iter

# ╔═╡ c0caadd0-4a41-11eb-1b06-138c65916be3
gp_anim.sol_iter

# ╔═╡ 9d599310-506e-11eb-3327-0954439a6b11
begin
	scatter(gp_anim.pop_fit,label = false, title = "Fitness of population after selection")
	xlabel!("genotype")
	ylabel!("fitness")
	ylims!((0.,500.))
end

# ╔═╡ d67b6110-505e-11eb-1d9d-7f38302c0d44
md""" The fittest solutions of each different generation can be plotted in an interactive way to visually inspect convergence to the exact solution, which in this case is f(x) = exp(x). Comment: This example is a bit silly though if exp(x) is already in the starting population."""

# ╔═╡ 3f3df2be-4b0b-11eb-3571-dba4fedcbc52
md"""
-Ni $(@bind Ni Slider(1:50, default=50, show_value=true))
"""

# ╔═╡ 61b66940-4b0b-11eb-1e14-311fb485c4d2
begin 
x_i = 0.1:0.01:10.
y_i = exp.(x_i)

plot(x_i,y_i, label = "Analytic solution", color = "black", linewidth = 3)

y_ti = plot_solution(reverse(gp_anim.sol_iter)[Ni], grammar, 0.1, 10.)
plot!(x_i,y_ti, linestyle =:dash, label = "GP approximation", linewidth = 3)
xlims!((0.,5.))
ylims!((0.,5.))
end

# ╔═╡ 33b7e230-4f02-11eb-0850-99bb90897832
md""" For simple a ODE like the previous example, the runtime of the manual implementation seems sufficient but for harder problems I switched to the genetic program from the package ExprOptimization.jl with custom fitness functions."""

# ╔═╡ 3ad61410-3cce-11eb-0e65-ebf59517000e
""" function GeneticProgram(
        pop_size::Int,                          #population size 
        iterations::Int,                        #number of generations 
        max_depth::Int,                         #maximum depth of derivation tree
        p_reproduction::Float64,                #probability of reproduction operator 
        p_crossover::Float64,                   #probability of crossover operator
        p_mutation::Float64;                    #probability of mutation operator) 
"""
g = GeneticProgram(1000,50,5,0.3,0.3,0.4)

# ╔═╡ 9c8a99b0-4f02-11eb-2eed-bf59946b8e12
md""" The first ODE I tested here is again f'(x) - f(x) = 0, with boundary condition f(0) = 1 on the interval [0:1]. The expected analytic solution is f(x) = exp(x)."""

# ╔═╡ 408525a0-44b1-11eb-115f-fd737e2887a4
results_0 = optimize(g, grammar, :R, fitness_0) 

# ╔═╡ 41e10c20-44b1-11eb-0684-e1b9539e2de0
(results_0.expr, results_0.loss) 
#results_0.expr shows best solution that was found,
#results_0.loss shows the corresponding fitness value (ideally to be 0).

# ╔═╡ e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
begin 
x_t = 0.1:0.01:10.
y_t = exp.(x_t)
plot(x_t,y_t, label = "Analytic solution", color = "black", linewidth = 3)

y_t2 = plot_solution(results_0.expr, grammar, 0.1, 10.)
plot!(x_t,y_t2, linestyle =:dash, label = "GP approximation", linewidth = 3)
end

# ╔═╡ 4daf91a0-4f03-11eb-050e-0f978842a720
md""" The next ODE I checked is y'' - 100y = 0, with boundary conditions y(0) = 0 and y'(0) = 10 on the interval [0,1]. The expected solution is f(x)= sin(10x)."""

# ╔═╡ 3cf8f410-3cce-11eb-277e-f5cf01627feb
results_1 = optimize(g, grammar, :R, fitness_1)

# ╔═╡ 3cf96940-3cce-11eb-3d47-f762c438e963
(results_1.expr, results_1.loss)

# ╔═╡ 37bdd520-44b1-11eb-2927-4f1bd6f21b99
begin 
x_11 = 0.1:0.01:10.
y_11 = sin.(10 .*x_11)
plot(x_11,y_11, label = "Analytic solution", color = "black", linewidth = 3)

y_12 = plot_solution(results_1.expr, grammar, 0.1, 10.)
plot!(x_11,y_12, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 07c74990-44c1-11eb-27f0-7b786b4380ae
md""" The two previous functions should be exact analytical solutions (well, most of the time). The following approximate solutions change a lot for the more complex ODE's and don't seem to be super reliable so it could be that when you run the notebook the approximations are rather bad. This could be improved by increasing the population size (up to 2000 is used by  Tsoulos and Lagaris (2006) or by increasing the number of iterations (50 is rather on the low side, the average number of generations in  Tsoulos and Lagaris (2006) is about 500) but this makes it too computationally expensive for this notebook."""

# ╔═╡ d27262a0-4f03-11eb-053a-1d2ae1f4bbfe
md""" The following ODE is y' - (1 - ycos(x)) / sin(x) = 0, with boundary condition y(0.1) = 2.1/sin(0.1) on the interval [0,1]. The expected solution is y(x) = (x + 2)/sin(x)."""

# ╔═╡ c63709c0-4ef2-11eb-22dc-2d5b8ff40338
results_2 = optimize(g, grammar, :R, fitness_2)

# ╔═╡ 5f1bf520-44b1-11eb-3eff-733bb1e93077
(results_2.expr, results_2.loss)

# ╔═╡ 3ff752a0-44b3-11eb-10cd-0ffb53fe286a
begin 
x_21 = 0.1:0.01:10.
y_21 = (x_21.+2)./sin.(x_21)
plot(x_21,y_21, label = "Analytic solution", color = "black", linewidth = 3)

y_22 = plot_solution(results_2.expr, grammar, 0.1, 10.)
plot!(x_21,y_22, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 699e5622-4f04-11eb-3588-5d8363a90b10
md""" ODE number four: y' - (2x-y)/x = 0, with boundary condition y(0) = 20.1. The expected solution is y(x) = (x+2)/x on [0.1,1.0]."""

# ╔═╡ d3650fc0-4ef2-11eb-1b0f-a195652faa0c
results_3 = optimize(g, grammar, :R, fitness_3)

# ╔═╡ 6f70dda0-44b1-11eb-18f2-d76f37ec9519
(results_3.expr, results_3.loss)

# ╔═╡ ec5c9fa0-44b3-11eb-038a-232443353943
begin 
x_31 = 0.1:0.01:10.
y_31 = (x_31.+2)./(x_31)
plot(x_31,y_31, label = "Analytic solution", color = "black", linewidth = 3)

y_32 = plot_solution(results_3.expr, grammar, 0.1, 10.)
plot!(x_31,y_32, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 97259c20-4f04-11eb-1a8e-1526cb03ee8b
md""" The last one: y'' - 6y' + 9y = 0, with boundary conditions y(0) = 0 and y'(0) = 2. The expected solution is y(x) = 2x*exp(3x) on [0,1]."""

# ╔═╡ df204be2-4ef2-11eb-3883-858e93736417
results_4 = optimize(g, grammar, :R, fitness_4)

# ╔═╡ 756cd920-44b1-11eb-0ad6-c95c100c57f6
(results_4.expr, results_4.loss)

# ╔═╡ 1df79920-44b4-11eb-2ddf-a3f7081a4642
begin 
x_41 = 0.1:0.01:10.
y_41 = 2 .*(x_41).*exp.(3 .*x_41)
plot(x_41,y_41, label = "Analytic solution", color =:black, linewidth = 3)

y_42 = plot_solution(results_4.expr, grammar, 0.1, 10.)
plot!(x_41,y_42, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 4a896620-44b5-11eb-03b0-d314fce42f9a
begin 
x_41s = 0.1:0.01:1.
y_41s = 2 .*(x_41s).*exp.(3 .*x_41s)
plot(x_41s,y_41s, label = "Analytic solution", color = "black", linewidth = 3)

y_42s = plot_solution(results_4.expr, grammar, 0.1, 1.)
plot!(x_41s,y_42s, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ c153cc0e-4f04-11eb-01d5-21b2dc26612d
md""" This methods works equally well for partial differential equations (in this case with 2 variables x and y). The principles are exactly the same as for the ODE case but the fitness functions are bit more elaborative."""

# ╔═╡ b6c97abe-4580-11eb-02e8-e1dfe421cbd5
#general grammar used for solving ODE's
grammar_2D = @grammar begin
	R2D2 = |(1:9)
	R2D2 = R2D2 + R2D2
	R2D2 = R2D2 - R2D2
	R2D2 = R2D2 / R2D2
	R2D2 = R2D2 * R2D2
	R2D2 = x ^ R2D2
	R2D2 = sin(R2D2)
	R2D2 = cos(R2D2)
	R2D2 = exp(R2D2)
	R2D2 = x
	R2D2 = y 
end

# ╔═╡ e5b818f0-4580-11eb-279f-8b6b2b2e0fe6
S_2D = SymbolTable(grammar_2D)

# ╔═╡ 3e615600-4587-11eb-2753-c35e34d5dd2d
g_2D = GeneticProgram(1000,25,5,0.3,0.3,0.4)

# ╔═╡ 1c1e2320-4f05-11eb-3e87-4f23573bd2c4
md"""Below I test the method on the the differential equation 	▽*▽(ψ(x,y)) - 2ψ(x,y) = 0, with boundary conditions (0, y) = 0, (1, y) = sin(1)cos(y), (x, 0) = sin(x), (x, 1) = sin(x)cos(1). The exact solution is f(x, y) = sin(x)cos(y)."""

# ╔═╡ f31bce30-4ef2-11eb-2d18-43c8990a3555
results_2D = optimize(g_2D, grammar_2D, :R2D2, fitness_2D)

# ╔═╡ 404fc740-4581-11eb-0071-dbe0af850d39
(results_2D.expr, results_2D.loss)

# ╔═╡ 215e21a0-4f05-11eb-2b91-050f91ed3424
md""" The plotted solutions (exact in red and approximation in green) are now surfaces instead of planes. When the found solution is exact the two surfaces perfeclty overlap."""

# ╔═╡ 0b8fb470-458b-11eb-2f41-cdd2935a94fd
begin
xs = range(0., stop=1., length=100)
ys = range(0., stop=1., length=100)
f(x,y) = sin(x)*cos(y)
s = surface(xs, ys, f, label = "Analytic solution", fc=:red, camera=(10,30))
#fa(x,y) = (sin(x) / (cos(3 * cos(y)) + 4))
function plot_solution_2D(x,y)
	g_2D = define_grammar_2D()
	S_2D = SymbolTable(g_2D)
	res_2D = results_2D.expr
	S_2D[:x] = x
	S_2D[:y] = y
	return  Core.eval(S_2D,res_2D)
end	
fa(x,y) = plot_solution_2D(x,y)
sa = surface!(xs, ys, fa, label = "GP approximation", fc=:green)
end

# ╔═╡ 4d18a040-4eec-11eb-31c9-4f2176b40823
md"""### References: 

Burgess, G. (1999). Finding Approximate Analytic Solutions to Differential Equations Using Genetic Programming, Surveillance Systems Division, Electronics and Surveillance Research Laboratory, Department of Defense.

Kochenderfer, M. J., & Wheeler, T. A. (2019). Algorithms for optimization. Mit Press.

Tsoulos, I. G., & Lagaris, I. E. (2006). Solving differential equations with genetic programming. Genetic Programming and Evolvable Machines, 7(1), 33-54."""


# ╔═╡ Cell order:
# ╠═0f9a6600-48a6-11eb-2b1f-59ab11633adc
# ╟─0487a66e-4175-11eb-3839-79ff040436c4
# ╟─bc79c4b0-4eeb-11eb-1347-2994621dd40c
# ╟─d110df2e-4ef5-11eb-18fe-491213fbaacd
# ╟─77a04130-4ef4-11eb-1b0e-6d8916bf8388
# ╟─9659f610-3b2c-11eb-132c-cfe5fbcbb7c1
# ╟─66366810-3b31-11eb-37b1-132e3837fe02
# ╟─08fdb830-4efd-11eb-3f3d-d18ec22bf313
# ╠═ee453bb0-4ef9-11eb-148a-514618b54711
# ╠═3fca38a0-4efa-11eb-3b0e-8d2ccafe2772
# ╠═15826632-4efa-11eb-3b23-abe491db2b75
# ╟─59e439a0-505a-11eb-3334-eddf62db2840
# ╟─f8a66d22-5059-11eb-041b-f1e31f7c2418
# ╟─be2c55b0-4ef6-11eb-0bb0-b725aa483399
# ╟─1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
# ╟─ac7a2a00-505d-11eb-3a07-95b08b1fef2b
# ╠═517c7490-3b2d-11eb-2470-1f864bb57d95
# ╟─ceb98f22-505d-11eb-32b7-fd601b0f8cf9
# ╠═42ac5de0-4c71-11eb-3855-4db90448a8e3
# ╠═64b70a20-400a-11eb-1561-b32b24c92788
# ╟─1ce96da0-505e-11eb-0c0b-bfa9f83610e6
# ╟─6ea07710-505e-11eb-2e5b-c587005d5000
# ╠═8ca83b30-4c67-11eb-39df-cd1c840e847c
# ╠═0b708cc0-4c67-11eb-1810-5be9ab23eb05
# ╠═04a27430-4c67-11eb-34fd-0fd565c829ab
# ╠═79e43510-5065-11eb-16fc-f58c5e10c3e3
# ╠═c44ee7a0-4c67-11eb-1cf6-abfa18225908
# ╠═d5ba4930-4c67-11eb-1bad-89b269317466
# ╠═dcffb4a0-4c67-11eb-03bd-91f02ea44521
# ╟─5ef5f700-506c-11eb-3f9c-3fa6eff67552
# ╠═85a04e50-4a40-11eb-1a8b-7d5e3e9b122c
# ╠═40f4e050-4c65-11eb-25a9-07ad6a2c3876
# ╠═c0caadd0-4a41-11eb-1b06-138c65916be3
# ╠═9d599310-506e-11eb-3327-0954439a6b11
# ╟─d67b6110-505e-11eb-1d9d-7f38302c0d44
# ╠═3f3df2be-4b0b-11eb-3571-dba4fedcbc52
# ╟─61b66940-4b0b-11eb-1e14-311fb485c4d2
# ╟─33b7e230-4f02-11eb-0850-99bb90897832
# ╠═3ad61410-3cce-11eb-0e65-ebf59517000e
# ╟─9c8a99b0-4f02-11eb-2eed-bf59946b8e12
# ╠═408525a0-44b1-11eb-115f-fd737e2887a4
# ╠═41e10c20-44b1-11eb-0684-e1b9539e2de0
# ╟─e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
# ╟─4daf91a0-4f03-11eb-050e-0f978842a720
# ╠═3cf8f410-3cce-11eb-277e-f5cf01627feb
# ╠═3cf96940-3cce-11eb-3d47-f762c438e963
# ╟─37bdd520-44b1-11eb-2927-4f1bd6f21b99
# ╟─07c74990-44c1-11eb-27f0-7b786b4380ae
# ╟─d27262a0-4f03-11eb-053a-1d2ae1f4bbfe
# ╠═c63709c0-4ef2-11eb-22dc-2d5b8ff40338
# ╠═5f1bf520-44b1-11eb-3eff-733bb1e93077
# ╟─3ff752a0-44b3-11eb-10cd-0ffb53fe286a
# ╟─699e5622-4f04-11eb-3588-5d8363a90b10
# ╠═d3650fc0-4ef2-11eb-1b0f-a195652faa0c
# ╠═6f70dda0-44b1-11eb-18f2-d76f37ec9519
# ╟─ec5c9fa0-44b3-11eb-038a-232443353943
# ╟─97259c20-4f04-11eb-1a8e-1526cb03ee8b
# ╠═df204be2-4ef2-11eb-3883-858e93736417
# ╠═756cd920-44b1-11eb-0ad6-c95c100c57f6
# ╟─1df79920-44b4-11eb-2ddf-a3f7081a4642
# ╟─4a896620-44b5-11eb-03b0-d314fce42f9a
# ╟─c153cc0e-4f04-11eb-01d5-21b2dc26612d
# ╟─b6c97abe-4580-11eb-02e8-e1dfe421cbd5
# ╟─e5b818f0-4580-11eb-279f-8b6b2b2e0fe6
# ╟─3e615600-4587-11eb-2753-c35e34d5dd2d
# ╟─1c1e2320-4f05-11eb-3e87-4f23573bd2c4
# ╟─f31bce30-4ef2-11eb-2d18-43c8990a3555
# ╠═404fc740-4581-11eb-0071-dbe0af850d39
# ╟─215e21a0-4f05-11eb-2b91-050f91ed3424
# ╟─0b8fb470-458b-11eb-2f41-cdd2935a94fd
# ╟─4d18a040-4eec-11eb-31c9-4f2176b40823
