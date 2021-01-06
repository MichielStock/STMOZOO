# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using ExprRules, ExprOptimization, Random, Calculus, AbstractTrees, GraphRecipes

export GraphRecipes, TreePlot, graphplot, graphplot!
export AbstractTrees, AnnotationNode, Leaves, PostOrderDFS, PreOrderDFS, ShadowTree, StatelessBFS, Tree, TreeCharSet, TreeIterator, children, print_tree, treemap, treemap!
export @dag, @dag_cse, @tree, @tree_with_call, LabelledTree, TreeView, make_dag, tikz_representation, walk_tree, walk_tree!
export @sexpr, AbstractVariable, BasicVariable, Calculus, SymbolParameter, Symbolic, SymbolicVariable, check_derivative, check_gradient, check_hessian, check_second_derivative, deparse, derivative, differentiate, hessian, integrate, jacobian, processExpr, second_derivative, simplify, symbolic_derivative_bessel_list, symbolic_derivatives_1arg
export AbstractRNG, MersenneTwister, Random, RandomDevice, bitrand, rand!, randcycle, randcycle!, randexp, randexp!, randn!, randperm, randperm!, randstring, randsubseq, randsubseq!, shuffle, shuffle!
export @grammar, CrossEntropy, CrossEntropys, ExprOptAlgorithm, ExprOptResult, ExprOptimization, ExprRules, ExpressionIterator, GeneticProgram, GeneticPrograms, Grammar, GrammaticalEvolution, GrammaticalEvolutions, MonteCarlo, MonteCarlos, NodeLoc, NodeRecycler, PIPE, PIPEs, PPT, PPTs, ProbabilisticExprRules, RuleNode, SymbolTable, child_types, contains_returntype, count_expressions, depth, get_executable, get_expr, interpret, iseval, isterminal, max_arity, mindepth, mindepth_map, nchildren, node_depth, nonterminals, optimize, recycle!, return_type, root_node_loc, sample
export @grammar, ExprRules, ExpressionIterator, Grammar, NodeLoc, NodeRecycler, RuleNode, SymbolTable, child_types, contains_returntype, count_expressions, depth, get_executable, interpret, iseval, isterminal, max_arity, mindepth, mindepth_map, nchildren, node_depth, nonterminals, recycle!, return_type, root_node_loc, sample


# export all functions that are relevant for the user
export fitness_0, define_grammar_1D, define_grammar_2D, fitness_1, fitness_2, fitness_3, fitness_4, fitness_2D, plot_solution, plot_solution_2D
export crossover, mutate, permutate, select, genetic_program, fitness_basic
#, ExprOptimization, GeneticProgram, optimize

"""
	define_grammar_1D(empty)

	Returns the grammar used to create and evaluate expression trees for ODE solving in one variable x.
"""
function define_grammar_1D()
	grammar = @grammar begin
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
	grammar = @grammar begin
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
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100. 
"""
function fitness_0(tree::RuleNode, grammar=grammar)
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
    fitness_basic(tree::RuleNode)
	
Fitness function for the differential equation y'(x) - y(x) = 0, 
with boundary condition y(0) = 1. The expected solution is y(x) = exp(x). It returns the fitness 
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_basic(tree::RuleNode)
	grammar = define_grammar_1D()
	S = ExprRules.SymbolTable(grammar) 
	ex = ExprRules.get_executable(tree, grammar) 
    loss = 0.   
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
	end
	
	S[:x] = 0
	λ = 100.
	loss += try λ * (((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return loss
end

"""
    fitness_1(tree::RuleNode, grammar::Grammar)
	
Fitness function for the differential equation y'' - 100y = 0, 
with boundary conditions y(0) = 0 and y'(0) = 10. The expected solution is y(x) = sin(10x). It returns the fitness 
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_1(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) 
    ex = get_executable(tree, grammar)
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
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_2(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = get_executable(tree, grammar)
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
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_3(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = get_executable(tree, grammar)
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
for a given expression tree based on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_4(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) 
    ex = get_executable(tree, grammar)
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
It returns the fitness for a given expression tree based 
on a given grammar by evaluating the expression tree over a specific interval of existence.
Penalizes deviation from boundary conditions weighted by factor λ = 100.
"""
function fitness_2D(tree::RuleNode, grammar::Grammar)
    S_2D = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = get_executable(tree, grammar)
    loss = 0.
	#domain
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
	#boundary conditions
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
a maximum depth `max depth` so the size of expression trees doesn't get too large.
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
	select(y, S)
Tournament selection with tournament size `S`, where each
parent is the fittest out of `S` randomly chosen expression trees of the population.
"""
function select(y, S)
	grammar = define_grammar_1D()
	getparent() = begin
	p = randperm(length(y))
	p[argmin(y[p[1:S]])]
	end
	return [[getparent(), getparent()] for i in y]
end

"""
	genetic_program(f::Function, population::Vector{RuleNode}, k_max::Int, S:Int, C:Float64, M:Float64, max_depth:Int)

Runs genetic program for a starting population `population`, which is a vector of RuleNodes (i.e. expression trees). 
Calculates for each expression tree the fitness based on a fitness function `f`. Uses tournament selection that keeps 
the best scoring expression tree out of `S` randomly chosen expression trees. Crossing over occurs with probability `C` and mutation with probability `M`. 
Iterated for `k_max` generations.
"""
function genetic_program(f, population, k_max, S, C, M, max_depth)
	grammar = define_grammar_1D()
	sol_iter = Expr[] #keeps track of best solution for every generation
	fit_iter = Float64[] #keeps track of fitness of best solution for every generation
	for k in 1 : k_max #iterates over k_max generations
		parents = select(f.(population), S) #selection step
		children = [crossover(C, population[p[1]], population[p[2]], max_depth) for p in parents] #crossover step
		population .= permutate.(children, M) #Ref(M) #mutation step
		fittest = population[argmin(f.(population))] #finds the best solution 
		fittest_expr = get_executable(fittest, grammar) #gets the expression for the best solution
		push!(sol_iter, fittest_expr)
		push!(fit_iter, f(fittest))
	end
	final = population[argmin(f.(population))]
	expr = get_executable(final, grammar)
	return (expr = expr, sol_iter = sol_iter, fit_iter = fit_iter)
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