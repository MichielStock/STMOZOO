### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 4b3e86ea-6973-11ec-014f-9f2708ba86cf
md"""
# RNAfolder

*STMO*

**Menno Van Damme**

This pluto notebook contains the code for a simple RNA secondary structure prediction tool and some illustrated examples on how to use it.

"""

# ╔═╡ 6482fcd3-23de-49bb-ae0a-b7db42305890
RNA = "GGGAAAUCC"

# ╔═╡ b266622e-db86-4690-8328-d17e1b5a6db0
function basepair(i, j, RNA)
	bp = 0
	ni = RNA[i]
	nj = RNA[j]
	if ni == 'A'
		if nj == 'U'
			bp = true
		else
			bp = false
		end
	elseif ni == 'U'
		if nj == 'A' || nj == 'G' # U-G basepairs are also possible
			bp = true
		else
			bp = false
		end
	elseif ni == 'G'
		if nj == 'C' || nj == 'U' # U-G basepairs are also possible
			bp = true
		else
			bp = false
		end
	elseif ni == 'C'
		if nj == 'U'
			bp = true
		else
			bp = false
		end		
	end
	return bp
end

# ╔═╡ 7a9b23c1-30cd-4516-bc47-259302d944fc
basepair(1, 2, RNA)

# ╔═╡ a624100b-59e7-483e-affd-d0b5391dd475
basepair(1, 3, RNA)

# ╔═╡ dc573955-b679-4fdc-aeba-7001ea8f7a4c
function calculate_S(RNA)
	n = length(RNA)
	S = zeros(n,n)
	for i in 1:n
		for j in i+1:n
			if basepair(i, j, RNA)
				bp = S[i+1,j-1] + 1
				S[i,j] = max(bp, S[i+1,j], S[i,j-1]) # add bifurcation
			else
				S[i,j] = max(S[i+1,j], S[i,j-1])
			end
		end
	end
	return S
end

# ╔═╡ 0a20eddd-24f7-43c6-a0f3-6c1c138fb90a
S = calculate_S(RNA)

# ╔═╡ Cell order:
# ╟─4b3e86ea-6973-11ec-014f-9f2708ba86cf
# ╠═6482fcd3-23de-49bb-ae0a-b7db42305890
# ╠═b266622e-db86-4690-8328-d17e1b5a6db0
# ╠═7a9b23c1-30cd-4516-bc47-259302d944fc
# ╠═a624100b-59e7-483e-affd-d0b5391dd475
# ╠═dc573955-b679-4fdc-aeba-7001ea8f7a4c
# ╠═0a20eddd-24f7-43c6-a0f3-6c1c138fb90a
