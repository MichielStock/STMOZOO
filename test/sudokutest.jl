# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`
        # use ≈ (`\approx<TAB>`) to check approximate equality
        # useful for rounding errors
        # NOTE: does NOT work on ≈ 0!

@testset "SudokuSolver" begin
    using STMOZOO.SudokuSolver 

    @testset "Block" begin
        sudoku =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        @test block(5, 8, sudoku) isa Array

        @test length(block(7, 4, sudoku)) == 9

        @test block(1, 1, sudoku) == [7 4 1 ; 3 0 6 ; 2 9 5]
        @test block(8, 4, sudoku) == [9 7 2 ; 8 3 5 ; 0 1 4]

    end

    @testset "Freq Table" begin
        list = [5 9 1 4 5 9 5]
        row = [9 7 2 0 0 8 0 1 4]

        @test freq_table(list) isa Dict
        
        @test length(freq_table(list)) == 4
        @test length(freq_table(row)) == 7

        @test freq_table(list)[9] ==2
        @test freq_table(list)[5] ==3
        @test freq_table(row)[7] ==1
        @test freq_table(row)[0] ==3
    end

    @testset "Duplicates" begin
        list = [5 9 1 4 5 9 5]
        row = [9 7 2 0 0 8 0 1 4]

        @test duplicates(list) isa Bool
        
        @test duplicates(list) == true
        @test duplicates(row) == false
    end

    @testset "Valid" begin
        sudoku =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        row = [9 7 2 0 0 8 0 1 4]
        
        notsudoku =  [7 4 1 5 9 0 3 8 2
            3 0 12 2 4 7 1 9 5
            2 9 5 1 8 3 6 0 7
            9 7 2 0 0 8 0 1 4
            0 0 4 0 5 0 8 0 0
            1 5 0 4 0 0 7 3 6
            5 0 3 9 7 2 4 6 8
            4 6 9 8 3 5 2 0 1
            8 2 7 0 1 4 9 5 3]

        dupsudoku =  [7 4 1 5 9 0 3 5 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        @test valid(sudoku) isa Bool
        
        @test valid(a) == false
        @test valid(row) == false
        @test valid(sudoku) == true
        @test valid(notsudoku) == false
        @test valid(dupsudoku) == false
    end

    @testset "Fixed Values" begin
        sudoku =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        fixed = [1  1  1  1  1  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  0  1  0  1  1
            0  0  1  0  1  0  1  0  0
            1  1  0  1  0  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  1  1  1  1  1]

        @test fixed_values(sudoku) isa Array

        @test length(fixed_values(sudoku)) == 91
        
        @test fixed_values(sudoku) == fixed
    end

    @testset "Nr Errors" begin
        sudoku =  [7  4  1  5  9  6  3  8  2
            3  8  6  2  4  7  1  9  5
            2  9  5  1  8  3  6  4  7
            9  7  2  6  3  8  2  1  4
            3  6  4  1  5  7  8  5  9
            1  5  8  4  2  9  7  3  6
            5  1  3  9  7  2  4  6  8
            4  6  9  8  3  5  2  7  1
            8  2  7  6  1  4  9  5  3]

        sudoku2 =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        @test nr_errors(sudoku) isa Int
        
        @test nr_errors(sudoku) == 10
        @test nr_errors(sudoku) == 18
    end

    @testset "Missing Nr" begin
        block1 = [7 4 1 ; 3 0 6 ; 2 9 5]
        block2 = [0 0 8 ; 0 5 0 ; 4 0 0]

        @test missing_nr(block1) isa Array
        
        @test length(missing_nr(block1)) == 1
        @test length(missing_nr(block2)) == 6

        @test missing_nr(block1) == [8]
    end

    @testset "Pick" begin
        list = [5, 9, 1, 4, 5, 9, 5]

        @test pick(list) isa Tuple
        @test pick(list)[1] isa Int
        @test pick(list)[2] isa Array

        list = [5, 9, 1, 4, 5, 9, 5]
        @test length(pick(list)[2]) == 6
        @test length(pick(list)[2]) == 5
    end


    @testset "Fill Block" begin
        block1 = [7 4 1 ; 3 0 6 ; 2 9 5]
        block2 = [0 0 8 ; 0 5 0 ; 4 0 0]

        @test fill_block(block1) isa array

        @test length(fill_block(block1)) == 9
        @test length(fill_block(block2)) == 9
        
        @test (0 in fill_block(block2)) == false

        @test fill_block(block1) == [7 4 1 ; 3 8 6 ; 2 9 5]
    end

    @testset "Fill Full" begin
        sudoku1 =  [4 9 2 8 1 7 3 6 5
        	8 1 3 5 6 4 7 9 0
        	6 7 5 9 2 3 4 8 1
        	9 5 4 6 8 1 2 3 7
	        2 0 1 3 7 9 6 0 4
	        7 3 6 2 4 0 8 1 9
	        5 2 9 7 3 6 1 4 8
	        0 4 8 1 5 2 9 7 6
	        1 6 7 4 9 8 5 2 0]

        sudoku2 =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        filled1 = [ 4  9  2  8  1  7  3  6  5
            8  1  3  5  6  4  7  9  2
            6  7  5  9  2  3  4  8  1
            9  5  4  6  8  1  2  3  7
            2  8  1  3  7  9  6  5  4
            7  3  6  2  4  5  8  1  9
            5  2  9  7  3  6  1  4  8
            3  4  8  1  5  2  9  7  6
            1  6  7  4  9  8  5  2  3]

        @test fill_full(sudoku2) isa Array
        
        @test length(fill_full(sudoku2)) == 81

        @test fill_full(sudoku1) == filled1
    end

    @testset "Not Fixed" begin
        fixed = [1  1  1  1  1  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  0  1  0  1  1
            0  0  1  0  1  0  1  0  0
            1  1  0  1  0  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  1  1  1  1  1]

        sudoku1 =  [4 9 2 8 1 7 3 6 5
        	8 1 3 5 6 4 7 9 0
        	6 7 5 9 2 3 4 8 1
        	9 5 4 6 8 1 2 3 7
	        2 0 1 3 7 9 6 0 4
	        7 3 6 2 4 0 8 1 9
	        5 2 9 7 3 6 1 4 8
	        0 4 8 1 5 2 9 7 6
	        1 6 7 4 9 8 5 2 0]

        block1 = [7 4 1 ; 3 0 6 ; 2 9 5]

        @test not_fixed(fixed) isa Array
        
        @test length(not_fixed(fixed)) == 18
        @test length(not_fixed(sudoku1)) == 6
        @test length(not_fixed(block1)) == 1

        @test not_fixed(block1) == [5]
    end

    @testset "Block Nr Ind" begin
        @test block_nr_ind(3) isa Tuple
        @test block_nr_ind(3)[1] isa Int
        @test block_nr_ind(3)[2] isa Int
        
        @test block_nr_ind(3) == (9, 3)
        @test block_nr_ind(5) == (6, 6)
        @test block_nr_ind(8) == (6, 9)
        @test block_nr_ind(1) == (3, 3)
    end

    @testset "Fixed Blocks" begin
        fixed = [1  1  1  1  1  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  0  1  0  1  1
            0  0  1  0  1  0  1  0  0
            1  1  0  1  0  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  1  1  1  1  1]

        @test fixed_blocks(fixed) isa Array
        
        @test length(fixed_blocks(fixed)) == 3

        @test fixed_blocks(fixed) == [2; 5; 8]
    end

    @testset "Possible Swap" begin
        fixed = [1  1  1  1  1  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  0  1  0  1  1
            0  0  1  0  1  0  1  0  0
            1  1  0  1  0  0  1  1  1
            1  0  1  1  1  1  1  1  1
            1  1  1  1  1  1  1  0  1
            1  1  1  0  1  1  1  1  1]

        @test possible_swap(fixed) isa Tuple
        @test possible_swap(fixed)[1] isa Array
        @test possible_swap(fixed)[2] isa Dict
        
        @test length(possible_swap(fixed)[2]) == 3

        @test possible_swap(fixed)[1] == [2; 5; 8]
    end

    @testset "Start Temp" begin
        sudoku =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        @test start_temp(sudoku) isa Tuple
        @test start_temp(sudoku)[2] isa Number
        @test start_temp(sudoku)[2] isa Array
        
        @test length(start_temp(sudoku)[2]) == 81
    end

    @testset "Solver" begin
        sudoku =  [7 4 1 5 9 0 3 8 2
    	    3 0 6 2 4 7 1 9 5
        	2 9 5 1 8 3 6 0 7
    	    9 7 2 0 0 8 0 1 4
        	0 0 4 0 5 0 8 0 0
        	1 5 0 4 0 0 7 3 6
    	    5 0 3 9 7 2 4 6 8
        	4 6 9 8 3 5 2 0 1
        	8 2 7 0 1 4 9 5 3]

        solution = [ 7  4  1  5  9  6  3  8  2
            3  8  6  2  4  7  1  9  5
            2  9  5  1  8  3  6  4  7
            9  7  2  3  6  8  5  1  4
            6  3  4  7  5  1  8  2  9
            1  5  8  4  2  9  7  3  6
            5  1  3  9  7  2  4  6  8
            4  6  9  8  3  5  2  7  1
            8  2  7  6  1  4  9  5  3]

        @test sudoku_solver(sudoku) isa Array

        @test length(sudoku_solver(sudoku)) == 81
        
        @test sudoku_solver(sudoku) == solution
    end
end