include("src/STMOZOO.jl")
raw = STMOZOO.GenProgAlign.fasta_to_array("../AAA_small.fasta")[1]


n = 0
for i = 1:10000
    ali1 = STMOZOO.GenProgAlign.Alignment(raw)
    block = STMOZOO.GenProgAlign.shifting_block(ali1)
    if !all([length(seq) for seq in block] .== length(block[1]))
        n = n+1
    end
end
# sd = STMOZOO.GenProgAlign.array_to_dict(ali)

# not_in_AA = 0
# a_string = ""
# for seq in keys(sd)
#     a_string = string(a_string, sd[seq])
# end
n = 0
v = 0
for i = 1:1000
    ali1 = STMOZOO.GenProgAlign.Alignment(raw)
    v, l, r = shifting_block(ali1)
    lengths = [length(seq) for seq in v]
    if !all(lengths .== lengths[1])
        println(l)
        println(r)

        for i = 1:length(v)
            println(v[i])

            println()
        end
        n+=1
        break
    
    end
    println(i)
end

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
            
        if !any(block_end_left .== 1) || !any(block_end_right .== length_alignment)
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
            return child, block_end_left, block_end_right

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
            return child, block_end_left, block_end_right
        else 
            return parent, block_end_left, block_end_right
        end
    else
        return parent, block_end_left, block_end_right
    end
    
end


