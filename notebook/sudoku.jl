### A Pluto.jl notebook ###
# v0.14.7

using Markdown
using InteractiveUtils

# ╔═╡ 5ad5c202-20f8-11eb-23f1-4f38b687c285
import Pkg

# ╔═╡ d2d007b8-20f8-11eb-0ddd-1181d4565a85
Pkg.activate("./Sarah/sudoku.jl")

# ╔═╡ 13c11517-1774-4ba7-add1-b84051860488
using Main.workspace2.SudokuSolver

# ╔═╡ f9f5eff0-16f9-4167-bc93-a6321abfd4cf
using PlutoUI

# ╔═╡ 6ecc9370-3cc7-400b-a6d8-3fd704c40984
include("C:/Users/Sarah/sudoku.jl/src/sudoku.jl")

# ╔═╡ 171fee18-20f6-11eb-37e5-2d04caea8c35
md"""
# Sudoku: Simulated annealing

By Sarah Laperre

## Introduction

Sudoku is probably the best known puzle game. Because simple rules and a variety of puzzles evrywhere, most people know hot solve them. In this project, I will take a look at one algorithm used for solving sudokus: simulated annealing. But first a short introduction to sudoku.

### A short history
Contrary to popular belief, sudoku does not originate from Japan, but from France. In the 19th centuryfirst sudoku-like puzzles appeared in newspapers. It was called "carré magique diabolique", and was a magic square with certain numbers removed. A magic square is a number-filled square where ueach of the rows, columns and diagonals adds up to the same number. It was later renamed to "Number Place" and simplified, resulting in the current rules. The puzzle became popular when it was renamed to sudoku, meaning single number, by a japanese puzzle company. In 2004, a program was made to genrate sudokus with unique solutions. Even now, sudokus are still linked to newspapers.

### The rules
Many sudoku variants exist, with different characters, grid sizes, additional constraints or blocks with different shapes. Here, only the original 9x9 sudoku will be considered.

A sudoku is a 9x9 grid, divided in 9 3x3 regions, called blocks. within the grid, some positions will already be filled. These filled positions will be referred to as fixed positions. The goal is to fill all empty positions, in such a way that every row, column and block contains the numbers 1 till 9 once.

It has been proven that there are at least 17 fixed positions needed for a sudoku to have a uniqe solution. There are $$6.67 * 10^{21}$$ different ways to fill a 9x9 sudoku grid.
"""

# ╔═╡ 38c3a299-b597-40aa-abbf-71afde17f26d
md"""
## Exploring sudokus

Sudokus level 1 till 3 will be used as explanation. Level 4 till 6 can be used to try some different sudokus, and blank can be used as a template for different sudokus.

To use as input, sudokus are represented by an array, with blanks filled by a zero.
"""

# ╔═╡ 7a25aac1-c7b2-4a94-81da-9325c30a0336
lvl1 =  [4 9 2 8 1 7 3 6 5
	8 1 3 5 6 4 7 9 0
	6 7 5 9 2 3 4 8 1
	9 5 4 0 8 1 2 3 7
	2 0 1 3 0 9 6 0 4
	7 3 6 2 4 0 8 1 9
	5 2 9 7 3 6 1 4 8
	0 4 8 1 5 2 9 7 6
	1 6 7 4 9 8 5 2 0]

# ╔═╡ ec046206-68a9-406d-a2ac-11ffdb2dee82
lvl2 =  [7 4 1 5 9 0 3 8 2
	3 0 6 2 4 7 1 9 5
	2 9 5 1 8 3 6 0 7
	9 7 2 0 0 8 0 1 4
	0 0 4 0 5 0 8 0 0
	1 5 0 4 0 0 7 3 6
	5 0 3 9 7 2 4 6 8
	4 6 9 8 3 5 2 0 1
	8 2 7 0 1 4 9 5 3]

# ╔═╡ cd1397a7-30ed-4542-993a-67548895691d
lvl3 =  [0 5 1 0 0 0 8 4 0
	3 8 4 0 5 0 2 7 6
	6 7 2 0 0 0 5 1 9
	1 3 9 7 0 8 4 2 5
	2 0 0 3 1 5 0 0 7
	5 6 7 4 0 2 1 3 8
	4 9 3 0 0 0 6 5 2
	8 2 6 0 3 0 7 9 1
	0 1 5 0 0 0 3 8 0]

