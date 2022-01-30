### A Pluto.jl notebook ###
# v0.16.4

using Markdown
using InteractiveUtils

# ╔═╡ e7e7c0e4-47e1-4856-9e71-11dfd12dfcd3
using StatsBase

# ╔═╡ 8c0c6652-aa5d-4cb8-a4cf-018c80b380cf
student_names = "Triana Forment";

# ╔═╡ f3aa9d9c-75e1-4948-b7dd-7f0596486e83
md"""
# Project: Hungarian algorithm

**STMO**

2021-2022

project by $student_names

## Introduction

Optimal transportation leads with two probability distributions and there is a cost function for moving elements from one distribution to the other distribution. And you have to find a transportation scheme to map one distribution into the other one. The original version of this problem of optimal transport dates back to Gaspard Monge in 1781. The Monge's problem has a discrete n number iron mines and n factories and, the cost is the distance between the mine and the factory. The solution is to find which mine suplies which factory, finding the minimum average distance transported.

The Hungarian algorithm solves an assignment problem which can be considered as a special type of transportation problem in which the number of sources and sinks are equal. The capacity of each source as well as the requirement of each sink is taken as 1. In this project, the Hungarian algorithm is implemented using an adjacency matrix.
This algorithm can be used to find the map that minimizes the transport cost, given two distributions and a cost function. For two discrete probability vectors, $$\mathbf{a} ∈ Σ_n$$ and $$\mathbf{b} ∈ Σ_m$$, we have a $$n \times m$$ cost matrix $$C$$. It can be represented as a adjacency matrix, with elements in $$a$$ as rows and elements in $$b$$ as columns, and their weights as entries in the matrix. 

An example of an assignment problem, can be, given $$n$$ agents and the money they ask for performing each task, finding which agent performs which task in order to minimize the cost of performing all $$m$$ tasks.
When there are the same number of agents than tasks, the the problem is called balanced assignment, otherwise is called unbalanced assignment. And if the total cost is the sum for each agent performing its task, the problem is called linear assignment, because the cost function to be optimized as well as all the constraints contain only linear terms. This implementation can be used to solve linear balanced assignment problems.
"""

# ╔═╡ bf771d76-099c-449b-bebd-5201ed72ebb6
md"""
# Implementation
"""

# ╔═╡ ed527906-da70-4186-a6db-da9906d72efa
md"""
## Outline of the approach

1. Subtract the smallest entry in each row from all the entries in the row, thus making the smallest entry in the row now equal to `0`. The same for each column.

2. Mark the rows and columns which have 0 entries, such that the fewest lines possible are drawn.

3. If there are $m$ marked rows and columns, an optimal assignment of zeros is possible and the algorithm is finished. The cost value and the optimal agent-task combination can be calculated. If the number of lines is less than $$m$$, then the optimal number of zeroes is not yet reached and the next step needs to be performed.

4. Find the smallest entry not marked by any marked row and by any column. Subtract this entry from each row which is not marked, and then add it to each column which is marked. Then, go back to step 2.
"""

# ╔═╡ 6be9cccf-160a-4d05-88bd-9f5e33ad3d05
md"""
**`Hungarian_algorithm`** is the funtion that uses as an input the cost matrix and gives as an output the cost value and the matrix solution. This function performs steps 1 to 4, by calling the previous functions. Once the marked rows and columns sum the number of tasks to perform, it calculates the cost value by adding each cost value of the different agent-task selected. The matrix solution has all zeros, except for each agent-task pair selected, where it has its original value.
"""

# ╔═╡ 23020cd7-333d-4d97-aabb-c13614d57c65
md"""
**`find_min_row`** is a function that gets the row with the fewest zeros. For that purpose, it needs as an input a boolean matrix, having `true` if the original value after subtracting the smallest entry in each row from all the other entries in the row was `0`, and a `false` if it was different from `0`. It also needs a vector `zero_list` that will store the coordinates of the `0` in the row with fewest zeros. After the first finding, it reajusts the boolean matrix so the whole row and column from the last coordinate stored is set to `false`. This function is used in the next function `mark_matrix`.
"""

