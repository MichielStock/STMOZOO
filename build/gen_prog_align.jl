# Kobe De Temmerman
module GenProgAlign

# Importing required packages
using BioSequences, BioAlignments, StatsBase, Random
# Export functions relevant for the user
export ga_alignment, fasta_to_array, objective_function

"""
    ga_alignment(path_to_fasta_file; population_size = 50, p = 0.95, max_operations_without_improvement = 2000, max_operations = 10000,score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)

Uses a genetic algorithm to perform alignment between a set of sequences. 
4 mutations are included:
- Single point crossover: Left part of 1 parent alignment is combined with right part of other parent alignment
- Gap insertion: At a random position of a random sequence in the alignment, one or more gaps are inserted.
- Shifting one sequence: A part of one sequence in the alignment is shifted to the left or the right
- Shifting a block: A contiguous block of residues is shifted in the alignment.

The algorithm starts from a random population of allignments. Every generation the 50% individuals with the best
alignment score  are kept the other 50% are replaced. To find replacements parent alignments
are mutated and selected if the mutant has a higher alignment score than it's parent. 
    
"""
function ga_alignment(path_to_fasta_file; population_size = 50, p = 0.95, max_operations_without_improvement = 2000, max_operations = 10000,score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    # Read in fastafile with  GenProgAlign.fasta_to_array 
    raw_data, seq_ids = fasta_to_array(path_to_fasta_file)
    n_seq = length(raw_data)
    # Create initial population and calculate their scores
    population = Array{Array, 1}(undef, population_size)
    scores = zeros(population_size)
    new_scores = deepcopy(scores)
    for individual = 1:population_size
        population[individual] = Alignment(raw_data, p = p)
        scores[individual] = objective_function(population[individual], 
                                                score_matrix = score_matrix,
                                                gap_opening = gap_opening,
                                                gap_extension = gap_extension,
                                                symbols = symbols)
    end

    # Define variables necessary for the dynamic scheduling of the operations
    operation_chance = ProbabilityWeights(fill(1/4, 4))
    parent_chance = ProbabilityWeights(fill(1/population_size, population_size))
    operations = [(1, "one_point_crossover"), (2, "gap_insertion"), (3, "shifting_one_seq"), (4, "shifting_block")]
    operation_performance = fill(1.0, (4, 10))
    performance_points = [0, 1/7 * 0.5, 2/7 * 0.5, 4/7 * 0.5]
    n_individuals_replaced = convert(Int16, round(population_size/2))
    renew = ones(Int, 4)
    go_on = true
    n_operations_without_improvement = 0
    n_operations = 0
    while go_on
        println(scores)
        new_population = deepcopy(population)
        new_scores = deepcopy(scores)
        replaced_individuals = sortperm(scores)[1:n_individuals_replaced]
        child = Array{String, 1}(undef, n_seq)
        for replacement_i in replaced_individuals
            parent_chance = ProbabilityWeights(fill(1/population_size, population_size))
            while true
                operation = sample(operations, operation_chance)
                parent_1 = sample(1:population_size, parent_chance)
                parent_2 = 0
                if operation[2] == "one_point_crossover"
                    parent_chance_opc = deepcopy(parent_chance)
                    parent_chance_opc[parent_1] = 0
                    parent_chance = ProbabilityWeights(parent_chance/ sum(parent_chance))
                    parent_2 = sample(1:population_size, parent_chance_opc)

                    child = one_point_crossover(population[parent_1], population[parent_2], 
                                                score_matrix = score_matrix, 
                                                gap_opening = gap_opening,
                                                gap_extension = gap_extension,
                                                symbols = symbols)
                    
                elseif operation[2] == "gap_insertion"
                    child = gap_insertion(population[parent_1])
                    for i = 1:5
                        child = gap_insertion(child)
                    end
                    
                elseif operation[2] == "shifting_one_seq"
                    child = shifting_one_seq(population[parent_1])
                    for i = 1:20
                        child = shifting_one_seq(child)
                    end
                else
                    child, parent_or_not = shifting_block(population[parent_1])

                end
                
                new_objective_value = objective_function(child, 
                                                            score_matrix = score_matrix,
                                                            gap_opening = gap_opening,
                                                            gap_extension = gap_extension,
                                                            symbols = symbols)
                
                if operation[2] == "one_point_crossover"
                    previous_score = minimum(scores[[parent_1, parent_2]])
                    operation_performance[operation[1], renew[operation[1]]] = new_objective_value - previous_score
                elseif operation[2] == "shifting_block"   
                    if parent_or_not
                        operation_performance[operation[1], renew[operation[1]]] = mean(operation_performance[operation[1], :])
                    else
                        operation_performance[operation[1], renew[operation[1]]] = new_objective_value - scores[parent_1]
                    end
                else
                    operation_performance[operation[1], renew[operation[1]]] = new_objective_value - scores[parent_1]
                end

                operation_chance = [0.05, 0.2, 0.2, 0.05]
                operation_chance[sortperm(mean(operation_performance, dims = 2)[:,1])] .+= performance_points 
                operation_chance = ProbabilityWeights(operation_chance)

                
                if operation[2] == "one_point_crossover"
                    parent_objective_value = maximum([scores[parent_1], scores[parent_2]])
                else
                    parent_objective_value = scores[parent_1]
                end

                if new_objective_value > parent_objective_value && child ∉ new_population
                    new_population[replacement_i] = child
                    new_scores[replacement_i] = new_objective_value
                    parent_chance[parent_1] = 0
                    if operation[2] == "one_point_crossover"
                        parent_chance[parent_2] = 0
                    end
                    parent_chance = ProbabilityWeights(parent_chance ./ sum(parent_chance))
                    
                    n_operations_without_improvement = 0
                    n_operations +=1
                    break
                else 
                    n_operations_without_improvement +=1
                    n_operations +=1
                    if n_operations_without_improvement > max_operations_without_improvement || n_operations > max_operations
                        
                        go_on = false
                        break
                    end
                end
                if renew[operation[1]] == 10
                    renew[operation[1]] = 1
                else
                    renew[operation[1]] += 1
                end


            end
            
        end
        scores = deepcopy(new_scores)
        population = deepcopy(new_population)
    end 
    
    return population[sortperm(scores)[end]], maximum(scores)

end
    
     


"""
    fasta_to_dict(fasta_file::String)


Reads a fasta file and returns 2 arrays 
"""



function fasta_to_array(path_to_fasta_file::String)
    fasta_file_handle = FASTA.Reader(open(path_to_fasta_file))
    sequence_array = Array{String, 1}(undef, 0)
    seq_ids = Array{String, 1}(undef, 0)

    for a_record in fasta_file_handle
        push!(sequence_array, sequence(a_record))
        push!(seq_ids, FASTA.identifier(a_record))
    end
    close(fasta_file_handle)
    return sequence_array, seq_ids

end


"""
    seq_selection(sequence_dict::Dict; n::Int = 10, sorting::Bool = false)

Takes a subset of a sequence dictionary as created by fasta_to_dict. The first n id's in the 
dictionaries key list are selected. If sorting == true, the key list is first sorted alphabetically.
Returns a dictonary of the n selected, seq_id, sequence pairs.
"""
function seq_selection(sequence_dict::Dict; n::Int = 10, sorting::Bool = false)
    seq_id_first_n = collect(keys(sequence_dict))[1:n] 
    if sorting
        seq_id_first_n = sort(seq_id_first_n)
    end
    seq_dict_selection = Dict{String, String}()
    for seq_id in seq_id_first_n
        push!(seq_dict_selection, (seq_id => sequence_dict[seq_id]))
    end
    return seq_dict_selection
end

"""
Create an Alignment type. The type has three attributes
- seq_array: The alignment array, has a row for each distinct sequence, and columns for the residues
gaps are denoted as '-'.
- seq_ids: The sequence id's of the distinct sequences in the same order as they appear in the seq_array.
- objective_value: The score of the alignment as calculated by objective_function().
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


# struct Alignment
#     seq_array::Array
#     seq_ids::Array
#     objective_value::Float64
    

#     function Alignment(sequencedict::Dict; n::Int = 20)
#         sequence_dict = deepcopy(sequencedict)
#         max_seq_length = 0 # Keep track of the maximum sequence length to equalize the lengths afterwards.
#         for seq_id in keys(sequence_dict)
#             sequence_dict[seq_id] = string("-"^rand(0:n), sequence_dict[seq_id])
#             if length(sequence_dict[seq_id]) > max_seq_length
#                 max_seq_length = length(sequence_dict[seq_id])
#             end
#         end

#         sequence_array = Array{Char, 2}(undef, (length(sequence_dict), max_seq_length))
#         seq_ids = Array{String, 1}(undef, length(sequence_dict))
        
#         for (i, seq_id) in enumerate(keys(sequence_dict))
#             sequence_array[i, :] = collect(string(sequence_dict[seq_id], "-"^(max_seq_length-length(sequence_dict[seq_id]))))
#             seq_ids[i] = seq_id
#         end
#         objective_value = objective_function(sequence_array, seq_ids)
#         new(sequence_array, seq_ids, objective_value)
#     end

#     function Alignment(sequence_array::Array, seq_ids::Array, objective_value::Float64)
#         new(sequence_array, seq_ids, objective_value)
#     end

    
# end


# function Alignment(seq_array; n::Int = 20)
#     max_seq_length = 0 
#     alignment = Array{String, 1}(undef, length(seq_array))# Keep track of the maximum sequence length to equalize the lengths afterwards.
#     for seq in 1:length(seq_array)
#         alignment[seq] = string("-"^rand(0:n), seq_array[seq])
#         if length(alignment[seq]) > max_seq_length
#             max_seq_length = length(alignment[seq])
#         end
    
#     end
#     for seq in 1:length(alignment)
#         alignment[seq]= join([alignment[seq], "-"^(max_seq_length-length(alignment[seq]))])
#     end
#     #objective_value = objective_function(alignment)
#     return alignment 
# end

function Alignment(seq_array; p = 0.8)
    max_seq_length = 0 
    alignment = Array{String, 1}(undef, length(seq_array))# Keep track of the maximum sequence length to equalize the lengths afterwards.
    for seq in 1:length(seq_array)
        sequence = fill('-', rand(1:5))
        for residue in 1:length(seq_array[seq])
            while true
                gap_or_not = rand()
                if gap_or_not > p
                    push!(sequence, '-')
                else
                    break
                end
            end
            
            push!(sequence, seq_array[seq][residue])
        end

        alignment[seq] = join(sequence)
        if length(alignment[seq]) > max_seq_length
            max_seq_length = length(alignment[seq])
        end
    
    end
    
    for seq in 1:length(alignment)
        alignment[seq]= join([alignment[seq], "-"^(max_seq_length-length(alignment[seq]))])
    end
    #objective_value = objective_function(alignment)
    return alignment 
end

    # function Alignment(sequence_array::Array, objective_value::Float64)
    #     new(sequence_array, objective_value)
    # end


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


Calculates pairwise alignment score between 2 sequences. The total score is the sum of individual scores for every
position in the alignment. The score for 2 matched aminoacids is determined by the used score_matrx. 
Opening new gaps in the alignment result in a gap_opening penalty, extending a gap in a gep_extension penalty.
"""


# function pairwise_score(seq_1::String, seq_2::String; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
#     score = 0
#     previous_gap_1 = false
#     previous_gap_2 = false
#     for (residue1, residue2) in zip(seq_1, seq_2)
#         if !(residue1 == '-' || residue2 == '-')
#             score += score_matrix[findall(symbols .== residue1)[1], findall(symbols .== residue2)[1]]
#             previous_gap_1 = false
#             previous_gap_2 = false
#         end

#         if residue1 == '-' 
#             if previous_gap_1
#             score += gap_extension
#             else 
#             score += gap_opening
#             end
#             previous_gap_1 = true
#         end 

#         if residue2 == '-' 
#             if previous_gap_2
#             score += gap_extension
#             else 
#             score += gap_opening
#             end
#             previous_gap_2 = true
#         end
#     end
#     return score
# end

function pairwise_score(seq_1::String, seq_2::String; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
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

Calculates full alignment score of alignment provided in an Alignment object. The score
is the sum of all the pairwise alignment scores calculated with pairwise_score().
"""


# function objective_function(alignment; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
#     seq_dict = array_to_dict(alignment)
#     objective_value = 0
#     seq_ids = alignment.seq_ids
#     for i in 2:length(seq_dict)
#         for j in 1:i-1
#             objective_value += pairwise_score(seq_dict[seq_ids[i]], seq_dict[seq_ids[j]], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
#         end
#     end
#     return objective_value
# end

function objective_function(alignment; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    objective_value = 0
    for i in 2:length(alignment)
        for j in 1:i-1
            objective_value += pairwise_score(alignment[i], alignment[j], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
        end
    end
    return objective_value
end

# function objective_function(alignment; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
#     seq_dict = array_to_dict(alignment)
#     objective_value = 0
#     seq_ids = alignment.seq_ids
#     for i in 2:length(seq_dict)
#         for j in 1:i-1
#             objective_value += pairwise_score(seq_dict[seq_ids[i]], seq_dict[seq_ids[j]], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
#         end
#     end
#     return objective_value
# end
"""
    objective_function(seq_array::Array, seq_ids::Array, score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)

Calculates full alignment score if a seq_array and seq_ids are provided. The score
is the sum of all the pairwise alignment scores calculated with pairwise_score().
"""

# function objective_function(seq_array::Array, seq_ids::Array, score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
#     seq_dict = array_to_dict(seq_array, seq_ids)
#     objective_value = 0
#     for i in 2:length(seq_dict)
#         for j in 1:i-1
#             objective_value += pairwise_score(seq_dict[seq_ids[i]], seq_dict[seq_ids[j]], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
#         end
#     end
#     return objective_value
# end

"""
    one_point_crossover(parent_1, parent_2)

    
Operation for the genetic algorithm. Create crossover between 2 parent alignments. In parent_1
a random position is selected, here the alignment is splitted in a left and a right part.
Parent_2 is splitted at the end residues of the first split. Two new alignments are created. 
One with the left part of parent_1 and the right part of parent_2. And one with the 
left part of parent_2 and the right part of parent_1. Gaps are inserted to ensure equal sequence lengths.
The new alginment with the best objective value is returned.
"""
# function one_point_crossover(parent_1, parent_2)
#     pos = rand(1:size(parent_1.seq_array)[2]-1)
#     n_AA_upto_pos_vec = zeros(Int16, size(parent_1.seq_array)[1])
#     pos_n_AA_alignment_2 = ones(Int16, size(parent_1.seq_array)[1])
#     for seq in 1:size(parent_1.seq_array)[1]
#         n_AA_upto_pos = sum(parent_1.seq_array[seq, 1:pos] .!= '-')
#         n_AA_upto_pos_vec[seq] = n_AA_upto_pos
#         n_AA = 0
#         for residue in 1:size(parent_2.seq_array)[2]
#             if parent_2.seq_array[seq, residue] != '-'
#                 n_AA += 1
#                 if n_AA == n_AA_upto_pos
#                     pos_n_AA_alignment_2[seq] = residue
#                     break 
#                 end
#             end
#         end
        
#     end


#     longest_left_part = maximum(pos_n_AA_alignment_2)
#     longest_right_part = size(parent_2.seq_array)[2] - minimum(pos_n_AA_alignment_2)

#     left_new_2 = fill('-', (size(parent_1.seq_array)[1], longest_left_part))
#     right_new_1 = fill('-', (size(parent_1.seq_array)[1], longest_right_part))
  

    
#     for seq in 1:size(parent_1.seq_array)[1]
#         left_new_2[seq, 1:pos_n_AA_alignment_2[seq]] .= parent_2.seq_array[seq, 1:pos_n_AA_alignment_2[seq]]
#         right_new_1[seq, end-(size(parent_2.seq_array)[2]-pos_n_AA_alignment_2[seq]-1):end] .= parent_2.seq_array[seq, end-(size(parent_2.seq_array)[2]-pos_n_AA_alignment_2[seq]-1):end]
#     end
    
#     new_alignment_1 = hcat(parent_1.seq_array[:, 1:pos], right_new_1)
#     new_alignment_2 = hcat(left_new_2, parent_1.seq_array[:, pos+1:end])
#     ov_1 = objective_function(new_alignment_1, parent_1.seq_ids)
#     ov_2 = objective_function(new_alignment_2, parent_1.seq_ids)
#     if ov_1 > ov_2
#         return Alignment(new_alignment_1, parent_1.seq_ids, ov_1)
#     else
#         return Alignment(new_alignment_2, parent_1.seq_ids, ov_2)
#     end
# end

function one_point_crossover(parent_1, parent_2; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    seq_length_1 = length(parent_1[1])
    seq_length_2 = length(parent_2[1])
    n_seq = length(parent_1)
    pos = rand(1:seq_length_1-1)
    n_AA_upto_pos_vec = zeros(Int16, n_seq)
    pos_n_AA_alignment_2 = ones(Int16, n_seq)
    for seq in 1:n_seq
        n_AA_upto_pos_vec[seq] = pos - length(findall("-", parent_1[seq][1:pos]))
        n_AA = 0
        for residue in 1:seq_length_2
            if parent_2[seq][residue] != '-'
                n_AA += 1
                if n_AA == n_AA_upto_pos_vec[seq]
                    pos_n_AA_alignment_2[seq] = residue
                    break 
                end
            end
        end
        
    end

    longest_left_part = maximum(pos_n_AA_alignment_2)
    longest_right_part = seq_length_2 - minimum(pos_n_AA_alignment_2)

    child_1 = Array{String, 1}(undef, n_seq)
    child_2 = Array{String, 1}(undef, n_seq)

    for seq in 1:n_seq
        child_1[seq] = join([parent_1[seq][1:pos], 
                             "-"^(longest_right_part - (seq_length_2-pos_n_AA_alignment_2[seq])), 
                             parent_2[seq][pos_n_AA_alignment_2[seq]+1:end]])
        child_2[seq] = join([parent_2[seq][1:pos_n_AA_alignment_2[seq]], 
                            "-"^(longest_left_part-pos_n_AA_alignment_2[seq]),
                            parent_1[seq][pos+1:end]])
    end
    objective_value_1 = objective_function(child_1; score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
    objective_value_2 = objective_function(child_2; score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
    if objective_value_1 > objective_value_2
        return child_1
    else
        return child_2
    end
  
end

#     new_alignment_1 = hcat(parent_1.seq_array[:, 1:pos], right_new_1)
#     new_alignment_2 = hcat(left_new_2, parent_1.seq_array[:, pos+1:end])
#     ov_1 = objective_function(new_alignment_1, parent_1.seq_ids)
#     ov_2 = objective_function(new_alignment_2, parent_1.seq_ids)
#     if ov_1 > ov_2
#         return Alignment(new_alignment_1, parent_1.seq_ids, ov_1)
#     else
#         return Alignment(new_alignment_2, parent_1.seq_ids, ov_2)
#     end
# end

""" 
    gap_insertion(alignment)

Operation for the genetic algorithm. The sequences in the parent alignment are splitted in 2 groups.
For each group a random position is selected where a gap is inserted. A new Alignment object is returned.
"""
function gap_insertion(parent)
    n_seq = length(parent)
    length_alignment = length(parent[1])
    n_per_group = convert(Int8, round(n_seq/2))
    group_selection = fill(true, n_seq)
    group_selection[sample(1:n_seq, n_per_group, replace = false)] .= false
    insertion_position_1 = rand(1:length_alignment-1)
    insertion_position_2 = 0
    while true
        insertion_position_2 = rand(insertion_position_1-10:insertion_position_1+10)
        if insertion_position_2 > 0 && insertion_position_2 < length_alignment -1
            break
        end
    end
    child = Array{String, 1}(undef, n_seq)
    n_gap = rand(1:10)
    for seq in 1:n_seq
        if group_selection[seq]
            child[seq] = join([parent[seq][1:insertion_position_1], '-'^n_gap, parent[seq][insertion_position_1:end]])
        else
            child[seq] = join([parent[seq][1:insertion_position_2], '-'^n_gap, parent[seq][insertion_position_2:end]])
        end
    end
    return child
end

"""
    shifting_one_seq(parent)

Operation for the genetic algorithm. One parent sequence in the parent alignment is randomly selected.
This sequence is shifted one position to the left by removing a gap and insert it at the right hand side.
"""
function shifting_one_seq(parent)
    sequence_length = length(parent[1])
    n_seq = length(parent)
    seq = rand(1:n_seq)
    pos = 0
    num_repeats = 0
    while true
        num_repeats += 1
        pos = rand(1:sequence_length)
        if parent[seq][pos] == '-'
            break
        end
        if num_repeats > 2*sequence_length
            seq = rand(1:n_seq)
            num_repeats = 0
        end
        
    end
    child = deepcopy(parent)
    shift_to_left = rand([true, false])    
    if shift_to_left
       child[seq] = join([parent[seq][1:pos-1], parent[seq][pos+1:end], '-'])
    else
       child[seq] = join(['-', parent[seq][1:pos-1], parent[seq][pos+1:end]])
    end
    return child
end

"""
    shifting_block(parent, partial = false)
    
Operation for the genetic algorithm. A random block in the parent alignment is searched.
To choose a block a position is searched where only amino-acids and no gaps are present. 
For every sequence all non-gap values adjacent to this position are taken up in the block. 
This block is shifted to the left with one position.
"""

function shifting_block(parent)
    n_seq = length(parent)
    length_alignment = length(parent[1])
    sample_order = shuffle(2:length_alignment-1)

    block_found = false
    start_pos = 0

    for residue in sample_order
        try if all([seq[residue] for seq in parent] .!= '-')
                start_pos = residue
                block_found = true
                break
            end
        catch e
            println()
            println(residue)
            println(length_alignment)
            println()
        end
    end

    
    if block_found
        block_end_left = zeros(Int16, n_seq)
        block_end_right = zeros(Int16, n_seq)
        for seq in 1:n_seq
            pos_left = deepcopy(start_pos) - 1
            pos_right = deepcopy(start_pos) +1
            while true
                if pos_left < 1 
                    block_end_left[seq] = 1
                    break
                elseif parent[seq][pos_left] == '-'
                    block_end_left[seq] = pos_left + 1
                    break
                else
                    pos_left -= 1
                end
            end
            while true
                if pos_right > length_alignment
                    block_end_right[seq] = length_alignment
                    break
                
                elseif parent[seq][pos_right] == '-'
                    block_end_right[seq] = pos_right - 1
                    break
                else
                    pos_right += 1
                end
            end

        end

        child = Array{String, 1}(undef, n_seq)
            
        if !any(block_end_left .== 1) && !any(block_end_right .== length_alignment)
            shift_direction= rand(["left", "right"])
        else any(block_end_left .== 1) && any(block_end_right .== length_alignment)
            shift_direction = "no shift"
        
        end
        
        

        
        if shift_direction == "left"
            
            for seq in 1:n_seq
                if block_end_left[seq] == 2 
                    child[seq] = join([parent[seq][2:block_end_right[seq]],
                                        '-', 
                                        parent[seq][block_end_right[seq]+1:end]])
                else
                    child[seq] = join([parent[seq][1:block_end_left[seq]-2], 
                                        parent[seq][block_end_left[seq]:block_end_right[seq]],
                                        '-',
                                        parent[seq][block_end_right[seq]+1:end]] )
                end
            end
            return child, false

        elseif shift_direction == "right"
        
            for seq in 1:n_seq
                if block_end_right[seq] == length_alignment - 1

                    child[seq] = join([parent[seq][1:block_end_left[seq]-1],
                                        '-', 
                                        parent[seq][block_end_left[seq]:block_end_right[seq]]])
                else
                    child[seq] = join([parent[seq][1:block_end_left[seq]-1], 
                                        '-',
                                        parent[seq][block_end_left[seq]:block_end_right[seq]],
                                        parent[seq][block_end_right[seq]+2:end]]
                                        )
                end
            end
            return child, false
        else 
            return parent, true
        end
    else
        return parent, true
    end
    
end

    #     if all(block_end_left .!= 0)
    #         block_end_left = convert(Array{Int16, 1}, block_end_left)
    #         block_end_right = convert(Array{Int16, 1}, block_end_right)
    #         new_seq_array = Array{Char, 2}(undef, (n_seq, length_alignment))
    #         for seq in 1:n_seq
    #             #new_seq_array[seq, :] .= alignment.seq_array[seq, vcat(1:block_end_left[seq]-1, block_end_left[seq]+1:length_alignment)]
    #             new_seq_array[seq, :] .= vcat(parent.seq_array[seq, 1:block_end_left[seq]-1], 
    #                                             parent.seq_array[seq, block_end_left[seq]+1:block_end_right[seq]-1],
    #                                             '-',
    #                                             parent.seq_array[seq, block_end_right[seq]:end])
    #         end
    #     end

    # objective_value = objective_function(new_seq_array, parent.seq_ids)
    # return Alignment(new_seq_array, parent.seq_ids, objective_value)



# function genetic_algorithm(path_to_fasta_file; population_size = 10, p = 0.8, score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    
#     population = Array{Array, 1}(undef, population_size)
#     raw_data, seq_ids = fasta_to_array(path_to_fasta_file)
#     n_seq = length(raw_data)
#     scores = zeros(population_size)
#     new_scores = deepcopy(scores)
#     for individual = 1:population_size
#         population[individual] = Alignment(raw_data, p = p)
#         scores[individual] = objective_function(population[individual], 
#                                                 score_matrix = score_matrix,
#                                                 gap_opening = gap_opening,
#                                                 gap_extension = gap_extension,
#                                                 symbols = symbols)
#     end

#     operation_chance = ProbabilityWeights(fill(1/4, 4))
#     parent_chance = ProbabilityWeights(fill(1/population_size, population_size))
#     operations = [(1, "one_point_crossover"), (2, "gap_insertion"), (3, "shifting_one_seq"), (4, "shifting_block")]
#     operation_performance = fill(1, (4, 10))
#     performance_points = [0, 1/7 * 0.5, 2/7 * 0.5, 4/7 * 0.5]
#     n_individuals_replaced = convert(Int16, round(population_size/2))
#     renew = ones(Int, 4)

#     for generation in 1:100
#         new_population = deepcopy(population)
#         new_scores = deepcopy(scores)
#         replaced_individuals = sortperm(scores)[1:n_individuals_replaced]
#         child = Array{String, 1}(undef, n_seq)
#         for replacement_i in replaced_individuals
#             parent_chance = ProbabilityWeights(fill(1/population_size, population_size))
#             while true
                
#                 operation = sample(operations, operation_chance)
#                 parent_1 = sample(1:population_size, parent_chance)
#                 parent_2 = 0
#                 if operation[2] == "one_point_crossover"
#                     parent_chance_opc = deepcopy(parent_chance)
#                     parent_chance_opc[parent_1] = 0
#                     parent_chance = ProbabilityWeights(parent_chance/ sum(parent_chance))
#                     parent_2 = sample(1:population_size, parent_chance_opc)

#                     child = one_point_crossover(population[parent_1], population[parent_2], 
#                                                 score_matrix = score_matrix, 
#                                                 gap_opening = gap_opening,
#                                                 gap_extension = gap_extension,
#                                                 symbols = symbols)
                    
#                 elseif operation[2] == "gap_insertion"
#                     child = gap_insertion(population[parent_1])
                    
#                 elseif operation[2] == "shifting_one_seq"
#                     child = shifting_one_seq(population[parent_1])
                   
#                 else
#                     child = shifting_block(population[parent_1])

#                 end
                
#                 new_objective_value = objective_function(child, 
#                                                             score_matrix = score_matrix,
#                                                             gap_opening = gap_opening,
#                                                             gap_extension = gap_extension,
#                                                             symbols = symbols)
                
#                 if operation[2] != "one_point_crossover"
#                     operation_performance[operation[1], renew[operation[1]]] = new_objective_value - scores[parent_1]
#                 else
#                     previous_score = minimum(scores[[parent_1, parent_2]])
#                     operation_performance[operation[1], renew[operation[1]]] = new_objective_value - previous_score
#                 end

#                 operation_chance = fill(0.125, 4)
#                 operation_chance[sortperm(mean(operation_performance, dims = 2)[:,1])] .+= performance_points 
#                 operation_chance = ProbabilityWeights(operation_chance)

#                 if operation[2] == "one_point_crossover"
#                     parent_objective_value = maximum([scores[parent_1], scores[parent_2]])
#                 else
#                     parent_objective_value = scores[parent_1]
#                 end

#                 if new_objective_value > parent_objective_value
#                     new_population[replacement_i] = child
#                     new_scores[replacement_i] = new_objective_value
#                     parent_chance[parent_1] = 0
#                     if operation[2] == "one_point_crossover"
#                         parent_chance[parent_2] = 0
#                     end
#                     parent_chance = ProbabilityWeights(parent_chance ./ sum(parent_chance))
#                     if renew[operation[1]] == 10
#                         renew[operation[1]] = 1
#                     else
#                         renew[operation[1]] += 1
#                     end
#                     break
#                 end


#             end
            
#         end
#         scores = deepcopy(new_scores)
#         population = deepcopy(new_population)
#     end 
    

# end
        
     

end






    






