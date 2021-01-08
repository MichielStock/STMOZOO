### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 44194c10-3d62-11eb-2089-2b2813796028
using STMOZOO.LocalSearch

# ╔═╡ 9db0d300-3d63-11eb-31bb-b3a8acc6a1c9
md""" 

# Solving a Sudoku using Local Search

Sudoku is a world wide popular Japanese puzzle. Although very challenging, Sudoku rules are quite simple: Place digits between 1-9 on a 9×9 grid such that
each digit appears once in each row, column and each 3x3 sub-grid.

Local search methods, opposed to brute force algorithm, move from state to state in the space of states by applying local changes, trying to get closer to the solution each time.

A naive local search algorithm starts from a complete random assignment, then attempts to find a better state by making an incremental change until it finds the solution or gets stuck in a local minimum.

#### Get a Sudoku puzzle
"""

# ╔═╡ dec03be0-3d6a-11eb-003a-197ac59933dc
md"""
The puzzle is presented so that in the beginning there are
some static numbers, givens, in the grid that are given in
advance and cannot be changed or moved. The number of
givens does not determine the difficulty of the puzzle. In the matrix, the zeros represent missing values.
"""

# ╔═╡ dd7c43d0-3d62-11eb-2f9c-69eb6819d094
sudoku_1

# ╔═╡ 479a4660-3d6b-11eb-2453-399baa5b059f
sudoku_2

# ╔═╡ 58841be0-3d6b-11eb-3e22-b5465d1cf3a3
md"""
#### Get an initial state

Randomly assign numbers from 1 to 9 to each missing value:

"""

# ╔═╡ f2e96870-3d6b-11eb-1dee-61f5f48f8ba4
sudoku_full1 = fill_in(sudoku_1)

# ╔═╡ 088135a0-3d6c-11eb-03a1-d5b500d99e92
sudoku_full2 = fill_in(sudoku_2)

# ╔═╡ 45f09890-3d6c-11eb-2653-b17cf5ebd7fd
md"""
#### Finding a better state

Randomly change the number of a particular position, then evaluate if the new state is better than the previous. To make the evaluation a fitness/cost function must be defined. Here the cost function shows how many times a number in the evaluated position is present in the same row, column or subgrid. 

Lets evaluate the cost of the **position [1,1]** in **Sudoku_full1.**
"""

# ╔═╡ 652f7270-3d6d-11eb-034f-4b9a8852189e
#shows the number of repetitions of number in position [1,1]
cc1 = check_value(sudoku_full1, 1, 1)

# ╔═╡ 8523fd2e-3d6d-11eb-30f2-cd1240c6f3d6
md"""
Now we can assign a different number, for example "5", to that position and evaluate if the cost increases or decreases. 
"""


# ╔═╡ 4efa8570-3d6e-11eb-1b08-6b78d70cfaac
cc2 = check_value(sudoku_full1, 1, 1, 5)

# ╔═╡ ab19f9e0-3dea-11eb-1bd1-1d1417688288
cc2 < cc1

# ╔═╡ 5f31fae0-3d6e-11eb-05bc-87215c66feb0
md"""
The total cost of the sudoku will be the sum of the costs of all positions
"""

# ╔═╡ d5f59dc0-3d6f-11eb-3c25-713923efc3ad
sudoku_cost(sudoku_full1)

# ╔═╡ 4597cd5e-3d70-11eb-275a-bfe09278d486
md"""
#### Solving a Sudoku

We can repeat multiple times the previous process using the function `sudoku_greedydesc`, which randomly assigns new numbers per position in the grid. it will only move to a new state if its cost isnt higher than the previous.
"""

# ╔═╡ 0f8aacb0-3d70-11eb-0be0-af7c2b65dc1b
solution1, cost1 = sudoku_greedydesc(sudoku_full1, sudoku_1, 1000)

# ╔═╡ e6888ebe-3d71-11eb-1774-89ccc2f2a893
md""" 
After 1000 random replacements, the obtained solution has a **total cost of $cost1.**
Therefore, it is not the true solution or global minimun.

Since the `fill_in` function fills each row with numbers from 1 to 9 without repetitions, a sligthly different approach we can use is not to change numbers randomly but to swap numbers only within rows.

We can swap two random positions using `fliprow` function.
"""

