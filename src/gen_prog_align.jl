# Kobe De Temmerman
# Try out source code file creation implementing a module
# Ks
module GenProgAlign

# Importing required packages
using BioSequences, BioAlignments, StatsBase, Random
# Export functions relevant for the user
export fasta_to_dict, seq_selection,Alignment, array_to_dict, objective_function, AA, pairwise_score,
one_point_crossover, gap_insertion, crude_method


"""
    fasta_to_dict(fasta_file::String)


Reads a fasta file and returns a dictionary with the identifiers as keys and
the sequences as values.
"""
function fasta_to_dict(path_to_fasta_file::String)
    fasta_file_handle = FASTA.Reader(open(path_to_fasta_file))
    sequence_dict = Dict()

    for a_record in fasta_file_handle
        push!(sequence_dict, BioSequences.FASTA.identifier(a_record) => sequence(a_record))
    end
    close(fasta_file_handle)
    return sequence_dict
end

"""
    seq_selection(sequence_dict::Dict; n::Int = 10, sorting::Bool = false)

Takes a subset of a sequence dictionary as created by `fasta_to_dict`. The first n id's in the 
dictionaries key list are selected. If sorting == true, the key list is first sorted alphabetically.
Returns a dictonary of the n selected, seq_id, sequence pairs.
"""
function seq_selection(sequence_dict::Dict; n::Int = 10, sorting::Bool = false)
    # QUESTION: since dictories don't have order, this might not make sense?
    seq_id_first_n = collect(keys(seq_dict))[1:n] 
    if sorting
        seq_id_first_n = sort(seq_id_first_n)
    end
    seq_dict_selection = Dict{String, String}()
    for seq_id in seq_id_first_n
        push!(seq_dict_selection, (seq_id => seq_dict[seq_id]))
    end
    return seq_dict_selection
end

"""
Create an Alignment type. The type has three attributes:
- `seq_array`: The alignment array, has a row for each distinct sequence, and columns for the residues
gaps are denoted as '-'.
- `seq_ids`: The sequence id's of the distinct sequences in the same order as they appear in the seq_array.
- `objective_value`: The score of the alignment as calculated by objective_function().
The Alignment type contains two inner constructors, to generate Alignment objects:
    Alignment(sequencedict::Dict; n::Int = 20)

Creates an initial alignment. Expects a dictionary as created by fasta_to_dict or seq_selection as input.
Every sequence receives a random amount of gaps between 0 and n at the left hand side. Gaps are added 
at the right hand side to equalize the sequence lengths. All generated sequences are combined in a seq_array, 
that is provided to the Alignment object. The seq_ids are directly extracted from the input dictionary
The objective_value is calculated with objective_function().

    Alignment(sequence_array::Array, seq_ids::Array, objective_value::Float)

Creates an alignment object with the provided content for the attributes.
"""

# FIXME: Array is an abstract type, so this will not be
# type stable, you can either be specify (e.g. `Maxtrix{Char}`)
# or work with parametric types
# this is a performance thing, your code will work regardless
struct Alignment
    seq_array::Array
    seq_ids::Array
    objective_value::Float64
    

    function Alignment(sequencedict::Dict; n::Int = 20)
        sequence_dict = deepcopy(sequencedict)
        max_seq_length = 0 # Keep track of the maximum sequence length to equalize the lengths afterwards.
        for seq_id in keys(sequence_dict)
            sequence_dict[seq_id] = string("-"^rand(0:n), sequence_dict[seq_id])
            if length(sequence_dict[seq_id]) > max_seq_length
                max_seq_length = length(sequence_dict[seq_id])
            end
        end

        sequence_array = Array{Char, 2}(undef, (length(sequence_dict), max_seq_length))
        seq_ids = Array{String, 1}(undef, length(sequence_dict))
        
        for (i, seq_id) in enumerate(keys(sequence_dict))
            sequence_array[i, :] = collect(string(sequence_dict[seq_id], "-"^(max_seq_length-length(sequence_dict[seq_id]))))
            seq_ids[i] = seq_id
        end
        objective_value = objective_function(sequence_array, seq_ids)
        new(sequence_array, seq_ids, objective_value)
    end

    function Alignment(sequence_array::Array, seq_ids::Array, objective_value::Float64)
        new(sequence_array, seq_ids, objective_value)
    end

    
