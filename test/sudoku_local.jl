@testset "Local_search" begin
    using STMOZOO.Local_search
    @testset "test2" begin
        min_cost = Inf
        solution =[]
        for i in 1:100
            sol = search(sudoku_1, 100, 100)
            if sudoku_cost(sol) == 0
                solution = sol
                break
            end
            if sudoku_cost(sol) < min_cost
                min_cost = sudoku_cost(sol)
                solution = sol
            end
            i += 1
        end
        #Test if a solution was founded or it is just an approximate solution
        @test sudoku_cost(solution) < 50
    end
end
    
