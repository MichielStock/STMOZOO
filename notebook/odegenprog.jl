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
md"""### Solving ordinary differential equations with genetic programming"""

# ╔═╡ d29547a0-44b5-11eb-01ec-a3804e3564c1
md""" note: first and second order linear differential equations """

# ╔═╡ fe2273d0-4590-11eb-0ad0-857e30bf1fc7
#@tree :(sin((3 + 7) * x))

# ╔═╡ 1496aa80-3cce-11eb-3a7f-635d62b89453
Random.seed!(10)

# ╔═╡ f347a420-44b5-11eb-1865-43ff190e3f3b
#explain something about GP in general, expression tree

# ╔═╡ a9646df0-457a-11eb-07c0-85ae52532bd8
md""" keywords: Genetic Programming, evolutionary algorithm, population-based meta-heuristic, evolving programs"""

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
global S = SymbolTable(grammar)

# ╔═╡ 4ee2da70-416e-11eb-0a44-7dc9ad5f95d4
#general fitness function
#write ODE in standard form f(x,y,y',y'',...) = 0
#specify boundary conditions
#specify interval of existence

# ╔═╡ 517c7490-3b2d-11eb-2470-1f864bb57d95
#limit max depth
population = [rand(RuleNode, grammar, :R, 5) for i in 1:1000]

# ╔═╡ a371e730-497e-11eb-149d-6b088ec6839c
grammar

# ╔═╡ 64b70a20-400a-11eb-1561-b32b24c92788
sort(fitness_basic.(population))

# ╔═╡ 42ac5de0-4c71-11eb-3855-4db90448a8e3
fitness_basic.(population)

# ╔═╡ 69160bc0-4c71-11eb-0962-d99041bfbcaf
population[26]

# ╔═╡ 772d3940-4c71-11eb-35cc-872adaef8954
typeof(population[26])

# ╔═╡ 5b237d40-4c71-11eb-3925-9ff13fe9d330
fitness_basic(population[26])

# ╔═╡ 7f7cc1ae-4c71-11eb-19a5-dfa656a40431
get_executable(population[26], grammar)

# ╔═╡ 8ca83b30-4c67-11eb-39df-cd1c840e847c
parents = select(fitness_basic.(population), 2)

# ╔═╡ 0b708cc0-4c67-11eb-1810-5be9ab23eb05
children = [crossover(0.3, population[p[1]], population[p[2]], 5) for p in parents]

# ╔═╡ 04a27430-4c67-11eb-34fd-0fd565c829ab
populationS = permutate.(children, 0.3)

# ╔═╡ c44ee7a0-4c67-11eb-1cf6-abfa18225908
fittest = population[argmin(fitness_basic.(population))]

# ╔═╡ 3c815230-4c68-11eb-068d-43b594d30e2c
typeof(fittest)

# ╔═╡ d5ba4930-4c67-11eb-1bad-89b269317466
fittest_expr = get_executable(fittest, grammar)

# ╔═╡ dcffb4a0-4c67-11eb-03bd-91f02ea44521
fitness_basic(fittest)

# ╔═╡ 1cc7fbb2-4c68-11eb-07bf-5d9556033910
fitness_test(fittest, grammar)

# ╔═╡ 85a04e50-4a40-11eb-1a8b-7d5e3e9b122c
gp_anim = genetic_program(fitness_basic, population, 50, 2,  0.3, 0.3, 5)

# ╔═╡ b3c146d0-4a41-11eb-0b43-9fea8083390e
gp_anim.expr

# ╔═╡ 40f4e050-4c65-11eb-25a9-07ad6a2c3876
gp_anim.fit_iter

# ╔═╡ c0caadd0-4a41-11eb-1b06-138c65916be3
gp_anim.sol_iter

# ╔═╡ 3f3df2be-4b0b-11eb-3571-dba4fedcbc52
md"""
-Ni $(@bind Ni Slider(25:50, default=50, show_value=true))
"""

# ╔═╡ 61b66940-4b0b-11eb-1e14-311fb485c4d2
begin 
x_i = 0.1:0.001:10.
y_i = exp.(x_i)

plot(x_i,y_i, label = "Analytic solution", color = "black", linewidth = 3)

