### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ a3c2226c-3f89-11eb-389e-9925792fc108
using CSV

# ╔═╡ d8139d04-3f87-11eb-10fa-c3e4fa828b57
md"""
### Introduction to SingleCellNMF

This tutorial provides an introduction to using non-negative matrix factorization (NMF) with single-cell data.

#### What is SingleCellNMF?

SingleCellNMF is a module that implements NMF as proposed by Jin and colleagues in scAI (Jin et al. 2020). Therein, single-cell RNA-seq and ATAC-seq data is jointly factorized to find an optimal representation of both transcriptomic and epigenomic features in a shared latent space. Additionally, a sparse epigenomic signal is aggregated to achieve better separation between clusters when analyzing scATAC-seq data. Please see the documentation page and scAI publication for more details.
"""

# ╔═╡ 62dbdaf2-3f89-11eb-2738-530350bccb92
md"""
### Analyzing example data
#### Dependencies
"""

# ╔═╡ d3c4c74a-3f8d-11eb-3918-8d7bff6cef04
md"""
#### Download data

Use your tool of choice (wget, curl) to download the following files:
- [RNA](https://raw.githubusercontent.com/f6v/data/master/simulation_RNA.сsv)
- [ATAC](https://raw.githubusercontent.com/f6v/data/master/simulation_ATAC.сsv)
- [Labels](https://raw.githubusercontent.com/f6v/data/master/labels.сsv)
"""

# ╔═╡ b3e57a5e-3f89-11eb-1122-17218be3ec4c
md"""
#### Read the data

Here we will apply SingleCellNMF to a simulated single-cell multiomics dataset which contains scRNA-seq and scATAC-seq data. The data has been previosly simulated using MOSim (Martínez-Mira and Tarazona 2018). Since it is a simulated dataset, the true cell labels are known.
"""

# ╔═╡ 74322ba8-3f9a-11eb-2833-dbf876466683
md"""
Set the variable values to the file paths in the system:
"""

# ╔═╡ 766fa040-3f8a-11eb-0142-5b8439fe7110
begin
	rna_file = "simulation_RNA.сsv"
	atac_file = "simulation_ATAC.сsv"
	labels = "labels.сsv"
end

# ╔═╡ f638a082-3f9a-11eb-2bd6-f567e55363a2
begin
	
end

# ╔═╡ cf71609a-3f88-11eb-3173-0d3274ed03af
md"""
### References

Jin, S., Zhang, L. & Nie, Q. scAI: an unsupervised approach for the integrative analysis of parallel single-cell transcriptomic and epigenomic profiles. Genome Biol 21, 25 (2020). https://doi.org/10.1186/s13059-020-1932-8

Martínez C, Tarazona S (2020). MOSim: Multi-Omics Simulation (MOSim). R package version 1.4.0, https://github.com/Neurergus/MOSim.

"""

# ╔═╡ Cell order:
# ╟─d8139d04-3f87-11eb-10fa-c3e4fa828b57
# ╟─62dbdaf2-3f89-11eb-2738-530350bccb92
# ╠═a3c2226c-3f89-11eb-389e-9925792fc108
# ╟─d3c4c74a-3f8d-11eb-3918-8d7bff6cef04
# ╟─b3e57a5e-3f89-11eb-1122-17218be3ec4c
# ╟─74322ba8-3f9a-11eb-2833-dbf876466683
# ╠═766fa040-3f8a-11eb-0142-5b8439fe7110
# ╠═f638a082-3f9a-11eb-2bd6-f567e55363a2
# ╟─cf71609a-3f88-11eb-3173-0d3274ed03af
