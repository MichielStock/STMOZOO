# Kobe De Temmerman
module GenProgAlign

# Importing required packages
using BioSequences, BioAlignments, StatsBase, Random
# Export functions relevant for the user
export  ga_alignment, 
        fasta_to_array, 
        Alignment, 
        AA,
        pairwise_score,
        objective_function,
        one_point_crossover,
        gap_insertion,
        shifting_one_seq,
        shifting_block

"""
## ga_alignment
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
A dynamic schedule is used to select the consecutive operations, i.e. the next operation is chosen stochastically
with a chance that depends on the recent performance history of the operations.

Argument list
- path\\_to\\_fasta_file: Path to fasta file containing the sequences to be aligned.
- population\\_size: Size of the population, remains constant over generations.
- p: Chance of inserting a gap during creation initial alignment. Necessary for Alignment function defined lower.
- max\\_operations\\_without\\_improvement: Stop criterion, maximum consecutive fails to improve the score of the parent alignment with an operation.
- max\\_operations: Stop criterion, total maximum operations performed. 
- score\\_matrix: Score matrix used to calculate the alignment score, necessary for objective\\_function => pairwise\\_score defined lower. 
- gap\\_opening: Penalty to introduce a gap in an alignment, necessary for objective\\_function => pairwise\\_score defined lower.
- gap\\_extension: Penalty to extend a gap in an alignment, necessary for objective\\_function => pairwise\\_score defined lower.
- symbols: Column and rownames of the score\\_matrix.
"""
function ga_alignment(path_to_fasta_file; population_size = 50, p = 0.95, max_operations_without_improvement = 2000, max_operations = 10000,score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    ## Read in fastafile with  GenProgAlign.fasta_to_array 
    raw_data, seq_ids = fasta_to_array(path_to_fasta_file)
    n_seq = length(raw_data)
    ## Create initial population and calculate the scores of the individuals
    # The objective function is defined lower.
    population = Array{Array, 1}(undef, population_size)
    scores = zeros(population_size)
    for individual = 1:population_size
        population[individual] = Alignment(raw_data, p = p)
        scores[individual] = objective_function(population[individual], 
                                                score_matrix = score_matrix,
                                                gap_opening = gap_opening,
                                                gap_extension = gap_extension,
                                                symbols = symbols)
    end
    # Variable that changes during the selection of a new generation
    # Necessary to keep scores constant during the current generation
    new_scores = deepcopy(scores)
    ## Define variables necessary for the dynamic scheduling of the operations
    # Initial chance of an operation to be selected
    operation_chance = ProbabilityWeights(fill(1/4, 4))
    # Initial chance of a parent to be selected
    parent_chance = ProbabilityWeights(fill(1/population_size, population_size))
    # Operations
    operations = [(1, "one_point_crossover"), (2, "gap_insertion"), (3, "shifting_one_seq"), (4, "shifting_block")]
    # Matrix to keep track of the recent performance of the operations
    operation_performance = fill(1.0, (4, 10))
    # Extra chances to be selected based on relative performance operations,
    # from worst to best.
    performance_points = [0, 1/7 * 0.5, 2/7 * 0.5, 4/7 * 0.5]
    # Number of individuals replaced
    n_individuals_replaced = convert(Int16, round(population_size/2))
    # Array that keeps track for every operation which score in the operation_performance 
    # array is the oldest, so that only one value has to be replaced.
    renew = ones(Int, 4)
    # Boolean variable that determines if a next generation or output will be generated.
    go_on = true
    # Two stop criteria 
    n_operations_without_improvement = 0
    n_operations = 0
    generation = 0
    # Every iteration in the while-loop is equal to the creation of a new generation.
    while go_on
        generation +=1 
        println(join(["Maximum value generation ", string(generation), ": " ,string(maximum(scores))]))
        # Copy of population and scores that can be changed during the creation of a new generation 
        # while still keeping population and scores constant, making sure parents can be selected.
        new_population = deepcopy(population)
        new_scores = deepcopy(scores)
        # Select the 50% individuals with the worst alignment score they will be replaced.
        replaced_individuals = sortperm(scores)[1:n_individuals_replaced]
        # Preallocate child which will be a candidate to be part of the next generation.
        child = Array{String, 1}(undef, n_seq)
        # Loop over all individuals that have to be replaced.
        for replacement_i in replaced_individuals
            while true
                # An operation is selected
                operation = sample(operations, operation_chance)
                # A parent is selected
                parent_1 = sample(1:population_size, parent_chance)
                parent_2 = 0
                ## Performance of the operation 
                if operation[2] == "one_point_crossover"
                    # Making sure that not the same parents are selected for as parent for this operation.
                    parent_chance_opc = deepcopy(parent_chance)
                    parent_chance_opc[parent_1] = 0
                    # Selection a second parent necessary for the crossing over
                    parent_2 = sample(1:population_size, parent_chance_opc)
                    # Perform the operation
                    child = one_point_crossover(population[parent_1], population[parent_2], 
                                                score_matrix = score_matrix, 
                                                gap_opening = gap_opening,
                                                gap_extension = gap_extension,
                                                symbols = symbols)
                    
                elseif operation[2] == "gap_insertion"
                    # Perform the operation
                    child = gap_insertion(population[parent_1])
                    # The operation is repeated multiple times to increase the possible variability in the final child.
                    for i = 1:5
                        child = gap_insertion(child)
                    end
                    
                elseif operation[2] == "shifting_one_seq"
                    # Perform the operation
                    child = shifting_one_seq(population[parent_1])
                    # The operation is performed a couple of times to increase the possible variability in the final child.
                    for i = 1:20
                        child = shifting_one_seq(child)
                    end
                else
                    # Perform the shifting_block operation: the parent_or_not variable is included to keep
                    # track if the operation was able to shift a block, if not the parent alignment is returned,
                    # this has an influence on the calculation of the operation performance_matrix. 
                    # If a parent is returned the performance of the operation is set to to the average performance 
                    # of the operator in the past.
                    child, parent_or_not = shifting_block(population[parent_1])

                end
                # Calculate objective value of the generated child.
                new_objective_value = objective_function(child, 
                                                            score_matrix = score_matrix,
                                                            gap_opening = gap_opening,
                                                            gap_extension = gap_extension,
                                                            symbols = symbols)
                ##Calculating the performance of the operator, the improvement(-/+) of the alignmentscore 
                # the child compared to the parent. 
                # The renew variable keeps track of the oldest perfmance value in the operation_performance array per operation.
                if operation[2] == "one_point_crossover"
                    # For the crossover the worst parent is used as reference.
                    previous_score = minimum(scores[[parent_1, parent_2]])
                    operation_performance[operation[1], renew[operation[1]]] = new_objective_value - previous_score
                elseif operation[2] == "shifting_block"   
                    # For the shifting_block-operation the mean of the recent performances is taken as value, if 
                    # no block shift was possible and the parent was returned, otherwise the performance would always be 
                    # 0 in this case.
                    if parent_or_not
                        operation_performance[operation[1], renew[operation[1]]] = mean(operation_performance[operation[1], :])
                    else
                        operation_performance[operation[1], renew[operation[1]]] = new_objective_value - scores[parent_1]
                    end
                else
                    operation_performance[operation[1], renew[operation[1]]] = new_objective_value - scores[parent_1]
                end
                # The chance of an operation is updated with the knowledge of the performance of the last operation.
                # Every operation has a base chance, where the gap insertion and the one sequence shifting operations are.
                # positively discriminated because these operations introduce new variation and their usefulness might be
                # dependent on the amount of times they are applicated.
                operation_chance = [0.05, 0.2, 0.2, 0.05]
                # Change this basechance per operation based on the relative performance
                operation_chance[sortperm(mean(operation_performance, dims = 2)[:,1])] .+= performance_points 
                operation_chance = ProbabilityWeights(operation_chance)
                
                # Select objective_value of the parent
                if operation[2] == "one_point_crossover"
                    parent_objective_value = maximum([scores[parent_1], scores[parent_2]])
                else
                    parent_objective_value = scores[parent_1]
                end
               
                # If the objective value of the child is bigger than the objective value of the parent
                # and the child doesn't result in identical individuals in the new generation it is selected
                # to be part of the next generation.
                if new_objective_value > parent_objective_value && child ∉ new_population
                    new_population[replacement_i] = child
                    new_scores[replacement_i] = new_objective_value
                    n_operations_without_improvement = 0
                    n_operations +=1
                    break
                else 
                    n_operations_without_improvement +=1
                    n_operations +=1
                    # Stop criterion
                    if n_operations_without_improvement > max_operations_without_improvement || n_operations > max_operations
                        
                        go_on = false
                        break
                    end
                end
                #Update the renew array
                if renew[operation[1]] == 10
                    renew[operation[1]] = 1
                else
                    renew[operation[1]] += 1
                end


            end
            
        end
        # If all replacements are found the next generation is set as the current generation, together with it's scores.
        scores = deepcopy(new_scores)
        population = deepcopy(new_population)
    end 
    # The best alignment, it's score and the sequence ID's are returned.
    return population[sortperm(scores)[end]], maximum(scores), seq_ids

end
    
     


"""
## fasta\\_to\\_array
    fasta_to_array(path_to_fasta_file::String)

Function that reads in a fasta file and returns 2 arrays. One array with the distinct sequences as strings, the other
one with the corresponding sequence id's.
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
## Alignment
    Alignment(seq_array; p = 0.95)

Creates a random initial alignment starting from the sequence\\_array generated with fasta\\_to\\_array.
Random gaps are inserted between the residues with a chance 1 - p.
The sequence lengths are equalized. An array with the sequences as strings is returned.
"""
function Alignment(seq_array; p = 0.95)
    # Keep track of the maximum sequence length
    max_seq_length = 0 
    # Preallocate output array.
    alignment = Array{String, 1}(undef, length(seq_array))# Keep track of the maximum sequence length to equalize the lengths afterwards.
    for seq in 1:length(seq_array)
        # Create a temporary Char-array and introduce 1:5 random gaps at the start.
        sequence = fill('-', rand(0:5))
        # Every residue in the sequence is preceded with a random amount of gaps. 
        for residue in 1:length(seq_array[seq])
            while true
                gap_or_not = rand()
                if gap_or_not > p
                    push!(sequence, '-')
                else
                    break
                end
            end
            # The residue is added to the temporary array.
            push!(sequence, seq_array[seq][residue])
        end
        # The temporary array is converted to a string and added to the output array.
        alignment[seq] = join(sequence)
        # Check if the last sequence is the longest sequence already present.
        if length(alignment[seq]) > max_seq_length
            max_seq_length = length(alignment[seq])
        end
    
    end
    # Add gaps at the end of the sequence to equalize the length of the sequences.
    for seq in 1:length(alignment)
        alignment[seq]= join([alignment[seq], "-"^(max_seq_length-length(alignment[seq]))])
    end
    return alignment 
end

"""
## AA 
 Column-, and rownames of the BLOSUM62-matrix provided by BioAlignments
"""
AA = ['A','R', 'N', 'D', 'C', 'Q', 'E',  'G', 'H',  'I' , 'L' , 'K',  'M', 'F','P', 'S',  'T', 'W',  'Y',  'V', 'O' ,'U', 'B', 'J', 'Z', 'X' ,'*']

"""
## pairwise\\_score
    pairwise_score(seq_1::String, seq_2::String; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)


Calculates pairwise alignment score between 2 sequences. The total score is the sum of individual scores for every
position in the alignment. The score for 2 matched aminoacids is determined by the used score\\_matrix. 
Opening new gaps in the alignment result in a gap\\_opening penalty, extending a gap in a gep\\_extension penalty.
"""
function pairwise_score(seq_1::String, seq_2::String; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    # Preallocate score
    score = 0
    # Keep track if the previous residue in the sequence was a gap or not
    previous_gap_1 = false
    previous_gap_2 = false

    # Loop over pairs of residues in the sequences.
    for (residue1, residue2) in zip(seq_1, seq_2)
        # If none of the residues is a gap, add the score of the residue pair extracted from the scorematrix
        if !(residue1 == '-' || residue2 == '-')
            score += score_matrix[findall(symbols .== residue1)[1], findall(symbols .== residue2)[1]]
            previous_gap_1 = false
            previous_gap_2 = false
        end
        # If a gap is present add a gap-opening or a gap-extension penalty
        # depending on the previous residues.
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
## objective\\_function
    objective_function(alignment; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)

Calculates full alignment score of alignment provided in an Alignment object. The score
is the sum of all the pairwise alignment scores calculated with pairwise\\_score().
"""
function objective_function(alignment; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    # Preallocate total objective_value
    objective_value = 0
    # Loop over pairs of sequences and add pairwise-scores to the objective_value.
    for i in 2:length(alignment)
        for j in 1:i-1
            objective_value += pairwise_score(alignment[i], alignment[j], score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
        end
    end
    return objective_value
end


"""
## one\\_point\\_crossover
    one_point_crossover(parent_1, parent_2; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)

    
Operation for the genetic algorithm. Create crossover between 2 parent alignments. In parent\\_1
a random position is selected, here the alignment is splitted in a left and a right part.
Parent\\_2 is splitted at the end residues of the first split. Two new alignments are created. 
One with the left part of parent\\_1 and the right part of parent\\_2. And one with the 
left part of parent\\_2 and the right part of parent\\_1. Gaps are inserted to ensure equal sequence lengths.
The child with the best objective value is returned.
"""
function one_point_crossover(parent_1, parent_2; score_matrix = BLOSUM62, gap_opening = -10, gap_extension = -1, symbols = AA)
    # Calculate length of parent_1
    seq_length_1 = length(parent_1[1])
    # Calculate length of parent_2
    seq_length_2 = length(parent_2[1])
    # Calculate the amount of sequences per alignment
    n_seq = length(parent_1)
    # Choose a random position in parent_1
    pos = rand(1:seq_length_1-1)
    # Preallocate a vector for the amount (n) of aminoacids present in every sequence
    # of parent_1 upto pos.
    n_AA_upto_pos_vec = zeros(Int16, n_seq)
    # Preallocate a vector for the positions of the n-th aminoacid for every sequence 
    # of parent_2
    pos_n_AA_alignment_2 = zeros(Int16, n_seq)
    # Loop over the sequences in the alignment.
    for seq in 1:n_seq
        # Calculate the amount (n) of aminoacids present in sequence seq of parent_1 upto pos.
        n_AA_upto_pos_vec[seq] = pos - length(findall("-", parent_1[seq][1:pos]))
        # Look for the position of the n-th aminoacid in sequence seq of parent_2.
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

    # Calculate the longest left part/ right part kept after the split of parent_2
    longest_left_part = maximum(pos_n_AA_alignment_2)
    longest_right_part = seq_length_2 - minimum(pos_n_AA_alignment_2)

    # Preallocate the 2 child alignments.
    child_1 = Array{String, 1}(undef, n_seq)
    child_2 = Array{String, 1}(undef, n_seq)
    
    # Create the 2 child-alignment, by joining the left(right) part of parent_1 with the right (left) part 
    # parent_1. Equal lengths are ensured by adding gaps in between.
    for seq in 1:n_seq
        child_1[seq] = join([parent_1[seq][1:pos], 
                             "-"^(longest_right_part - (seq_length_2-pos_n_AA_alignment_2[seq])), 
                             parent_2[seq][pos_n_AA_alignment_2[seq]+1:end]])
        child_2[seq] = join([parent_2[seq][1:pos_n_AA_alignment_2[seq]], 
                            "-"^(longest_left_part-pos_n_AA_alignment_2[seq]),
                            parent_1[seq][pos+1:end]])
    end
    # Calculate the alignment score for both children and return the one with the highest score.
    objective_value_1 = objective_function(child_1; score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
    objective_value_2 = objective_function(child_2; score_matrix = score_matrix, gap_opening = gap_opening, gap_extension = gap_extension, symbols = symbols)
    if objective_value_1 > objective_value_2
        return child_1
    else
        return child_2
    end
  
end


""" 
## gap\\_insertion
    gap_insertion(alignment)

Operation for the genetic algorithm. The sequences in the parent alignment are splitted in 2 groups.
For each group a random position is selected where one or more gaps are inserted. 
"""
function gap_insertion(parent)
    # Calculate the amount of sequences in the alignment.
    n_seq = length(parent)
    # Calculate the length of the sequences.
    length_alignment = length(parent[1])
    # Devide the sequences in 2 groups.
    n_per_group = convert(Int8, round(n_seq/2))
    group_selection = fill(true, n_seq)
    group_selection[sample(1:n_seq, n_per_group, replace = false)] .= false
    # Select a random position where one or more gaps will be inserted in group 1. 
    insertion_position_1 = rand(2:length_alignment-1)
    # Select a random position where the gaps will be inserted in group 2.
    # The position is selected in a range -10:+10 around insertion_position_1.
    insertion_position_2 = undef
    while true
        insertion_position_2 = rand(insertion_position_1-10:insertion_position_1+10)
        if insertion_position_2 > 0 && insertion_position_2 < length_alignment -1
            break
        end
    end
    child = Array{String, 1}(undef, n_seq)
    # Select the amount of gaps inserted.
    n_gap = rand(1:10)
    # Introduce the gaps in the 2 groups.
    for seq in 1:n_seq
        if group_selection[seq]
            child[seq] = join([parent[seq][1:insertion_position_1], '-'^n_gap, parent[seq][insertion_position_1+1:end]])
        else
            child[seq] = join([parent[seq][1:insertion_position_2], '-'^n_gap, parent[seq][insertion_position_2+1:end]])
        end
    end
    return child
end

"""
## shifting\\_one\\_seq
    shifting_one_seq(parent)

Operation for the genetic algorithm. One parent sequence in the parent alignment is randomly selected.
This sequence is shifted one position to the left (right) by removing a gap and insert it at the right (left) side.
"""
function shifting_one_seq(parent)
    # Calculate the sequence length
    sequence_length = length(parent[1])
    # Calculate the amount of sequences in the alignment.
    n_seq = length(parent)
    # Randomly select the sequences which will be shifted.
    seq = rand(1:n_seq)
    # Look for a gap in sequence seq which can be replaced.
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
    # Randomly chose if the shift will be to the left or the right.
    # If the gaps are present at the ends the direction is fixed.
    if pos == 1
        shift_to_left = true
    elseif pos == sequence_length
        shift_to_left = false
    else
    shift_to_left = rand([true, false])
    end
    # Perform the shift.
    if shift_to_left
       child[seq] = join([parent[seq][1:pos-1], parent[seq][pos+1:end], '-'])
    else
       child[seq] = join(['-', parent[seq][1:pos-1], parent[seq][pos+1:end]])
    end
    return child
end

"""
# shifting\\_block
    shifting_block(parent, partial = false)
    
Operation for the genetic algorithm. A random block in the parent alignment is searched.
To choose a block a position is searched where only amino-acids and no gaps are present. 
For every sequence all non-gap values adjacent to this position are taken up in the block. 
This block is shifted to the left with one position.
"""
function shifting_block(parent)
    # Calculate the amount of sequences in the alignment.
    n_seq = length(parent)
    # Calculate the length of the sequences.
    length_alignment = length(parent[1])
    # Reorder the residue order to select a startpoint for the block.
    sample_order = shuffle(2:length_alignment-1)
    # Create boolean value to keep track if a block was found succesfully
    block_found = false
    # Select a start position to build the block.
    start_pos = 0
    for residue in sample_order
        if all([seq[residue] for seq in parent] .!= '-')
                start_pos = residue
                block_found = true
                break
        end
    end

    
    if block_found
        # Look for the left and right borders of the block per sequence
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

        # Preallocate child
        child = Array{String, 1}(undef, n_seq)
        
        # Choose the shifting direction.
        if !any(block_end_left .== 1) && !any(block_end_right .== length_alignment)
            shift_direction= rand(["left", "right"])
        else any(block_end_left .== 1) && any(block_end_right .== length_alignment)
            shift_direction = "no shift"
        
        end
        
        
        # Perform the shift
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


end






    






