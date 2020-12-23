# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using ExprRules, ExprOptimization, Random, Plots, Calculus


# export all functions that are relevant for the user
export foo_bar, fitness_test, define_grammar, ODEinit, fitness_general, ExprOptimization, GeneticProgram, optimize

"""
	this is a test function
"""
function foo_bar(x::Int64,y::Int64)
    return x+y
end

"""
	define_grammar()
	This function returns the standard grammar that is used to create and evaluate expression trees.
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
	S = SymbolTable(grammar) #ExprRule's interpreter, should increase performance according to documentation
	return grammar, S
end


"""
    fitness_test(tree::RuleNode, grammar::Grammar)
This is a hardcoded fitness function for the differential equation f'(x) - f(x) = 0, 
with boundary condition f(0) = 1. The expected solution is f(x) = exp(x). Inspired by Tsoulos and Lagaris (2006). Returns the fitness 
for a given tree based on a given grammar.

I implemented this function to make it more clear how the fitness for each expression derived from the expression tree is evaluated. 
This is based on evaluating the differential equation over an interval of sensible points. Also penalizes deviation from boundary conditions.
Weighted by factor λ (here set to 100). I tested this for 5 different ODE's in the notebook. Some solutions are exact, others are more
approximations. The problem now it that I have a different fitness function for each differential equation, see also comment below". 

"""
function fitness_test(tree::RuleNode, grammar::Grammar)
	S = SymbolTable(grammar)
	ex = get_executable(tree, grammar) #Get the expression from a given tree based on the grammar
    los = 0.0
	#Evaluate expression over an interval [0:1]. The calculus package is used to do symbolic differentiation of the expression according to the given differential equation. 
    for x = 0.0:0.1:1.0
		S[:x] = x
		los += try (Core.eval(S,differentiate(ex)) - Core.eval(S,ex))^2
		catch
			return Inf
		end
    end
	#Also boundary conditions are evaluated in this seperate step that allows for weighting the score with a factor λ. Here set default to 100 (as in Tsoulos and Lagaris (2006)). 
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
function fitness_general(tree::RuleNode, grammar::Grammar)
end

end