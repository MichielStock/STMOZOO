### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 90b57e7c-71bf-4290-905c-a2ae677d7635
using BioAlignments, FASTX, PlutoUI

# ╔═╡ e4971d8d-b844-4cef-bf33-fdb97d52a6ca
md"""
# Finding design patterns in phage lytic proteins using evolutionary algorithms

*Exam project STMO*

**Ian Engels & Faust Schotte**
"""

# ╔═╡ cc3af6cb-efc7-4903-a1a6-a44135ba097b
md"""
## Introduction 

In this project we will give an overview of the steps involved in the development of the tool that performs a *de novo* design pattern discovery in a set of proteins of interest.
We will focus primarily on the discovery of design patterns in phage lytic proteins, however the tool can also be used to discover design patterns in other kinds of proteins over any type of organism.

### What is the in- and output?
As input of the tool we take a set of protein sequences in FASTA format. These will be multiple aligned, followed by detection of motifs using the consensus sequence, and an arbitrary threshold (depending on your own research question).
"""

# ╔═╡ 6ad398e1-9b14-4096-ab07-178ed0c9a03e
md"""
## The data
We will use a toy example to simply visualize and explain the different steps of the *de novo* protein design patterns discovery tool.
This toy example contains 7 subsequences of the scenence \"I LIKE PLANTS AND ANIMALS\".

At the end we will use three sets of protein sequences collected from NCBI (BLASTP) in FASTA format. The first set contains sequences of the lytic enzyme from phage species which are closely related (all *Pseudomonas phages*). The second set contains sequences of endolysin and lysin proteins (homologues) from *Staphylococcus phages*. The last set contains random lytic protein sequences from different phage species. The phage species of this final set are more distantly related compaired to the other two sets.

"""

# ╔═╡ 81e81775-1286-4780-baee-1984c9bf691b
proteins_toy = ["ILIKEPLANTSANDANIMALS", "ILIKEPLANTANDANIMAL", "ILIKEPLANTS","ILIKEPLANTSANIMALS","ILIKEANIMALS", "PLANTSANDANIMALS", "ILIKEAND"]

# ╔═╡ 0bf0c6ca-3eb8-4b43-8001-dc7e16ccefd2
md"""
### The read_file function (FASTX package)
This function works as follows:
1) The function has as input a string containing the name of your FASTA document.
2) It will open the file, read, and store the content. 
3) All unique sequences will be stored in a dictionairy, which will be used in subsequent steps. 

"""

# ╔═╡ be483eee-04dc-45eb-b827-b3701f11facb
function read_file(file)
	reader = FASTA.Reader(open(file, "r"))
	protein = Dict()
	all_seq = []
	for record in reader
		ID = FASTA.identifier(record)
		sequence = FASTA.sequence(record)
		if (sequence in all_seq) == false
			push!(protein, ID => String(sequence))
			push!(all_seq, sequence)
		else
			break
		end
	end
	close(reader)
	record = Nothing
	return protein
end

# ╔═╡ fb3685bf-3690-415a-88e5-ea838840d635
proteins_pseudo = collect(values(read_file("pseudomonas_phages_lytic_enzyme.txt")))

# ╔═╡ 062e799c-37ae-4404-adf2-4c3ce2cc62b1
proteins_coccus = collect(values(read_file("phage_lytic_proteins.txt")))

# ╔═╡ 525d4410-7c73-11ec-1a29-d3c07c314af3
proteins_random = collect(values(read_file("random_phage_lytic.txt")))

# ╔═╡ e4137347-bc1b-4e06-a4f7-c5662fb92aa3
md"""
## The *de novo* proteins design pattern discovery alghorithm

### Multiple Sequence Alignment
A multiple sequence alignment is based on the individual pairwise alignments of all protein sequence pairs. We took an evolutionary alghoritm using a tree based multiple alignment. This is done by taking the pair with the best score as initial alignment and in a stepwise manner adding the sequence which is the most closely related to the existing multiple sequence alignment, including iteration steps, which results in the most optimal alignment. Here we also take in account multiple subtrees, resulting in a less greedy and better result. 
The main problem with this approach, is the \"once a gap, always a gap\" problem. This means that once a gap is introduced in the alignment, this can not be undone in subsequent alignment steps. This problem is also present in heuristic and progressive alignment approaches such as ClustalW, and T-Coffee.
"""