# ╔═╡ 07e5b4c0-3d73-11eb-0e06-d7907a930654
sudoku_flip1, pos1, pos2 = fliprow(sudoku_full1, sudoku_1)

# ╔═╡ 17aa4b10-3dea-11eb-10c8-e98295270098
md"""
Now, we can check the cost of the new state and evaluate if it is better/worse than the previous.
"""

# ╔═╡ 4ad903f0-3dea-11eb-188b-cfd082eb0727
sudoku_cost(sudoku_flip1) <= sudoku_cost(sudoku_full1)

# ╔═╡ 77b58ea0-3d74-11eb-057f-11a15bcab5b3
md"""
Similarly to what we did with `sudoku_greedydesc` function, we can repeat this process many times while evaluating the cost of the new state after the swap. It will only move to a new state if its cost isnt higher than the previous. This can be done with the function `makefliprow`
"""

# ╔═╡ 4c189700-3d75-11eb-06e2-878687d8edba
solution2 = makefliprow(sudoku_full1, sudoku_1, 1000)

# ╔═╡ 77ce2a40-3d75-11eb-3808-3df0aefaa6be
cost2 = sudoku_cost(solution2)

# ╔═╡ 89f9ce90-3d75-11eb-0e85-49bbafb27035
md"""
Again, since the **cost is $cost2**, the obtained state is not the global minimum.

The problem with these approaches is that they are strongly affected by the initial state, therefore, it is necessary to restart or iteratively change the initial state to avoid getting stuck in a local minimum. 

We can use the swapping approach. Start with a random assigment, then make swaps to reduce the cost of the solution, if the cost is not zero, start from another random assigment. 
"""

# ╔═╡ 5c5fa760-3d76-11eb-074d-b57c5caed0ba
#SUGGESTION: maybe move this to the src ?
begin
	solution3 =[]
	min_cost = Inf
	j = 0
	for i in 1:100
		global j, min_cost, solution3
		j += 1 #to count iterations
		start = fill_in(sudoku_1) #restart in a different state
		sol = makefliprow(start, sudoku_1, 1000) #make 1000 swaps
		cost = sudoku_cost(sol) #get the cost of the obtained solution
		if cost == 0 #if it is zero then it is the final solution
			solution3 = sol
			break
		end
		if cost < min_cost #keep track of the solution with the minimum cost
			min_cost = cost
			solution3 = sol
		end
	end		
end

# ╔═╡ 0ed0cac0-3ded-11eb-2542-4f3c14ebbbe2
solution3

# ╔═╡ 3bf138a0-3ded-11eb-09b6-bba39aa01e3b
sudoku_cost(solution3)

# ╔═╡ 72a372f0-3ded-11eb-3dcf-4b342b390890
md"""
By restarting the intial state, the algorithm was able to find the true solution with **cost $(sudoku_cost(solution3))** in **$j iterations**.

Now, we can try to solve `sudoku_2`
"""

# ╔═╡ df1ceb52-3ded-11eb-3223-f1a0ae406d4c
begin
	solution4 =[]
	min_cost2 = Inf
	k = 0
	for i in 1:100
		global k, min_cost2, solution4
		k += 1 #to count iterations
		start = fill_in(sudoku_2) #restart in a different state
		sol = makefliprow(start, sudoku_2, 1000) #make 1000 swaps
		cost = sudoku_cost(sol) #get the cost of the obtained solution
		if cost == 0 #if it is zero then it is the final solution
			solution4 = sol
			break
		end
		if cost < min_cost2 #keep track of the solution with the minimun cost
			min_cost2 = cost
			solution4 = sol
		end
	end		
end

# ╔═╡ 37e557e0-3dee-11eb-2f5f-03a88ced69c3
solution4

# ╔═╡ 3e56d182-3dee-11eb-07a9-d7baa09ebc45
sudoku_cost(solution4)

# ╔═╡ 506e5190-3dee-11eb-184e-4d36e8eb1c51
md"""
The true solution with **cost $(sudoku_cost(solution4))** was found in **$k iterations.**
"""

# ╔═╡ 61de9850-3df2-11eb-1452-c79af84acab7
md"""
Now, lets use `sudoku_greedydesc` to find the true solution. As mentioned before, this function randomly replaces numbers in the matrix that decrease the cost of the solution. 
"""

