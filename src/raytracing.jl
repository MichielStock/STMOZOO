# Chananchida Sang-aram
module Raytracing

using Plots
using DataStructures:PriorityQueue

export create_scene, dijkstra, reconstruct_path, get_neighbors, 
get_circle_perimeter, get_circle_inside, get_circle,
plot_pixels, plot_pixel_edges, plot_paths, plot_circle

"""
    create_scene(w::Int, h::Int, circle::Set{Tuple{Int,Int}}, circle_ior::Real)

Create a `h` x `w` matrix of ones. If a circle (from the function `get_circle`) is provided, those
indices are replaced by the value `circle_ior`.
"""
create_scene(w::Int, h::Int, circle::Set{Tuple{Int,Int}}, circle_ior::Real) =
    [(i,j) ∈ circle ? circle_ior : 1.0 for i=1:h,j=1:w]

create_scene(w::Int, h::Int) = create_scene(w, h, Set{Tuple{Int,Int}}(), 1.0)

"""
    get_circle_perimeter(r::Int, h_center::Int, w_center::Int)

Return the perimeter points of a circle centered at `w_center` on the x-axis (columns) and `h_center`
on the y-axis (rows) with radius `r` based on the midpoint circle algorithm.
"""
function get_circle_perimeter(r::Int, h_center::Int, w_center::Int)
    points = []
    x, y = r, 0
    
    # Adding initial point
    push!(points, (x+w_center, y+h_center)) 
      
    # When radius is zero only a single point will be returned
    if r > 0
        push!(points, (-x+w_center, h_center), (w_center, r+h_center),
            (w_center, -r+h_center))
    end
    
    # Initializing the value of P  
    P = 1-r  
    while x > y
        y += 1
        
        # Is the midpoint inside or outside the perimeter
        x = P <= 0 ? x : x-1
        P = P <= 0 ? P+2y+1 : P+2y-2x+1
        
        # All the perimeter points have already been added  
        x < y && break
          
        # Adding the reflection of the generated point in other octants
        push!(points, (x+w_center, y+h_center), (-x+w_center, y+h_center),
            (x+w_center, -y+h_center), (-x+w_center, -y+h_center))

        # If the generated point is on the line x = y then  
        # the perimeter points have already been added
        if x != y
            push!(points, (y+w_center, x+h_center), (-y+w_center, x+h_center),
                (y+w_center, -x+h_center), (-y+w_center, -x+h_center))
        end
    end
    return points
end

"""
    get_circle_inside(r::Int, h_center::Int, w_center::Int)

Return a list of points inside a circle centered at `w_center` on the x-axis (columns)
and `h_center` on the y-axis (rows) with radius `r`.
"""
get_circle_inside(r::Int, h_center::Int, w_center::Int) =
    [(x,y) for x=-r+w_center:r+w_center, y=-r+h_center:r+h_center
        if (x-w_center)^2 + (y-h_center)^2 < r^2]

"""
    get_circle(r::Int, h_center::Int, w_center::Int)

Call `get_circle_perimeter` and `get_circle_inside` to get all points inside
and on a circle centered at `w_center` on the x-axis (columns) and `h_center`
on the y-axis (rows) with radius `r`.
"""
get_circle(r::Int, h_center::Int, w_center::Int) =
    union(Set{Tuple{Int,Int}}(get_circle_perimeter(r, w_center, h_center)),
    Set{Tuple{Int,Int}}(get_circle_inside(r, w_center, h_center)))

"""
    get_neighbors(scene::Array{Real,2}, u::Tuple{Int,Int})

Get adjacent neighbors (including diagonals) of an element `u` in the scene.
Returns a list of tuples.
"""
function get_neighbors(scene::Array{R,2}, u::Tuple{Int,Int}) where {R<:Real}
    m, n = size(scene)
    i, j = u
    ρ = scene[i,j] # Index of refraction
    neighbors = []
    
    # Cardinals
    j < n && push!(neighbors, (ρ, (i, j+1)))  # Right
    j > 1 && push!(neighbors, (ρ, (i, j-1)))  # Left
    i < m && push!(neighbors, (ρ, (i+1, j)))  # Down
    i > 1 && push!(neighbors, (ρ, (i-1, j)))  # Up
    
    # Diagonals
    j < n && i < m && push!(neighbors, (ρ*sqrt(2), (i+1, j+1)))  # Bottom right
    j < n && i > 1 && push!(neighbors, (ρ*sqrt(2), (i-1, j+1)))  # Top right
    j > 1 && i < m && push!(neighbors, (ρ*sqrt(2), (i+1, j-1)))  # Bottom left
    j > 1 && i > 1 && push!(neighbors, (ρ*sqrt(2), (i-1, j-1)))  # Top left
    
    return neighbors
