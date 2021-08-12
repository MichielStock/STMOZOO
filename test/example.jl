# example of a unit test in Julia
# runs a test for a certain module
# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`

# wrap all your tests and subgroups in a `@testset` block
@testset "Example" begin
    using STMOZOO.Example  # load YOUR module

    @testset "solve quadratic" begin
        # test some cases
        @test solve_quadratic_system(8.0, -2.0, 3.0) == 0.25

        # test for type
        @test solve_quadratic_system(7.0, 27.4, 3.0) isa Number

        # test for type stability
        @test solve_quadratic_system(1//2 , -2//1, 3//1) isa Rational

        P = [10 1; 1 5]
        q = [100, -7]

        # test for a result
        # use ≈ (`\approx<TAB>`) to check approximate equality
        # useful for rounding errors
        # NOTE: does NOT work on ≈ 0!
        @test solve_quadratic_system(P, q) ≈  - P \ q
        @test solve_quadratic_system(P, q, testPD=true) isa Vector

        # test if a certain error is thrown
        @test_throws AssertionError solve_quadratic_system(-P, q, testPD=true) 
    end

    @testset " quadratic function" begin
        f_scalar = quadratic_function(3, 4, 8)

        @test f_scalar isa Function
        @test f_scalar(2) isa Number
        @test f_scalar(2) ≈ 0.5 * 3 * 2^2 + 4 * 2 + 8
        
        P = [9.0 -2; -2 3]
        q = [-3, -4]
        r = -π
        x = [-2.0, 2.8]

        f_vect = quadratic_function(P, q, r)
        @test f_vect isa Function
        @test f_vect(x) isa Number
        @test f_vect(x) ≈ 0.5x' * P * x + q' * x + r
    end
end