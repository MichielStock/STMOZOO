# Michael Van de Voorde

module ODEGenProg

using ExprRules
using ExprOptimization
using Random
using Calculus
using AbstractTrees
using GraphRecipes

export ExprOptimization, GeneticProgram, GeneticPrograms, optimize
export ExprRules, ExpressionIterator, @grammar, Grammar, NodeLoc, NodeRecycler, RuleNode, SymbolTable, child_types, contains_returntype, count_expressions, depth, get_executable, interpret, iseval, isterminal, max_arity, mindepth, mindepth_map, nchildren, node_depth, nonterminals, recycle!, return_type, root_node_loc, sample
export TreePlot, print_tree, differentiate
export plot_solution, plot_solution_2D
export define_grammar_1D, define_grammar_2D, fitness_0, fitness_1, fitness_2, fitness_3, fitness_4, fitness_2D
export crossover, mutate, permutate, genetic_program, fitness_basic, tournament_selection, truncation_selection

"""
	define_grammar_1D(empty)

	Returns the grammar used to create and evaluate expression trees for ODE solving in one variable x.
"""
function define_grammar_1D()
	grammar = ExprRules.@grammar begin
        R = |(1:9) #shortway notation to add all integers to the grammar
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
	return grammar
end

"""
	define_grammar_2D(empty)

	Returns the grammar used to create and evaluate expression trees for PDE solving in two variables x and y.
"""
function define_grammar_2D()
	grammar = ExprRules.@grammar begin
        R = |(1:9) #shortway notation to add all integers to the grammar
        R = R + R
        R = R - R
        R = R / R
        R = R * R
        R = x ^ R
        R = sin(R)
        R = cos(R)
        R = exp(R)
		R = x
		R = y
    end
	return grammar
end

