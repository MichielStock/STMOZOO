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

# ╔═╡ 45189a82-20fa-11eb-0423-05ce1b84639d
using Zygote

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

### SA for sudokus

SA works by comparing 2 different neighbouring states. For sudokus, these are randomly filled out grids, with 2 positions swapped in one of the states. To compare the states, the number of errors in rows and columns are counted. If there are less errors in the new state, it is accepted automatically. When the new state has more errors, it is accepted or rejected depending on the temperature.

As such, the first step was to fill the sudoku with random numbers.

The filled sudoku looks as follows:
"""

# ╔═╡ fdd4e550-20f8-11eb-227b-25f36708484d
with_terminal() do
	filledlvl2 = fill_full(lvl2)
	show_sudoku(filledlvl2)
end

# ╔═╡ ca79bf63-af4d-46a3-9ef7-ce04c404fcfd
md"""
Notice that each block contains all numbers from 1 till 9. Because it would be cumbersome to count errors within the blocks, the sudoku is randomly filled block by block and swaps occur within the blocks. This way, blocks contain all numbers from the start, and this remains throughout the program.

Since it is not clear in the filled sudoku which positions are fixed, a separate array is formed to keep track of these positions.
"""

# ╔═╡ 025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
with_terminal() do
	fixedlvl2 = fixed(lvl2)
	show_sudoku(fixedlvl2)
end

# ╔═╡ 096eff98-20f9-11eb-1e61-99d5714895ba
md"""
Since there are blocks with less than 2 non-fixed positions, we need to identify these positions from the start. In these cases, the block will already be solved by now. From the blocks with more non-fixed positions, 1 will be chosen at random in each iteration. From this block 2 non-fixed positions will be chosen, again at random, and swapped to create a new neighbouring state.
"""

# ╔═╡ 165509ca-20f9-11eb-107c-550cbba0f0e9
fixed_blocks(fixedlvl2)

# ╔═╡ 1fffc82a-20f9-11eb-198c-c160d7dac87d
f_quadr([2, 1])

# ╔═╡ 26ab6ce2-20f9-11eb-1836-1756b290e5e3
md"No more need to remember the formulla for the minimizer! Just use `solve_quadratic_system`!"

# ╔═╡ 49832a8e-20f9-11eb-0841-19a40a12db18
x_star = solve_quadratic_system(P, q, r)

# ╔═╡ 55e0e274-20f9-11eb-36c0-753f228f7e9b
begin
	contourf(-20:0.1:20, -20:0.1:20, (x, y) -> f_quadr([x,y]), color=:speed)
	scatter!([x_star[1]], [x_star[2]], label="minimizer")
end

# ╔═╡ b1551758-20f9-11eb-3e8f-ff9a7127d7f8
md"""
## Approximating non-quadratic functions

We can approximate non-quadratic functions by a quadratic function: The second order Taylor approximation $\hat{f}$ of a function $f$ at $\mathbf{x}$ is
$$f(\mathbf{x}+\mathbf{v})\approx\hat{f}(\mathbf{x}+\mathbf{v}) = f(\mathbf{x}) + \nabla f(\mathbf{x})^\top \mathbf{v} + \frac{1}{2} \mathbf{v}^\top \nabla^2 f(\mathbf{x}) \mathbf{v}\,.$$

Let us use this idea for the Rosenbrock function.
"""

# ╔═╡ 41d8f1dc-20fa-11eb-3586-a989427c1fd6
f_nonquadr((x1, x2); a=1, b=5) = (a-x1)^2 + b * (x2 - x1^2)^2

# ╔═╡ 4ed4215e-20fa-11eb-11ee-f7741591163c
x = [0.0, 0.0]

# ╔═╡ 56af99ee-20fa-11eb-0240-69c675efb78c
fx = f_nonquadr(x)

# ╔═╡ 6c5473b4-20fa-11eb-327b-51ac560530eb
∇fx = f_nonquadr'(x)

# ╔═╡ 7518c2c0-20fa-11eb-32c0-a9db2a91cbc5
∇²fx = Zygote.hessian(f_nonquadr, x)

# ╔═╡ 34027942-20fb-11eb-261e-3b991ce4c9f8
v = solve_quadratic_system(∇²fx, ∇fx, fx)

# ╔═╡ 3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
f̂(x′) = quadratic_function(∇²fx, ∇fx, fx)(x′ .- x)

# ╔═╡ 8623ac1a-20fa-11eb-2d45-49cce0fdac86
begin
	plot_nonquadr = contourf(-2:0.01:2, -2:0.01:2, (x, y) -> f_nonquadr([x,y]), color=:speed, title="non-quadratic function")
	scatter!(plot_nonquadr, [x[1]], [x[2]], label="x")
	scatter!(plot_nonquadr, [x[1]+v[1]], [x[2]+v[2]], label="x + v")
	
	plot_approx = contourf(-2:0.01:2, -2:0.01:2, (x, y) -> f̂([x,y]), color=:speed,
		title="quadratic approximation")
	scatter!(plot_approx, [x[1]], [x[2]], label="x")
	scatter!(plot_approx, [x[1]+v[1]], [x[2]+v[2]], label="x + v")
	
	plot(plot_nonquadr, plot_approx, layout=(2,1), size=(600, 800))
	
end


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
# ╠═fdd4e550-20f8-11eb-227b-25f36708484d
# ╟─ca79bf63-af4d-46a3-9ef7-ce04c404fcfd
# ╠═025fd6e8-20f9-11eb-3e7d-3519f3c4b58f
# ╟─096eff98-20f9-11eb-1e61-99d5714895ba
# ╠═165509ca-20f9-11eb-107c-550cbba0f0e9
# ╠═1fffc82a-20f9-11eb-198c-c160d7dac87d
# ╟─26ab6ce2-20f9-11eb-1836-1756b290e5e3
# ╠═49832a8e-20f9-11eb-0841-19a40a12db18
# ╠═55e0e274-20f9-11eb-36c0-753f228f7e9b
# ╠═b1551758-20f9-11eb-3e8f-ff9a7127d7f8
# ╠═41d8f1dc-20fa-11eb-3586-a989427c1fd6
# ╠═45189a82-20fa-11eb-0423-05ce1b84639d
# ╠═4ed4215e-20fa-11eb-11ee-f7741591163c
# ╠═56af99ee-20fa-11eb-0240-69c675efb78c
# ╠═6c5473b4-20fa-11eb-327b-51ac560530eb
# ╠═7518c2c0-20fa-11eb-32c0-a9db2a91cbc5
# ╠═34027942-20fb-11eb-261e-3b991ce4c9f8
# ╠═3bbeb85c-20fc-11eb-04d0-fb12d8ace50a
# ╟─8623ac1a-20fa-11eb-2d45-49cce0fdac86