end

"""
    dijkstra(scene::Array{R,2}, source::Tuple{Int,Int}, sink::Tuple{Int,Int}) where {R<:Real}

Dijkstra's shortest path algorithm on a 2D array. Returns the `distances` and `previous` dictionaries.
"""
function dijkstra(scene::Array{R,2}, source::Tuple{Int,Int}, sink::Tuple{Int,Int}) where {R<:Real}
    m, n = size(scene)
    
    # Initialize the tentative distances as Inf except for source
    distances = Dict((i,j) => Inf for i=1:m,j=1:n)
    distances[source] = 0
    
    # Initialize backtracking matrix and priority queue
    previous = Dict{Tuple{Int,Int},Tuple{Int,Int}}()
    pq = PriorityQueue{Tuple{Int,Int},Real}(source => 0)
    
    while length(pq) > 0
        u = dequeue!(pq)   # Remove and return best node
        u == sink && break
        
        neighbors = get_neighbors(scene, u)
        for (dist_to_v, v) in neighbors
            alternative = distances[u] + dist_to_v
            if alternative < distances[v]
                distances[v] = alternative
                previous[v] = u
                pq[v] = alternative
            end
        end
    end
    return distances, previous
end

"""
    reconstruct_path(previous::Dict{Tuple{Int,Int},Tuple{Int,Int}},
        source::Tuple{Int,Int}, sink::Tuple{Int,Int}

Reconstruct the path from the `previous` dictionary obtained from `dijkstra`.
"""
function reconstruct_path(previous::Dict{Tuple{Int,Int},Tuple{Int,Int}},
        source::Tuple{Int,Int}, sink::Tuple{Int,Int})
    # Return empty path if source is not in previous 
    if source ∉ values(previous)
        return []
    end
    
    v = sink        # Path is reconstructed backwards
    path = [v]      # Path is a list of no
    while v != source
       v = previous[v] 
        pushfirst!(path, v)
    end
    return path
end

"""
    plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}

Add individual pixels of the `scene` to a `Plots` object.
"""
function plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}
    m,n = size(scene)
    pixels = [(i,j) for i=1:m,j=1:n]
    plot!(p, last.(pixels), first.(pixels), seriestype = :scatter,
        markersize = 50/maximum(first.(pixels)))
end

"""
    plot_pixel_edges(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}

Add edges between adjacent pixels of the `scene` to a `Plots` object.
"""
function plot_pixel_edges(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}
    m,n = size(scene)
    # Get neighbors of each point, store original node as first element of list
    neighbors_matrix = [vcat((i,j), last.(get_neighbors(scene, (i,j)))) for i=1:m,j=1:n]
    for neighbors in neighbors_matrix
        for neighbor in neighbors[2:end]
            plot!(p, [neighbors[1][2], neighbor[2]], [neighbors[1][1], neighbor[1]],
                        label=false, color=:black)
        end
    end
end

"""
    plot_paths(p::Plots.Plot, paths::Array{Array{Tuple{Int64,Int64},1},1}) 

Plot reconstructed paths on a `Plots` object. Each element in the `paths` array
is an output of `reconstruct_path.`
"""
function plot_paths(p::Plots.Plot, paths::Array{Array{Tuple{Int,Int},1},1})
    for path in paths
        for (i, pixel) in enumerate(path[1:end-1])
            # Connect point i to point i+1 with a line
            plot!(p, [pixel[2], path[i+1][2]], [pixel[1], path[i+1][1]],
                label=false, color=:red, lw=3)
        end
    end
end

"""
    plot_circle(p::Plots.Plot, r::Int, h_center::Int, w_center::Int,
                plot_pixels::Bool=true) 

Plot a circle centered at `w_center` on the x-axis (columns) and `h_center`
on the y-axis (rows) with radius `r` on a `Plots` object. If `plot_pixels=true`,
individual pixels are plotted instead of a vector shape.
"""
function plot_circle(p::Plots.Plot, r::Int, h_center::Int, w_center::Int,
                    plot_pixels::Bool=true)
    if plot_pixels
        points = get_circle_perimeter(r, w_center, h_center)
        points_inside = get_circle_inside(r, w_center, h_center)
        plot!(p, last.(points), first.(points), seriestype = :scatter,
            markerstrokewidth=0, color=:gray)
        plot!(p, last.(points_inside), first.(points_inside), seriestype = :scatter,
            markerstrokewidth=0, markeralpha=0.5, color=:blue)
    else
        θ = LinRange(0, 2π, 500)
        plot!(p, w_center .+ r*sin.(θ), h_center .+ r*cos.(θ),
            seriestype=[:shape], legend=false, fillalpha=0.5)
    end
end

end