# ╔═╡ d7c22bc5-088d-4a74-a00d-5833430bf219
"""
	find_min_row(matrix_zero, zero_list) 

Inputs:
	- `matrix_zero`: boolean matrix
	- `zero_list`: array to store the coordinates of the zeros in the row with fewest zeros.
	
Outputs:
	- `min_row`: tuple with the first element the number of zeros in the row with fewest zeros and the index of that row as second element
	- `zero_list`: list of coordinates tuples of the zeros found
"""
function find_min_row(matrix_zero, zero_list)
	min_row = [Inf, -1]
	
	for row in 1:size(matrix_zero)[1]
		#if true in matrix_zero[row, :] # Needs a 0 in the row
			# If the number of zeros < than the last min stored
			if sum(matrix_zero[row,:]) > 0 && min_row[1] > sum(matrix_zero[row,:])
				#stores the number of zeros and the row index
				min_row = [sum(matrix_zero[row,:]), row]
			end
	end
	# Get the column index 
	zero_index = findall(x->x==true, matrix_zero[min_row[2],:])[1]  
	# Store tuple in zero_list the tuple of coordinates
	append!(zero_list, [(min_row[2], zero_index)]) 
	# Mark the specific row and column as false.
	matrix_zero[min_row[2], :] .= false
	matrix_zero[:, zero_index] .= false
	return min_row, zero_list
end

# ╔═╡ 4f82e659-944a-4ff2-aa77-db81187da001
md"""
**`mark_matrix`** needs as an input the matrix with the already subtracted the smallest entry in each row from all the other entries and it returns the `zero_list` and the marked row and column indexes. For that, it creates the boolean matrix and calls the function `find_min_row`. It performs steps 2 and 3.
"""

# ╔═╡ 8d04677a-5f97-4e76-937c-e79f69c14788
"""
	mark_matrix(mat)

Perform steps 2 and 3: It marks the rows and columns that have the 0 entries such that the fewest lines possible are drawn. If there are "m" marked rows and columns, an optimal assignment solution can be found.  

Input:
	- `mat` : cost matrix already modified by step 1 or an adjusted matrix by `adjust_matrix`
	
Outputs:
	- `zero_list` : coordinates of the zeros found by `find_min_row`
	- `marked_rows`: array of marked rows 
	- `marked_cols`: array of marked columns
"""
function mark_matrix(mat)
	
	#Transform the matrix to boolean matrix(0 = true, others = false)
	cur_mat = mat
	boolean_mat = iszero.(mat)
	boolean_mat_copy = copy(boolean_mat)
	#Recording possible answer positions by zero_list
    zero_list = []	
    while true in boolean_mat_copy
        find_min_row(boolean_mat_copy, zero_list)
	end
    #Recording the row indexes
    zero_list_row = []
    for i in 1:length(zero_list)
        append!(zero_list_row, zero_list[i][1])
	end

	# Get non marked rows
    non_marked_row = (x->collect(x))(setdiff(Set(1:size(cur_mat)[1]), Set(zero_list_row)))
    
    marked_cols = []
    flag = 0 
    while flag == 0 # Enter in the loop until there's no more unmarked cols and rows
        flag = 1 
        for i in 1:length(non_marked_row)
            row_array = boolean_mat[non_marked_row[i], :]
            for j in 1:length(row_array)
				# Find unmarked 0 elements in the corresponding column
				if row_array[j] == true && j ∉ marked_cols
                    # Store column index in "marked_cols"
                    append!(marked_cols, j)
                    flag = 0
				end
			end
		end
		zero_rows = [t[1] for t in zero_list]
		zero_cols = [t[2] for t in zero_list]
		for i in 1:length(zero_list)
			# If in "zero_list" coordinates there was a 0 marked in cols,
			# but not in marked_rows, add its row index to "non_marked_row"
            if zero_rows[i] ∉ non_marked_row && zero_cols[i] in marked_cols
                append!(non_marked_row, zero_rows[i])
                flag = 0
			end
		end
	end
	# Add those the indexes not stored in "non_marked_row" to "marked_rows"
	marked_rows = (x->collect(x))(setdiff(Set(1:size(cur_mat)[1]), Set(non_marked_row)))   
    return zero_list, marked_rows, marked_cols
