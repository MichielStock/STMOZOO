module LocalSearch
using Plots

export fill_in, check_value, sudoku_cost, sudoku_greedydesc, flip, fliprow, makeflip, makefliprow, search, show_sudoku 

"""
    show_sudoku(sudoku::Matrix)
    Print a sudoku grid with a nice format
"""
function show_sudoku(sudoku)
	xloc = [0.19,0.5,0.8,1.19,1.5,1.8,2.19,2.5,2.8] # x-axis locations (left to right)
    yloc = [2.8,2.5,2.19,1.8,1.5,1.19,0.8,0.5,0.19] # y-axis locations (up to down)
    # plot grid
	vline([0,1,2,3],color = "black",axis = false,ticks = false, lim = [0,9], legend = false,width = 2)
    hline!([0,1,2,3],color = "black",width = 2)
	vline!([0.33,0.66,1.33,1.66,2.33,2.66],color = "black",width = 0.5)
    hline!([0.33,0.66,1.33,1.66,2.33,2.66],color = "black",width = 0.5)
    # plot numbers
    # I tried this with a for-loop but then there is no plot shown, I don't know why...
	annotate!(xloc[1],yloc,sudoku[:,1])
	annotate!(xloc[2],yloc,sudoku[:,2])
	annotate!(xloc[3],yloc,sudoku[:,3])
	annotate!(xloc[4],yloc,sudoku[:,4])
	annotate!(xloc[5],yloc,sudoku[:,5])
	annotate!(xloc[6],yloc,sudoku[:,6])
	annotate!(xloc[7],yloc,sudoku[:,7])
	annotate!(xloc[8],yloc,sudoku[:,8])
	annotate!(xloc[9],yloc,sudoku[:,9])
end

"""
    fill_in(sudoku::Matrix)

Fills a sudoku with non-repeated random numbers per row,
so each row has all numbers from 1 to 9.
"""
function fill_in(sudoku::Matrix)
    grid = deepcopy(sudoku)
    for i = 1:9
      row = grid[i,:]
      missing_entries = Set(findall(row .== 0))
      for n = 1:9
          if !(n in row)
                  ms = rand(missing_entries)
                  grid[i, ms] = n
                  delete!(missing_entries, ms)
              end
      end
    end
    grid
  end

""" 
    check_value(sudoku, val_i::Int, val_j::Int, value =nothing)

Gives the number of repetitions in row, column and subgrid for a number in position [val_i, val_j] in the sudoku
it is used to check if a particular number meets the sudoku constraints.
It takes as inputs a filled sudoku grid, two coordinates of the evaluated position (row, column) and an optional argument.
If the optional argument is given then it will return the number of constrains violations when this value is placed in the input position. 
"""
function check_value(sudoku::Matrix, val_i::Int, val_j::Int, val = sudoku[val_i, val_j])
  
    constr = 0.0
    #for a particular position [val_i][val_j] how many repetions are in the row.
    for j in 1:length(sudoku[val_i,:])
        if sudoku[val_i, val_j] != 0 && sudoku[val_i, j] == val && j != val_j 
            constr += 1
        end
    end
    #for a particular position [val_i][val_j] how many repetions are in the column.
    for i in 1:length(sudoku[val_j,:])
        if sudoku[val_i, val_j] != 0 && sudoku[i, val_j] == val && i != val_i 
            constr += 1
        end
    end
    #for a particular position [val_i][val_j] how many repetions are in the subgrid.
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
            if (i, j) != (val_i, val_j) && sudoku[i, j] != 0 && sudoku[i, j] == val
                constr += 1
            end
        end
    end
    return Int(constr)
end

""" 
    sudoku_cost(sudoku::Matrix)

Returns the total number of constraints violations in the sudoku,
Ex. if a number is found two times in a row the cost will be 4 (2 for each number).
"""
function sudoku_cost(sudoku::Matrix)
    total_cost = 0
    for i in 1:9
        for j in 1:9
            total_cost += check_value(sudoku, i, j)
        end
    end
    return Int(total_cost)
end

"""" 
    sudoku_greedydesc(sudoku::Matrix, empty::Matrix, max_iter::Int)

Selects a random position in the sudoku and changes its number with a different random number, 
if the number of constraints violations increase, tries another random, otherwise, 
assigns the new number to that position. Then repeats the same process 'max_iter' times
"""
function sudoku_greedydesc(sudoku::Matrix, empty::Matrix, max_iter::Int)
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
        if empty[rand_i, rand_j] != 0
            continue
        end
        #check which number in [0:9] decrease the number of conflicts and assign it to the current position 
        for new_val in Set(1:9)
            if check_value(board, rand_i, rand_j) >= check_value(board, rand_i, rand_j, new_val)
                board[rand_i, rand_j] = new_val
            end
        end
        i += 1
    end
    
    return board, Int(total_cost)