# ╔═╡ 05c8dded-6b14-4d5a-9988-d477123516b3
md"""
#### 1. The pairwise_alignment function

We used the BioAlignment package in this function.

Our function works as follows:
1) The input contains two sequences you want to align. Also you can indicate which type of alignment you want to perform (e.g. Global alignment, SemiGlobal alignment or local alignment). We selected as default the Global alignment. The second parameter is the type of substitution matrix one wants to use when performing the alignment. We chose as default the BLOSUM62 matrix. However PAM30/70/250, or BLOSUM45/50/62/80/90 are also available, the choice of scoring matrix depends on the research question, as all will give slightly different results.
2) The output of the function is the alignment score and the two resulting aligned sequences in a string format.
"""

# ╔═╡ 31bea822-b6d1-4592-9e3b-ea201b6f0399
blosum62 = BLOSUM62

# ╔═╡ 1a78a955-7814-4141-a48a-98b33670e7ac
function pairwise_alignment(protein1, protein2, method = GlobalAlignment(), score_matrix = BLOSUM62) #possible substitution matrices are PAM30/70/250, BLOSUM45/50/62/80/90
	model = AffineGapScoreModel(score_matrix, gap_open=-12, gap_extend=-4)
	alignment1 = pairalign(method, replace(protein1, "-" => "*"), replace(protein2, "-" => "*"), model)
	scores = score(alignment1)
	align = alignment(alignment1)
	align_collected = collect(align)
	seq1 = join([x for (x, _) in align_collected])
	seq2 = join([y for (_,y) in align_collected])
	return scores, seq1, seq2
end
	

# ╔═╡ 229db0b5-c899-4b95-8f4a-2cf644700d51
md"""
##### 1.1. Pairwise alignment toy example
"""

# ╔═╡ 3e133739-a93f-45f4-a6c8-1eb1fc858f2e
pairwise_alignment(proteins_toy[1], proteins_toy[2], GlobalAlignment())

# ╔═╡ 60d87de2-200a-4b9c-93af-c837be725580
md"""
#### 2. The Similarity_matrix function
The similarity matrix is a matrix that contains the pairwise alignment scores of all sequence pairs. We use this as a base for the tree based (evolutionary) multiple sequence alignment. The highest score in the similarity matrix is correlated with the closest related sequences (in other words the best alignment will have the highest score). 
the function works as follows:
1) The input has to be a set of all protein sequences that have to be aligned. The parameters of your choosing which are used for the pairwise alignment can also be included (described in 1.).
2) The output is a list containing the score of all the sequences aligned to sequence X. We chose a list instead of a matrix, since it is more accessible for further use. Furthermore the score of the alignment of the intercept is set to -Inf, as this alignment is of no use in the multiple sequence alignment. 
"""

# ╔═╡ 451ada98-1ac7-4207-a36d-a9d30c8de48a
function similarity_matrix(protein, method = GlobalAlignment(), score_matrix = BLOSUM62)
	proteins = collect(protein)
	matrix = []
	for (ind, protein1) in enumerate(proteins)
		best = []
		for protein2 in proteins
			score, seq1, seq2 = pairwise_alignment(protein1, protein2, method, score_matrix)
			push!(best, score)
		end
		best[ind] = -Inf
		push!(matrix, best)
	end
	return matrix
end
	

# ╔═╡ 37763f01-2fc8-4d43-ad66-3b94ff7aecb1
md"""
##### 2.1. similarity matrix toy example
"""

# ╔═╡ 68cc0a27-c8d9-4eab-a03d-d87228725325
similarity_matrix(proteins_toy)

