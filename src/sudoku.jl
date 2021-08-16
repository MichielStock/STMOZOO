module SudokuSolver
    using Statistics
    export show_sudoku, sudoku_solver, block, fixed_values, nr_errors, fill_full, fixed_blocks, start_temp, decide

    """
        show_sudoku(sudoku)

    Shows sudoku with grid lines.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> show_sudoku(sudoku)
    741|590|382
    306|247|195
    295|183|607
    -----------
    972|008|014
    004|050|800
    150|400|736
    -----------
    503|972|468
    469|835|201
    827|014|953
    ```
    """
    function show_sudoku(sudoku)
        # Michiel: show 0 as a '-' or '.'?
    	for i in 1:9
	    	line = ""
		    if i == 4 || i == 7
			    println("-----------")
    		end
	    	for j in 1:9
		    	if j == 4 || j == 7
			    	line = line * "|"
    			end
	    		line = line * string(sudoku[i,j])
		    end
    		println(line)
	    end
    end

    """
        block(row, column, sudoku)

    Returns the block a certain position is located in. With blocks as the 3x3 subsections of the sudoku between the gridlines.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> block(1, 1, sudoku)
    3x3 Array{Int64,2}:
    741
    306
    295
    ```
    """
    function block(row, column, sudoku)
        # Michiel: adding the following checks gives errers, there is something wrong here!
        #@assert 1 ≤ row ≤ 3 BoundsError()
        #@assert 1 ≤ column ≤ 3 BoundsError()
        # Michiel: you can do this much more concisely, e.g. `range(3(row-1)+1, 3row, step=1)`
        # if you use `@view` you also don't take a copy of the block (more memory efficient)
	    if row in [1, 2, 3]
    		block = sudoku[1:3, :]
    	elseif row in [4 5 6]
	    	block = sudoku[4:6, :]
	    else
		    block = sudoku[7:9, :]
	    end
        
    	if column in [1, 2, 3]
	    	block = block[:, 1:3]
    	elseif column in [4 5 6]
	    	block = block[:, 4:6]
    	else
	    	block = block[:, 7:9]
    	end

	    return block
    end

    """
        freq_table(row)

    Makes a frequency table of a given row, column or block. Row can be any array.

    ## Examples

    ```julia-repl
    julia> row = [9 7 2 0 0 8 0 1 4]

    julia> freq_table(row)
    Dict{Any, Any}(
    7 => 1
    9 => 1
    0 => 3
    4 => 1
    2 => 1
    8 => 1
    1 => 1
    )

    ```
    """
    function freq_table(row)
        # Michiel: fine, but know that a bitarray would be *much* faster here
    	freqs = Dict()
	    for value in row
		    if haskey(freqs, value)
			    freqs[value] += 1
    		else
	    		freqs[value] = 1
		    end
    	end
	    return freqs
    end

    """
        duplicates(row)

    Searches for duplicates in a row, column or block. 0 values are ignored. Returns true if a duplicate is found.

    ## Examples

    ```julia-repl
    julia> row = [9 7 2 0 0 8 0 1 4]

    julia> duplicates(row)
    false

    julia> row2 = [9 7 2 0 9 8 0 1 4]

    julia> duplicates(row2)
    true
    ```
    """
    function duplicates(row)
        table = freq_table(row)
        for i in 1:9
            if haskey(table, i)
                if table[i] > 1
                    return true
                end
            end
        end
        return false
    end

    """
        valid(sudoku)

    Checks if a given array is a valid sudoku. Sudoku should be a 9x9 array, blanks are filled with zeros and rows, columns and blocks do not have duplicate values other than zero.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
    3 0 6 2 4 7 1 9 5
    2 9 5 1 8 3 6 0 7
    9 7 2 0 0 8 0 1 4
    0 0 4 0 5 0 8 0 0
    1 5 0 4 0 0 7 3 6
    5 0 3 9 7 2 4 6 8
    4 6 9 8 3 5 2 0 1
    8 2 7 0 1 4 9 5 3]

    julia> valid(sudoku)
    true

    julia> valid(3)
    false
    ```
    """
    function valid(sudoku)
        if size(sudoku) != (9, 9) # 9x9 array
            return false
        end
    
        for entry in keys(freq_table(sudoku)) # no values other than 0:9
            if !(entry in 0:9)
                return false
            end
        end
    
        for i in 1:9 # no repeated numbers in rows and columns
            if duplicates(sudoku[i,:])
                return false
            elseif duplicates(sudoku[:,i])
                return false
            end
        end
    
        for i in [1, 4, 7] # no repeats in blocks
            for j in [1, 4, 7]
                if duplicates(block(i,j,sudoku))
                    return false
                end
            end
        end
    
        return true
    end

    """
        fixed_values(sudoku)

    Returns an array indicating which values the sudoku started out whith (fixed values).
    Fixed positions are indicated with a 1, non-fixed values with a 0.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> fixed_values(sudoku)
    9×9 Array{Int64,2}:
     1  1  1  1  1  0  1  1  1
     1  0  1  1  1  1  1  1  1
     1  1  1  1  1  1  1  0  1
     1  1  1  0  0  1  0  1  1
     0  0  1  0  1  0  1  0  0
     1  1  0  1  0  0  1  1  1
     1  0  1  1  1  1  1  1  1
     1  1  1  1  1  1  1  0  1
     1  1  1  0  1  1  1  1  1
    ```
    """
    function fixed_values(sudoku)
        # michiel: why not sudoku .== 0 ? (or `!ismissing.(sudoku)` if you use a data type)
    	fixed = zero(sudoku)
	    for i in 1:9
		    for j in 1:9
			    if sudoku[i, j] != 0
				    fixed[i, j] = 1
    			end
	    	end
    	end
	    return fixed
    end

    """
        nr_errors(sudoku)

    Calculates the number of errors (repeated values in a row or column) are in a sudoku.
    Assumes that blocks have no repeat values.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7  4  1  5  9  6  3  8  2
        3  8  6  2  4  7  1  9  5
        2  9  5  1  8  3  6  4  7
        9  7  2  6  3  8  2  1  4
        3  6  4  1  5  7  8  5  9
        1  5  8  4  2  9  7  3  6
        5  1  3  9  7  2  4  6  8
        4  6  9  8  3  5  2  7  1
        8  2  7  6  1  4  9  5  3]
    
    julia> nr_errors(sudoku)
    10
    ```
    """
    function nr_errors(sudoku)
	    errors = 0
    	for i in 1:9
	    	errors += (9 - length(freq_table(sudoku[i,:])))
		    errors += (9 - length(freq_table(sudoku[:,i])))
    	end
	    return errors
    end

    """
        missing_nr(block)

    Finds numbers (1-9) not yet in block.

    ## Examples

    ```julia-repl
    julia> block =  [7  4  1
    3  0  6
    2  9  5]

    julia> missing_nr(block)
    1-element Array{Any,1}:
    8
    ```
    """
    function missing_nr(block)
    	freqs = freq_table(block)
	    values =  []
    	for value in 1:9
	    	if !haskey(freqs, value)
		    	append!(values, value)
    		end
	    end
	    return values
    end

    """
        pick(list)

    Returns a random value from list(value) and the input list without the picked value (list).

    ## Examples

    ```julia-repl
    julia> list = [9, 7, 2, 0, 9, 8, 0, 1, 4]

    julia> pick(list)
    (2, [9, 7, 0, 9, 8, 0, 1, 4])
    ```
    """
    function pick(list)
        # Michiel: alternative: i = rand(1:length(list)); value = popat!(list, i)
		value = rand(list)
    	deleteat!(list, findfirst(x -> x==value, list))
	    return value, list
    end

    """
    fill_block(block)

    Fills a block randomly with non-repeated numbers from 1 to 9.

    ## Examples

    ```julia-repl
    julia> block =  [7  4  1
    3  0  6
    2  9  5]

    julia> fill_block(block)
    3×3 Array{Int64,2}:
     7  4  1
     3  8  6
     2  9  5
    ```
    """
    function fill_block(block)
    	values = missing_nr(block)
	    for (i, v) in enumerate(block)
		    if v == 0
			    nr, values = pick(values)
    			block[i] = nr
	    	end
    	end
    	return block
    end

    """
        fill_full(sudoku)

    Fills all empty spaces of a sudoku at random (numbers between 1 and 9). Numbers are not repeated within a block, but there are repeats in rows and columns.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]
    
    julia> fill_full(sudoku)
    9×9 Array{Int64,2}:
     7  4  1  5  9  6  3  8  2
     3  8  6  2  4  7  1  9  5
     2  9  5  1  8  3  6  4  7
     9  7  2  6  3  8  2  1  4
     3  6  4  1  5  7  8  5  9
     1  5  8  4  2  9  7  3  6
     5  1  3  9  7  2  4  6  8
     4  6  9  8  3  5  2  7  1
     8  2  7  6  1  4  9  5  3
    ```
    """
    function fill_full(sudoku)
    	filled = zero(sudoku)
	    for i in [1, 4, 7]
		    for j in [1, 4, 7]
			    fullblock = fill_block(block(i,j,sudoku))
    			filled[i:i+2, j:j+2] = fullblock
	    	end
    	end
	    return filled
    end

    """
        not_fixed(fixed)

    Returns an array of positions with non-fixed values. Non-fixed values are the blank (0) values in the start sudoku. Starts from the result of the fixed_values function. 

    ## Examples

    ```julia-repl
    julia> fixed = [ 1  1  1  1  1  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  0  1  0  1  1
        0  0  1  0  1  0  1  0  0
        1  1  0  1  0  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  1  1  1  1  1]

    julia> not_fixed(fixed)
    18-element Array{Any,1}:
     5
     11
     14
     16
     24
     31
     32
     36
     40
     42
     46
     50
     51
     58
     66
     68
     71
     77
    ```
    """
    function not_fixed(fixed)
        # Michiel: findall(isequal(0), sudoku) / findall(ismissing, sudoku) 
    	nonfixed = []
	    for (i, v) in enumerate(fixed)
		    if v == 0
			    append!(nonfixed, i)
    		end
	    end
    	return nonfixed
    end

    """
        block_nr_ind(nr)

    Blocks are numbered from 1 to 9, from top to bottom and left to right.
    This function returns an index within that block. Row and column will be 3, 6 or 9.

    ## Examples

    ```julia-repl
    julia> block_nr_ind(3)
    (9, 3)
    ```
    """
    function block_nr_ind(nr)
        row = (mod(nr-1, 3) + 1) * 3
        column = (div(nr-1, 3) + 1) * 3
        return row, column
    end

    """
        fixed_blocks(fixed)

    Lists blocks that have more than 2 non-fixed positions. Blocks are numbered from 1 to 9, from top to bottom and left to right.

    ## Examples

    ```julia-repl
    julia> fixed = [ 1  1  1  1  1  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  0  1  0  1  1
        0  0  1  0  1  0  1  0  0
        1  1  0  1  0  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  1  1  1  1  1]

    julia> fixed_blocks(fixed)
    Any
    2
    5
    8
    ```
    """
    function fixed_blocks(fixed)
        blocks = Int[]
        for i in 1:9
            row, col = block_nr_ind(i)
            # Michiel: you might make this faster using the function `count`
            nonfixed = not_fixed(block(row, col, fixed))
            if length(nonfixed) > 2
                append!(blocks, i)
            end
        end
        return blocks
    end

    """
        possible_swap(fixed)

    Generates a list of blocks with more than two non-fixed positions and a dictionary of
    possible positions to swap. Keys are the block numbers used in fixed_blocks.

    ## Examples

    ```julia-repl
    julia> fixed = [ 1  1  1  1  1  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  0  1  0  1  1
        0  0  1  0  1  0  1  0  0
        1  1  0  1  0  0  1  1  1
        1  0  1  1  1  1  1  1  1
        1  1  1  1  1  1  1  0  1
        1  1  1  0  1  1  1  1  1]

    julia> possible_swap(fixed)
    (Any[2, 5, 8], Dict{Any,Any}(2 => Any[2, 5, 9],5 => Any[1, 2, 4, 6, 8, 9],8 => Any[1, 5, 8]))
    ```
    """
    function possible_swap(fixed)
        blocks = fixed_blocks(fixed)
        possible = Dict{Int, Vector{Int}}()  #michiel: Type stability
        for i in blocks
            row, col = block_nr_ind(i)
            possible[i] = not_fixed(block(row, col, fixed))
        end
        return blocks, possible
    end

    """
        swap(sudoku, fixed, blocks, possible)

    Randomly swaps the values of two non-fixed positions within the same (random) block. Generates a new state.
    ```
    """
    function swap(sudoku, fixed, blocks, possible)
        # Michiel: fixed is not used here?
    	blocknr = rand(blocks) # random block where positions can be swapped
        row, col = block_nr_ind(blocknr)
        nrblock = block(row, col, sudoku)
        nonfixed = copy(possible[blocknr])
    	pos1, nonfixed = pick(nonfixed) # Select random positions
	    pos2, nonfixed = pick(nonfixed)
    	temp = nrblock[pos1] # Swap values
	    nrblock[pos1] = nrblock[pos2]
    	nrblock[pos2] = temp
	    sudoku[row-2:row, col-2:col] = nrblock # Replace selected block in sudoku
    	return sudoku
    end

    """
        start_temp(sudoku)

    Chooses a starting temperature by taking the standard deviation of the errors of 50 starting states.
    Returns the best of these stating states as a starting point.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> start_temp(sudoku)
    (
    3.0445
    9×9 Array{Int64,2}:
    9  5  1  2  7  3  8  4  3
    3  8  4  1  5  8  2  7  6
    6  7  2  6  4  9  5  1  9
    1  3  9  7  6  8  4  2  5
    2  8  4  3  1  5  9  6  7
    5  6  7  4  9  2  1  3  8
    4  9  3  7  5  8  6  5  2
    8  2  6  6  3  4  7  9  1
    7  1  5  9  2  1  3  8  4
    )
    ```
    """
    function start_temp(sudoku)
    	errorscores = []
        bestscore = 80
        best = []
    	for i in 1:50
    		state = fill_full(sudoku)
            score = nr_errors(state)
            if score < bestscore
                bestscore = score
               best = state
            end
		    append!(errorscores, nr_errors(state))
	    end
	    return std(errorscores), best 
    end

    """
        decide(diff, T)

    Decides whether a new state is used or discarded. Diff is the difference in amount of errors between the new and old states.
    """
    decide(diff, T) = rand() < exp(-diff/T)


    """
        sudoku_solver(sudoku)

    Solves a given sudoku using Simulated Annealing. Sudoku should be a 9x9 array, blanks are filled with zeros and rows, columns and blocks do not have duplicate values other than zero.

    ## Examples

    ```julia-repl
    julia> sudoku =  [7 4 1 5 9 0 3 8 2
	    3 0 6 2 4 7 1 9 5
    	2 9 5 1 8 3 6 0 7
    	9 7 2 0 0 8 0 1 4
    	0 0 4 0 5 0 8 0 0
    	1 5 0 4 0 0 7 3 6
    	5 0 3 9 7 2 4 6 8
    	4 6 9 8 3 5 2 0 1
    	8 2 7 0 1 4 9 5 3]

    julia> sudoku_solver(sudoku)
    741|590|382
    306|247|195
    295|183|607
    -----------
    972|008|014
    004|050|800
    150|400|736
    -----------
    503|972|468
    469|835|201
    827|014|953
    741|596|382
    386|247|195
    295|183|647
    -----------
    972|368|514
    634|751|829
    158|429|736
    -----------
    513|972|468
    469|835|271
    827|614|953
    ```
    """
    function sudoku_solver(sudoku)
        if !valid(sudoku)
            error("Input is not a valid sudoku")
        end
        # Michiel: please add the parameters as optional keyword arguments
    	solved = 0
	    cooling = 0.99
    	stuck = 0
        restart = 0
    	show_sudoku(sudoku)
	    fixed = fixed_values(sudoku)
    	T0, filled = start_temp(sudoku)
        T = T0
        blocks, possible = possible_swap(fixed)
	    errors = nr_errors(filled)
    	iterations = 81 - sum(fixed)
	    state = filled
        best = filled
        bestscore = 90
	
    	if errors == 0
	    	solved = 1
	    end
	
    	while solved == 0
	    	lastscore = errors
		    for i in 1:iterations
			    newstate = swap(state, fixed, blocks, possible)
    			newerrors = nr_errors(newstate)

	    		if newerrors == 0
		    		solved = 1
			    	break
    			end

	    		diff = newerrors - errors
		    	if diff <= 0
			    	state = newstate
				    errors = newerrors
                    if errors < bestscore
                        best = state
                        bestscore = errors
                    end
    			else
	    			kept = decide(diff, T)
		    		if kept
			    		state = newstate
				    	errors = newerrors
    				end
	    		end
		    end
		
    		T *= cooling
	    	if errors == 0
		    	solved = 1
			    break
    		end
		
	    	if errors >= lastscore
			    stuck += 1
		    else
    			stuck = 0
	    	end
    
            if stuck > 1000 # When running too long:
                restart +=1
                if restart > 20 # Return to best solution
                    state = best
                    errors = bestscore
                    restart = 0
                    stuck = 0
                else
                    T += T0/3 # Or increase temperature
                    stuck = 0
                end
            end
    	end
    
    	show_sudoku(state)
	    return state
    end
end
