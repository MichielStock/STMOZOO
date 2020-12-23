# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using ExprRules, ExprOptimization, Random, Plots, Calculus
export AbstractRNG, MersenneTwister, Random, RandomDevice, bitrand, rand!, randcycle, randcycle!, randexp, randexp!, randn!, randperm, randperm!, randstring, randsubseq, randsubseq!, shuffle, shuffle!
export @grammar, CrossEntropy, CrossEntropys, ExprOptAlgorithm, ExprOptResult, ExprOptimization, ExprRules, ExpressionIterator, GeneticProgram, GeneticPrograms, Grammar, GrammaticalEvolution, GrammaticalEvolutions, MonteCarlo, MonteCarlos, NodeLoc, NodeRecycler, PIPE, PIPEs, PPT, PPTs, ProbabilisticExprRules, RuleNode, SymbolTable, child_types, contains_returntype, count_expressions, depth, get_executable, get_expr, interpret, iseval, isterminal, max_arity, mindepth, mindepth_map, nchildren, node_depth, nonterminals, optimize, recycle!, return_type, root_node_loc, sample
export @grammar, ExprRules, ExpressionIterator, Grammar, NodeLoc, NodeRecycler, RuleNode, SymbolTable, child_types, contains_returntype, count_expressions, depth, get_executable, interpret, iseval, isterminal, max_arity, mindepth, mindepth_map, nchildren, node_depth, nonterminals, recycle!, return_type, root_node_loc, sample
export @sexpr, AbstractVariable, BasicVariable, Calculus, SymbolParameter, Symbolic, SymbolicVariable, check_derivative, check_gradient, check_hessian, check_second_derivative, deparse, derivative, differentiate, hessian, integrate, jacobian, processExpr, second_derivative, simplify, symbolic_derivative_bessel_list, symbolic_derivatives_1arg


# export all functions that are relevant for the user
export foo_bar, fizzywop_test, define_grammar, ODEinit, fizzywop_g

"""
	this is a test function
"""
function foo_bar(x::Int64,y::Int64)
    return x+y
end

"""
"""
function define_grammar()
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
	return grammar
end


"""
    fizzywop_test(tree::RuleNode, grammar::Grammar)
This is a hardcoded fitness function to solve the differential equation f'(x) - f(x) = 0, 
with boundary condition f(0) = 1. The expected solution is f(x) = exp(x). Inspired by Tsoulos and Lagaris (2006). 
I implemented this function to make it more clear how the fitness for each expression derived from the expression tree is evaluated. 
This is based on evaluating the differential equation over an interval of sensible points. Also penalizes deviation from boundary conditions.
Weighted by factor λ (here set to 100). I tested this for 5 different ODE's in the notebook. Some solutions are exact, the others very good
approximations.  

"""
function fizzywop_test(tree::RuleNode, grammar::Grammar)
    ex = get_executable(tree, grammar)
    los = 0.0
	#domain
    for x = 0.0:0.1:1.0
		S[:x] = x
		los += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
    end
	#boundary conditions
	S[:x] = 0
	λ = 100.
	los += try λ*(((Core.eval(S,ex)-1))^2)
	catch
		return Inf
	end
	return los
end

"""
	Standardize ODE form: the problem is that now I test 4-5 ODE in my notebook but each time have a seperate fitness function
	where I 'hardcoded' the system and boundary conditions. I guess it would be tidier if I have one function that could generate 
	a proper fitness function based on a standardized input of ODE f(x,y,y',y'',...) = 0 + boundary conditions. 
"""
function ODEinit(ODE,boundary,interval)
end

"""
	General fitness function
"""
function fizzywop_g(tree::RuleNode, grammar::Grammar)
end

end