# ╔═╡ 21352e05-251a-4fcf-9441-592d5844bddf
md"""
### 3. Multiple_alignment function
The actual multiple sequence alignment (MSA) function consists of 3 subfunctions, which also use the pairwise alingment and similarity matrix function described above.
The entire multiple sequence alignment goes as follows:
1) The input is the same as was used in the similarity matrix function, which is a set of proteins that have to be aligned, and parameters for the pairwise alignment method. In contrast to the similarity matrix, we use a SemiGlobalAlignment for the MSA. 
The actual MSA: the output is a multiple sequence alignment:
1) Make a similarity matrix.
2) Find the 2 most closely related sequences by scanning the similarity matrix for the highest score.
3) Perform a pairwise alignment of these 2 sequences.
4) The 2 sequences are compared to all other consensus sequences (no consensus made in first alignment). If these do not match, the resulting sequence obtained from the pairwise alignment is added to the existing alignment.
5) This is the iteration step where the new sequence is added to the existing MSA and iterated to become the new MSA with the highest score (using the iterate function). This looks for the sequence pair with the highest score, and adds the other sequences with a decreasing score to the alignment (similarity based). The first iteration will always include the new sequence.
6) The sequences that were aligned are stripped from the set of non-aligned sequences. 
7) A consensus is made from the resulting sequences of the pairwise alignment. This consensus is added to the non-aligned sequence set. Basis of **The evolutionary alghorithm**. The consensus sequence is made by use of the make_consensus function.
8) Repeat steps 1-7 until all sequences are aligned.
9) Iterate 1 last time for optimal result.

"""

# ╔═╡ 2f3c3fcb-c91c-4b87-8818-3349d6ea85b2
function iterate(MSA, new_protein, method = GlobalAlignment(), score_matrix = BLOSUM62)
	n = length(MSA) + 1
	new_MSA = []
	if MSA == []
		new_MSA = [new_protein]
	end
	while length(new_MSA) < n #n = amount of sequences in the final alignment
		push!(MSA, new_protein)
		SM = similarity_matrix(MSA, method, score_matrix)
		line = pop!(SM)
		id2 = findfirst(isequal(maximum(line)), line)
		score, seq1, seq2 = pairwise_alignment(MSA[id2], new_protein, GlobalAlignment())
		if new_MSA == []
			push!(new_MSA, replace(seq2, "-" => "*"))
		end
		push!(new_MSA, replace(seq1, "-" => "*"))
		deleteat!(MSA, id2)
		pop!(MSA)
		new_protein = seq1
	end
	return new_MSA
end
	

# ╔═╡ 40d2a415-6c4a-4098-a79d-ca4926efde5d
function make_consensus(seq1, seq2)
	consensus = []
	for i in range(1, length =length(seq1)) #i = place of aminoaicd in sequence
		if seq1[i] == seq2[i]
			append!(consensus, seq1[i])
		else
			append!(consensus, "-")
		end
	end
	a = join(consensus)
	return replace(a, "-" => "*") #"*" instead of "-" because "-" not in BLOSUM62 matrix
end
			

# ╔═╡ ecfbf86e-d0d4-4747-94b0-6cfd20acc40f
function multiple_alignment(proteins, method = GlobalAlignment(), score_matrix = BLOSUM62)
	protein = copy(proteins)
	n = length(protein)
	evolution = []
	consensus = []
	while length(evolution) < n #n = number of sequences to be aligned
		SM = similarity_matrix(protein, method, score_matrix)
		id1 = findfirst(isequal(maximum(SM)), SM)
		line = SM[id1]
		id2 = findfirst(isequal(maximum(line)), line)
		score, seq1, seq2 = pairwise_alignment(protein[id2],protein[id1], SemiGlobalAlignment(), score_matrix)
		if (protein[id2] in consensus) == false
			evolution = iterate(evolution, seq1, method, score_matrix)
		end
		if (protein[id1] in consensus) == false
			evolution = iterate(evolution, seq2, method, score_matrix)
		end
		protein = symdiff!(proteins, (proteins[id1],proteins[id2]))
		new_consensus = make_consensus(seq1,seq2)
		push!(consensus, new_consensus)
		push!(protein, new_consensus)
	end
	return iterate(evolution[2:n], evolution[1])
end	

# ╔═╡ be90edbb-9253-473d-8d18-0e7a3166e5e9
md"""
##### 3.1. Multiple sequence alignment toy example
"""

# ╔═╡ c0329931-d53c-47ea-a2d4-7a0ab132f398
multiple_alignment(collect(proteins_toy))