end 

""" 
    flip(sudoku::Matrix, empty::Matrix) 

Randomly selects two positions in the sudoku and makes a swap. 
Returns the new sudoku and the indices of changed positions
"""
function flip(sudoku::Matrix, empty::Matrix)
    (i1, j1, i2, j2) = (rand(1:9), rand(1:9), rand(1:9), rand(1:9))
    res = deepcopy(sudoku)
    while empty[i1, j1] != 0 || empty[i2, j2] != 0
        (i1, j1, i2, j2) = (rand(1:9), rand(1:9), rand(1:9), rand(1:9))
    end
    (res[i1,j1], res[i2,j2]) = (res[i2,j2], res[i1,j1])
    return res, (i1,j1), (i2,j2)
end

"""
    fliprow(sudoku::Matrix, empty::Matrix) 

Randomly selects two positions in the same row in the sudoku and makes a swap. 
Returns the new sudoku and the indices of changed positions
"""
function fliprow(sudoku::Matrix, empty::Matrix)
    (i1, j1, j2) = (rand(1:9), rand(1:9), rand(1:9))
    res = deepcopy(sudoku)
    while empty[i1, j1] != 0 || empty[i1, j2] != 0
        (i1, j1, j2) = (rand(1:9), rand(1:9), rand(1:9))
    end
    (res[i1,j1], res[i1,j2]) = (res[i1,j2], res[i1,j1])
    return res, (i1,j1), (i1,j2)
end

"""" 
    makeflip(sudoku::Matrix, empty::Matrix, max_iter::Int)

Evaluates if the swap make by 'flip' function increased/decreased the total cost of the sudoku, if increase,
doesnt make the swap and selects another swap, otherwise makes the swap. 
Repeat the process 'max_iter' times
"""
function makeflip(sudoku::Matrix, empty::Matrix, max_iter::Int)
    resp = deepcopy(sudoku)
    i = 0
    while i < max_iter
        resp2, pos1, pos2 = flip(resp, empty)
        if sudoku_cost(resp2) <= sudoku_cost(resp)
            (resp[pos1[1], pos1[2]], resp[pos2[1],pos2[2]]) = (resp[pos2[1], pos2[2]], resp[pos1[1],pos1[2]]) 
        else
            (resp2[pos1[1], pos1[2]], resp2[pos2[1], pos2[2]]) = (resp2[pos2[1], pos2[2]], resp2[pos1[1], pos1[2]])
        end
        i +=1
    end
    return resp
end

"""" 
    makefliprow(sudoku::Matrix, empty::Matrix, max_iter::Int)

Evaluates if the swap made by 'flip_row' function increased/decreased the total cost of the sudoku, if increase,
doesnt make the swap and selects another swap, otherwise makes the swap. 
Repeat the process 'max_iter' times
"""
function makefliprow(sudoku::Matrix, empty::Matrix, max_iter::Int)
    resp = deepcopy(sudoku)
    i = 0
    while i < max_iter
        resp2, pos1, pos2 = fliprow(resp, empty)
        if sudoku_cost(resp2) <= sudoku_cost(resp)
            (resp[pos1[1], pos1[2]], resp[pos2[1],pos2[2]]) = (resp[pos2[1], pos2[2]], resp[pos1[1],pos1[2]]) 
        else
            (resp2[pos1[1], pos1[2]], resp2[pos2[1], pos2[2]]) = (resp2[pos2[1], pos2[2]], resp2[pos1[1], pos1[2]])
        end
        i +=1
    end
    return resp
end

"""" 
    search(sudoku::Matrix, max_repl::Int, max_flips::Int)

Takes an empty Sudoku, and search for the solution that minimizes the number of constraint violations
To find the solution the search must be done at least 1000 times. This algorithm is not efficient.
"""
function search(sudoku::Matrix, max_repl::Int, max_flips::Int)
    @assert length(sudoku[1,:]) == length(sudoku[:,1]) == 9 "Sudoku must be 9x9"
    grid = fill_in(sudoku)
    sol, cost = sudoku_greedydesc(grid, sudoku, max_repl)
    if cost == 0
        return sol, cost
    else res = makeflip(sol, sudoku, max_flips)
    end
    return res
end

include("print_sudoku.jl")
include("examples.jl")
end #module