# ╔═╡ 51464e74-c439-49f4-802c-9dba8e5fcadc
lvl4 =  [0 7 4 0 0 0 1 6 0
	8 0 6 0 0 0 2 0 5
    0 1 5 0 7 0 8 3 0
	0 0 3 8 0 6 7 0 0
	0 2 0 0 0 0 0 5 0
	0 0 9 2 0 3 4 0 0
	0 3 2 0 6 0 5 8 0
	9 0 8 0 0 0 6 0 1
	0 6 7 0 0 0 9 2 0]

# ╔═╡ 9cc0129e-3122-41b6-8d3f-ed0dd5420da4
lvl5 =  [7 6 3 9 4 1 0 5 8
	9 0 5 0 0 0 0 0 7
	0 0 0 0 0 5 0 6 9
	2 0 4 0 3 0 0 0 5
	5 0 0 7 0 8 0 0 3
	6 0 0 0 5 0 8 0 1
	3 7 0 5 0 0 0 0 0
	8 0 0 0 0 0 1 0 4
	4 9 0 3 8 2 5 7 6]

# ╔═╡ f991f1de-a92d-45e0-8294-44715e616e6c
lvl6 =  [2 0 0 0 5 0 0 0 6
	0 9 0 7 6 0 0 2 0
	0 0 6 0 0 0 3 0 0
	0 0 0 4 3 7 0 5 0
	7 6 0 9 0 5 0 3 8
	0 5 0 6 8 2 0 0 0
	0 0 1 0 0 0 8 0 0
	0 2 0 0 4 9 0 7 0
	3 0 0 0 7 0 0 0 9]

# ╔═╡ 45587b5d-86c9-436f-a573-03a8fdb68ebb
blank = [0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0]

# ╔═╡ 24d2d6e2-5283-4700-9459-6b84b3f80c4f
md"""
The fuction show_sudoku(sudoku) can be used to make this look more like an actual sudoku.
"""

# ╔═╡ eb18ffab-3c45-4bd6-af6a-1c7b422f14bc
with_terminal() do
	show_sudoku(lvl1)
end

# ╔═╡ 9556bf81-9486-4b00-8f82-18febb29e22e
with_terminal() do
	show_sudoku(lvl2)
end

# ╔═╡ f307ed1d-28a8-4896-9931-f004e11cffd5
with_terminal() do
	show_sudoku(lvl3)
end

# ╔═╡ fb4aeb8c-20f7-11eb-0444-259de7b76883
md"""

## Simulated annealing

Simulated annealing is used to find global optima in large, but discrete search spaces. Its uses include solving the travelling salesman problemSince the goal with sudoku is to find a single solution among many possibilities, simulated annealing can be used as a solver. However, it is better at finding an aproximate global optimum than a pricize local optimum. Simulated annealing falls into somewhat of a grey zone between local and global seach. As such it seemed interesting to find out how well SA performs when solving a sudoku. 

Annealing is a method in matalwork, where the speed by which the metal cools is controlled. This results in fewer defects, because the material forms a larger crystal structure. 

Similarly, in simulated annealing, you start with a certain temperature. This temperature represents the chance that a step with a worse score (more errors) is accepted. A high temperature means a higher acceptance for mistakes. As the program runs, the temperature gets lower (cools down) and fewer errors are accepted. This means that the search is more global with higher temperatures, but becomes more local as the temperature decreases;

## SA for sudokus

SA works by comparing 2 different neighbouring states. For sudokus, these are randomly filled out grids, with 2 positions swapped in one of the states. To compare the states, the number of errors in rows and columns are counted. If there are less errors in the new state, it is accepted automatically. When the new state has more errors, it is accepted or rejected depending on the temperature.

### Getting started
As such, the first step was to fill the sudoku with random numbers.

The filled sudoku looks as follows:
"""

# ╔═╡ f40d46d6-c022-4ee5-aa06-99439e69f5f9
filledlvl2 = fill_full(lvl2)

# ╔═╡ fdd4e550-20f8-11eb-227b-25f36708484d
with_terminal() do
	show_sudoku(filledlvl2)
end

