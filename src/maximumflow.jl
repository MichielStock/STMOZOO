#Douwe De Vestele

module MaximumFlow

# add needed packages

# export all functions
export MFP,test_edge,test_mat ,edges,cap,res_network

# struct MFP Array{Tuple{C::Number,V::Int,V::Int},1}
#     capacity::C
#     A::V
#     B::V
# end

# Returns the edges of the graph
edges(mf::Array{Tuple{Int,Int,Int},1}) = [mf[i][2:3] for i in 1:length(mf)] 

# Returns the capacities of the graph
function cap(mf::Array{Int,2})
    caps = []
    for i in mf
        i !=0 && push!(caps,i)
    end
    return caps
end
cap(mf::Array{Tuple{Int,Int,Int},1}) = [mf[i][1] for i in 1:length(mf)]

"""
    res_network(mf_oc::Array{Int,2},mf_cur::Array{Int,2})
Calculates the residual network of a network implemented as an adjacency matrix.
"""
function res_network(mf_oc::Array{Int,2},mf_cur::Array{Int,2})
    r = size(mf_oc,1) # rows
    c = size(mf_oc,2) # columns
    @assert r == c "Adjacency matrix has to be square."
    mf_res = zeros(Int,r,c)
    for i in 1:r
        for j in 1:c
            mf_res[i,j] = mf_oc[i,j] - mf_cur[i,j] + mf_cur[j,i]
        end
    end
    return mf_res
end



"""
    augmenting_path(mf::Array{Tuple{Int,Int,Int},1})
Execute Ford-Fulkerson algorithm with DFS search to find maximum flow of a network G.
"""
function augmenting_path(mf::Array{Int,2})
    @assert size(mf,1) == size(mf,2) "Adjacency matrix has to be square."
    @assert all(mf .>=0) "There are negative flow capacities, which is not possible." 
    max_flow = 0
    #mf_edges = edges(mf)
    mf_capacities = cap(mf)
    # search existing paths

    # add flow if possible
end

"""
    e_list_to_adj_mat(elist::Array{Tuple{Int,Int,Int},1})
Converts an edge list to an adjacency matrix
"""
function e_list_to_adj_mat(elist::Array{Tuple{Int,Int,Int},1})

end

# test graph as edge list
test_edge = [(8,0,1),(2,0,2),(4,1,3),(1,2,3)];

# test graph as adjacency matrix
test_mat = [0 8 2 0;
            0 0 2 4;
            0 0 0 1;
            0 0 0 0]
end