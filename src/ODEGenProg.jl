# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using ExprRules, ExprOptimization, Random, Calculus, AbstractTrees

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
	define_grammar_1D()

	This function returns the standard grammar that is used to create and evaluate expression trees.
"""
function define_grammar_1D()
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
	    R = x
    end
	return grammar
end

"""
	define_grammar_2D()

	This function returns the standard grammar that is used to create and evaluate expression trees.
"""
function define_grammar_2D()
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
		R = x
		R = y
    end
	return grammar
end

"""
	fitness_test(tree::RuleNode, grammar::Grammar)
	
This is a hardcoded fitness function for the differential equation f'(x) - f(x) = 0, 
with boundary condition f(0) = 1. The expected solution is f(x) = exp(x). It returns the fitness 
for a given tree based on a given grammar. Inspired by Tsoulos and Lagaris (2006).

Comment: I implemented this function to make it more clear how the fitness for each expression derived from the expression tree is evaluated. 
This is based on evaluating the differential equation over an interval of sensible points. Also penalizes deviation from boundary conditions.
Weighted by factor λ (here set to 100). I tested this for 5 different ODE's in the notebook. Some solutions are exact, others are more
approximations. The problem now it that I have a different fitness function for each differential equation, see also comment below". 

"""
function fitness_0(tree::RuleNode, grammar=grammar)
	S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
	ex = ExprRules.get_executable(tree, grammar) #Get the expression from a given tree based on the grammar
    loss = 0.  #I minimize fitness 
	#Evaluate expression over an interval [0:1]. The calculus package is used to do symbolic differentiation of the expression according to the given differential equation. 
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
    end
	#Also boundary conditions are evaluated in this seperate step that allows for weighting the score with a factor λ. Here set default to 100 (as in Tsoulos and Lagaris (2006)). 
	S[:x] = 0
	λ = 100.
	loss += try λ * (((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return loss
end

"""
"""
function fitness_basic(tree::RuleNode)
	grammar = define_grammar_1D()
	S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
	ex = ExprRules.get_executable(tree, grammar) #Get the expression from a given tree based on the grammar
    loss = 0.  #minimize fitness 
	#Evaluate expression over an interval [0:1]. The calculus package is used to do symbolic differentiation of the expression according to the given differential equation. 
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
    end
	#Also boundary conditions are evaluated in this seperate step that allows for weighting the score with a factor λ. Here set default to 100 (as in Tsoulos and Lagaris (2006)). 
	S[:x] = 0
	λ = 100.
	loss += try λ * (((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return loss
end

"""
    hardcoded fitness function for y''=100y, y(0)=0, y'(0)=10 -> y(x)=sin(10x)
"""
function fitness_1(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = get_executable(tree, grammar)
    loss = 0.
	#domain
    for x = 0.0:0.1:1.0
		S[:x] = x
		loss += try ((Core.eval(S,differentiate(differentiate(ex))) + 100*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	#boundary conditions
	S[:x] = 0
	λ = 100.
	loss += try λ*((((Core.eval(S,ex)-0))^2) + (((Core.eval(S,differentiate(ex))-10))^2)) 
	catch
		return Inf
	end
		
	return loss
end

"""
    hardcoded fitness function for y'=(1-y*cos(x))/sin(x), y(0.1)=2.1/sin(0.1)-> y(x)=(x+2)/sin(x)
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
    hardcoded fitness function for y'=(2x-y)/x, y(0)=20.1-> y(x)=x+2/x
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
    hardcoded fitness function for y''-6y'+9y=0
"""
function fitness_4(tree::RuleNode, grammar::Grammar)
    S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
    ex = get_executable(tree, grammar)
    loss = 0.
	#domain
    for x = 0.1:2.:20.1
		S[:x] = x
		loss += try (abs(Core.eval(S,differentiate(differentiate(ex))) - 6*(Core.eval(S,differentiate(ex))) + 9*Core.eval(S,ex)))^2
		catch
			return Inf
		end
    end
	#boundary conditions
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
    hardcoded fitness function
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
"""
function crossover(p, a, b, max_depth)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	crosspoint = sample(b)
	typ = return_type(grammar, crosspoint.ind)
	d_subtree = depth(crosspoint)
	d_max = max_depth + 1 - d_subtree
	if d_max > 0 && contains_returntype(child, grammar, typ, d_max)
		loc = sample(NodeLoc, child, typ, grammar, d_max)
		insert!(child, loc, deepcopy(crosspoint))
	end
	return child
end

"""
"""
function mutate(a, p)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	if rand() < p
		loc = sample(NodeLoc, child)
		typ = return_type(grammar, get(child, loc).ind)
		subtree = rand(RuleNode, grammar, typ)
		insert!(child, loc, subtree)
	end
	return child
end

"""
"""
function permutate(a, p)
	grammar = define_grammar_1D()
	child = deepcopy(a)
	if rand() < p
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
    tournamentselection method, S number of winners ?
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
"""
function genetic_program(f, population, k_max, S, C, M, max_depth)
	grammar = define_grammar_1D()
	sol_iter = Expr[]
	fit_iter = Float64[]
	for k in 1 : k_max
		parents = select(f.(population), S)
		children = [crossover(C, population[p[1]], population[p[2]], max_depth) for p in parents]
		population .= permutate.(children, M) #Ref(M)
		fittest = population[argmin(f.(population))]
		fittest_expr = get_executable(fittest, grammar)
		push!(sol_iter, fittest_expr)
		push!(fit_iter, f(fittest))
	end
	final = population[argmin(f.(population))]
	expr = get_executable(final, grammar)
	return (expr = expr, sol_iter = sol_iter, fit_iter = fit_iter)
end

"""
	plot_solution(ex::Expr, gr::Grammar, s::Float64, t::Float64)

Plot a function of one variable given as an expression `ex` and the corresponding grammar `gr` 
over an interval from `s` to `t`. 
"""
function plot_solution(ex, grammar, s, t)
S = ExprRules.SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
sol = Float64[]
for x = s:0.01:t
    S[:x] = x
    push!(sol, Core.eval(S,ex))
end
return sol
end	

"""
	plot_solution_2D(x::Float64, y::Float64)

Define a function of two variables `x` and `y` compatible with 
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