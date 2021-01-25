### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ be3a9b90-4869-11eb-34c8-1ff89e8e7b4a
using BioAlignments

# ╔═╡ e5939cee-48e1-11eb-119a-63226a6d12a9
using STMOZOO.GenProgAlign, Random

# ╔═╡ 8204d79e-4849-11eb-2144-83ba3693990d
md"
# GenProgAlign
##### Multiple sequence alignment with genetic programming

## Introduction
Multiple sequence alignment is the task of aligning three or more biological (RNA, 
DNA, aminoacid) sequences that are assumed to have an evolutionary relationship.
This can be used for example to infer structural properties of sequences based on it's 
similarity with other sequences, to find common patterns in sequence families so pcr-primers can be designed for unknown sequences. 

Homogologous sequences descent from a common ancestor. They diverge from eachother
by mutation events, like deletions, insertions, SNP's... Their survival is controlled by the selection of individuals that have sequences with the most functional properties. Multiple sequence alignment tries to look for equivalent regions/residues between the diverged sequences and places where deletions or imputations have been introduced.
In the module GenProgAlign a genetic algorithm is available to perform multiple sequence alignment, the algorithm is inspired by SAGA (Notredame, Higgins, 1996)$^1$
, but contains only a small subset of the suggested alignment mutation operations.
For simplification there is also no phylogenetic information ,generated with clustalw,
used to build weights for the alignment score or to seperate the sequences in 2 groups. The algorithm was implemented with peptidesequences in mind, but when an appropriate scorematrix is used DNA/RNA-alignments are also possible.

## Genetic algorithm (GA)
A genetic algorithm is a metaheuristic that is part of the class of evolutionary algorithms. In genetic algorithms a problem is solved starting from a population of 
initial solutions. The fitness of the individuals is calculated with an appropriate
objective function. Mutations and crossovers are present to introduce variability and changes in the solutions. A new generation is chosen based on the fitness of the (mutated) individuals. The process of mutation and selection is repeated untill a certain stop criterion is reached.

In GenProgAlign the functions ga_alignment is present that performs a genetic algorithm to do multiple sequence alignment. 

### Starting population
The starting population is created starting from the raw sequences. Random gaps between the residues are inserted in the raw sequences. This is done repeatedly to create a population of  a chosen size with differing individuals.

### Fitness function
A simple objective function is used to estimate the fitness of the alignments. 
The value of the objective function is a score, a higher score indicates a more fit 
alignment. The objective value is the sum of the pairwise alignment scores between all unique pairs of sequences in the alignemnt. The pairwise alignment score between two sequences is calculated with the aid of a score matrix. The 2 sequences, who are forced to have an equal length, are walked through from the start to the end and for each pair of residues the substitution score is added to the total pairwise score. This substitution score is extracted from the score matrix and is an indication for the likelihood that a certain residue of a sequence is transformed to the other residue preserving the functionality and structure of the biological molecule (protein, dna, rna). The BLOSUM62 subsitution matrix is used as the default score matrix and is only applicable for protein alignment. In the pairwise score calculation different penalties are added for gap openings and gap extension. 

### Generations 
In each generation of the genetic algorithm the 50% individuals with the highest alignment scores are kept to include in the next generation. The other 50% individuals are replaced one by one. This is done by mutating individuals of the parent alignment 
if this mutation results in a higher fitness score, the child alignment is included in the next generation. The parents are selected with replacement because this was observed to perform better than without replacement. New generations are calculated until the algorithm fails to find improvements for a certain amount of times.
"

# ╔═╡ ced0d2d0-4869-11eb-1da8-d98dc1ce69d2
BLOSUM62

# ╔═╡ 28339150-486f-11eb-1ece-dbd89752b1d4
md"
### Operations
Four operations are included in the genetic algorithm. Additional operations can be found in the SAGA algorithm (Notredame, Higgins, 1996)$^1$ 
It is charachteristic for genetic algorithms that both crossover and mutation operations are present, respective 1 and 3. 

