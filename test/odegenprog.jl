@testset "ODEGenProg" begin

    using STMOZOO.ODEGenProg
    grammar = define_grammar()
     
    @testset "odegenprog" begin

    x = 4
    y = 4
    s = foo_bar(x,y)
    @test s == 8

    #I switched to using the build in GP from the ExprOptimization package with my custom fitness functions because it's very fast. 
    #This test evalutates the fitness_test function for ODE f'(x) - f(x) = 0, with boundary condition f(0) = 1. The expected solution is f(x) = exp(x)
    g = ExprOptimization.GeneticProgram(250,50,5,0.3,0.3,0.4) 
    results_gp = ExprOptimization.optimize(g, grammar, :R, fitness_test)
    @test results_gp.expr == :(exp(x))

    end

end