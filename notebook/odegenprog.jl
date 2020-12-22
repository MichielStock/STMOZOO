### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 66a50de0-39bc-11eb-1073-ef22db3f78c6
using ExprRules, ExprOptimization, Random, Plots, Calculus

# ╔═╡ a5aedb10-3b29-11eb-2863-a57194a31502
md"""https://nbviewer.jupyter.org/github/sisl/ExprRules.jl/blob/master/examples/grammar.ipynb"""

# ╔═╡ 0487a66e-4175-11eb-3839-79ff040436c4
"""first and second order linear ODE's"""

# ╔═╡ 5046e1a0-414a-11eb-2cfd-c73667f808f7
#limit search space
#fitness function
#integrate code + rewrite
#comments
#extra concepts
#plots/visualisation

# ╔═╡ 6c5d5bf0-4157-11eb-3cf1-87d33b65b6e0
#(1) I sped up the fitness function by adjusting the discretization; (2) reduced the max_depth of the derivation trees searched; (3) reduced the number of evaluations of the fitness function by using smaller population sizes and iterations.

# ╔═╡ c147efd0-447d-11eb-21cc-29c63b9a9fa3
#AbstractTrees, Zygote, SymEngine, ForwardDiff

# ╔═╡ c0d86520-447d-11eb-234d-9f35a685a286


# ╔═╡ f22bee90-3b2b-11eb-3838-557bd4a26f73
abstract type CrossoverMethod
end

# ╔═╡ c30f4612-3b2c-11eb-3596-53810b140434
abstract type MutationMethod
end

# ╔═╡ 5bab0820-3b2b-11eb-19cc-73e1b2e558ab
struct TreeCrossover <: CrossoverMethod
	grammar
	max_depth
end

# ╔═╡ ec1dcaa2-3b2b-11eb-04be-8b96a6c86464
function crossover(C::TreeCrossover, a, b)
	child = deepcopy(a)
	crosspoint = sample(b)
	typ = return_type(C.grammar, crosspoint.ind)
	d_subtree = depth(crosspoint)
	d_max = C.max_depth + 1 - d_subtree
	if d_max > 0 && contains_returntype(child,C.grammar,typ,d_max)
		loc = sample(NodeLoc, child, typ, C.grammar, d_max)
		insert!(child, loc, deepcopy(crosspoint))
	end
	return child
end

# ╔═╡ 0fc39d90-3b2c-11eb-1771-29dc28d9d3fb
struct TreeMutation <: MutationMethod
	grammar
	p
end

# ╔═╡ 26839710-3b2c-11eb-0ec6-61ffe3a4b321
function mutate(M::TreeMutation, a)
	child = deepcopy(a)
	if rand() < M.p
		loc = sample(NodeLoc, child)
		typ = return_type(M.grammar, get(child, loc).ind)
		subtree = rand(RuleNode, M.grammar, typ)
		insert!(child, loc, subtree)
	end
	return child
end

# ╔═╡ feee9400-43fc-11eb-2b7b-e52187e9636f
"""
    mutation(a::RuleNode, grammar::Grammar, dmap::AbstractVector{Int}, max_depth::Int=5)
Mutation genetic operator.  Pick a random node from 'a', then replace the subtree with a random one.
"""
function mutation(a::RuleNode, grammar::Grammar, dmap::AbstractVector{Int}, max_depth::Int=5)
    child = deepcopy(a)
    loc = sample(NodeLoc, child)
    mutatepoint = get(child, loc) 
    typ = return_type(grammar, mutatepoint.ind)
    d_node = node_depth(child, mutatepoint)
    d_max = max_depth + 1 - d_node
    if d_max > 0
        subtree = rand(RuleNode, grammar, typ, dmap, d_max)
        insert!(child, loc, subtree)
    end
    child
end

# ╔═╡ 48190092-3b2c-11eb-1bec-fd94323c361b
struct TreePermutation <: MutationMethod
	grammar
	p
end

# ╔═╡ 43642b10-3b2c-11eb-0d93-5d2313bc3926
function mutate(M::TreePermutation, a)
	child = deepcopy(a)
	if rand() < M.p
		node = sample(child)
		n = length(node.children)
		types = child_types(M.grammar, node)
		for i in 1 : n-1
			c = 1
			for k in i+1 : n
				if types[k] == types[i] &&
				rand() < 1/(c+=1)
				node.children[i], node.children[k] =
				node.children[k], node.children[i]
				end
			end
		end
	end
	return child