# ╔═╡ 8c30956b-6687-4695-97f5-04a121ec1fda
md"""
### 4. Position count matrix (PCM) function
This matrix contains the occurance of a certain aminoacid at a specific location in the multiple alignment. This matrix can then be used to find a consensus of the MSA, which is needed to perform the *de novo* pattern detection.

The function works as follows:
1) Input are the proteins that have to be aligned, followed by the first step of the multiple sequence alignment. 
2) Each protein in the MSA is scanned individually to count which aminoacid occurs at which position.
3) The output is a Dictionairy instead of a matrix, for easier access. It contains as keys all aminoacids present in the sequence, including the gaps. The corresponding values are the count of the key (or aminoacid) at a location. *e.g.* A => [1,0,2], means at location 1 in the MSA 1 alanin residue, location 2 no alanin residues, and at location 3 two alanin residues.
"""

# ╔═╡ 114a1b19-ce5d-42b9-8d89-13ddbde876d6
function PCM(proteins, method = GlobalAlignment(), score_matrix = BLOSUM62)
	protein = collect(proteins)
	M_alignment = multiple_alignment(protein, method, score_matrix)
	n = length(M_alignment[1]) #n = length of a sequence in MSA
	pcm = zeros(Int32,n)
	dpcm = Dict()
	for proteins in M_alignment
		for index in range(1, length=n)
			if (proteins[index] in keys(dpcm)) == false
				push!(dpcm, proteins[index] => pcm)
			end
			change = collect(dpcm[proteins[index]])
			change[index] += 1
			push!(dpcm, proteins[index] => change)
		end
	end
	return dpcm
end
		

# ╔═╡ f9b99135-8deb-440a-a461-d3e392d0cf9a
md"""
##### 4.1. Position Count Matrix (PCM) toy example
"""

# ╔═╡ 583a1bcd-1ab3-4975-a54f-497b2f818a48
PCM(proteins_toy)

# ╔═╡ 61fe7cc1-88b7-4a95-8494-7ed3ba739e6d
md"""
### 5. The find_consensus function
This function makes a consensus sequence of the MSA by using the position count matrix. An aminoacid is allocated to a specific location if the frequency of that aminoacid at the specific location is higher than the manually entered frequency. The frequency is arbitrarily chosen according to the research question. We chose 85% coverage of an amino acid as default, because we are interested in motifs (conserved over distant relatives, since they have a biological purpose and are thus less subjected to mutation).
"""


# ╔═╡ 840c03fa-244c-48fd-bee0-9930ca5b73c9
function find_consensus(protein, frequency = 0.85, method = GlobalAlignment(), score_matrix = BLOSUM62)
	proteins = collect(protein)
	n = length(proteins) #amount of proteins, used to make frequency
	pcm = PCM(proteins, method, score_matrix)
	consensus = []
	freq = frequency
	for i in range(1,length =length(collect(values(pcm))[1]))
		new_AA = ""
		count = 0
		for AA in collect(keys(pcm)) #AA = Aminoacid
			if pcm[AA][i] > count
				count = pcm[AA][i]
				new_AA = AA
			end
		end
		if (count/n) > freq
			push!(consensus, new_AA)
		else
			push!(consensus, "-")
		end
	end
	return replace(join(consensus), "*" => "-")
end	

# ╔═╡ b7bf2bbb-92b1-4571-9d03-367883a96984
md"""
##### 5.1. MSA consensus sequence (with frequency >70%) toy example
"""

# ╔═╡ 79e55028-6e99-4a41-82d2-4240aafe167f
general_concensus = find_consensus(proteins_toy, 0.7)

# ╔═╡ a4fc186c-87b8-4e86-bb46-21c156f4cc9e
md"""
### 6. Motif detection
The final goal was to detect conserved motifs in a set of proteins of interest.
There are different kinds of design patterns in proteins, for example catalytic centers, signal peptides, anchoring peptides (part of a peptide that is embedded in for example the plasmamembrane), binding sites (for other proteins or substrate), and protein domains. 
In order to find these we look at overrepresented peptides (ranging between 3-20AA). We make a consensus sequence that shows coverage of >85% of an aminoacid. Than we look at the potential motifs. As in most cases the surrounding aminoacid of the biologicaly relevant aminoacid(s) tend to be linked, a low false positive discovery rate will be the result of our method.
Furthermore, to find catalytic centers and protein domains we look at the place of the discovered motifs. If these are close to each other (we chose <5 aminoacids apart) than there is a posibility that these belong to the same motif (if the resulting motif <20)(Asgari et al., 2018). 
"""