end

"""
    array_to_dict(alignment)

Extract the seq_array and the seq_ids from an Alignment object and generate a dictionary with 
the seq_ids as keys and the corresponding sequences as their value.
"""
function array_to_dict(alignment)
    seq_dict = Dict(alignment.seq_ids[i] => join(alignment.seq_array[i,:]) for i = 1:length(alignment.seq_ids))
    return seq_dict
end

"""
    array_to_dict(seq_array::Array, seq_ids)

Generate a dictionary with the seq_ids as keys and the corresponding sequences as their value.
"""
function array_to_dict(seq_array::Array, seq_ids)
    seq_dict = Dict(seq_ids[i] => join(seq_array[i,:]) for i = 1:size(seq_array)[1])
    return seq_dict
end

"""
 Column-, and rownames of the BLOSUM62-matrix provided BioAlignments
"""
AA = ['A','R', 'N', 'D', 'C', 'Q', 'E',  'G', 'H',  'I' , 'L' , 'K',  'M', 'F','P', 'S',  'T', 'W',  'Y',  'V', 'O' ,'U', 'B', 'J', 'Z', 'X' ,'*']

"""
    pairwise_score(seq_1::String, seq_2::String; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)


Calculates pairwise alignment score between two sequences. The total score is the sum of individual scores for every
position in the alignment. The score for two matched aminoacids is determined by the used `score_matrx`. 
Opening new gaps in the alignment result in a `gap_opening` penalty, extending a gap in a `gep_extension` penalty.
"""
function pairwise_score(seq_1::String, seq_2::String; 
                            score_matrix = BLOSUM62, gap_opening = -10,
                            gap_extension = -1, symbols = AA)
    score = 0
    previous_gap_1 = false
    previous_gap_2 = false
    for (residue1, residue2) in zip(seq_1, seq_2)
        if !(residue1 == '-' || residue2 == '-')
            score += score_matrix[findall(symbols .== residue1)[1], findall(symbols .== residue2)[1]]
            previous_gap_1 = false
            previous_gap_2 = false
        end

        if residue1 == '-' 
            if previous_gap_1
            score += gap_extension
            else 
            score += gap_opening
            end
            previous_gap_1 = true
        end 

        if residue2 == '-' 
            if previous_gap_2
            score += gap_extension
            else 
            score += gap_opening
            end
            previous_gap_2 = true
        end
    end
    return score
end