# ╔═╡ a932ed90-3dee-11eb-3c98-71279cf5e3bb
begin
	solution5 =[]
	min_cost3 = Inf
	m = 0
	for i in 1:100
		global m, min_cost3, solution5
		m += 1 #to count iterations
		start = fill_in(sudoku_1) #restart in a different state
		sol, cost = sudoku_greedydesc(start, sudoku_1, 10000) #make 1000 swaps
		if cost == 0 #if it is zero then it is the final solution
			solution5 = sol
			break
		end
		if cost < min_cost3 #keep track of the solution with the minimun cost
			min_cost3 = cost
			solution5 = sol
		end
	end		
end

# ╔═╡ 5c5853f0-3df0-11eb-1a78-274cceaf7711
solution5

# ╔═╡ 633fe7f0-3df0-11eb-3f20-1d38fa05b17c
sudoku_cost(solution5)

# ╔═╡ 1fe59f80-3dfb-11eb-08f2-b1e4a62e679f
md"""
This approach is far less effecient than the previous. It will need at least 10000 iterations to find the correct solution.
"""

# ╔═╡ Cell order:
# ╠═44194c10-3d62-11eb-2089-2b2813796028
# ╟─9db0d300-3d63-11eb-31bb-b3a8acc6a1c9
# ╟─dec03be0-3d6a-11eb-003a-197ac59933dc
# ╠═dd7c43d0-3d62-11eb-2f9c-69eb6819d094
# ╠═479a4660-3d6b-11eb-2453-399baa5b059f
# ╟─58841be0-3d6b-11eb-3e22-b5465d1cf3a3
# ╠═f2e96870-3d6b-11eb-1dee-61f5f48f8ba4
# ╠═088135a0-3d6c-11eb-03a1-d5b500d99e92
# ╟─45f09890-3d6c-11eb-2653-b17cf5ebd7fd
# ╠═652f7270-3d6d-11eb-034f-4b9a8852189e
# ╟─8523fd2e-3d6d-11eb-30f2-cd1240c6f3d6
# ╠═4efa8570-3d6e-11eb-1b08-6b78d70cfaac
# ╠═ab19f9e0-3dea-11eb-1bd1-1d1417688288
# ╟─5f31fae0-3d6e-11eb-05bc-87215c66feb0
# ╠═d5f59dc0-3d6f-11eb-3c25-713923efc3ad
# ╟─4597cd5e-3d70-11eb-275a-bfe09278d486
# ╠═0f8aacb0-3d70-11eb-0be0-af7c2b65dc1b
# ╟─e6888ebe-3d71-11eb-1774-89ccc2f2a893
# ╠═07e5b4c0-3d73-11eb-0e06-d7907a930654
# ╟─17aa4b10-3dea-11eb-10c8-e98295270098
# ╠═4ad903f0-3dea-11eb-188b-cfd082eb0727
# ╟─77b58ea0-3d74-11eb-057f-11a15bcab5b3
# ╠═4c189700-3d75-11eb-06e2-878687d8edba
# ╠═77ce2a40-3d75-11eb-3808-3df0aefaa6be
# ╟─89f9ce90-3d75-11eb-0e85-49bbafb27035
# ╠═5c5fa760-3d76-11eb-074d-b57c5caed0ba
# ╠═0ed0cac0-3ded-11eb-2542-4f3c14ebbbe2
# ╠═3bf138a0-3ded-11eb-09b6-bba39aa01e3b
# ╟─72a372f0-3ded-11eb-3dcf-4b342b390890
# ╠═df1ceb52-3ded-11eb-3223-f1a0ae406d4c
# ╠═37e557e0-3dee-11eb-2f5f-03a88ced69c3
# ╠═3e56d182-3dee-11eb-07a9-d7baa09ebc45
# ╟─506e5190-3dee-11eb-184e-4d36e8eb1c51
# ╟─61de9850-3df2-11eb-1452-c79af84acab7
# ╠═a932ed90-3dee-11eb-3c98-71279cf5e3bb
# ╠═5c5853f0-3df0-11eb-1a78-274cceaf7711
# ╠═633fe7f0-3df0-11eb-3f20-1d38fa05b17c
# ╠═1fe59f80-3dfb-11eb-08f2-b1e4a62e679f
