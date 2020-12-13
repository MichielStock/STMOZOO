#Douwe De Vestele

module MaximumFlow

# add needed packages

# export all functions
export MFP,test_edge,test_mat ,edges,cap

# struct MFP Array{Tuple{C::Number,V::Int,V::Int},1}
#     capacity::C
#     A::V
#     B::V
# end

# Returns the edges of the graph
edges(mf::Array{Tuple{Int,Int,Int},1}) = [mf[i][2:3] for i in 1:length(mf)] 

# Returns the capacities of the graph
cap(mf::Array{Tuple{Int,Int,Int},1}) = [mf[i][1] for i in 1:length(mf)]

"""
    augmenting_path(mf::Array{Tuple{Int,Int,Int},1})
Execute Ford-Fulkerson algorithm with DFS search to find maximum flow of a network G.
"""
function augmenting_path(mf::Array{Tuple{Int,Int,Int},1})
    max_flow = 0
    mf_edges = edges(mf)
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
            0 0 0 4;
            0 0 0 1;
            0 0 0 0];
end