# Douwe De Vestele

module MaximumFlow

# add needed packages

# export all functions
export cap,res_network,augmenting_path,bfs

# Returns the edges of the graph
# function edges(nw::Array{Int,2})
#     es = []
#     for i in nw
#         i != 0 && push!(caps, i)
#     end
#     return caps
# end
# edges(mf::Array{Tuple{Int,Int,Int},1}) = [mf[i][2:3] for i in 1:length(mf)] 

"""
    cap(nw::Array{Int,2})

Get the capacities or values of the edges of a graph `nw` implemented as an 
adjacency matrix.
"""
function cap(nw::Array{Int,2})
    caps = []
    for c in nw
        c != 0 && push!(caps, c)
    end
    return caps
end

"""
    cap(nw::Array{Int,2}, nw_sol::Array{Int,2})

Get the flows in a network `nw_sol` resulting from the solution of a maximum flow problem
`nw`. Both networks are implemented as adjacency matrices.
"""
function cap(nw::Array{Int,2}, nw_sol::Array{Int,2})
    caps = []
    for (i,c) in enumerate(nw)
        c != 0 && push!(caps, nw_sol[i])
    end
    return caps
end

"""
    res_network(mf_oc::Array{Int,2},mf_cur::Array{Int,2})

Calculate the residual network of a network from a maximum flow problem `mf_oc` 
and a network containing the current flow `mf_cur`, both implemented as 
adjacency matrices.
"""
function res_network(mf_oc::Array{Int,2}, mf_cur::Array{Int,2})
    r = size(mf_oc, 1) # rows
    c = size(mf_oc, 2) # columns
    @assert r == c "Adjacency matrix has to be square."
    @assert size(mf_cur, 1) == size(mf_cur, 2) "Adjacency matrix has to be square."
    @assert r == size(mf_cur, 1) "Adjacency matrices need to have same size."
    mf_res = zeros(Int, r, c)
    for i in 1:r
        for j in 1:c
            mf_res[i,j] = mf_oc[i,j] - mf_cur[i,j] + mf_cur[j,i]
        end
    end
    return mf_res
end

""" 
    bfs(nw::Array{Int,2}, s::Int, t::Int)

Search an existing path in the network `nw` with a breadth-first-search from 
source `s` to sink `t`.
Return `true` if path exists and an array with the predecessor vertices 
to make backtracking possible. 
Return `false` if path does not exist.
"""
    function bfs(nw::Array{Int,2}, s::Int, t::Int)
    n = size(nw, 1) # number of vertices
    @assert n == size(nw, 2) "Adjacency matrix has to be square."
    @assert all(nw .>= 0) "There are negative flow capacities, which is not possible."

    labeled = falses(n) # true if vertex is labeled
    labeled[s] = true # start at source
    L = [s] # labels, start at source
    pred = zeros(Int, n) # predecessor labels

    while ! labeled[t] && ! isempty(L)# as long as t is not labeled and there are still unvisited nodes
        i = pop!(L) # select labeled node
        for j in findall(nw[i,:] .> 0) # there is still possible flow from node i to node j
        # if j is unlabeled, label it and save the predecessor
            if ! labeled[j]
                labeled[j] = true
                pred[j] = i
                push!(L, j)
            end
        end
    end
    return labeled[t], pred
end

"""
    augmenting_path(mf::Array{Int,2}, s::Int, t::Int)

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from source `s` to sink `t`.
"""
function augmenting_path(mf::Array{Int,2}, s::Int, t::Int)
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # initialization
    max_flow = 0 # start with zero flow
    cur_flow = zeros(Int, n, n) # start with zero flow
    res_flow = res_network(mf, cur_flow)

    # search for a path
    path, pred = bfs(res_flow, s, t)

    # if there is a path, add lowest capacity (=limiting) from the path to the flow.
    while path
    # backtracking
        P = [t]
        while P[end] != s
            push!(P, pred[P[end]])
        end
        P
    # calculate lowest capacity
    Δ = minimum([res_flow[x,y] for (y, x) in zip(P[1:end - 1], P[2:end]) ])
    # add this flow to current flow
        [cur_flow[x,y] += Δ for (y, x) in zip(P[1:end - 1], P[2:end])]
        res_flow = res_network(mf, cur_flow) # update residual network
    # search for a path
    path, pred = bfs(res_flow, s, t)
    end
    max_flow = sum(cur_flow[:,t])
    return cur_flow, max_flow
end

"""
    augmenting_path(mf::Array{Int,2}, s::Array{Int,1}, t::Int)

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from multiple sources `s` to sink `t`.
"""
function augmenting_path(mf::Array{Int,2}, s::Array{Int,1}, t::Int)
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # multiple sources
    # add node in front of the graph with huge capacities to each source node
    mf_sourcerow = zeros(Int, n + 1)
    mf_sourcerow[s .+ 1] .= 10^20 
    mf_sourcecol = zeros(Int, n)
    mf_new = [mf_sourcerow';mf_sourcecol mf] # new network

    cur_flow, max_flow = augmenting_path(mf_new, 1, t + 1)
    cur_flow_new = cur_flow[2:end,2:end] # delete extra row and column from source
    return cur_flow_new, max_flow
end

"""
    augmenting_path(mf::Array{Int,2}, s::Int, t::Array{Int,1})

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from source `s` to multiple sinks `t`.
"""
function augmenting_path(mf::Array{Int,2}, s::Int, t::Array{Int,1})
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # multiple sinks
    # add node at the back of the graph receiving huge capacities from each sink node
    mf_sinkcol = zeros(Int, n + 1)
    mf_sinkcol[t] .= 10^20 
    mf_sinkrow = zeros(Int, n)
    mf_new = [[mf; mf_sinkrow'] mf_sinkcol] # extended network

    cur_flow, max_flow = augmenting_path(mf_new, s, n + 1)
    cur_flow_new = cur_flow[1:end - 1,1:end - 1] # delete extra row and column from sink
    return cur_flow, max_flow
end

"""
    augmenting_path(mf::Array{Int,2}, s::Array{Int,1}, t::Array{Int,1})

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
with multiple sources `s` and multiple sinks `t`.
"""
function augmenting_path(mf::Array{Int,2}, s::Array{Int,1}, t::Array{Int,1})
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # multiple sources and sinks
    # add node in front of the graph with huge capacities to each source node
    mf_sourcerow = zeros(Int, n + 2)
    mf_sourcerow[s .+ 1] .= 10^20 
    mf_sourcecol = zeros(Int, n + 1)
    # add node at the back of the graph receiving huge capacities from each sink node
    mf_sinkcol = zeros(Int, n + 1)
    mf_sinkcol[t] .= 10^20 
    mf_sinkrow = zeros(Int, n)
    mf_new = [mf_sourcerow'; [mf_sourcecol [mf; mf_sinkrow'] mf_sinkcol]] # extended network

    cur_flow, max_flow = augmenting_path(mf_new, 1, n + 2)
    cur_flow_new = cur_flow[2:end - 1,2:end - 1] # delete extra rows and columns from source and sink
    return cur_flow_new, max_flow
end
# """
#     e_list_to_adj_mat(elist::Array{Tuple{Int,Int,Int},1})
# Converts an edge list to an adjacency matrix
# """
# function e_list_to_adj_mat(elist::Array{Tuple{Int,Int,Int},1})

# end
end