"""
	fitness_0(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y'(x) - y(x) = 0, 
with boundary condition y(0) = 1. The expected solution is y(x) = exp(x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100. 
"""
function fitness_0(tree::RuleNode, grammar::Grammar)
	S = ExprRules.SymbolTable(grammar) #ExprRule package interpreter, should increase performance according to documentation
	ex = ExprRules.get_executable(tree, grammar) #gets the expression from a given tree based on the grammar
    loss = 0.  #the goal is to minimize fitness 
	#evaluate the expression over an interval of equidistant points 
	#calculus package is used to do symbolic differentiation 
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2 #mean square error, (f'(x) - f(x) - 0)^2
		catch #try catch garantees domain errors can be passed that can arise with some functions
			return Inf #if there is a domain error the fitness becomes Inf
		end
    end
	#boundary conditions are evaluated in this seperate step that allows for 
	#weighting the score with a factor λ. Here set default to 100 (as in Tsoulos and Lagaris (2006)). 
	S[:x] = 0
	λ = 100.
	loss += try λ * (((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return loss
end

"""
    fitness_0(tree::RuleNode)
	
Fitness function for the differential equation y'(x) - y(x) = 0, 
with boundary condition y(1) = ℯ. The expected solution is y(x) = exp(x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_0(tree::RuleNode)
	grammar = define_grammar_1D()
	S = ExprRules.SymbolTable(grammar) 
	ex = ExprRules.get_executable(tree, grammar) 
    loss = 0.   
    for x = 0.1:0.1:1.0
		S[:x] = x
		loss += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
	end
	
	S[:x] = 1.
	λ = 100.
	loss += try λ * (((Core.eval(S,ex)-ℯ))^2)
	catch
		return Inf
	end
	return loss
end

"""
    fitness_1(tree::RuleNode)
	
Fitness function for the differential equation y'' - 100y = 0, 
with boundary conditions y(0) = 0 and y'(0) = 10. The expected solution is y(x) = sin(10x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_1(tree::RuleNode)
	grammar = define_grammar_1D()
    S = ExprRules.SymbolTable(grammar) 
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	
    for x = 0.1:0.1:1.0
		S[:x] = x
		loss += try ((Core.eval(S,differentiate(differentiate(ex))) + 100*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	S[:x] = 2*π
	λ = 100.
	loss += try λ*((((Core.eval(S,ex)-0))^2) + (((Core.eval(S,differentiate(ex))-10))^2)) 
	catch
		return Inf
	end
		
	return loss
end

"""
    fitness_1(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y'' - 100y = 0, 
with boundary conditions y(0) = 0 and y'(0) = 10. The expected solution is y(x) = sin(10x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_1(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) 
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try ((Core.eval(S,differentiate(differentiate(ex))) + 100*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	S[:x] = 0
	λ = 100.
	loss += try λ*((((Core.eval(S,ex)-0))^2) + (((Core.eval(S,differentiate(ex))-10))^2)) 
	catch
		return Inf
	end
		
	return loss
end

"""
    fitness_2(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y' - (1-ycos(x))/sin(x) = 0, 
with boundary condition y(0.1) = 2.1/sin(0.1). The expected solution is y(x) = (x+2)/sin(x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_2(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	#domain
    for x = 0.1:0.1:1.0
		S[:x] = x
		loss += try (abs(Core.eval(S,differentiate(ex)) - ((1-(Core.eval(S,ex)*cos(x)))/sin(x))))^2
		catch
			return Inf
		end
    end
	#boundary conditions
	S[:x] = 0.1
	λ = 100.
	loss += try λ*(Core.eval(S,ex)-(2.1/sin(0.1)))^2
	catch
		return Inf
	end
	return loss
end

"""
    fitness_3(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y' - (2x-y)/x = 0, 
with boundary condition y(0) = 20.1. The expected solution is y(x) = x+2/x. It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_3(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	#domain
    for x = 0.1:0.1:1.0
		S[:x] = x
		loss += try (abs(x*Core.eval(S,differentiate(ex)) - 2*x + Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	#boundary conditions
	S[:x] = 0.
	λ = 100.
	loss += try λ*(Core.eval(S,ex)-20.1)^2 
	catch
		return Inf
	end
	return loss
end

"""
    fitness_4(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y'' - 6y' + 9y = 0, 
with boundary conditions y(0) = 0 and y'(0) = 2. The expected solution is y(x) = 2x*exp(3x). It returns the fitness 
for a given expression `tree` based on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_4(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) 
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	for x = 0.1:2.:20.1
		S[:x] = x
		loss += try (abs(Core.eval(S,differentiate(differentiate(ex))) - 6*(Core.eval(S,differentiate(ex))) + 9*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	
	S[:x] = 0.
	λ = 100.
	loss += try λ*(Core.eval(S,ex)-0)^2 
	catch
		return Inf
	end
	loss += try λ*(Core.eval(S,differentiate(ex))-2)^2 
	catch
		return Inf
	end
	return loss
end

"""
    fitness_2D(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation 	(d/dx + d/dy)^2(f(x,y)) - 2f(x,y) = 0, 
with boundary conditions (0, y) = 0, (1, y) = sin(1)cos(y), (x, 0) = sin(x), (x, 1) = sin(x)cos(1). 
The exact solution is f(x, y) = sin(x)cos(y). 
It returns the fitness for a given expression `tree` based 
on a given `grammar` by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_2D(tree::RuleNode, grammar::Grammar)
    S_2D = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = ExprRules.get_executable(tree, grammar)
    loss = 0.
	
    for x = 0.1:0.1:1.0
		for y = 0.1:0.1:1.0
			S_2D[:x] = x
			S_2D[:y] = y
			loss += try (Core.eval(S_2D,differentiate(differentiate(ex, :x), :x)) + Core.eval(S_2D,differentiate(differentiate(ex, :y), :y)) + (2*(Core.eval(S_2D,ex))))^2
			catch
				return Inf
			end
		end
    end
	
	S_2D[:x] = 0.
	λ = 10.
	loss += try λ*(Core.eval(S_2D,ex)-0)^2 
	catch
		return Inf
	end
	S_2D[:x] = 1.
	λ = 10.
	loss += try λ*(Core.eval(S_2D,ex)-(Core.eval(S_2D,:(sin(1)*cos(y)))))^2 
	catch
		return Inf
	end
	S_2D[:y] = 0.
	λ = 10.
	loss += try λ*(Core.eval(S_2D,ex)-(Core.eval(S_2D,:(sin(x)))))^2 
	catch
		return Inf
	end
	S_2D[:y] = 1.
	λ = 10.
	loss += try λ*(Core.eval(S_2D,ex)-(Core.eval(S_2D,:(sin(x)*cos(1)))))^2 
	catch
		return Inf
	end
	return loss
end

"""
	crossover(p::Float64, a::RuleNode, b::RuleNode, max_depth::Int)
Crossover genetic operator. Picks a random node from an expression tree `a`, then picks a random node 
from an expression tree `b` that has the same type, then replaces the subtree. The crossover is constrained to 
a maximum depth `max_depth` so the size of expression trees doesn't get too large. 
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function crossover(p, a, b, max_depth)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	if rand() < p #mutation probability p
		crosspoint = sample(b) #samples random node from b
		typ = return_type(grammar, crosspoint.ind) #checks type
		d_subtree = depth(crosspoint)
		d_max = max_depth + 1 - d_subtree #constraints max depth
		if d_max > 0 && contains_returntype(child, grammar, typ, d_max)
			loc = sample(NodeLoc, child, typ, grammar, d_max)
			insert!(child, loc, deepcopy(crosspoint))
		end
	end
	return child
end

"""
	mutate(a::RuleNode, p::Float64)
Mutation genetic operator. Picks a random node from an expression tree `a`, 
then replaces the subtree with a random one.
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function mutate(a, p)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	if rand() < p #mutation probability p
		loc = sample(NodeLoc, child) #picks random node from expression tree
		typ = return_type(grammar, get(child, loc).ind) #checks the type of the random node
		subtree = rand(RuleNode, grammar, typ) #creates a new random subtree that starts in the correct node type
		insert!(child, loc, subtree) #substitutes new subtree into old expression tree
	end
	return child
end

"""
	permutate(a::RuleNode, p::Float64)
Permutation is a second form of genetic mutation for a given expression tree `a` with probability of mutation `p`. 
The children of a randomly chosen node are randomly permuted.
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function permutate(a, p)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	if rand() < p #mutation probability p
		node = sample(child)
		n = length(node.children)
		types = child_types(grammar, node)
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

"""
	tournament_selection(y::Vector{Float64}, S::Int)
Tournament selection with tournament size `S`, where each
parent is the fittest, given a vector `y` with fitnesses for the whole population, 
out of `S` randomly chosen expression trees of the population.
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function tournament_selection(y, S)
	getparent() = begin
	p = randperm(length(y))
	p[argmin(y[p[1:S]])]
	end
	return [[getparent(), getparent()] for i in y] #returns a vector of vectors of 2 expression trees 
	#that will serve as input for crossing over
end

"""
	truncation_selection(y::Vector{Float64}, T::Int)
Truncation selection that chooses parents from among the
best `T` expression trees in the population given a vector `y` with fitnesses.
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function truncation_selection(y, T)
	p = sortperm(y)
	return [p[rand(1:T, 2)] for i in y]
	end

"""
	genetic_program(f::Function, population::Vector{RuleNode}, k_max::Int, S:Int, C:Float64, M:Float64, max_depth:Int)

Runs genetic program for a starting population `population`, which is a vector of RuleNodes (i.e. expression trees). 
Calculates for each expression tree the fitness based on a fitness function `f`. Uses tournament selection that keeps 
the best scoring expression tree out of `S` randomly chosen expression trees. Crossing over occurs with probability `C` and mutation with probability `M`. 
Iterated for `k_max` generations.
Adapted from Kochenderfer, M. J., & Wheeler, T. A. (2019). 
"""
function genetic_program(f, population, k_max, S, C, M, max_depth)
	grammar = define_grammar_1D()
	sol_iter = Expr[] #keeps track of best solution for every generation
	fit_iter = Float64[] #keeps track of fitness of best solution for every generation
	for k in 1 : k_max #iterates over k_max generations
		parents = truncation_selection(f.(population), S) #selection step
		children = [crossover(C, population[p[1]], population[p[2]], max_depth) for p in parents] #crossover step
		population .= mutate.(children, M) #Ref(M) #mutation step
		population = children
		fittest = population[argmin(f.(population))] #gets the best solution 
		fittest_expr = get_executable(fittest, grammar) #gets the expression for the best solution
		push!(sol_iter, fittest_expr)
		push!(fit_iter, f(fittest))
	end
	final = population[argmin(f.(population))]
	expr = get_executable(final, grammar)
	pop_fit = f.(population)
	return (expr = expr, sol_iter = sol_iter, fit_iter = fit_iter, pop_fit = pop_fit)
end

"""
	plot_solution(ex::Expr, gr::Grammar, s::Float64, t::Float64)

Plots a function of one variable given as an expression `ex` and the corresponding grammar `gr` 
over an interval from `s` to `t`. 
"""
function plot_solution(ex, grammar, s, t)
S = ExprRules.SymbolTable(grammar) 
sol = Float64[]
for x = s:0.01:t
    S[:x] = x
    push!(sol, Core.eval(S,ex))
end
return sol
end	

"""
	plot_solution_2D(x::Float64, y::Float64)

Defines a function of two variables `x` and `y` from a global expression 'results_2D.expr'
to make it compatible with the surface function of the Plots package, allowing to plot expressions directly.
"""
function plot_solution_2D(x,y)
	g_2D = define_grammar_2D()
	S_2D = SymbolTable(g_2D)
	res_2D = results_2D.expr
	S_2D[:x] = x
	S_2D[:y] = y
	return  Core.eval(S_2D,res_2D)
end	

#grammar = define_grammar_1D()
#population = [rand(RuleNode, grammar, :R, 5) for i in 1:2000]
#gp = genetic_program(fitness_basic, population, 15, 2,  0.3, 0.3, 5)

end