# Douwe De Vestele

module MaximumFlow

# add needed packages

# export all functions
export res_network,augmenting_path,bfs,isfeasible,clean!

"""
    res_network(mf_oc::AbstractMatrix{Int},mf_cur::AbstractMatrix{Int})

Calculate the residual network of a network from a maximum flow problem `mf_oc` 
and a network containing the current flow `mf_cur`, both implemented as 
adjacency matrices.
"""
function res_network(mf_oc::AbstractMatrix{Int}, mf_cur::AbstractMatrix{Int})
    # Maybe it is a style choice on your part, but you can also do: r, c = size(mf_oc)
    r = size(mf_oc, 1) # rows
    c = size(mf_oc, 2) # columns
    @assert r == c "Adjacency matrix has to be square."
    @assert size(mf_cur, 1) == size(mf_cur, 2) "Adjacency matrix has to be square."
    @assert r == size(mf_cur, 1) "Adjacency matrices need to have the same size."
    mf_res = zeros(Int, r, c)
    for i in 1:r
        for j in 1:c
            mf_res[i,j] = mf_oc[i,j] - mf_cur[i,j] + mf_cur[j,i]
        end
    end
    return mf_res
end

""" 
    bfs(nw::AbstractMatrix{Int}, s::Int, t::Int)

Search an existing path in the network `nw` with a breadth-first-search from 
source `s` to sink `t`.
Return `true` if a path exists and an array with the predecessor vertices 
to make backtracking possible. 
Return `false` if there doesn't exist a path.
"""
function bfs(nw::AbstractMatrix{Int}, s::Int, t::Int)
    n = size(nw, 1) # number of vertices
    @assert n == size(nw, 2) "Adjacency matrix has to be square."
    @assert all(nw .≥ 0) "There are negative flow capacities, which is not possible."

    labeled = falses(n) # true if vertex is labeled
    labeled[s] = true # start at source
    L = [s] # labels to explore, start at source
    pred = zeros(Int, n) # predecessor labels

    while !labeled[t] && !isempty(L)# as long as t is not labeled and there are still unvisited nodes
        i = popfirst!(L) # select labeled node
        for j in findall(nw[i,:] .> 0) # there is still possible flow from node i to node j
        # if j is unlabeled, label it and save the predecessor
            if !labeled[j] # remove space here?
                labeled[j] = true
                pred[j] = i
                push!(L, j)
            end
        end
    end
    return labeled[t], pred
end

"""
    augmenting_path(mf::AbstractMatrix{Int}, s::Int, t::Int; track=false)

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from source `s` to sink `t`. If `track` is `true`, an additional output `t` will be given,
which contains the original flow, the residual network and corresponding augmenting_path 
at each iteration.
"""
function augmenting_path(mf::AbstractMatrix{Int}, s::Int, t::Int; track=false)
    n = size(mf, 1) # number of vertices
    e = length(mf[mf .> 0]) # number of edges
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # initialization
    max_flow = 0 # start with zero flow
    cur_flow = zeros(Int, n, n) # start with zero flow
    res_flow = res_network(mf, cur_flow)
    iter = 0

    # tracker
    track && (tracker = [])

    # search for a path
    path, pred = bfs(res_flow, s, t)

    # if there is a path, add lowest capacity (=limiting) from the path to the flow.
    while path
        iter += 1
    # backtracking
        P = [t]
        while P[end] != s
            push!(P, pred[P[end]])
        end
        P
    # tracker
        track && push!(tracker, [copy(cur_flow),res_flow, P]) # add original flow, res network and the augmenting_path to the tracker
    # calculate lowest capacity
        Δ = minimum((res_flow[x,y] for (y, x) in zip(P[1:end - 1], P[2:end]) ))  # changed with round brackets, so it is an iterator (memory efficiency)
    # add this flow to current flow
        [cur_flow[x,y] += Δ for (y, x) in zip(P[1:end - 1], P[2:end])]           
        res_flow = res_network(mf, cur_flow) # update residual network
    # search for a path
        path, pred = bfs(res_flow, s, t)
    end
    max_flow = sum(cur_flow[:,t])
    if track
        return cur_flow, max_flow, tracker
    else
        return cur_flow, max_flow
    end