# ╔═╡ 74ffdcb2-31fb-4b47-96a7-119becf0521a
function detect_motifs(protein, frequency = 0.85, method = GlobalAlignment(), score_matrix = BLOSUM62)
	proteins = collect(protein)
	consensus = find_consensus(proteins, frequency, method, score_matrix)
	motifs = []
	motif = []
	stop = 0
	for element in consensus
		stop += 1
		if motif == [] && element != '-'
			push!(motif, element) 
			continue
		end
		if element == '-'
			if (length(motif) > 2) && (length(motif) < 21)
				push!(motifs, [join(motif), (stop - length(motif)), (stop-1)])
			end
			motif = []
		else
			push!(motif, element)
		end
	end
	if length(motif) > 2
		push!(motifs, [join(motif), (stop - length(motif)), (stop-1)])
	end
	return motifs
end	

# ╔═╡ 4c2fb83c-5460-484d-ae7c-841a447f9d10
md"""
##### 6.1. Motif discovery on real input sets
"""

# ╔═╡ e7100c60-b04a-47b4-8dfb-e95a361c17a3
detect_motifs(proteins_coccus, 0.8)

# ╔═╡ 614af78c-a801-455e-b757-79a3869ef609
detect_motifs(proteins_random, 0.5)

# ╔═╡ eb1d9e55-e37b-418e-8afc-bedf0f997f72
detect_motifs(proteins_pseudo, 0.8)