y_ti = plot_solution(gp_anim.sol_iter[Ni], grammar)
plot!(x_i,y_ti, linestyle =:dash, label = "GP approximation", linewidth = 3)
xlims!((0.,10.))
ylims!((0.,10.))
end

# ╔═╡ 8b5e24d2-4a3f-11eb-2e5b-71f3dae61ca4
begin
	x_a = collect(0.1:0.001:10.)
	#y = sin.(x)
	df = 2
	j = 1

	anim =  @animate for i = 1:df:length(x_a)
		j = 1
		sol_approx = gp_anim.sol_iter[j]
		function plot_solution_1D(x)
			g_1D = define_grammar_1D()
			S_1D = SymbolTable(g_1D)
			res_1D = sol_approx
			S_1D[:x] = x
			return  Core.eval(S_1D,res_1D)
		end	
		y_a = plot_solution_1D(x_a)
	    plot(x_a[1:i], y_a[1:i], legend=false)
		j += 1
	end
	 
	gif(anim, "tutorial_anim_fps30.gif", fps = 30)
end

# ╔═╡ 5046e1a0-414a-11eb-2cfd-c73667f808f7
#limit search space
#fitness function
#integrate code + rewrite
#comments
#extra concepts
#plots/visualisation

# ╔═╡ 6c5d5bf0-4157-11eb-3cf1-87d33b65b6e0
#(1) I sped up the fitness function by adjusting the discretization; (2) reduced the max_depth of the derivation trees searched; (3) reduced the number of evaluations of the fitness function by using smaller population sizes and iterations.

# ╔═╡ 1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
md"""
    fitness_test(tree::RuleNode, grammar::Grammar)
This is a hardcoded fitness function for the differential equation f'(x) - f(x) = 0, 
with boundary condition f(0) = 1. The expected solution is f(x) = exp(x). Inspired by Tsoulos and Lagaris (2006). Returns the fitness 
for a given tree based on a given grammar.

I implemented this function to make it more clear how the fitness for each expression derived from the expression tree is evaluated. 
This is based on evaluating the differential equation over an interval of sensible points. Also penalizes deviation from boundary conditions.
Weighted by factor λ (here set to 100). I tested this for 5 different ODE's in the notebook. Some solutions are exact, others are more
approximations. The problem now it that I have a different fitness function for each differential equation, see also comment below". 

"""

# ╔═╡ 3e717920-44b7-11eb-18a3-bbb77312ad93
fitness_test

# ╔═╡ 3ad61410-3cce-11eb-0e65-ebf59517000e
""" function GeneticProgram(
        pop_size::Int,                          #population size 
        iterations::Int,                        #number of generations 
        max_depth::Int,                         #maximum depth of derivation tree
        p_reproduction::Float64,                #probability of reproduction operator 
        p_crossover::Float64,                   #probability of crossover operator
        p_mutation::Float64;                    #probability of mutation operator) 
"""
g = GeneticProgram(1000,30,5,0.3,0.3,0.4)

# ╔═╡ 07c74990-44c1-11eb-27f0-7b786b4380ae
md""" #### General remark: the solutions change a lot for the more complex ODE's and don't seem to be super reliable yet. I could up the population size to 1000-2000 or increase the number of iterations (50 seems pretty low) butt this makes it more computationally expensive for this notebook."""

# ╔═╡ 408525a0-44b1-11eb-115f-fd737e2887a4
results_test = optimize(g, grammar, :R, fitness_test)

# ╔═╡ 41e10c20-44b1-11eb-0684-e1b9539e2de0
(results_test.expr, results_test.loss)

# ╔═╡ e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
begin 
x_t = 0.1:0.001:10.
y_t = exp.(x_t)
plot(x_t,y_t, label = "Analytic solution", color = "black", linewidth = 3)

y_t2 = plot_solution(results_test.expr, grammar)
plot!(x_t,y_t2, linestyle =:dash, label = "GP approximation", linewidth = 3)
end

# ╔═╡ 3cf8f410-3cce-11eb-277e-f5cf01627feb
results_1 = optimize(g, grammar, :R, fitness_1)

# ╔═╡ 3cf96940-3cce-11eb-3d47-f762c438e963
(results_1.expr, results_1.loss)

# ╔═╡ 37bdd520-44b1-11eb-2927-4f1bd6f21b99
begin 
x_11 = 0.1:0.001:10.
y_11 = sin.(10 .*x_11)
plot(x_11,y_11, label = "Analytic solution", color = "black", linewidth = 3)