##### Operation 1: One point crossover
As the name suggestst this is a crossover operation. 2 parent alignments are both split into 2 halves, the left(right) part of parent 1 and the right(left) part of parent 2 are combined to create two new alignments. The splitting of the 2 parents is done in a way that the children alignments still contain the full sequences, without artificial duplications/deletions.

##### Operation 2: Gap insertion
This mutation operation introduces new gaps in the alignments. All sequences in the aligment are devided into 2 groups. For each group in the alignment a random position in the alignment is chosen where a new gap is inserted. 

##### Operation 3: Shifting one sequence
In this mutation operation one random sequence in the alignment is selected and is partly shifted to the left or to the right. This is done by choosing a random gap in the sequence and replace this to the left or right end of the sequence.

##### Operation 4: Block shifting 
Another shifting mutation operation is the block shift. In this operation a block of residues is shifted. A block here is defined as a contiguous collection of aminoacids across all sequences in the alignment and contains thus no gaps. This block is randomly chosen and shifted one position to the right or left.

### Dynamic programming of the operations.
The next operation that will be used is chosen randomly but the chances to pick a certain operation is not necessarily uniform. This chance is influenced by the recent performance of the operations. While the algorithm runs it keeps track of the 10 most recent changes of the child's alignment score compared to the parents alignment score for each operation. According to the relative average recent performance the chance of selecting an operation is changed, increasing the chance to pick well performing operations.

### Example
Below an example of the use of GenProgAlign.ga_alignment is shown. The first 10 sequences of the UBQ data of the QuanTest2 dataset (Sievers, Higgins, 2020)$^2$ are used as a toy example. 

As a baseline test the objective value of the left aligned raw data is calculated
"

# ╔═╡ 0a29cde0-48e3-11eb-13b5-49b9a03d1d2c
raw_data, seq_ids = fasta_to_array("UBQ_small.fasta")

# ╔═╡ 2015f110-48ed-11eb-3fba-29f26b72068e
begin
	md"$raw_data"
end

# ╔═╡ bbff7e90-48eb-11eb-3c5d-6977837da153
md"To make all sequence lengths equal gaps are added at the right side."

# ╔═╡ ef696bb0-48eb-11eb-1983-8f36dca89440
begin 
	sequence_lengths = length.(raw_data)
	max_sequence_length = maximum(sequence_lengths)
	raw_data_equal_lengths = [join([raw_data[seq], "-"^(max_sequence_length - sequence_lengths[seq])]) for seq in 1:length(raw_data)]
end

# ╔═╡ a7725152-48f0-11eb-13e0-5beef86a1717
raw_data_equal_lengths

# ╔═╡ 47dba850-48f4-11eb-20ae-033f9f053dbe
md"Calculate the fitness score for this initial alignment"

# ╔═╡ 615a73b0-48f4-11eb-0666-4b80ff0a89a0
objective_value_raw_alignment = objective_function(raw_data_equal_lengths)

# ╔═╡ 95a4d5c0-48f4-11eb-0953-2bac0d3390c6
md"The ga_alignment function is used to find a better alignment. A population size of 50 is used. p ∈ [0:1] can be interpreted as the similarity between individuals in the initial population, for this example high values of p resulted in better alignments."

# ╔═╡ be2f19b0-48f4-11eb-36d8-19df0e2678d3
begin 
	Random.seed!(100)
	alignment, score , _ = GenProgAlign.ga_alignment("UBQ_small.fasta", population_size = 50, p = 0.95, max_operations_without_improvement = 500, max_operations = 20000)
end

# ╔═╡ 006f058e-48f7-11eb-3a50-cf1292121995
alignment

# ╔═╡ 78f6e320-48f7-11eb-3302-f7375d601f12
score

# ╔═╡ be254e50-48f7-11eb-239e-8387d373f813
md"The alignment score increases from 2076 to 6992. It is hard to imagine what this improvement of 5000 points means. So we can compare it to other random alignments to get a little more insight into the variability of the alignment score."

# ╔═╡ b4e8b150-48f8-11eb-39a2-99656f132ddf
begin
	Random.seed!(100)
		scores = []
	for i = 1:10	
		random_alignment = GenProgAlign.Alignment(raw_data, p = 0.95)
		push!(scores, objective_function(random_alignment))
	end
	scores