end

# ╔═╡ 858f9a02-3b2d-11eb-0b56-d984fbca64f0
abstract type SelectionMethod 
end

# ╔═╡ 9901c812-3b2d-11eb-24c3-2bd6973fcec6
begin
struct TournamentSelection <: SelectionMethod
k
end
	
function select(t::TournamentSelection, y)
	getparent() = begin
	p = randperm(length(y))
	p[argmin(y[p[1:t.k]])]
	end
	return [[getparent(), getparent()] for i in y]
end
end

# ╔═╡ 1e597b80-3b2d-11eb-0ea8-c1a0ace9e067
function genetic_algorithm(f, population, k_max, S, C, M)
	for k in 1 : k_max
		parents = select(S, f.(population))
		children = [crossover(C,population[p[1]],population[p[2]])
		for p in parents]
		population .= mutate.(Ref(M), children)
	end
	population[argmin(f.(population))]
end

# ╔═╡ 3ea34f00-400b-11eb-0df7-5bc2916a138d
base_function(x) = exp(x)

# ╔═╡ 3de69490-4151-11eb-3160-45e7563741a5
begin 
x_b = 1:0.1:10; 
y_b = foo_best.(x_b);
plot(x_b,y_b)
y_b2 = (exp.(x_b));
plot!(x_b,y_b2)
end

# ╔═╡ 010bb480-3b32-11eb-2dbc-67c877f904e9


# ╔═╡ 2e759c80-3e69-11eb-2833-7595a8f766c3


# ╔═╡ 0de5b4c0-3e6c-11eb-30a8-413735ce9a36


# ╔═╡ b752ce50-3f46-11eb-2027-d73e4b605122


# ╔═╡ 8d1bda80-4164-11eb-0351-4513d94fb8ab


# ╔═╡ 86279fde-3f41-11eb-2e36-095d5a56d73a
	#macro expr2fn(expr, arg)
    #return :($arg -> $(expr))
	#end

	#expr2 = :(f = @expr2fn $sol x)
	#:(f = @expr2fn(sin(x) + cos(x), x))
	
	#eval(expr2)
	#f(1.0)
	


# ╔═╡ 9659f610-3b2c-11eb-132c-cfe5fbcbb7c1
grammar = @grammar begin
	R = |(1:9)
	R = R + R
	R = R - R
	R = R / R
	R = R * R
	R = x ^ R
	R = sin(R)
	R = cos(R)
	R = exp(R)
	R = log(R)
	R = x
	#R = y
	#R = z
	
end

# ╔═╡ 0b262180-43fc-11eb-3042-d3f83630d086
"""mindepth_map(grammar::Grammar)
Returns the minimum depth achievable for each production rule, dmap."""
dmap = mindepth_map(grammar)

# ╔═╡ e680c290-3b2c-11eb-3412-fb0830edf1b9
function f(node)
	value = 
	try Core.eval(node, grammar)
	catch 
		return Inf
	end
		
	if isinf(value) || isnan(value)
		return Inf
	end
	
	Δ = abs(value - π)
	return log(Δ) + length(node)/1e3
end

# ╔═╡ 66366810-3b31-11eb-37b1-132e3837fe02
S = SymbolTable(grammar)

# ╔═╡ 1b260a40-3e6c-11eb-18a2-9f0e0166163f
S

# ╔═╡ 517c7490-3b2d-11eb-2470-1f864bb57d95
#limit max depth
population = [rand(RuleNode, grammar, :R, 5) for i in 1:500]

# ╔═╡ 44ec8ab0-400c-11eb-0ab4-2b8c33ad568d
sort(f.(population))