# ╔═╡ ca79bf63-af4d-46a3-9ef7-ce04c404fcfd
md"""
Notice that each block contains all numbers from 1 till 9. Because it would be cumbersome to count errors within the blocks, the sudoku is randomly filled block by block and swaps occur within the blocks. This way, blocks contain all numbers from the start, and this remains throughout the program.

Since it is not clear in the filled sudoku which positions are fixed, a separate array is formed to keep track of these positions.
"""

# ╔═╡ acb21fa7-64e8-4a6b-ad00-d64b33252cb0
fixedlvl2 = fixed_values(lvl2)

# ╔═╡ 025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
with_terminal() do
	show_sudoku(fixedlvl2)
end

# ╔═╡ 096eff98-20f9-11eb-1e61-99d5714895ba
md"""
Since there are blocks with less than 2 non-fixed positions, we need to identify these positions from the start. In these cases, the block will already be solved by now. From the blocks with more non-fixed positions, 1 will be chosen at random in each iteration. From this block 2 non-fixed positions will be chosen, again at random, and swapped to create a new neighbouring state.
"""

# ╔═╡ 165509ca-20f9-11eb-107c-550cbba0f0e9
fixed_blocks(fixedlvl2)

# ╔═╡ 1fffc82a-20f9-11eb-198c-c160d7dac87d
md"""
For the lvl2 sudoku, there are 3 blocks where positions can be swapped. Blocks are numbered as follows:

1 4 7

2 5 8

3 4 9


Block 1 has no positions that can be swapped and will be solved in het filled sudoku.
"""

# ╔═╡ 26ab6ce2-20f9-11eb-1836-1756b290e5e3
md"No more need to remember the formulla for the minimizer! Just use `solve_quadratic_system`!"

# ╔═╡ 49832a8e-20f9-11eb-0841-19a40a12db18
block(1, 1, lvl2)

# ╔═╡ 9c369269-b5af-4fcf-955c-7609f55f43a6
block(1, 1, filledlvl2)

# ╔═╡ 55e0e274-20f9-11eb-36c0-753f228f7e9b
md"""
Comparing fixed positions in blocks 2 and 5 reveals a disadvantage of picking a random block: even though block 2 has fewer positions that can be switched, the block is still picked just as often. This results in a longer runtime.
"""

# ╔═╡ 2a520041-4a9e-458d-8d06-f67b51143aab
block(4, 1, fixedlvl2) # block 2

# ╔═╡ 6731c4f5-c6d3-4efc-a982-80cbe1ffd357
block(4, 4, fixedlvl2) # block 5

# ╔═╡ b1551758-20f9-11eb-3e8f-ff9a7127d7f8
md"""
### Calculating errors
The following function is used to caculate the amount of errors in a given state.
"""

# ╔═╡ 45189a82-20fa-11eb-0423-05ce1b84639d
function nr_errors(sudoku)
	errors = 0
  	for i in 1:9
    	errors += (9- length(freq_table(sudoku[i,:])))
	    errors += (9- length(freq_table(sudoku[:,i])))
   	end
    return errors
end

# ╔═╡ 41d8f1dc-20fa-11eb-3586-a989427c1fd6
SudokuSolver.nr_errors(filledlvl2)

# ╔═╡ 4ed4215e-20fa-11eb-11ee-f7741591163c
md"""
### Determining starting temperature

A good starting temperature is calculated from the standard deviation of 50 starting states. Since 50 starting states need to be generated anyway, I opted to keep track of these starting states, and return the best one to start from. For easy sudokus like lvl1, this can already solve the sudoku.
"""

# ╔═╡ 6c5473b4-20fa-11eb-327b-51ac560530eb
T0lvl1, bestlvl1 = start_temp(lvl1)

# ╔═╡ d3b42073-d0de-43f3-8627-f9b350fa5167
SudokuSolver.nr_errors(bestlvl1)

# ╔═╡ 252903c4-8aa3-40aa-b9cd-8fbd00c13953
md" For lvl2"

# ╔═╡ 91a5cbbf-dd94-4786-b65b-6755c7f76804
T0lvl2, bestlvl2 = start_temp(lvl2)

# ╔═╡ 3639da42-6a95-4df9-b777-9cf68758a6b0
SudokuSolver.nr_errors(bestlvl2)

# ╔═╡ 1d3d599f-78c3-4d9f-ac2b-e9d81b086836
md" For lvl3"

