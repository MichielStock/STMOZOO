### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ a3c2226c-3f89-11eb-389e-9925792fc108
using CSV, DataFrames, Plots, STMOZOO.SingleCellNMF

# ╔═╡ d8139d04-3f87-11eb-10fa-c3e4fa828b57
md"""
### Introduction to SingleCellNMF

This tutorial provides an introduction to using non-negative matrix factorization (NMF) with single-cell data.

#### What is SingleCellNMF?

`SingleCellNMF` is a module that implements NMF as proposed by Jin and colleagues in `scAI` (Jin et al. 2020). Therein, single-cell RNA-seq and ATAC-seq data is jointly factorized to find an optimal representation of both transcriptomic and epigenomic features in a shared latent space. The low-dimensional representation of the data can be used for downstream analysis. Additionally, sparse epigenomic signal is aggregated to achieve better separation between clusters when analyzing scATAC-seq data. Please see the documentation page and scAI publication for more details.
"""

# ╔═╡ 62dbdaf2-3f89-11eb-2738-530350bccb92
md"""
### Analyzing example data
#### Dependencies
"""

# ╔═╡ d3c4c74a-3f8d-11eb-3918-8d7bff6cef04
md"""
#### Download data

Download the following files into the folder with the notebook:
- [RNA](https://raw.githubusercontent.com/f6v/data/master/simulation_RNA.csv)
- [ATAC](https://raw.githubusercontent.com/f6v/data/master/simulation_ATAC.csv)
- [Labels](https://raw.githubusercontent.com/f6v/data/master/labels.csv)

Alternatively, uncomment and run the code block below if you have `wget` installed.
"""

# ╔═╡ 038be600-49f6-11eb-3734-590b7d723c66
# begin
# 	run(`wget https://raw.githubusercontent.com/f6v/data/master/simulation_RNA.csv`)
# 	run(`wget https://raw.githubusercontent.com/f6v/data/master/simulation_ATAC.csv`)
# 	run(`wget https://raw.githubusercontent.com/f6v/data/master/labels.csv`)
# end

# ╔═╡ b3e57a5e-3f89-11eb-1122-17218be3ec4c
md"""
#### Read the data

Here we will apply `SingleCellNMF` to a simulated single-cell multiomics dataset which contains scRNA-seq and scATAC-seq data. The data has been previosly simulated using `MOSim` (Martínez-Mira and Tarazona 2018). Since it is a simulated dataset, we know the true number of clusters - 5.
"""

# ╔═╡ 74322ba8-3f9a-11eb-2833-dbf876466683
md"""
Set the variable values to the file paths in the system:
"""

# ╔═╡ 766fa040-3f8a-11eb-0142-5b8439fe7110
begin
	rna_file = "simulation_RNA.csv"
	atac_file = "simulation_ATAC.csv"
	labels_file = "labels.csv"
end

# ╔═╡ f638a082-3f9a-11eb-2bd6-f567e55363a2
begin
	rna_data = CSV.read(rna_file)
	rename!(rna_data, :Column1 => :gene_name)
	
	atac_data = CSV.read(atac_file)
	rename!(atac_data, :Column1 => :locus_name)

	labels_data = CSV.read(labels_file)
	rename!(labels_data, :Column1 => :cell_name)
end;

# ╔═╡ 1204a49e-3f9d-11eb-06c5-f91c92257ffd
md"""
Let's examine the structure of the data:
"""

# ╔═╡ 1e3593e0-3f9d-11eb-1c03-8b9ead1e7172
first(rna_data, 5)

# ╔═╡ 5039cc3c-3f9d-11eb-1b6a-0b09cfa7a4e8
first(atac_data, 5)

# ╔═╡ b07789ac-3fd4-11eb-3157-7d56d5007b18
md"""
Note that the input data is very sparse.
"""

# ╔═╡ 541c7ba2-3f9d-11eb-29a4-97295a582477
first(labels_data, 5)

# ╔═╡ 799bb0ae-3f9d-11eb-00dc-aff4153a09c1
md"""
### Running NMF

We can now run coupled NMF on RNA and ATAC data. Choice of `k` (dimensionality of latent space) is usually determined empirically (rather computationally intensive, as algoritm needs to be run many times). Since we have simulated data, we know the "true dimensionality" of the data. 
"""

# ╔═╡ 95c93ea2-3f9d-11eb-27cd-6bb7b62ec299
H, W_rna, W_atac, Z, R, obj_history = perform_nmf(rna_data, atac_data, 5;
	n_iter = 150)

# ╔═╡ 1c4ab4b0-3fa5-11eb-35dd-e330112258c6
md"""
Does objective value decrease?
"""

# ╔═╡ c8e29f3e-3fa4-11eb-3691-2b437f5b2621
begin
	plot(obj_history, title = "Optimization objective history", legend = false)
	xlabel!("Iteration")
	ylabel!("Objective value")
end

# ╔═╡ 979bf0f0-3fa5-11eb-245f-8b5f0c2d6c38
md"""
#### Visualize results

We can now assess the effect of aggregation of epigenetic signal by visualizing ATAC data in a low-dimensional space using UMAP. Let's define a helper function first.
"""

