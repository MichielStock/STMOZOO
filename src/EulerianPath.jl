module EulerianPath

export  create_adj_list, has_eulerian_cycle, has_eulerian_path

#SUGGESTION: Consider naming the function create_adj_dict 
# and the variable adj_dict so that it's clearer what 
# type of variable you create (same in the other functions)
"""
    create_adj_list(edges)

    This is the function to create adjacent list.
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

#SUGGESTION: Consider specifying the type of the parameter adj_list as adj_list::Dict
#both in has_eulerian_cycle and has_eulerian_path to clarify what thenfunction takes as
#input parameter
"""
    has_eulerian_cycle(adj_list)

    This is the function to test if the dictionary of nodes, 
    whose key is for each node and the value is the list of nodes that has edges,
    has an eulerian cycle. 
    It is based on the theory: 
    A connected graph has an Euler cycle if and only if every node has even degree. 

"""

function has_eulerian_cycle(adj_list::Dict)
    odd = 0
    for node in keys(adj_list)
        if isodd(length(adj_list[node]))
            odd += 1
        end
    end
    return odd == 0
end

"""
    has_eulerian_path(adj_list)

    This is the function to test if the dictionary of nodes, 
    whose key is for each node and the value is the list of nodes that has edges,
    has an eulerian path. 

    It is based on the theory :
    An undirected graph has an Eulerian trail if and only if exactly zero or two vertices have odd degree, 
    and all of its vertices with nonzero degree belong to a single connected component.

"""

function has_eulerian_path(adj_list::Dict)
    odd = 0
    for node in keys(adj_list)
        if isodd(length(adj_list[node]))
            odd += 1
        end
    end
    if odd == 0 || odd == 2
        return true
    end
    return false
end

end