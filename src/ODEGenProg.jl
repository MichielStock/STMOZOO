# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using ExprRules, ExprOptimization, Random, Plots, Calculus


# export all functions that are relevant for the user
export foo_bar, fizzywop_test

"""
	this is a testfunction
"""
function foo_bar(x::Int64,y::Int64)
    return x+y
end

"""
    fizzywop_test(tree::RuleNode, grammar::Grammar)
This is a hardcoded fitness function to solve the differential equation f'(x) - f(x) = 0, 
with boundary condition f(0) = 1. The expected solution is f(x) = exp(x).

"""
function fizzywop_test(tree::RuleNode, grammar::Grammar)
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

end