"""
    objective_function(alignment, score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)

Calculates full alignment score of alignment provided in an `Alignment` object. The score
is the sum of all the pairwise alignment scores calculated with `pairwise_score()`.
"""
function objective_function(alignment, score_matrix = BLOSUM62,  #FIXME: keyword arguments cfr pairwise_score?
                            gap_opening = -10, gap_extension = -1, symbols = AA)
    seq_dict = array_to_dict(alignment)
    objective_value = 0
    seq_ids = alignment.seq_ids
    for i in 2:length(seq_dict)
        for j in 1:i-1
            objective_value += pairwise_score(seq_dict[seq_ids[i]], seq_dict[seq_ids[j]], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
        end
    end
    return objective_value
end

"""
    objective_function(seq_array::Array, seq_ids::Array, score_matrix = BLOSUM62,
                            gap_opening = -10, gap_extension = -1, symbols = AA)

Calculates full alignment score if a seq_array and seq_ids are provided. The score
is the sum of all the pairwise alignment scores calculated with pairwise_score().
"""
function objective_function(seq_array::Array, seq_ids::Array, score_matrix = BLOSUM62,  #FIXME: keyword arguments?
                            gap_opening = -10, gap_extension = -1, symbols = AA)
    seq_dict = array_to_dict(seq_array, seq_ids)
    objective_value = 0
    for i in 2:length(seq_dict)
        for j in 1:i-1
            objective_value += pairwise_score(seq_dict[seq_ids[i]],
                                                seq_dict[seq_ids[j]],
                                                score_matrix, gap_opening,
                                                gap_extension, symbols)
        end
    end
    return objective_value
end


# SUGGESTION: why not use two types of crossover:
# 1. sequence swap: randomly exchange sequences from the alignment matrices
# 2. breaking: choose a position to break your two alignments and swich out the first 

#=
e.g. 

AAAAA       DDDDD
BBBBB  and  EEEEE
CCCCC       FFFFF

First type might yield

DDDDD       AAAAA
BBBBB  and  EEEEE
FFFFF       CCCCC

Second type might yield

AAADD       DDDDD
BBBEE  and  EEEBB
CCCFF       FFFCC
=#

"""
    one_point_crossover(parent_1, parent_2)

Operation for the genetic algorithm. Create crossover between two parent alignments. In `parent_1`
a random position is selected, here the alignment is split in a left and a right part.
`parent_2` is split at the end residues of the first split. Two new alignments are created. 
One with the left part of `parent_1` and the right part of `parent_2`. And one with the 
left part of `parent_2` and the right part of `parent_1`. Gaps are inserted to ensure equal sequence lengths.
The new alginment with the best objective value is returned.
"""
function one_point_crossover(parent_1, parent_2)
    pos = rand(1:size(parent_1.seq_array)[2]-1)
    n_AA_upto_pos_vec = zeros(Int16, size(parent_1.seq_array)[1])
    pos_n_AA_alignment_2 = ones(Int16, size(parent_1.seq_array)[1])
    # FIXME: some comments would make this function be more maintainable...
    for seq in 1:size(parent_1.seq_array)[1]
        n_AA_upto_pos = sum(parent_1.seq_array[seq, 1:pos] .!= '-')
        n_AA_upto_pos_vec[seq] = n_AA_upto_pos
        n_AA = 0
        for residue in 1:size(parent_2.seq_array)[2]
            if parent_2.seq_array[seq, residue] != '-'
                n_AA += 1
                if n_AA == n_AA_upto_pos
                    pos_n_AA_alignment_2[seq] = residue
                    break 
                end
            end
        end
        
    end


    longest_left_part = maximum(pos_n_AA_alignment_2)
    longest_right_part = size(parent_2.seq_array)[2] - minimum(pos_n_AA_alignment_2)

    left_new_2 = fill('-', (size(parent_1.seq_array)[1], longest_left_part))
    right_new_1 = fill('-', (size(parent_1.seq_array)[1], longest_right_part))
  

    
    for seq in 1:size(parent_1.seq_array)[1]
        left_new_2[seq, 1:pos_n_AA_alignment_2[seq]] .= parent_2.seq_array[seq, 1:pos_n_AA_alignment_2[seq]]
        right_new_1[seq, end-(size(parent_2.seq_array)[2]-pos_n_AA_alignment_2[seq]-1):end] .= parent_2.seq_array[seq, end-(size(parent_2.seq_array)[2]-pos_n_AA_alignment_2[seq]-1):end]
    end
    
    new_alignment_1 = hcat(parent_1.seq_array[:, 1:pos], right_new_1)
    new_alignment_2 = hcat(left_new_2, parent_1.seq_array[:, pos+1:end])
    ov_1 = objective_function(new_alignment_1, parent_1.seq_ids)
    ov_2 = objective_function(new_alignment_2, parent_1.seq_ids)
    if ov_1 > ov_2
        return Alignment(new_alignment_1, parent_1.seq_ids, ov_1)
    else
        return Alignment(new_alignment_2, parent_1.seq_ids, ov_2)
    end
end

""" 
    gap_insertion(alignment)

Operation for the genetic algorithm. The sequences in the parent alignment are splitted in 2 groups.
For each group a random position is selected where a gap is inserted. A new Alignment object is returned.
"""
function gap_insertion(parent)
    n_seq = length(parent.seq_ids)
    length_alignment = size(parent.seq_array)[2]
    n_per_group = convert(Int8, round(n_seq/2))  # or: n_seq ÷ 2
    group_selection = fill(true, n_seq)
    group_selection[sample(1:n_seq, n_per_group, replace = false)] .= false
    insertion_position_1 = rand(1:length_alignment)
    insertion_position_2 = rand(insertion_position_1-10:insertion_position_1+10)
    gapped_group_1 = hcat(parent.seq_array[group_selection, 1:insertion_position_1],
                            fill('-', n_per_group), 
                            parent.seq_array[group_selection, insertion_position_1+1:end])
    gapped_group_2 = hcat(parent.seq_array[.!group_selection, 1:insertion_position_2], 
                            fill('-', n_seq-n_per_group),
                            parent.seq_array[.!group_selection, insertion_position_2+1:end])
    new_seq_array = Array{Char, 2}(undef, (n_seq, length_alignment+1))
    new_seq_array[group_selection, :] = gapped_group_1
    new_seq_array[.!group_selection,:] = gapped_group_2
    objective_value = objective_function(parent)
    new_alignment = Alignment(new_seq_array, parent.seq_ids, objective_value)
    return new_alignment
end

"""
    shifting_one_seq(parent)

Operation for the genetic algorithm. One parent sequence in the parent alignment is randomly selected.
This sequence is shifted one position to the left by removing a gap and insert it at the right hand side.
"""
function shifting_one_seq(parent)
    seq = rand(1:length(parent.seq_ids))
    pos = 0
    while true
        pos = rand(1:size(parent.seq_array)[2])
        if parent.seq_array[seq, pos] == '-'
            break
        end
    end
    shift_to_left = rand(Bool)
    new_alignment = deepcopy(parent.seq_array)
    if shift_to_left
        new_alignment[seq, pos:end] = vcat(parent.seq_array[seq, pos+1:end], '-')
    else
        new_alignment[seq, 1:pos] = vcat('-', parent.seq_array[seq, 1:pos-1])
    end
    objective_value = objective_function(new_alignment, parent.seq_ids)
    return Alignment(new_alignment, parent.seq_ids, objective_value)
end

"""
    shifting_block(parent, partial = false)
    
Operation for the genetic algorithm. A random block in the `parent` alignment is searched.
To choose a block a position is searched where only amino-acids and no gaps are present. 
For every sequence all non-gap values adjacent to this position are taken up in the block. 
This block is shifted to the left with one position.
"""
function shifting_block(parent)
    n_seq = length(parent.seq_ids)
    length_alignment = size(parent.seq_array, 2)
    sample_order = shuffle(1:length_alignment)
    residue_found = false
    start_pos = 0
    for residue in sample_order
        if all(parent.seq_array[:, residue] .!= '-')
            start_pos = residue
            residue_found = true
            break
        end
    end
    
    if residue_found
        block_end_left = zeros(n_seq)
        block_end_right = zeros(n_seq)
        for seq in 1:n_seq
            pos_left = deepcopy(start_pos) - 1
            pos_right = deepcopy(start_pos) +1
            while true
                if pos_left == 0 
                    break
                end
                if parent.seq_array[seq, pos_left] == '-'
                    block_end_left[seq] = pos_left
                    break
                else
                    pos_left -= 1
                end
            end
            while true
                if pos_right == length_alignment
                    block_end_right[seq] = pos_right
                    break
                end
                if parent.seq_array[seq, pos_right] == '-'
                    block_end_right[seq] = pos_right
                    break
                else
                    pos_right += 1
                end
            end

        end
            

        if all(block_end_left .!= 0)
            block_end_left = convert(Array{Int16, 1}, block_end_left)
            block_end_right = convert(Array{Int16, 1}, block_end_right)
            new_seq_array = Array{Char, 2}(undef, (n_seq, length_alignment))
            for seq in 1:n_seq
                #new_seq_array[seq, :] .= alignment.seq_array[seq, vcat(1:block_end_left[seq]-1, block_end_left[seq]+1:length_alignment)]
                new_seq_array[seq, :] .= vcat(parent.seq_array[seq, 1:block_end_left[seq]-1], 
                                                parent.seq_array[seq, block_end_left[seq]+1:block_end_right[seq]-1],
                                                '-',
                                                parent.seq_array[seq, block_end_right[seq]:end])
            end
        end

    objective_value = objective_function(new_seq_array, parent.seq_ids)
    return Alignment(new_seq_array, parent.seq_ids, objective_value)
    end
    
    
end
end


# function genetic_algorithm(seq_dict::Dict, n_start = 20)
#     alignments = Array(Any, 1)(undef, n_start)
#     for i = 1:n_start
#         alignments[i] = Alignment(seq_dict)
#     end
#     operation_chance = fill(1/4, 4)
#     operations = ["one_point_crossover", "gap_insertion", "shifting_one_seq", "shifting_block"]
#     last_sucesses = fill(1, (4, 10))
#     for 1 in 1:10000
#         rand[operations]
#     end
        
        

#     end
# end




    