end

"""
    augmenting_path(mf::AbstractMatrix{Int}, s::Array{Int,1}, t::Int; 
        send::Array{Int,1}=fill(10^20,length(s)), track = false)

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from multiple sources `s` to sink `t`. If `track` is `true`, an additional output `t` will 
be given, which contains the original flow, the residual network and corresponding 
augmenting_path at each iteration.

The optional argument `send` contains the maximum "stock" that is available to originate in
the source node(s). This can be used to solve a feasible flow problem. 
This method can also be used for a feasible flow problem with a single source, if `s` is 
given as a single element array.

# Example
```julia-repl
julia> network = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0];
julia> s = [1];
julia> t = 4;
julia> augmenting_path(network, s,t, send = [3])
([0 2 1 0; 0 0 0 2; 0 0 0 1; 0 0 0 0], 3)
```
"""
function augmenting_path(mf::AbstractMatrix{Int}, s::Array{Int,1}, t::Int; 
    send::Array{Int,1}=fill(10^20,length(s)), track = false)

    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .≥ 0) "There are negative flow capacities, which is not possible." 

    # multiple sources
    # add node in front of the graph with the capacities that have to be sent to each source node
    # if the sources can create as much flow as possible, capacities equal to 10^20 are used
    mf_sourcerow = zeros(Int, n + 1)
    mf_sourcerow[s .+ 1] .= send 
    mf_sourcecol = zeros(Int, n)
    mf_new = [mf_sourcerow'; mf_sourcecol mf] # new network

    cur_flow, max_flow, tracker = augmenting_path(mf_new, 1, t + 1, track = true)
    cur_flow_new = cur_flow[2:end,2:end] # delete extra row and column from source
    return cur_flow_new, max_flow, tracker
end

"""
    augmenting_path(mf::AbstractMatrix{Int}, s::Int, t::Array{Int,1}; 
        desired::Array{Int,1}=fill(10^20,length(t)))

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
from source `s` to multiple sinks `t`.

The optional argument `desired` contains the flow that is desired to arrive in
the sink node(s). This can be used to solve a feasible flow problem. 
This method can also be used for a feasible flow problem with a single sink, if `t` is 
given as a single element array.

# Example
```julia-repl
julia> network = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0]
julia> s = 1
julia> t = [4]
julia> augmenting_path(network, s,t, desired = [3])
([0 2 … 0 0; 0 0 … 2 0; … ; 0 0 … 0 3; 0 0 … 0 0], 3)
```
"""
function augmenting_path(mf::AbstractMatrix{Int}, s::Int, t::Array{Int,1}; 
    desired::Array{Int,1}=fill(10^20,length(t)))
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .>= 0) "There are negative flow capacities, which is not possible." 

    # multiple sinks
    # add node at the back of the graph receiving the desired flow from each sink node
    # if the sinks can accept as much flow as possible, capacities equal to 10^20 are used
    mf_sinkcol = zeros(Int, n + 1)
    mf_sinkcol[t] .= desired 
    mf_sinkrow = zeros(Int, n)
    mf_new = [[mf; mf_sinkrow'] mf_sinkcol] # extended network

    cur_flow, max_flow = augmenting_path(mf_new, s, n + 1)
    cur_flow_new = cur_flow[1:end - 1,1:end - 1] # delete extra row and column from sink
    return cur_flow, max_flow
end

"""
    augmenting_path(mf::AbstractMatrix{Int}, s::Array{Int,1}, t::Array{Int,1}; 
        send::Array{Int,1}=fill(10^20,length(s)), 
        desired::Array{Int,1}=fill(10^20,length(t)))

Execute Ford-Fulkerson method with breadth-first-search (Edmonds-Karp algorithm)
to find the maximum flow of a network from a maximum flow problem `mf` 
with multiple sources `s` and multiple sinks `t`.

The optional argument `send` contains the maximum "stock" that is available to originate in
the source node(s). The optional argument `desired` contains the flow that is desired to 
arrive in the sink node(s).This can be used to solve a feasible flow problem. 
This method can also be used for a feasible flow problem with a single source and/or sink, 
if `s` and/or `t` is given as a single element array.

# Example
```julia-repl
julia> network = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0];
julia> s = [1];
julia> t = [4];
julia> augmenting_path(network, s,t, send = [3], desired = [3])
([0 2 1 0; 0 0 0 2; 0 0 0 1; 0 0 0 0], 3)
```
"""
function augmenting_path(mf::AbstractMatrix{Int}, s::Array{Int,1}, t::Array{Int,1}; 
    send::Array{Int,1}=fill(10^20,length(s)), desired::Array{Int,1}=fill(10^20,length(t)))
    n = size(mf, 1) # number of vertices
    @assert n == size(mf, 2) "Adjacency matrix has to be square."
    @assert all(mf .≥ 0) "There are negative flow capacities, which is not possible." 

    # multiple sources and sinks
    # add node in front of the graph with the capacities that have to be sent to each source node
    # if the sources can create as much flow as possible, capacities equal to 10^20 are used
    mf_sourcerow = zeros(Int, n + 2)
    mf_sourcerow[s .+ 1] .= send 
    mf_sourcecol = zeros(Int, n + 1)
    # add node at the back of the graph receiving the desired flow from each sink node
    # if the sinks can accept as much flow as possible, capacities equal to 10^20 are used
    mf_sinkcol = zeros(Int, n + 1)
    mf_sinkcol[t] .= desired 
    mf_sinkrow = zeros(Int, n)
    mf_new = [mf_sourcerow'; [mf_sourcecol [mf; mf_sinkrow'] mf_sinkcol]] # extended network

    cur_flow, max_flow = augmenting_path(mf_new, 1, n + 2)
    cur_flow_new = cur_flow[2:end - 1,2:end - 1] # delete extra rows and columns from source and sink
    return cur_flow_new, max_flow
