# Chananchida Sang-aram

module Raytracing

using Plots, DataStructures

export create_scene

"""
    create_scene(w::Int, h::Int, circle::Set{Tuple{Int,Int}}, circle_ior::Real)

Creates an m x n matrix with a circle of differing index of refraction inside.

Inputs:
    - `w` : width of the scene (n)
    - `h` : height of the scene (m)
    - `circle` : set of points of a circle (from function `get_circle`)
    - `circle_ior`: index of refraction of points in/on the circle
Ouput:
    - a matrix with each element corresponding to the index of refraction at that point
"""
create_scene(w::Int, h::Int, circle::Set{Tuple{Int,Int}}, circle_ior::Real) =
    [(i,j) ∈ circle ? circle_ior : 1.0 for i=1:h,j=1:w]

create_scene(w::Int, h::Int) = create_scene(w, h, Set{Tuple{Int,Int}}(), 1.0)

"""
    get_circle_perimeter(r::Int, h_center::Int, w_center::Int)

Returns a list of points making up the perimeter of a circle based on the
midpoint circle algorithm.

Inputs:
    - `r` : radius of the circle
    - `h_center` : center of the circle on the y-axis
    - `w_center` : center of the circle on the x-axis
Ouput:
    - a list of points to draw the circle
"""
function get_circle_perimeter(r::Int, h_center::Int=0, w_center::Int=0)
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

Returns a list of points inside a circle.

Inputs:
    - `r` : radius of the circle
    - `h_center` : center of the circle on the y-axis
    - `w_center` : center of the circle on the x-axis
Ouput:
    - a list of points inside the circle
"""
get_circle_inside(r::Int, h_center::Int=0, w_center::Int=0) =
    [(x,y) for x=-r+w_center:r+w_center, y=-r+h_center:r+h_center
        if (x-w_center)^2 + (y-h_center)^2 < r^2]

"""
    get_circle(r::Int, h_center::Int, w_center::Int)

Returns a list of all points of a circle.

Inputs:
    - `r` : radius of the circle
    - `h_center` : center of the circle on the y-axis
    - `w_center` : center of the circle on the x-axis
Ouput:
    - a set of points on the perimeter and inside of the circle
"""
get_circle(r::Int, h_center::Int=0, w_center::Int=0) =
    union(Set{Tuple{Int,Int}}(get_circle_perimeter(r, w_center, h_center)),
    Set{Tuple{Int,Int}}(get_circle_inside(r, w_center, h_center)))

"""
    get_neighbors(scene::Array{Real,2}, u::Tuple{Int,Int})

Get adjacent neighbors of a grid element. Returns up to 8 neighbors.

Inputs:
    - `scene` : 2-dimensional matrix representing the grid, contains the index of refraction as values
    - `u`: the element (i,j) in which to get the neighbors

Outputs:
    - a list of neighbors (Array{Tuple{Int, Int}})
"""
function get_neighbors(scene::Array{R,2}, u::Tuple{Int,Int}) where {R<:Real,T}
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
    dijkstra(scene::Array{R,2}, source::Tuple{Int,Int}, sink::Tuple{Int,Int}) where {R<:Real,T}

Dijkstra's shortest path algorithm.

Inputs:
    - `graph` : adjacency list representing a weighted directed graph
    - `source`
    - `sink`

Outputs:
    - the shortest path
    - the cost of this shortest path
"""
function dijkstra(scene::Array{R,2}, source::Tuple{Int,Int}, sink::Tuple{Int,Int}) where {R<:Real,T}
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

Reconstruct the path from the output of the Dijkstra algorithm.

Inputs:
    - `previous` : a Dict with the previous node in the path
    - `source` : the source node
    - `sink` : the sink node
Ouput:
    - the shortest path from source to sink
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
    plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real,T}

Adds individual pixels of the scene matrix to a Plots object.

Inputs:
    - `p` : a Plots object
    - `scene`: a matrix with each element corresponding to the index of refraction at that point
Ouput:
    - modified plots object with pixels plotted
"""

function plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real,T}
    m,n = size(scene)
    pixels = [(i,j) for i=1:m,j=1:n]
    plot!(p, last.(pixels), first.(pixels), seriestype = :scatter,
        markersize = 50/maximum(first.(pixels)))
end

"""
    plot_pixel_edges(p::Plots.Plot, scene::Array{R,2}) where {R<:Real,T}

Add edges between adjacent pixels to a Plots object.

Inputs:
    - `p` : a Plots object
    - `scene`: a matrix with each element corresponding to the index of refraction at that point
Ouput:
    - modified plots object with edges between adjacent pixels plotted
"""
function plot_pixel_edges(p::Plots.Plot, scene::Array{R,2}) where {R<:Real,T}
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

Plot reconstructed paths on a Plots object.

Inputs:
    - `p` : a Plots object
    - `paths`: an array of paths, where each path is a list of tuples from source to sink
Ouput:
    - modified plots object with paths plotted
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
    plot_circle(p::Plots.Plot, r::Int, h_center::Int=0, w_center::Int=0,
                plot_pixels::Bool=true) 

Plot given circle on a Plots object.

Inputs:
    - `p` : a Plots object
    - `r` : radius of the circle
    - `h_center` : center of the circle on the y-axis
    - `w_center` : center of the circle on the x-axis
    - `plot_pixels` : if true, plot individual pixels instead of a clean shape
Ouput:
    - modified plots object with a circle plotted
"""
function plot_circle(p::Plots.Plot, r::Int, h_center::Int=0, w_center::Int=0,
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