end			

# ╔═╡ 05e77871-d6d1-4d7b-b368-89aeeed878a4
md"""
**`adjust_matrix`** is a function needed when, after performing steps 1, 2 and 3, the number of marked rows plus the number of marked columns is not equal to the number of tasks/activities to perform by the agents. Then, it adjustes and returns the matrix as described in step 4.
"""

# ╔═╡ f94e0b59-80d0-4d26-bac3-d75c30e4d3ee
"""
	adjust_matrix(mat, marked_rows, marked_cols)

Perform step 4: Adjust the matrix by finding the smallest entry not marked by any marked row and by any column. Subtract this entry from each row that isn’t marked, and then add it to each column that is marked. 

Inputs:
	- `mat` : boolean matrix created and modified by `mark_matrix`
	- `marked_rows`: array of marked rows produced by `mark_matrix`
	- `marked_cols`: array of marked columns produced by `mark_matrix`

Output:
	- `adjusted`: the adjusted matrix
"""
function adjust_matrix(mat, marked_rows, marked_cols)
	adjusted = mat
    min_values = []
    n = size(adjusted)[1]
	
    # Find the minimum value for that is not in marked_rows and not in marked_cols
    for row in 1:n
        if row ∉ marked_rows
            for i in 1:n
                if i ∉ marked_cols
                    append!(min_values, adjusted[row,i])
				end
			end
		end
	end
    min_value = minimum(min_values)
	# Substract that min value to all elements not in marked rows and columns
    for row in 1:n
        if row ∉ marked_rows
            for i in 1:n
                if i ∉ marked_cols
                    adjusted[row, i] = adjusted[row, i] - min_value
				end
			end
		end
	end
    # Add the min value to elements that are in both marked row and columns
    for row in marked_rows
        for col in marked_cols
            adjusted[row, col] = adjusted[row,col] + min_value
		end
	end
    return adjusted
end

# ╔═╡ d4435d9e-1c3a-4d0d-80b3-8c0061336975
"""
	Hungarian_algorithm(mat)

Solves a linear balanced assignment problem.

Input:
	- 'mat`: the cost matrix

Outputs:
	- `cost`: the resulting cost value
	- `matrix solution`: the matrix with the selected agent-task as its original cost value and the rest zeros. 
"""
function Hungarian_algorithm(mat)
	num_rows = size(mat)[1]
	num_cols = size(mat)[1]
		 @assert num_rows == num_cols throw(DimensionMismatch("It is not balanced. Number of sources and sinks need to match"))
	
	matrix = copy(mat)
	#Step 1: subtract its internal minimum from every column and every row 
	matrix .-= minimum(matrix, dims=2) # from rows
	matrix .-= minimum(matrix, dims=1) # from columns
	
	
	num_zeros = 0
	
	# Step 2: mark rows and columns that have the 0 entries 
	pos = [] 
    while num_zeros < num_rows
        pos, rows, cols = mark_matrix(matrix)
		rows = reverse(rows)
        num_zeros = length(rows) + length(cols)
		# Step 3: if marked rows & columns is less than num_rows, go to step 4.
        if num_zeros < num_rows
			# Step 4: adjust the matrix
            matrix = adjust_matrix(matrix, rows, cols)
		end
	end
	# Calculate total cost and matrix solution
	cost = 0
	matrix_solution = zeros(Int64, size(mat)[1], size(mat)[2])
	for i in 1:num_rows
		cost += mat[pos[i][1], pos[i][2]]
		matrix_solution[pos[i][1], pos[i][2]] = mat[pos[i][1], pos[i][2]]
	end
	return cost, matrix_solution
end

# ╔═╡ d8dd3d3f-2ed6-434c-8878-c3af69abc45b
md"""
### Example and solution of assignment problem

Suppose we have 5 companies having different costs to realize 5 different tasks. You want to select a different company for each task in the way that we spend the minimum money. In order to find that combination, you just have to create a matrix with the cost each company asks for performing each activity. Here we have the following cost matrix with the companies as rows, the tasks as columns, and the values in thousand euros unit.
"""