end

"""
    isfeasible(flow::AbstractMatrix{Int}; s, t, send::Array{Int,1}=Int[], 
        desired::Array{Int,1}=Int[])

Check if the `flow` obtained by solving a maximum flow problem with source(s) `s` and 
sink(s) `t`, is a solution to the feasible flow problem, where  `send` is the amount of flow
that has to be sent from the source node(s) and `desired` the needed flow in the sink 
node(s). Can also be used if there is only a `send` or `desired` constraint to the 
feasible flow problem. Return `true` if the flow is feasible, `false` if not.

# Example
```julia-repl
julia> network = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0];
julia> s = [1];
julia> t = [4];
julia> flow, mflow = augmenting_path(network, s,t, send = [3], desired = [3])
julia> isfeasible(flow,s = s, t = t, send = [3], desired = [3])
true
```
"""
function isfeasible(flow::AbstractMatrix{Int}; s, t, send::Array{Int,1}=Int[], desired::Array{Int,1}=Int[])
    r,c = size(flow) # rows and columns of flow
    @assert r == c "Flow matrix has to be square"
    # Maybe delete the space between the exclamation mark and isempty? Or make it consistent, cause line 52 had no space in between
    ! isempty(send) && @assert length(s) == length(send) "Length of `send` has to be equal to the number of sources."
    ! isempty(desired) && @assert length(t) == length(desired) "Length of `desired` has to be equal to the number of sinks."
    # initialization
    a,b = true,true
    # check if all is sent
    ! isempty(send) && (a = all([sum(flow[j,:]) - sum(flow[:,j]) == send[i] for (i,j) in enumerate(s)]))
    # check if all is received
    ! isempty(desired) && (b = all([sum(flow[:,j]) - sum(flow[j,:]) == desired[i] for (i,j) in enumerate(t)]))
    return a && b
end

"""
	clean!(flow::AbstractMatrix{Int})
Clean a `flow` if some irregularities occur due to the use of multiple sources and/or sinks.
"""
function clean!(flow::AbstractMatrix{Int})
    r,c = size(flow) # rows and columns of flow
    @assert r == c "Flow matrix has to be square"
	flow .-= flow'
	flow[flow .< 0] .= 0
end
end