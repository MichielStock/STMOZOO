@testset "Local_search" begin
    using STMOZOO.LocalSearch
    @testset "fill_in" begin
        #A filled sudoku must not include zeros
        x = fill_in(sudoku_1)
        y = fill_in(sudoku_2)
        @test length(findall(iszero, x)) == 0
        @test length(findall(iszero, y)) == 0
    end
    @testset "cost" begin
        #Cost function must return a Integers
        @test check_value(sudoku_1, 1, 1) isa Int
        @test sudoku_cost(sudoku_1) isa Int
    end
    @testset "search" begin
        #cost of solution must be less than the cost of a sudoku randomly filled
        @test sudoku_cost(search(sudoku_1, 1000, 1000)) < sudoku_cost(fill_in(sudoku_1))
    end
end
    