# ╔═╡ 29fa7690-43f9-11eb-0627-fb7ca7d07ad2
"hardcoded fitness function for y''=100y, y(0)=0, y(0)=10 -> y(x)=sin(10x)"
function fizzywop_1(tree::RuleNode)
    ex = get_executable(tree, grammar)
    los = 0.0
	
	#domain
    for x = 0.0:0.1:1.0
		S[:x] = x
		#los += try (abs(Core.eval(S,differentiate(ex)) - Core.eval(S,ex)))^2
		los += try ((Core.eval(S,differentiate(differentiate(ex))) + 100*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	#boundary conditions
	S[:x] = 0
	λ = 100.
	los += try λ*((((Core.eval(S,ex)-0))^2) + (((Core.eval(S,differentiate(ex))-10))^2)) 
	catch
		return Inf
	end
	#los += try ((Core.eval(S,differentiate(ex))-10))^2
	#catch
		#return Inf
	#end
	
	return los
end

# ╔═╡ d503e4a0-3cc8-11eb-33f2-2bfdef902159
ground_truth(x) = sin(10*x)

# ╔═╡ d8c35da0-3cc8-11eb-0a0d-1b0cef840d03
function loss(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
    for x = -5.0:1.0:5.0
        S[:x] = x
        los += try abs2(Core.eval(S,ex) - ground_truth(x))
		catch
			return Inf
		end
    end
    los
end

# ╔═╡ 2828cd90-3cd7-11eb-0815-658096d0dff0
"hardcoded fitness function for y''=100y, y(0)=0, y(0)=10 -> y(x)=sin(10x)"
function fizzywop_1(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
	
	#domain
    for x = 0.0:0.1:1.0
		S[:x] = x
		#los += try (abs(Core.eval(S,differentiate(ex)) - Core.eval(S,ex)))^2
		los += try ((Core.eval(S,differentiate(differentiate(ex))) + 100*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	#boundary conditions
	S[:x] = 0
	λ = 100.
	los += try λ*((((Core.eval(S,ex)-0))^2) + (((Core.eval(S,differentiate(ex))-10))^2)) 
	catch
		return Inf
	end
	#los += try ((Core.eval(S,differentiate(ex))-10))^2
	#catch
		#return Inf
	#end
	
	return los
end

# ╔═╡ 64b70a20-400a-11eb-1561-b32b24c92788
sort(fizzywop_1.(population))

# ╔═╡ 517cc2b2-3b2d-11eb-2fd1-c57f0f601edf
best_tree = genetic_algorithm(fizzywop_1, population, 50, TournamentSelection(2), TreeCrossover(grammar, 5), TreeMutation(grammar, 0.40))

# ╔═╡ 8b892f10-3b2e-11eb-098b-ef308cb61752
print_tree(best_tree)

# ╔═╡ ea5bb580-4150-11eb-0606-7710bf0c4c06
ex_best = get_executable(best_tree, grammar)

# ╔═╡ 8ab5f380-4163-11eb-3ac6-f55b0a5ae1f3
(deparse(ex_best))

# ╔═╡ a41a3200-4163-11eb-2948-b3e4854c7041
differentiate(ex_best)

# ╔═╡ e9508790-3b30-11eb-1720-111d5f7761b2
value = Core.eval(best_tree, grammar)

# ╔═╡ d5151bf0-4158-11eb-266b-bb6b7966134a
fizzywop_1(best_tree)

# ╔═╡ 4ee2da70-416e-11eb-0a44-7dc9ad5f95d4
#write ODE in standard form f(x,y,y',y'',...) = 0
#specify boundary conditions
#specify interval of existence

# ╔═╡ 15acf7f0-416d-11eb-0b0c-e9bf40b3994a
"hardcoded fitness function for y'=(1-y*cos(x))/sin(x), y(0.1)=2.1/sin(0.1)-> y(x)=(x+2)/sin(x)"
function fizzywop_2(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
	
	#domain
    for x = 0.1:0.1:1.0
		S[:x] = x
		los += try (abs(Core.eval(S,differentiate(ex)) - ((1-(Core.eval(S,ex)*cos(x)))/sin(x))))^2
		catch
			return Inf
		end
    end
	
	#boundary conditions
	S[:x] = 0.1
	los += try (abs(Core.eval(S,ex)-(2.1/sin(0.1))))^4 
	catch
		return Inf
	end
		
	return los
end

# ╔═╡ 34823660-4175-11eb-2555-23ae963b2331
"hardcoded fitness function for y'=(2x-y)/x, y(0)=20.1-> y(x)=x+2/x"
function fizzywop_3(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
	
	#domain
    for x = 0.1:0.1:1.0
		S[:x] = x
		los += try (abs(x*Core.eval(S,differentiate(ex)) - 2*x + Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	#boundary conditions
	S[:x] = 0.
	los += try (abs(Core.eval(S,ex)-20.1))^2 
	catch
		return Inf
	end
		
	return los
end

# ╔═╡ a33d4f70-4177-11eb-24e4-2b5bce116674
"hardcoded fitness function for y''-6y'+9y=0"
function fizzywop_4(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
	
	#domain
    for x = 0.:0.1:1.0
		S[:x] = x
		los += try (abs(Core.eval(S,differentiate(differentiate(ex))) - 6*(Core.eval(S,differentiate(ex))) + 9*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	#boundary conditions
	S[:x] = 0.
	los += try (abs(Core.eval(S,ex)-0))^2 
	catch
		return Inf
	end
	los += try (abs(Core.eval(S,differentiate(ex))-2))^2 
	catch
		return Inf
	end
		
	return los
end

# ╔═╡ e780dae0-4176-11eb-3000-312401960d08
function ODEinit(ODE,boundary,interval)
end
	

# ╔═╡ 8e3cf55e-4179-11eb-26a1-138d1c0e9ffc
function fizzywop_g(tree::RuleNode, grammar::Grammar)
end

# ╔═╡ 1496aa80-3cce-11eb-3a7f-635d62b89453
Random.seed!(10)

# ╔═╡ 00b7a320-3cc9-11eb-1976-c78d4e1a2f44
p = MonteCarlo(10000, 2)

# ╔═╡ 3ad61410-3cce-11eb-0e65-ebf59517000e
g = GeneticProgram(250,50,5,0.3,0.3,0.4)

# ╔═╡ e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
begin 
x_ = 1:0.1:10
y_ = sin.(10 .*x_)
plot(x_,y_)
y_2 = (2 ./x_)
plot!(x_,y_2)
y_3 = sin.(9 .*x_)
plot!(x_,y_3)
end

# ╔═╡ 1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
function fizzywop_t(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    score = 0.0
	#domain
    for x = 0.0:0.1:1.0
		S[:x] = x
		score += try (abs(Core.eval(S,differentiate(ex)) - Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	#boundary conditions
	S[:x] = 0
	λ = 100.
	score += try λ*(((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return score
end

# ╔═╡ 4939a620-3cc9-11eb-1814-d1576a0e8571
results_mc = optimize(p, grammar, :R, fizzywop_t)

# ╔═╡ 4939f440-3cc9-11eb-3c45-237d6d1ec7d7
(results_mc.expr, results_mc.loss)

# ╔═╡ 3cf8f410-3cce-11eb-277e-f5cf01627feb
results_gp = optimize(g, grammar, :R, fizzywop_t)

# ╔═╡ b26d6b90-3cd8-11eb-2286-c1bcdb62ae58
sol = results_gp.expr

# ╔═╡ e3e02b50-3f43-11eb-1cee-3534cbc03bef
sol.args

# ╔═╡ 2402a050-3f44-11eb-107e-091d71973035
sol.head

# ╔═╡ ea73c640-3e6f-11eb-0424-9d2f7cd0f049
sol.args[1:end]

# ╔═╡ fb59bb5e-3f44-11eb-1b44-ed41a1411728
(sol.args[1])

# ╔═╡ fdf81cc0-3e6f-11eb-1c74-490ff3d5852c
typeof(sol)

# ╔═╡ 75036940-3e6c-11eb-2cd3-d50b0670c3da
Core.eval(S,sol)

# ╔═╡ df76cbd0-3f45-11eb-1d01-3ba63724d1fa
t(x) = sol

# ╔═╡ 3cf96940-3cce-11eb-3d47-f762c438e963
(results_gp.expr, results_gp.loss)

# ╔═╡ 05dcaede-4485-11eb-3a3c-4f6a45a54b24
results_gp.expr == :(log(1))

# ╔═╡ Cell order:
# ╠═a5aedb10-3b29-11eb-2863-a57194a31502
# ╠═0487a66e-4175-11eb-3839-79ff040436c4
# ╠═5046e1a0-414a-11eb-2cfd-c73667f808f7
# ╠═6c5d5bf0-4157-11eb-3cf1-87d33b65b6e0
# ╠═66a50de0-39bc-11eb-1073-ef22db3f78c6
# ╠═c147efd0-447d-11eb-21cc-29c63b9a9fa3
# ╠═c0d86520-447d-11eb-234d-9f35a685a286
# ╠═f22bee90-3b2b-11eb-3838-557bd4a26f73
# ╠═c30f4612-3b2c-11eb-3596-53810b140434
# ╠═5bab0820-3b2b-11eb-19cc-73e1b2e558ab
# ╠═1e597b80-3b2d-11eb-0ea8-c1a0ace9e067
# ╠═ec1dcaa2-3b2b-11eb-04be-8b96a6c86464
# ╠═0fc39d90-3b2c-11eb-1771-29dc28d9d3fb
# ╠═26839710-3b2c-11eb-0ec6-61ffe3a4b321
# ╠═feee9400-43fc-11eb-2b7b-e52187e9636f
# ╠═48190092-3b2c-11eb-1bec-fd94323c361b
# ╠═43642b10-3b2c-11eb-0d93-5d2313bc3926
# ╠═858f9a02-3b2d-11eb-0b56-d984fbca64f0
# ╠═0b262180-43fc-11eb-3042-d3f83630d086
# ╠═9901c812-3b2d-11eb-24c3-2bd6973fcec6
# ╠═e680c290-3b2c-11eb-3412-fb0830edf1b9
# ╠═66366810-3b31-11eb-37b1-132e3837fe02
# ╠═517c7490-3b2d-11eb-2470-1f864bb57d95
# ╠═64b70a20-400a-11eb-1561-b32b24c92788
# ╠═44ec8ab0-400c-11eb-0ab4-2b8c33ad568d
# ╠═3ea34f00-400b-11eb-0df7-5bc2916a138d
# ╠═29fa7690-43f9-11eb-0627-fb7ca7d07ad2
# ╠═517cc2b2-3b2d-11eb-2fd1-c57f0f601edf
# ╠═8b892f10-3b2e-11eb-098b-ef308cb61752
# ╠═d5151bf0-4158-11eb-266b-bb6b7966134a
# ╠═ea5bb580-4150-11eb-0606-7710bf0c4c06
# ╠═8ab5f380-4163-11eb-3ac6-f55b0a5ae1f3
# ╠═a41a3200-4163-11eb-2948-b3e4854c7041
# ╠═3de69490-4151-11eb-3160-45e7563741a5
# ╠═e9508790-3b30-11eb-1720-111d5f7761b2
# ╟─010bb480-3b32-11eb-2dbc-67c877f904e9
# ╟─2e759c80-3e69-11eb-2833-7595a8f766c3
# ╟─0de5b4c0-3e6c-11eb-30a8-413735ce9a36
# ╠═1b260a40-3e6c-11eb-18a2-9f0e0166163f
# ╠═b26d6b90-3cd8-11eb-2286-c1bcdb62ae58
# ╠═e3e02b50-3f43-11eb-1cee-3534cbc03bef
# ╠═2402a050-3f44-11eb-107e-091d71973035
# ╠═ea73c640-3e6f-11eb-0424-9d2f7cd0f049
# ╠═fb59bb5e-3f44-11eb-1b44-ed41a1411728
# ╠═fdf81cc0-3e6f-11eb-1c74-490ff3d5852c
# ╠═75036940-3e6c-11eb-2cd3-d50b0670c3da
# ╠═df76cbd0-3f45-11eb-1d01-3ba63724d1fa
# ╟─b752ce50-3f46-11eb-2027-d73e4b605122
# ╟─8d1bda80-4164-11eb-0351-4513d94fb8ab
# ╠═86279fde-3f41-11eb-2e36-095d5a56d73a
# ╠═9659f610-3b2c-11eb-132c-cfe5fbcbb7c1
# ╠═d8c35da0-3cc8-11eb-0a0d-1b0cef840d03
# ╠═d503e4a0-3cc8-11eb-33f2-2bfdef902159
# ╠═2828cd90-3cd7-11eb-0815-658096d0dff0
# ╠═4ee2da70-416e-11eb-0a44-7dc9ad5f95d4
# ╠═15acf7f0-416d-11eb-0b0c-e9bf40b3994a
# ╠═34823660-4175-11eb-2555-23ae963b2331
# ╠═a33d4f70-4177-11eb-24e4-2b5bce116674
# ╠═e780dae0-4176-11eb-3000-312401960d08
# ╠═8e3cf55e-4179-11eb-26a1-138d1c0e9ffc
# ╠═1496aa80-3cce-11eb-3a7f-635d62b89453
# ╠═00b7a320-3cc9-11eb-1976-c78d4e1a2f44
# ╠═4939a620-3cc9-11eb-1814-d1576a0e8571
# ╠═4939f440-3cc9-11eb-3c45-237d6d1ec7d7
# ╠═3ad61410-3cce-11eb-0e65-ebf59517000e
# ╠═3cf8f410-3cce-11eb-277e-f5cf01627feb
# ╠═3cf96940-3cce-11eb-3d47-f762c438e963
# ╠═05dcaede-4485-11eb-3a3c-4f6a45a54b24
# ╠═e48e17f0-3fda-11eb-07f5-c3a3e3bb07b5
# ╠═1aa00a80-4484-11eb-3d2f-8f4fdb6a4c61
