module Local_search

export fill_in, check_value, sudoku_cost, sudoku_greedydesc, fixvars, flip, make_flip 

"""Fill a sudoku with non-repeated random numbers per row,
so each row has all numbers from 1 to 9"""
function fill_in(sudoku)
    grid = deepcopy(sudoku)
    for i = 1:9
      row = grid[i]
      missing_entries = Set(findall(row .== 0))
      for n = 1:9
          if !(n in row)
                ms = rand(missing_entries)
                grid[i][ms] = n
                delete!(missing_entries, ms) 
            end
      end
    end
    grid
end

""" Gives the number of repetitions in row, column and subgrid for a number in the position [val_i][val_j] in the sudoku """
function check_value(sudoku, val_i, val_j, value = nothing)
  
    if value == nothing
        val = sudoku[val_i][val_j]
    else
        val = value
    end
    
    constr = 0.0
    #cheking for a particular position [val_i][val_j] how many repetions are in the row.
    for j in 1:length(sudoku)
        if sudoku[val_i][val_j] != 0 && sudoku[val_i][j] == val && j != val_j 
            constr += 1
        end
    end
    #cheking for a particular position [val_i][val_j] how many repetions are in the column.
    for i in 1:length(sudoku)
        if sudoku[val_i][val_j] != 0 && sudoku[i][val_j] == val && i != val_i 
            constr += 1
        end
    end
    #cheking for a particular position [val_i][val_j] how many repetions are in the subgrid.
    sqrt_n = isqrt(length(sudoku))
    x_i = val_i/3
    x_j = val_j/3
    #create subgrid indices
    if x_i <=1
        bloq_i = 1
        vars_i = [1, 2, 3]
    elseif 1 < x_i <= 2
        bloq_i = 2
        vars_i = [4, 5, 6]
    else
        bloq_i = 3
        vars_i = [7, 8, 9]
    end 

    if x_j <=1
        bloq_j = 1
        vars_j = [1, 2, 3]
    elseif 1 < x_j <= 2
        bloq_j = 2
        vars_j = [4, 5, 6]
    else
        bloq_j = 3
        vars_j = [7, 8, 9]
    end 
    #looping over each element in the subgrid
    for i in vars_i
        for j in vars_j
            if (i, j) != (val_i, val_j) && sudoku[i][j] != 0 && sudoku[i][j] == val
                constr += 1
            end
        end
    end
    return constr
end

""" return the total number of constraints violations in the sudoku"""
function sudoku_cost(sudoku)
    total_cost = 0
    for i in 1:length(sudoku)
        for j in 1:length(sudoku)
            total_cost += check_value(sudoku, i, j)
        end
    end
    return total_cost
end

"""Return the indices of the fixed numbers in the sudoku board """
function fixvars(sudoku)
    fixed_vars = Set()
    for i in 1:9
        for j in 1:9
            if sudoku[i][j] != 0
                push!(fixed_vars, (i,j))
            end
        end
    end
    return fixed_vars
end

"""" Selects a random position in the sudoku, and changes its number with a different random number, 
if the number of constraints violations increased, tries another random, otherwise, 
assigns the new number to that position. Then repeats the same process 'max_iter' times"""
function sudoku_greedydesc(sudoku, fixed_vars, max_iter)
    board = deepcopy(sudoku)
    i = 0
    while i < max_iter
        global total_cost
        #calculate number of conflicts
        total_cost = sudoku_cost(board)
        #check if there are no repeated numbers return the solution
        if total_cost == 0
            return board, 0
        end
        
        #Select random position to change
        rand_i = rand(1:9)
        rand_j = rand(1:9)
        
        #check if that position is in fixed variables, if true then randomly select another position
        if (rand_i, rand_j) in fixed_vars
            continue
        end
        #check which number in [0:9] decrease the number of conflicts and assign it to the current position 
        for new_val in Set(1:9)
            if check_value(board, rand_i, rand_j) >= check_value(board, rand_i, rand_j, new_val)
                board[rand_i][rand_j] = new_val
            end
        end
        i += 1
    end
    
    return board, total_cost
end 

""" Randomly selects two positions in the sudoku and makes a swap. 
Returns the new sudoku and the changed positions"""
function flip(grid, fixed_vars)
    (i1, j1, i2, j2) = (rand(1:9), rand(1:9), rand(1:9), rand(1:9))
    res = deepcopy(grid)
    while (i1, j1) in fixed_vars || (i2, j2) in fixed_vars
        (i1, j1, i2, j2) = (rand(1:9), rand(1:9), rand(1:9), rand(1:9))
    end
    (res[i1][j1], res[i2][j2]) = (res[i2][j2], res[i1][j1])
    return res, (i1,j1), (i2,j2)
end

"""" Evaluates if the swap increased/decreased the cost of the sudoku, if increase,
doesnt make the swap and selects another swap, otherwise makes the swap. 
Repeat the process 'max_iter' times"""
function make_flip(sudoku, fixed_vars, max_iter)
    resp = deepcopy(sudoku)
    i = 0
    while i < max_iter
        resp2, pos1, pos2 = flip(resp, fixed_vars)
        if sudoku_cost(resp2) <= sudoku_cost(resp)
            (resp[pos1[1]][pos1[2]], resp[pos2[1]][pos2[2]]) = (resp[pos2[1]][pos2[2]], resp[pos1[1]][pos1[2]]) 
        else
            (resp2[pos1[1]][pos1[2]], resp2[pos2[1]][pos2[2]]) = (resp2[pos2[1]][pos2[2]], resp2[pos1[1]][pos1[2]])
        end
        i +=1
    end
    
    return resp
end