end

# ╔═╡ 6dbc4150-48fa-11eb-0667-cfbeb9f7f5dd
md"The alignment score reached after using the algorithm is thus clearly better than the ones of the random alignments."

# ╔═╡ 921d0a60-48fb-11eb-3c99-db5f6d0ad09f
md"### Problems
The problem with this (implementation of the) algorithm is that running the algorithm multiple times can result in different alignments, with a variable fitnessscore. For example if the alignment procedure is run again, the resulting alignment score decreases from 6992 to 4884."

# ╔═╡ cb1b9b20-48fa-11eb-0a9a-ab57806c967a
begin 
	Random.seed!(1000)
	alignment_2, score_2 , __ = GenProgAlign.ga_alignment("UBQ_small.fasta", population_size = 50, p = 0.95, max_operations_without_improvement = 500, max_operations = 20000)
end

# ╔═╡ 5f53f120-48fb-11eb-0f7e-fd366cc18d5c
alignment_2

# ╔═╡ 49b0b240-48fb-11eb-1684-753db08c0a76
score_2

# ╔═╡ a8f8d3d0-48fc-11eb-3a4e-3b1b99cd939d
md"
Before this module is used for multiple sequence alignment it is important that additional operations are included. There are also a lot of parameters that influence the performance of the model, like the population size, the randomness of the alignments, these should also still be analysed and optimized."

# ╔═╡ f9ea171e-484a-11eb-1aa1-572f1d21ff97
md"
### References
1. Cédric Notredame, Desmond G. Higgins, SAGA: Sequence Alignment by Genetic Algorithm, Nucleic Acids Research, Volume 24, Issue 8, 1 April 1996, Pages 1515–1524, https://doi.org/10.1093/nar/24.8.1515

2. Fabian Sievers, Desmond G Higgins, QuanTest2: benchmarking multiple sequence alignments using secondary structure prediction, Bioinformatics, Volume 36, Issue 1, 1 January 2020, Pages 90–95, https://doi.org/10.1093/bioinformatics/btz552"



# ╔═╡ Cell order:
# ╟─8204d79e-4849-11eb-2144-83ba3693990d
# ╟─be3a9b90-4869-11eb-34c8-1ff89e8e7b4a
# ╟─ced0d2d0-4869-11eb-1da8-d98dc1ce69d2
# ╟─28339150-486f-11eb-1ece-dbd89752b1d4
# ╠═e5939cee-48e1-11eb-119a-63226a6d12a9
# ╠═0a29cde0-48e3-11eb-13b5-49b9a03d1d2c
# ╟─2015f110-48ed-11eb-3fba-29f26b72068e
# ╟─bbff7e90-48eb-11eb-3c5d-6977837da153
# ╠═ef696bb0-48eb-11eb-1983-8f36dca89440
# ╟─a7725152-48f0-11eb-13e0-5beef86a1717
# ╟─47dba850-48f4-11eb-20ae-033f9f053dbe
# ╠═615a73b0-48f4-11eb-0666-4b80ff0a89a0
# ╟─95a4d5c0-48f4-11eb-0953-2bac0d3390c6
# ╠═be2f19b0-48f4-11eb-36d8-19df0e2678d3
# ╠═006f058e-48f7-11eb-3a50-cf1292121995
# ╠═78f6e320-48f7-11eb-3302-f7375d601f12
# ╟─be254e50-48f7-11eb-239e-8387d373f813
# ╠═b4e8b150-48f8-11eb-39a2-99656f132ddf
# ╟─6dbc4150-48fa-11eb-0667-cfbeb9f7f5dd
# ╟─921d0a60-48fb-11eb-3c99-db5f6d0ad09f
# ╠═cb1b9b20-48fa-11eb-0a9a-ab57806c967a
# ╠═5f53f120-48fb-11eb-0f7e-fd366cc18d5c
# ╠═49b0b240-48fb-11eb-1684-753db08c0a76
# ╟─a8f8d3d0-48fc-11eb-3a4e-3b1b99cd939d
# ╟─f9ea171e-484a-11eb-1aa1-572f1d21ff97