# ╔═╡ 39e43f6d-7a7a-4e3f-a346-2f5e718c5ec9
md"""
## References

1) Larkin, M.A. *et al.* (2007) "Clustal W and Clustal X version 2.0." Bioinformatics 23(21):2947-8 PubMed: 17846036  DOI: 10.1093/bioinformatics/btm404
2) Henikoff, S.; Henikoff, J.G. (1992). "Amino Acid Substitution Matrices from Protein Blocks". PNAS. 89 (22): 10915–10919. DOI: 10.1073/pnas.89.22.10915
3) Asgari, E., McHardy, A. & Mofrad, M.R.K. Probabilistic variable-length segmentation of protein sequences for discriminative motif discovery (DiMotif) and sequence embedding (ProtVecX). Sci Rep 9, 3577 (2019). https://doi.org/10.1038/s41598-019-38746-w
4) Proteins with FASTA sequences obtained from NCBI

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BioAlignments = "00701ae9-d1dc-5365-b64a-a3a3ebf5695e"
FASTX = "c2308a5c-f048-11e8-3e8a-31650f418d12"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BioAlignments = "~2.0.0"
FASTX = "~1.2.0"
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BioAlignments]]
deps = ["BioGenerics", "BioSequences", "BioSymbols", "IntervalTrees", "LinearAlgebra"]
git-tree-sha1 = "f610a3a965f187890edb0b1fdef4f30d77852edd"
uuid = "00701ae9-d1dc-5365-b64a-a3a3ebf5695e"
version = "2.0.0"

[[BioGenerics]]
deps = ["TranscodingStreams"]
git-tree-sha1 = "6d3f3b474b3df2e83dc67ad12ec63aee4eb5241b"
uuid = "47718e42-2ac5-11e9-14af-e5595289c2ea"
version = "0.1.1"

[[BioSequences]]
deps = ["BioGenerics", "BioSymbols", "Combinatorics", "IndexableBitVectors", "Printf", "Random", "StableRNGs", "Twiddle"]
git-tree-sha1 = "093ccb9211bdc71924abf8e74a0790af11da35a7"
uuid = "7e6ae17a-c86d-528c-b3b9-7f778a29fe59"
version = "2.0.5"

[[BioSymbols]]
deps = ["Automa"]
git-tree-sha1 = "ec77888ac3e78f9d372c2b533bdb52668f9e2b09"
uuid = "3c28c6f8-a34d-59c4-9654-267d177fcfa9"
version = "4.0.4"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FASTX]]
deps = ["Automa", "BioGenerics", "BioSequences", "BioSymbols", "TranscodingStreams"]
git-tree-sha1 = "6582055aa8f890663f63cbf9bc748b0a537b5fd3"
uuid = "c2308a5c-f048-11e8-3e8a-31650f418d12"
version = "1.2.0"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IndexableBitVectors]]
deps = ["Random", "Test"]
git-tree-sha1 = "b7f5e42dc867b8a8654a5f899064632dac05bc82"
uuid = "1cb3b9ac-1ffd-5777-9e6b-a3d42300664d"
version = "1.0.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IntervalTrees]]
deps = ["InteractiveUtils", "Profile", "Random", "Test"]
git-tree-sha1 = "6c9fcd87677231ae293f6806fad928c216ab6658"
uuid = "524e6230-43b7-53ae-be76-1e9e4d08d11b"
version = "1.0.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SIMD]]
git-tree-sha1 = "39e3df417a0dd0c4e1f89891a281f82f5373ea3b"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.0"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "b57c4216b6c163a3a9d674f6b9f7b99cdccdb959"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "0.1.2"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[Twiddle]]
git-tree-sha1 = "29509c4862bfb5da9e76eb6937125ab93986270a"
uuid = "7200193e-83a8-5a55-b20d-5d36d44a0795"
version = "1.1.2"

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
# ╟─e4971d8d-b844-4cef-bf33-fdb97d52a6ca
# ╠═90b57e7c-71bf-4290-905c-a2ae677d7635
# ╟─cc3af6cb-efc7-4903-a1a6-a44135ba097b
# ╟─6ad398e1-9b14-4096-ab07-178ed0c9a03e
# ╠═81e81775-1286-4780-baee-1984c9bf691b
# ╟─0bf0c6ca-3eb8-4b43-8001-dc7e16ccefd2
# ╠═be483eee-04dc-45eb-b827-b3701f11facb
# ╠═fb3685bf-3690-415a-88e5-ea838840d635
# ╠═062e799c-37ae-4404-adf2-4c3ce2cc62b1
# ╠═525d4410-7c73-11ec-1a29-d3c07c314af3
# ╟─e4137347-bc1b-4e06-a4f7-c5662fb92aa3
# ╟─05c8dded-6b14-4d5a-9988-d477123516b3
# ╠═31bea822-b6d1-4592-9e3b-ea201b6f0399
# ╠═1a78a955-7814-4141-a48a-98b33670e7ac
# ╟─229db0b5-c899-4b95-8f4a-2cf644700d51
# ╠═3e133739-a93f-45f4-a6c8-1eb1fc858f2e
# ╟─60d87de2-200a-4b9c-93af-c837be725580
# ╠═451ada98-1ac7-4207-a36d-a9d30c8de48a
# ╟─37763f01-2fc8-4d43-ad66-3b94ff7aecb1
# ╠═68cc0a27-c8d9-4eab-a03d-d87228725325
# ╟─21352e05-251a-4fcf-9441-592d5844bddf
# ╠═ecfbf86e-d0d4-4747-94b0-6cfd20acc40f
# ╠═2f3c3fcb-c91c-4b87-8818-3349d6ea85b2
# ╠═40d2a415-6c4a-4098-a79d-ca4926efde5d
# ╟─be90edbb-9253-473d-8d18-0e7a3166e5e9
# ╠═c0329931-d53c-47ea-a2d4-7a0ab132f398
# ╟─8c30956b-6687-4695-97f5-04a121ec1fda
# ╠═114a1b19-ce5d-42b9-8d89-13ddbde876d6
# ╟─f9b99135-8deb-440a-a461-d3e392d0cf9a
# ╠═583a1bcd-1ab3-4975-a54f-497b2f818a48
# ╟─61fe7cc1-88b7-4a95-8494-7ed3ba739e6d
# ╠═840c03fa-244c-48fd-bee0-9930ca5b73c9
# ╟─b7bf2bbb-92b1-4571-9d03-367883a96984
# ╠═79e55028-6e99-4a41-82d2-4240aafe167f
# ╟─a4fc186c-87b8-4e86-bb46-21c156f4cc9e
# ╠═74ffdcb2-31fb-4b47-96a7-119becf0521a
# ╟─4c2fb83c-5460-484d-ae7c-841a447f9d10
# ╠═e7100c60-b04a-47b4-8dfb-e95a361c17a3
# ╠═614af78c-a801-455e-b757-79a3869ef609
# ╠═eb1d9e55-e37b-418e-8afc-bedf0f997f72
# ╟─39e43f6d-7a7a-4e3f-a346-2f5e718c5ec9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