# ╔═╡ 8b4ea346-9bed-4889-bc7e-e0795a212812
T0lvl3, bestlvl3 = start_temp(lvl3)

# ╔═╡ 134bf884-c7eb-4fb3-b993-71ae40133cd2
SudokuSolver.nr_errors(bestlvl3)

# ╔═╡ 7518c2c0-20fa-11eb-32c0-a9db2a91cbc5
md"""
### Deciding if a worse state is kept
Following function is the core of how SA works. If a state has more errors than the last, this dicides whether or not it is accepted. It is only dependent on the difference in errors (diff) and the current temperature.
"""

# ╔═╡ 34027942-20fb-11eb-261e-3b991ce4c9f8
function decide(diff, T)
   	chance = exp(-diff/T)
   	if rand() < chance
    	return true
   	end
    return false
end

# ╔═╡ 3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
md"""
### Actual solving

The final function looks as follows.
"""

# ╔═╡ 8623ac1a-20fa-11eb-2d45-49cce0fdac86
function sudoku_solver(sudoku)
    if !valid(sudoku)
        error("Input is not a valid sudoku")
    end
    
	solved = 0
	cooling = 0.99 # Determines the rate by which the temperature decreases.
	stuck = 0
    restart = 0
	show_sudoku(sudoku)
	fixed = fixed_values(sudoku)
	T0, filled = start_temp(sudoku)
    T = T0
    blocks, possible = possible_swap(fixed)
	errors = nr_errors(filled)
	iterations = 81 - sum(fixed) # T0 and iterations are dependent on how many non-fixed values there are.
	state = filled
    best = filled # Keep track of best encountered result.
    bestscore = 90
	
	if errors == 0
		solved = 1
	end
	
	while solved == 0
		lastscore = errors
		for i in 1:iterations # Temperature does not decrease for a certain number of iterations.
			newstate = swap(state, fixed, blocks, possible) # Create a new neighbouring state.
			newerrors = nr_errors(newstate)
			if newerrors == 0
				solved = 1
				break
			end
			
			diff = newerrors - errors
			if diff <= 0 # Better score is always accepted.
				state = newstate
				errors = newerrors
                if errors < bestscore # Remember best result.
                    best = state
                    bestscore = errors
                end
			else
				kept = decide(diff, T) # SA at work.
				if kept
					state = newstate
					errors = newerrors
				end
			end
		end
			
		T *= cooling # Temperature decreases.
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
            if restart > 20 # Return to best solution (restart).
                state = best
                errors = bestscore
                restart = 0
				stuck = 0
            else
                T += T0/3 # Or increase temperature.
				stuck = 0
            end
		end
	end
    
	show_sudoku(state)
	return state
end

# ╔═╡ 48de2108-1677-4277-a33b-a02650636a76
md"""
Over all, it takes a long time to run, depending on how many positions are fixed. SA seems to be quik to find good results, but finding the actual solution is more difficult. The restart seems to be really necessary to keep the program on track. Due to the more global searching, sudokus with few errors are quickly found, but for the same reason, this good solution is also quickly discarded. A solution with as few as 2 errors is found quikly, but the actual sulution is harder to find. The cooling rate needs to kept low in order not to miss the solution.
"""

# ╔═╡ 1c4bdb0f-52e8-4eca-a10d-85fee6fa3e1a
with_terminal() do
	SudokuSolver.sudoku_solver(lvl1)
end

# ╔═╡ 702e4676-c461-4588-bccb-b63e30d410e5
with_terminal() do
	SudokuSolver.sudoku_solver(lvl2)
end

# ╔═╡ 67fd3250-f165-4201-9426-7fe89825404d
md"""
## Conclusion

SA is a quik way to solve simple sudokus, but is not a good fit for sudokus with fewer fixed values. Since SA does not keep track of which solutions have been tried already, it ends up trying more (identical) combinations than other algorithms use for sudoku solving. Better options would be a branch-and-bound method, or brute-force search with backtracking. Both keep track of arlready tried solutions and as such, dont try the same one over and over again. Given that SA does reach a low number of errors relatively quikly, perhaps a hybrid approach would work?
"""

# ╔═╡ bac46fbd-5c17-4418-b59d-136bac701b63
# with_terminal() do
# 	SudokuSolver.sudoku_solver(lvl3)
# end