# ╔═╡ f21d582c-3fa5-11eb-0efe-b396524a0075
function plot_umap(umap_data::Array{Float64}, plot_title::String)
	scatter(umap_data[1,:], umap_data[2,:], color = labels_data[!, "group"], 
		title=plot_title, legend = false, marker=(2, 2, :auto, stroke(0)))
	xlabel!("UMAP 1")
	ylabel!("UMAP 2")
end

# ╔═╡ 61f440d0-3fa6-11eb-0cbb-e75f3aa2570f
begin
	umap_not_aggregated = reduce_dims_atac(atac_data)
	plot_umap(umap_not_aggregated, "Not aggregated ATAC")
end

# ╔═╡ c10bcf50-3fa5-11eb-3243-1b951ee4ce0b
begin
	umap_aggregated = reduce_dims_atac(atac_data, Z, R)
	plot_umap(umap_aggregated, "Aggregated ATAC")
end

# ╔═╡ 8248cb3c-3fa6-11eb-2c78-8d3f04584cb9
md"""
We can see that the sparse ATAC signal has been aggregated across similar cells, which makes identification of clusters easier. You can also try changing the value of `k` to see how it affects the results!
"""

# ╔═╡ 99c2caec-3fbd-11eb-24a6-17595dac79da
md"""
We can also visualize the importance of the factors in the cells. Matrix `H` captures cell loadings and the ith row of matrix `H` can be used to visualize the importance of the ith factor in each cell. Hopefully, the factors would capture major variability, such as cell type.

We start by defining a helper function:
"""

# ╔═╡ c86c10be-3fbd-11eb-2121-435d901c1f06
function plot_factor(umap_data::Array{Float64}, H::Array{Float64}, 
		factor_index::Int64)
	scatter(umap_data[1,:], umap_data[2,:], zcolor = H[factor_index, :], 
		title="Factor $(factor_index)", legend = false, marker=(2, 2, :auto, 
		stroke(0)))
	xlabel!("UMAP 1")
	ylabel!("UMAP 2")
end

# ╔═╡ 7422de64-3fd1-11eb-3a12-f3908e7c3eec
md"""
Now select which factor you want to show:

`Factor = ` $(@bind k_to_show html"<select><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option></select>")
"""

# ╔═╡ 2c1a3a58-3fbe-11eb-325c-73d5e92f851d
plot_factor(umap_aggregated, H, parse(Int64, k_to_show))

# ╔═╡ ca589470-3fbf-11eb-2099-a1834113d287
md"""
As we can see, the inferred factors are meaningful and capture the major sources of variability in the data.
"""

# ╔═╡ cf71609a-3f88-11eb-3173-0d3274ed03af
md"""
### References

Jin, S., Zhang, L. & Nie, Q. scAI: an unsupervised approach for the integrative analysis of parallel single-cell transcriptomic and epigenomic profiles. Genome Biol 21, 25 (2020). https://doi.org/10.1186/s13059-020-1932-8

Martínez C, Tarazona S (2020). MOSim: Multi-Omics Simulation (MOSim). R package version 1.4.0, https://github.com/Neurergus/MOSim.

"""

# ╔═╡ Cell order:
# ╠═d8139d04-3f87-11eb-10fa-c3e4fa828b57
# ╟─62dbdaf2-3f89-11eb-2738-530350bccb92
# ╠═a3c2226c-3f89-11eb-389e-9925792fc108
# ╠═d3c4c74a-3f8d-11eb-3918-8d7bff6cef04
# ╠═038be600-49f6-11eb-3734-590b7d723c66
# ╠═b3e57a5e-3f89-11eb-1122-17218be3ec4c
# ╟─74322ba8-3f9a-11eb-2833-dbf876466683
# ╠═766fa040-3f8a-11eb-0142-5b8439fe7110
# ╠═f638a082-3f9a-11eb-2bd6-f567e55363a2
# ╠═1204a49e-3f9d-11eb-06c5-f91c92257ffd
# ╠═1e3593e0-3f9d-11eb-1c03-8b9ead1e7172
# ╠═5039cc3c-3f9d-11eb-1b6a-0b09cfa7a4e8
# ╠═b07789ac-3fd4-11eb-3157-7d56d5007b18
# ╠═541c7ba2-3f9d-11eb-29a4-97295a582477
# ╠═799bb0ae-3f9d-11eb-00dc-aff4153a09c1
# ╠═95c93ea2-3f9d-11eb-27cd-6bb7b62ec299
# ╠═1c4ab4b0-3fa5-11eb-35dd-e330112258c6
# ╠═c8e29f3e-3fa4-11eb-3691-2b437f5b2621
# ╠═979bf0f0-3fa5-11eb-245f-8b5f0c2d6c38
# ╠═f21d582c-3fa5-11eb-0efe-b396524a0075
# ╠═61f440d0-3fa6-11eb-0cbb-e75f3aa2570f
# ╠═c10bcf50-3fa5-11eb-3243-1b951ee4ce0b
# ╠═8248cb3c-3fa6-11eb-2c78-8d3f04584cb9
# ╠═99c2caec-3fbd-11eb-24a6-17595dac79da
# ╠═c86c10be-3fbd-11eb-2121-435d901c1f06
# ╠═7422de64-3fd1-11eb-3a12-f3908e7c3eec
# ╠═2c1a3a58-3fbe-11eb-325c-73d5e92f851d
# ╠═ca589470-3fbf-11eb-2099-a1834113d287
# ╟─cf71609a-3f88-11eb-3173-0d3274ed03af