y_12 = plot_solution(results_1.expr, grammar)
plot!(x_11,y_12, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 2588f610-4582-11eb-2c24-fb15147640f7
md""" The 2 previous functions should be exact solutions, the following are more difficult test functions that yield viarble results, don't converge very well. This is also the case in paper where the range for iterations was pretty large (up to 1200 generations). Try different population methods. Entropy. Calculate complexity of predicted solution based grammar ?"""

# ╔═╡ 15acf7f0-416d-11eb-0b0c-e9bf40b3994a


# ╔═╡ 5f1bf520-44b1-11eb-3eff-733bb1e93077
begin
	results_2 = optimize(g, grammar, :R, fitness_2)
	(results_2.expr, results_2.loss)
end

# ╔═╡ 3ff752a0-44b3-11eb-10cd-0ffb53fe286a
begin 
x_21 = 0.1:0.001:10.
y_21 = (x_21.+2)./sin.(x_21)
plot(x_21,y_21, label = "Analytic solution", color = "black", linewidth = 3)

y_22 = plot_solution(results_2.expr, grammar)
plot!(x_21,y_22, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 6f70dda0-44b1-11eb-18f2-d76f37ec9519
begin
	results_3 = optimize(g, grammar, :R, fitness_3)
	(results_3.expr, results_3.loss)
end

# ╔═╡ ec5c9fa0-44b3-11eb-038a-232443353943
begin 
x_31 = 0.1:0.001:10.
y_31 = (x_31.+2)./(x_31)
plot(x_31,y_31, label = "Analytic solution", color = "black", linewidth = 3)

y_32 = plot_solution(results_3.expr, grammar)
plot!(x_31,y_32, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 756cd920-44b1-11eb-0ad6-c95c100c57f6
begin
	results_4 = optimize(g, grammar, :R, fitness_4)
	(results_4.expr, results_4.loss)
end

# ╔═╡ 1df79920-44b4-11eb-2ddf-a3f7081a4642
begin 
x_41 = 0.1:0.001:10.
y_41 = 2 .*(x_41).*exp.(3 .*x_41)
plot(x_41,y_41, label = "Analytic solution", color =:black, linewidth = 3)

y_42 = plot_solution(results_4.expr, grammar)
plot!(x_41,y_42, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

# ╔═╡ 451fe6a0-44b5-11eb-3f88-77696c6d234e
function plot_solution_small(ex::Expr, grammar::Grammar)
	#ex = get_executable(tree, grammar)
	sol = Float64[]
	for x = 0.1:0.01:1.
		S[:x] = x
		push!(sol, Core.eval(S,ex))
	end
	return sol
end	

# ╔═╡ 4a896620-44b5-11eb-03b0-d314fce42f9a
begin 
x_41s = 0.1:0.01:1.
y_41s = 2 .*(x_41s).*exp.(3 .*x_41s)
plot(x_41s,y_41s, label = "Analytic solution", color = "black", linewidth = 3)

y_42s = plot_solution_small(results_4.expr, grammar)
plot!(x_41s,y_42s, label = "GP approximation", linestyle =:dash, linewidth = 3)
end

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

# ╔═╡ 404fc740-4581-11eb-0071-dbe0af850d39
begin
	results_2D = optimize(g_2D, grammar_2D, :R2D2, fitness_2D)
	(results_2D.expr, results_2D.loss)
end

# ╔═╡ 0b8fb470-458b-11eb-2f41-cdd2935a94fd
begin
xs = range(0., stop=1., length=100)
ys = range(0., stop=1., length=100)
f(x,y) = sin(x)*cos(y)
s = surface(xs, ys, f, label = "Analytic solution")
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
sa = surface!(xs, ys, fa, label = "GP approximation")
end

# ╔═╡ Cell order:
# ╠═0487a66e-4175-11eb-3839-79ff040436c4
# ╠═d29547a0-44b5-11eb-01ec-a3804e3564c1
# ╠═0f9a6600-48a6-11eb-2b1f-59ab11633adc
# ╠═fe2273d0-4590-11eb-0ad0-857e30bf1fc7
# ╠═1496aa80-3cce-11eb-3a7f-635d62b89453
# ╠═f347a420-44b5-11eb-1865-43ff190e3f3b
# ╠═a9646df0-457a-11eb-07c0-85ae52532bd8
# ╠═9659f610-3b2c-11eb-132c-cfe5fbcbb7c1
# ╠═66366810-3b31-11eb-37b1-132e3837fe02
# ╠═4ee2da70-416e-11eb-0a44-7dc9ad5f95d4
# ╠═517c7490-3b2d-11eb-2470-1f864bb57d95
# ╠═a371e730-497e-11eb-149d-6b088ec6839c
# ╠═64b70a20-400a-11eb-1561-b32b24c92788
# ╠═42ac5de0-4c71-11eb-3855-4db90448a8e3
# ╠═69160bc0-4c71-11eb-0962-d99041bfbcaf
# ╠═772d3940-4c71-11eb-35cc-872adaef8954
# ╠═5b237d40-4c71-11eb-3925-9ff13fe9d330
# ╠═7f7cc1ae-4c71-11eb-19a5-dfa656a40431
# ╠═8ca83b30-4c67-11eb-39df-cd1c840e847c
# ╠═0b708cc0-4c67-11eb-1810-5be9ab23eb05
# ╠═04a27430-4c67-11eb-34fd-0fd565c829ab
# ╠═c44ee7a0-4c67-11eb-1cf6-abfa18225908
# ╠═3c815230-4c68-11eb-068d-43b594d30e2c
# ╠═d5ba4930-4c67-11eb-1bad-89b269317466
# ╠═dcffb4a0-4c67-11eb-03bd-91f02ea44521
# ╠═1cc7fbb2-4c68-11eb-07bf-5d9556033910
# ╠═85a04e50-4a40-11eb-1a8b-7d5e3e9b122c
# ╠═b3c146d0-4a41-11eb-0b43-9fea8083390e
# ╠═40f4e050-4c65-11eb-25a9-07ad6a2c3876
# ╠═c0caadd0-4a41-11eb-1b06-138c65916be3
# ╠═3f3df2be-4b0b-11eb-3571-dba4fedcbc52
# ╠═61b66940-4b0b-11eb-1e14-311fb485c4d2
# ╠═8b5e24d2-4a3f-11eb-2e5b-71f3dae61ca4
# ╠═5046e1a0-414a-11eb-2cfd-c73667f808f7
# ╠═6c5d5bf0-4157-11eb-3cf1-87d33b65b6e0
# ╟─1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
# ╠═3e717920-44b7-11eb-18a3-bbb77312ad93
# ╠═3ad61410-3cce-11eb-0e65-ebf59517000e
# ╠═07c74990-44c1-11eb-27f0-7b786b4380ae
# ╠═408525a0-44b1-11eb-115f-fd737e2887a4
# ╠═41e10c20-44b1-11eb-0684-e1b9539e2de0
# ╠═e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
# ╠═3cf8f410-3cce-11eb-277e-f5cf01627feb
# ╠═3cf96940-3cce-11eb-3d47-f762c438e963
# ╠═37bdd520-44b1-11eb-2927-4f1bd6f21b99
# ╠═2588f610-4582-11eb-2c24-fb15147640f7
# ╠═15acf7f0-416d-11eb-0b0c-e9bf40b3994a
# ╠═5f1bf520-44b1-11eb-3eff-733bb1e93077
# ╠═3ff752a0-44b3-11eb-10cd-0ffb53fe286a
# ╠═6f70dda0-44b1-11eb-18f2-d76f37ec9519
# ╠═ec5c9fa0-44b3-11eb-038a-232443353943
# ╠═756cd920-44b1-11eb-0ad6-c95c100c57f6
# ╠═1df79920-44b4-11eb-2ddf-a3f7081a4642
# ╠═451fe6a0-44b5-11eb-3f88-77696c6d234e
# ╠═4a896620-44b5-11eb-03b0-d314fce42f9a
# ╠═b6c97abe-4580-11eb-02e8-e1dfe421cbd5
# ╠═e5b818f0-4580-11eb-279f-8b6b2b2e0fe6
# ╠═3e615600-4587-11eb-2753-c35e34d5dd2d
# ╠═404fc740-4581-11eb-0071-dbe0af850d39
# ╠═0b8fb470-458b-11eb-2f41-cdd2935a94fd
