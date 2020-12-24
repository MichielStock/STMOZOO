# Chananchida Sang-aram
module Raytracing

using Plots, DataStructures

export add_objects!, create_scene, dijkstra, reconstruct_path, get_neighbors, 
draw_circle, plot_pixels, plot_pixel_edges, plot_paths, plot_circle

"""
    add_objects!(scene::Array{R,2}, objects::Array{Set{Tuple{Int,Int}},1},
        objects_ior::Array{R,1}) where {R<:Real}

Add one or more objects to a pre-existing `scene`. The objects are placed
in the scene following the order of the array.
"""
function add_objects!(scene::Array{R,2}, objects::Array{Set{Tuple{Int,Int}},1},
    objects_ior::Array{R,1}) where {R<:Real}
    h, w = size(scene)
    for o=1:length(objects)  # FIXME using `=` in for loops is bad style, replace with `is`
        for (i,j) in objects[o]
            (i <= 0 || j <= 0 || i > h || j > w) && continue # Check bounds
            scene[i,j] = objects_ior[o]
        end
    end 
end

add_objects!(scene::Array{R,2}, object::Set{Tuple{Int,Int}},
    object_ior::Real) where {R<:Real} = add_objects!(scene, [object], [object_ior])

"""
    create_scene(w::Int, h::Int, objects::Array{Set{Tuple{Int,Int}},1},
        objects_ior::Array{R,1}) where {R<:Real}

Create a `h` x `w` matrix of ones. If one or more objects (a set of points) are provided, those
indices are replaced by the value `objects_ior`. The objects are placed in the scene following the
order of the array.
"""
function create_scene(w::Int, h::Int, objects::Array{Set{Tuple{Int,Int}},1},
        objects_ior::Array{R,1}) where {R<:Real}
    scene = [1.0 for i=1:h,j=1:w]
    add_objects!(scene, objects, objects_ior)
    return scene
end

create_scene(w::Int, h::Int, object::Set{Tuple{Int,Int}}, object_ior::Real) =
    [(i,j) ∈ object ? object_ior : 1.0 for i=1:h,j=1:w]

#FIXME: this definition seems redundant if you add default values for the previous one
create_scene(w::Int, h::Int) = create_scene(w, h, Set{Tuple{Int,Int}}(), 1.0)

"""
    draw_circle(r::Int, w_center::Int, h_center::Int)

Return a list of points of a circle with radius `r` centered at `w_center` on the x-axis (columns)
and `h_center` on the y-axis (rows) with radius. The first part draws the circle
perimeter based on the midpoint circle algorithm. Then, the points inside the inside
are calculated using the equation of a circle.
"""
function draw_circle(r::Int, w_center::Int, h_center::Int)  # QUESTION: can these not be just numbers instead of Int?
    points = Set{Tuple{Int,Int}}()
    x, y = r, 0
    
    # Adding initial point
    push!(points, (x+h_center, y+w_center)) 
      
    # When radius is zero only a single point will be returned
    if r > 0
        push!(points, (-x + h_center, w_center), (h_center, r + w_center),
            (h_center, -r + w_center))
    end
    
    # Initializing the value of P  
    P = 1 - r  
    while x > y
        y += 1
        
        # Is the midpoint inside or outside the perimeter
        x = P <= 0 ? x : x - 1
        P = P <= 0 ? P + 2y + 1 : P + 2y - 2x + 1
        
        # All the perimeter points have already been added  
        x < y && break
          
        # Adding the reflection of the generated point in other octants
        push!(points, (x+h_center, y+w_center), (-x+h_center, y+w_center),
            (x+h_center, -y+w_center), (-x+h_center, -y+w_center))

        # If the generated point is on the line x = y then  
        # the perimeter points have already been added
        if x != y
            push!(points, (y + h_center, x + w_center), (-y + h_center, x + w_center),
                (y + h_center, -x + w_center), (-y + h_center, -x + w_center))
        end
    end
    
    inside_pts = Set{Tuple{Int,Int}}((x, y) for x=-r+h_center:r+h_center,
                                                y=-r+w_center:r+w_center
                                            if (x-h_center)^2 + (y-w_center)^2 < r^2)
                    
    return union(points, inside_pts)
end

# FIXME: Array{R,2} => Matrix{R} ?
# suggestion: you might make an iterator, i.e., return ((x, y) for ...), this is more memory efficient than making lists
"""
    get_neighbors(scene::Array{Real,2}, u::Tuple{Int,Int})

Get adjacent neighbors (including diagonals) of an element `u` in the scene.
Returns a list of tuples.
"""
function get_neighbors(scene::Array{R,2}, u::Tuple{Int,Int}) where {R<:Real}
    m, n = size(scene)
    i, j = u
    ρ = scene[i,j] # Index of refraction
    neighbors = []  #FIXME: add type annotation, cannot be inferred here
    
    i < m && push!(neighbors, (ρ, (i+1, j)))  # Down
    i > 1 && push!(neighbors, (ρ, (i-1, j)))  # Up
    
    if j < n
        push!(neighbors, (ρ, (i, j+1)))  # Right
        i < m && push!(neighbors, (ρ*sqrt(2), (i+1, j+1)))  # Bottom right
        i > 1 && push!(neighbors, (ρ*sqrt(2), (i-1, j+1)))  # Top right
    end
    
    if j > 1
        push!(neighbors, (ρ, (i, j-1)))  # Left
        i < m && push!(neighbors, (ρ*sqrt(2), (i+1, j-1)))  # Bottom left
        i > 1 && push!(neighbors, (ρ*sqrt(2), (i-1, j-1)))  # Top left
    end

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

# FIXME: technically, these should be of the form `plot_pixels!()` as they add something to a plot
# SUGGESTION: when i write custom plotting functions it might be useful to do something like
#=
function myplot(data; kwargs...)
    do something
    plot(...; kwargs...)
end

here, `kwargs...` ensures you can pass any other keyword argument to the plot, like color, alpha and line tickness

=#

"""
    plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}

Add individual pixels of the `scene` to a `Plots` object.
"""
function plot_pixels(p::Plots.Plot, scene::Array{R,2}) where {R<:Real}
    m,n = size(scene)
    pixels = [(i,j) for i=1:m,j=1:n]
    plot!(p, last.(pixels), first.(pixels), seriestype = :scatter,
        markersize = 50/maximum(first.(pixels)), color=:red)
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
                        label=false, color=:black, lw=0.5, linealpha=0.3)
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
                label=false, color=:red, lw=2)
        end
    end
end

"""
    plot_circle(p::Plots.Plot, r::Int, w_center::Int, h_center::Int,
                plot_pixels::Bool=true) 

Plot a circle centered at `w_center` on the x-axis (columns) and `h_center`
on the y-axis (rows) with radius `r` on a `Plots` object. If `plot_pixels=true`,
individual pixels are plotted instead of a vector shape.
"""
function plot_circle(p::Plots.Plot, r::Int, w_center::Int, h_center::Int,
                    plot_pixels::Bool=false)
    if plot_pixels
        points = draw_circle(r, w_center, h_center)
        plot!(p, last.(points), first.(points), seriestype = :scatter,
            markerstrokewidth=0, markeralpha=0.5, color=:blue)
    else
        θ = LinRange(0, 2π, 500)
        plot!(p, w_center .+ r*sin.(θ), h_center .+ r*cos.(θ),
            seriestype=[:shape], legend=false, fillalpha=0.5)
    end
end

end