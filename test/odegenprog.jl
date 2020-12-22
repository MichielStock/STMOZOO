@testset "ODEGenProg" begin

    using STMOZOO.ODEGenProg
    x = 4
    y = 4
    s = foo_bar(x,y)
    @test s == 8

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
    
    g = GeneticProgram(250,50,5,0.3,0.3,0.4)
    results_gp = optimize(g, grammar, :R, fizzywop_test)

    @test results_gp.expr == :(exp(x))


end