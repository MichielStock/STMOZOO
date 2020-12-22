module EulerianPath

export  create_adj_list
using DataStructures
"""
This is function to create adjacent list.
The input is a list of edges, the output is a dictionary. 
The key is each node, the value is the node has edges with it.
"""
function create_adj_list(edges)
    adj_list = DefaultDict{Int, Array{Int}}(() -> Vector{Int}())
        for (x, y) in edges
        push!(adj_list[x], y)
        push!(adj_list[y], x)
        end
return adj_list 
end

function has_eulerian_cycle(adj_list)
    odd = 0
    for node in adj_list
        if len(adj_list[node]) % 2 != 0
            odd += 1
        end
    end
    if odd == (0 || 2)
        return True
    end
    return False
end


end