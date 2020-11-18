# example of a unit test in Julia
# runs a test for a certain module
# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`

# wrap all your tests and subgroups in a `@testset` block
@testset "BeesAlgorithm" begin
    using STMOZOO.BeesAlgorithm  # load YOUR module

    @testset "initialize population" begin
        # test for type
     #   @test initialize_population() isa vec




        # test if a certain error is thrown
       # @test_throws AssertionError 
    end

    @testset "evaluate population" begin

     #   @test 
    end
end