# ╔═╡ 4cbb69df-9573-4b9f-a03a-4d1e3c53b8ff
cost_matrix = [7 6 2 9 2;
               1 2 5 3 9;
               5 3 9 6 5;
               9 2 5 8 7;
               2 5 3 6 1]

# ╔═╡ 8f59c095-4cab-4d2f-bfe5-85ab121070bd
md"""
After applying the function `Hungarian_algorithm`, you get the minimum cost (12000 €),
and the solution matrix, which shows the company-task combination to get that minimum cost. The first company will perform the third task for 2000 €, the second company the first task for 1000 €, etc.
"""

# ╔═╡ 545a38bf-4edc-4c16-9f1a-0c26ff2e5f33
Hungarian_algorithm(cost_matrix)

# ╔═╡ 011e0f2f-ac2f-4ca6-94a9-912dee4b21ae
md"""
In case you want to maximize the values (e.g. instead of cost values you have benefit values), you just have to create the benefit matrix with negative values. This would solve an assigment problem maximizing the solution.
"""

# ╔═╡ 0ad00f08-c712-4dde-892f-e48a8b7f02d4
begin 
	benefit_matrix = copy(cost_matrix)
	benefit_matrix .= - cost_matrix 
end

# ╔═╡ 50b784ac-64a1-41eb-ba01-fd1af65f6fe7
md"""
After applying `Hungarian_agorithm` to the benefit matrix, you get a maximum benefit of 41000 € by selecting the first company performing the fourth task, the second company the fifth, etc.
"""

# ╔═╡ b76c5a89-fb4c-4840-b5e7-ce816ba4b4fc
Hungarian_algorithm(benefit_matrix)

# ╔═╡ dfd65b50-b0a7-4ad1-83d8-7bfa0bedfed7
md"""
## References

- H. W. Kuhn. The Hungarian Method for the Assignment Problem. (2010), from http://bioinfo.ict.ac.cn/~dbu/AlgorithmCourses/Lectures/Lec10-HungarianMethod-Kuhn.pdf
- M. Thorpe. Introduction to Optimal Transport. (2018), from https://www.math.cmu.edu/~mthorpe/OTNotes
- Chapter 6 - Selected Topic in Mathematical Optimization course by Michiel Stock
- https://brilliant.org/wiki/hungarian-matching/
- https://python.plainenglish.io/hungarian-algorithm-introduction-python-implementation-93e7c0890e15

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
StatsBase = "~0.33.13"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─e7e7c0e4-47e1-4856-9e71-11dfd12dfcd3
# ╟─f3aa9d9c-75e1-4948-b7dd-7f0596486e83
# ╟─8c0c6652-aa5d-4cb8-a4cf-018c80b380cf
# ╟─bf771d76-099c-449b-bebd-5201ed72ebb6
# ╟─ed527906-da70-4186-a6db-da9906d72efa
# ╟─6be9cccf-160a-4d05-88bd-9f5e33ad3d05
# ╠═d4435d9e-1c3a-4d0d-80b3-8c0061336975
# ╠═23020cd7-333d-4d97-aabb-c13614d57c65
# ╠═d7c22bc5-088d-4a74-a00d-5833430bf219
# ╠═4f82e659-944a-4ff2-aa77-db81187da001
# ╠═8d04677a-5f97-4e76-937c-e79f69c14788
# ╟─05e77871-d6d1-4d7b-b368-89aeeed878a4
# ╠═f94e0b59-80d0-4d26-bac3-d75c30e4d3ee
# ╟─d8dd3d3f-2ed6-434c-8878-c3af69abc45b
# ╠═4cbb69df-9573-4b9f-a03a-4d1e3c53b8ff
# ╟─8f59c095-4cab-4d2f-bfe5-85ab121070bd
# ╠═545a38bf-4edc-4c16-9f1a-0c26ff2e5f33
# ╟─011e0f2f-ac2f-4ca6-94a9-912dee4b21ae
# ╠═0ad00f08-c712-4dde-892f-e48a8b7f02d4
# ╟─50b784ac-64a1-41eb-ba01-fd1af65f6fe7
# ╠═b76c5a89-fb4c-4840-b5e7-ce816ba4b4fc
# ╟─dfd65b50-b0a7-4ad1-83d8-7bfa0bedfed7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
