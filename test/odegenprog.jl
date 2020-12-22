@testset "ODEGenProg" begin

    using STMOZOO.ODEGenProg

    x = 4
    y = 4

    s = foo_bar(x,y)

    @test s == 8



end