# ╔═╡ Cell order:
# ╟─171fee18-20f6-11eb-37e5-2d04caea8c35
# ╠═5ad5c202-20f8-11eb-23f1-4f38b687c285
# ╠═d2d007b8-20f8-11eb-0ddd-1181d4565a85
# ╠═6ecc9370-3cc7-400b-a6d8-3fd704c40984
# ╠═13c11517-1774-4ba7-add1-b84051860488
# ╠═f9f5eff0-16f9-4167-bc93-a6321abfd4cf
# ╟─38c3a299-b597-40aa-abbf-71afde17f26d
# ╟─7a25aac1-c7b2-4a94-81da-9325c30a0336
# ╟─ec046206-68a9-406d-a2ac-11ffdb2dee82
# ╟─cd1397a7-30ed-4542-993a-67548895691d
# ╟─51464e74-c439-49f4-802c-9dba8e5fcadc
# ╟─9cc0129e-3122-41b6-8d3f-ed0dd5420da4
# ╟─f991f1de-a92d-45e0-8294-44715e616e6c
# ╟─45587b5d-86c9-436f-a573-03a8fdb68ebb
# ╟─24d2d6e2-5283-4700-9459-6b84b3f80c4f
# ╠═eb18ffab-3c45-4bd6-af6a-1c7b422f14bc
# ╠═9556bf81-9486-4b00-8f82-18febb29e22e
# ╠═f307ed1d-28a8-4896-9931-f004e11cffd5
# ╟─fb4aeb8c-20f7-11eb-0444-259de7b76883
# ╠═f40d46d6-c022-4ee5-aa06-99439e69f5f9
# ╠═fdd4e550-20f8-11eb-227b-25f36708484d
# ╟─ca79bf63-af4d-46a3-9ef7-ce04c404fcfd
# ╠═acb21fa7-64e8-4a6b-ad00-d64b33252cb0
# ╠═025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
# ╟─096eff98-20f9-11eb-1e61-99d5714895ba
# ╠═165509ca-20f9-11eb-107c-550cbba0f0e9
# ╟─1fffc82a-20f9-11eb-198c-c160d7dac87d
# ╟─26ab6ce2-20f9-11eb-1836-1756b290e5e3
# ╠═49832a8e-20f9-11eb-0841-19a40a12db18
# ╠═9c369269-b5af-4fcf-955c-7609f55f43a6
# ╟─55e0e274-20f9-11eb-36c0-753f228f7e9b
# ╠═2a520041-4a9e-458d-8d06-f67b51143aab
# ╠═6731c4f5-c6d3-4efc-a982-80cbe1ffd357
# ╟─b1551758-20f9-11eb-3e8f-ff9a7127d7f8
# ╠═45189a82-20fa-11eb-0423-05ce1b84639d
# ╠═41d8f1dc-20fa-11eb-3586-a989427c1fd6
# ╟─4ed4215e-20fa-11eb-11ee-f7741591163c
# ╠═6c5473b4-20fa-11eb-327b-51ac560530eb
# ╠═d3b42073-d0de-43f3-8627-f9b350fa5167
# ╟─252903c4-8aa3-40aa-b9cd-8fbd00c13953
# ╠═91a5cbbf-dd94-4786-b65b-6755c7f76804
# ╠═3639da42-6a95-4df9-b777-9cf68758a6b0
# ╟─1d3d599f-78c3-4d9f-ac2b-e9d81b086836
# ╠═8b4ea346-9bed-4889-bc7e-e0795a212812
# ╠═134bf884-c7eb-4fb3-b993-71ae40133cd2
# ╟─7518c2c0-20fa-11eb-32c0-a9db2a91cbc5
# ╠═34027942-20fb-11eb-261e-3b991ce4c9f8
# ╟─3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
# ╠═8623ac1a-20fa-11eb-2d45-49cce0fdac86
# ╟─48de2108-1677-4277-a33b-a02650636a76
# ╠═1c4bdb0f-52e8-4eca-a10d-85fee6fa3e1a
# ╠═702e4676-c461-4588-bccb-b63e30d410e5
# ╟─67fd3250-f165-4201-9426-7fe89825404d
# ╠═bac46fbd-5c17-4418-b59d-136bac701b63
