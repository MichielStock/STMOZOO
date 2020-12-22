module EulerianPath

export  create_adj_list, has_eulerian_cycle
"""
This is function to create adjacent list.
The input is a list of edges, the output is a dictionary. 
The key is each node, the value is the node has edges with it.
"""
function create_adj_list(edges)
    adj_list = Dict{Int, Array{Int}}()
        for (x, y) in edges
            if x ∉ keys(adj_list)
                adj_list[x] = [y]
            else
                push!(adj_list[x], y)
            end
            
            if y ∉ keys(adj_list)
                adj_list[y] = [x]
            else
                push!(adj_list[y], x)
            end
        end
return adj_list    
end

"""
This is the function to test if the dictionary of nodes, 
whose key is for each node and the value is the list of nodes that has edges,
has an eulerian cycle. 

It is based on the theory :
An undirected graph has an Eulerian trail if and only if exactly zero or two vertices have odd degree, 
and all of its vertices with nonzero degree belong to a single connected component.

"""

function has_eulerian_cycle(adj_list)
    odd = 0
    for node in keys(adj_list)
        if length(adj_list[node]) % 2 != 0
            odd += 1
        end
    end
    if odd == 0 || odd == 2
        return true
    end
    return false
end



end