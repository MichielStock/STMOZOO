### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 91553c30-3d37-11eb-2a33-2d6d4ee5e9b2
#Loading needed packages:
using Plots,GraphPlot,GraphRecipes, STMOZOO.MaximumFlow

# ╔═╡ 814488a0-3d37-11eb-3dc9-a97e67207e93
md"""
# Maximum Flow Problem

**Exam project for the course Selected Topics on Mathematical Optimization**

Project by: Douwe De Vestele"""


# ╔═╡ 8694b650-3d90-11eb-0dce-fbf032e56897
test_edge

# ╔═╡ 90a799a0-3d90-11eb-25a0-1ff2f43d01ba
test_mat = [0 8 2 0;
            0 0 0 4;
            0 0 0 1;
            0 0 0 0];

# ╔═╡ 8bbee2de-3d90-11eb-39b7-5b465d373a0e
begin
	graphplot(test_mat, names=1:4, curvature_scalar=0,edgelabel = test_mat, arrow = true ,markersize = 0.3, labelsize = 30)
end

# ╔═╡ Cell order:
# ╠═814488a0-3d37-11eb-3dc9-a97e67207e93
# ╠═91553c30-3d37-11eb-2a33-2d6d4ee5e9b2
# ╠═8694b650-3d90-11eb-0dce-fbf032e56897
# ╠═90a799a0-3d90-11eb-25a0-1ff2f43d01ba
# ╠═8bbee2de-3d90-11eb-39b7-5b465d373a0e
