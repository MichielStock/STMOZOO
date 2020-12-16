# example of a unit test in Julia
# runs a test for a certain module
# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`

# wrap all your tests and subgroups in a `@testset` block
@testset "Polygon" begin
    using STMOZOO.polygon, Colors  # load YOUR module

    @testset "in triangle" begin
        T1 = Triangle(3 + 2im, 4 + 4im, 5 + 0im, RGB(0, 0, 1))
        testpoint1 = Vector{Complex}(undef, 8)
        testpoint1[1] = 1 + 3im # not in T1
        testpoint1[2] = 5 + 2im # not in T1
        testpoint1[3] = 4 + 5im # not
        testpoint1[4] = 0.9 + 2im # no
        testpoint1[5] = 3 + 2im # in T1
        testpoint1[6] = 4 + 1im # in T1
        testpoint1[7] = 2 + 1.5im # on edge off T1 (= in)
        testpoint1[8] = 3.5 + 2.5im # yes
        
        T2 = Triangle(3 + 2im, 3 + 4im, 5 + 1im, RGB(0, 0, 1))
        testpoint2 = Vector{Complex}(undef, 8)
        testpoint2[1] = 4 + 1im #not
        testpoint2[2] = 3 + 0.5im #not
        testpoint2[3] = 5 + 3im #not
        testpoint2[4] = 1 + 2im #not
        testpoint2[5] = 4 + 2im #yes
        testpoint2[6] = 3 + 2im #yes
        testpoint2[7] = 3.5 + 2.5im #yes
        testpoint2[8] = 3.1 + 3.5im #yes

        for i in 1:4
            @test (testpoint1[i] in T1) == false
            @test (testpoint2[i] in T2) == false
        end
        for i in 5:8
            @test (testpoint1[i] in T1) == true
            @test (testpoint2[i] in T2) == true
        end 
    end


end