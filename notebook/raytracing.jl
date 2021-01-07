### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 297c8c20-4058-11eb-1971-33d12e5164de
using Plots, DataStructures, STMOZOO.Raytracing, PlutoUI

# ╔═╡ e1779dd0-4056-11eb-0e2d-b5b2899e9b47
md"""# Ray Tracing with Dijkstra's Algorithm

Welcome to the notebook on ray tracing based on Dijkstra's algorithm!"""

# ╔═╡ 2c27d600-4058-11eb-1b24-4bd3cab88d09
md"""## What is Ray Tracing?

One problem with discussing ray-tracing is that ray-tracing is an overloaded term. In 3D computer graphics (CG), ray tracing is a **rendering technique** for generating an image by tracing the path of light as pixels in an image plane and simulating the effects of its encounters with virtual objects. It is the technique that studios like Disney and Pixar use to create their animated 3D films. In physics, ray tracing is a **method for calculating the path of waves or particles** through a system with regions of varying propagation velocity, absorption characteristics, and reflecting surfaces.

While these two definitions are highly similar (we essentially trace a path of light from a source to a sink), an important distinction lies on how the source is defined (see figure below). Ray-tracing in physics is the more intuitive way: we start at a light source and follow the path of each ray, a process called forward tracing. This process is not very useful for computer graphics, as most of the rays will not hit the observer and many computations will not be used. Therefore, modern rendering techniques rely on reverse tracing, where we define the observer as the source, and we only follow the rays that reaches the light source.

![](https://raysect.github.io/documentation/_images/ray-tracing_directions.png)

(Figure taken from the [Raysect](https://raysect.github.io/documentation/how_it_works.html#id1) package.)

In this notebook, we will only concern ourselves with the forward tracing algorithm in the 2D space (so no fancy rendered images, unfortunately). We will also only implement refraction of light rays."""

# ╔═╡ 7a325230-4058-11eb-0668-31cd724624c3
md"""## Constructing a Scene

We would like to follow the path of light rays emanating from a single source. To do that, we will construct a 2D grid (representative of our "scene") and trace the path of light to designated edges of the grid. First we will create a scene with width 20 and height 10 (a $10\times20$ grid)."""

# ╔═╡ cf690c80-4058-11eb-0651-378b92054e4d
tiny_scene = create_scene(20, 10);

# ╔═╡ fee12600-4058-11eb-3eea-df7aed35a7c2
md"""Just for demonstration, we can use `plot_pixels` and `plot_pixel_edges` to see how each element in the grid is connected. We define two elements as neighbors if they are next to each other horizontally, vertically or diagonally."""

# ╔═╡ f143e370-4058-11eb-24ca-3f867b1638f8
let
	h, w = size(tiny_scene)
	p = plot(xticks=0:5:w+1, xlims=(0,w+1),
			 yticks=0:5:h+1, ylims=(0,h+1),
			 legend=false, aspectratio=1,
			 yflip=true, size=(450, 300))
	plot_pixel_edges!(p, tiny_scene)
	plot_pixels!(p, tiny_scene)
	plot(p)
end

# ╔═╡ 120ed0fe-4059-11eb-2ed4-f33531ba8588
md"""### Drawing objects in a scene

To study the refraction of rays, there would need to be some objects in the scene. Let us start by creating another scene and placing some circles in there."""

# ╔═╡ 30febd00-4059-11eb-15b6-57b68583a378
circle = draw_circle(5, 45, 20);

# ╔═╡ 1e363c70-4059-11eb-0d3d-5312bd042d56
scene = create_scene(80, 60, circle, 0.7);

# ╔═╡ ac63f0f0-4059-11eb-0676-078ce8af6a46
heatmap(scene, yflip=true, seriescolor=:ice, size=(300,200))

# ╔═╡ d36523e0-4059-11eb-3379-153b66651a92
md"""We can add another circle to the scene with the function `add_objects!`, which modifies the scene in-place."""

# ╔═╡ beee08f0-4059-11eb-16b1-73fca7023e32
add_objects!(scene, draw_circle(5, 20, 30), 0.9)

# ╔═╡ d1e38cf2-4059-11eb-266a-ddc98480544e
heatmap(scene, yflip=true, seriescolor=:ice, size=(300,200))

# ╔═╡ b07eb3e0-405a-11eb-3c2a-65bd7c1b796b
md"""It is also possible to define a scene with multiple objects from the start. In addition, we demonstrate an alternate way to visualize the scene in the code chunk below. The `plot_circle` function plots the circle(s) as a vector by default."""

# ╔═╡ b5313f72-405a-11eb-22c7-6bd6f47cdc0b
let
	# Define scene with multiple circles
	r, w_center, h_center = [5,5], [45,20], [20,30]
	circles = draw_circle.(r, w_center, h_center)

	w,h = 80,60
	scene = create_scene(w, h, circles, [0.7, 0.9])

	p = plot(xticks=0:5:w+1, xlims=(0,w+1),
			 yticks=0:5:h+1, ylims=(0,h+1),
			 legend=false, aspectratio=1, yflip=true,
			 size=(450,300))

	for i=1:length(circles)
		plot_circle!(p, r[i], w_center[i], h_center[i])
	end
	plot(p)
end

# ╔═╡ face23e0-405a-11eb-0e45-532725c7967a
md"""## Dijkstra's Algorithm

Dijkstra's algorithm (DA) is an algorithm for finding the shortest paths between nodes in a graph. The pseudocode and further explanation of the algorithm can be found [here](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm).

For our use case, we will always be providing both a source and a sink node. As we are tracing the path on an image plane, i.e., a grid, we will implement a version of DA that takes an $m \times n$ matrix as input instead of the usual adjacency list. This will also shorten our computation time. The only difference in practice is that we will compute the neighboring nodes of node ($i$,$j$) on the fly (using the function `get_neighbors`) instead of pre-storing the neighbors in a dictionary.

Let us test out the algorithm on a scene with a single circle. We will place the source on the center left of the scene and calculate the shortest paths to the right edge of the scene. Play around with the sliders below to see how the paths change!

`source_x`: location of the source on the y-axis

`n_sinks`: number of sinks in the right edge

`r`, `w_center`, `h_center`: radius and centers of the circle on the x and y-axis.

`ior`: index of refraction of the circle
"""

# ╔═╡ 74f1e0b0-4067-11eb-1b5a-b9716a4b6d7f
md"""
`source_x` $(@bind source_x html"<input type=range min=1 max=60 value=30 >")
`n_sinks` $(@bind n_sinks html"<input type=range min=10 max=50 value=20>")

`r` $(@bind r html"<input type=range min=1 max=30 value=15 >")
`w_center` $(@bind w_center html"<input type=range min=1 max=80 value=40 >")
`h_center` $(@bind h_center html"<input type=range min=1 max=60 value=30 >")

`ior` $(@bind ior html"<input type=range min=0.2 max=1.2 step=0.1 value=0.7 >")
"""

# ╔═╡ 388758b0-4069-11eb-2cbb-19d5f2aa84df
md"The source is at $(source_x) and there are $(n_sinks) sinks. The circle is centered at $(w_center), $(h_center) with radius $(r), and an index of refraction of $(ior)."

# ╔═╡ 2846c3e2-405b-11eb-3a0e-f3686b82c142
let
	# Define scene; circle properties are retrieved from the sliders
	w,h = 80, 60
	test_circle = draw_circle(r, w_center, h_center)
	scene = create_scene(w, h, test_circle, ior)

	p = plot(xticks=0:5:w+1, xlims=(0,w+1),
			 yticks=0:5:h+1, ylims=(0,h+1),
		     legend=false, aspectratio=1, yflip=true)

	# Remember we are working with a matrix, so (i,j) = (row, column)
	source = (source_x,1) # value from slider
	sinks = [(k,w) for k=round.(Int64, LinRange(1, h, n_sinks))]
	path = [reconstruct_path(dijkstra(scene, source, sinks[i])[2],
			source, sinks[i]) for i=1:length(sinks)];

	plot_circle!(p, r, w_center, h_center)
	plot_paths!(p, path)
	plot(p)
end

# ╔═╡ e8696900-406c-11eb-1a6c-c78c52b20ac5
md"""Notice that the more you increase the index of refraction ($\rho$), the more the light rays will try to avoid the circle. This makes sense because the distance between each pixel is defined as $\rho$ for horizontal/vertical pixels and $\sqrt{2}\rho$ for diagonal pixels."""

# ╔═╡ 103d9170-406f-11eb-0a04-dd7f46ec64b2
md"""### Why use a Dijkstra ray tracer?

As you may have noticed, the code runs substantially slower with the maximum number of sinks. If this is the computational time for just one ray, it does not seem practical for usage in CG rendering which may require the processing of millions of rays. 

Indeed, traditional ray tracers (RTs) use analytical methods to determine how far a light ray is from a certain object. This is often implemented as vectors instead of discrete pixels like we have done in this tutorial. Solving the intersection between a ray and a circle boils down to solving the equation $(x_c-x_p)^2+(y_c-y_p)^2 = r^2$, where $c$ and $p$ subscripts represent the circle and light ray, respectively. As this is just solving the quadratic equation, finding the path of this ray can essentially be done in constant time. Nonetheless, different shapes would require solving different equations, so an intersection method would have to be defined separately for each shape.

What about more complicated shapes which cannnot be defined by an equation, i.e., shapes which are not [parametric](https://en.wikipedia.org/wiki/Parametric_surface) and/or [implicit](https://en.wikipedia.org/wiki/Implicit_surface)? In that case, the traditional approach is to model the shape using polygons. These polygons are then converted to triangles because it is generally much easier to ray trace each individual triangle rather than develop an algorithm to ray trace polygons.

The Dijkstra RT does not have these drawbacks. Since we follow the ray pixel-by-pixel (and light will always travel using the shortest path), we do not need to define an intersection between a ray and an object. By extension, this also means that the Dijkstra RT works with any shape without a need for object conversion (e.g., to triangles). In addition, Dijkstra could be useful for when there are many objects in a scene. In contrast to traditional RT, the runtime of Dijkstra does not depend on the number of objects in the scene but rather on the size of the scene itself.

Knowing this, we can go crazy with the scene creation! A final example is shown below, where the light source is placed in the center, and we trace its path to the scene boundaries. Observe how the rays try to avoid circles with a high index of refraction, and go towards circles with a low index of refraction."""

# ╔═╡ c3a18370-4f42-11eb-0bbd-f7c18b3dd76d
let
	w, h = 80, 60
	circles = draw_circle.([12, 10, 5, 2, 7, 5],	 # radii
						   [60, 0, 15, 23, 45, 75],	 # w_center
						   [15,40, 12, 50, 56, 45]); # h_center
	circles_ior = [0.7, 0.9, 1.5, 0.3, 0.5, 1.2]
	scene = create_scene(w, h, circles, circles_ior);
	
	source = (h÷2,w÷2) # Center of scene
	# Create sinks for all four edges of the scene
	sinks = hcat([(k,j) for j in (1, w), k=round.(Int64, LinRange(1, h, 30))],
             [(i,k) for i in (1, h), k=round.(Int64, LinRange(1, w, 60))])
	paths = [reconstruct_path(dijkstra(scene, source, sink)[2],
        	source, sink) for sink in vcat(sinks...)]; # flatten sinks with vcat
	
	p = heatmap(scene, yflip=true, aspectratio=1, c=:redsblues, clim=(0,2))
	plot_paths!(p, paths)
	p
end

# ╔═╡ 68578a30-4f44-11eb-398c-91b744c83610
md"""Thanks for reading, and hope you enjoyed the tutorial!"""

# ╔═╡ 23afba50-4081-11eb-3c62-e3d9c19ece56
md"""## References & Further Reading

* This project was inspired by a blog post of Eric Jang (2018) [[1](https://blog.evjang.com/2018/08/dijkstras.html)].
* A great introductory video about CG rendering and ray tracing [[2](https://www.youtube.com/watch?v=LAsnQoBUG4Q)].
* Tutorials for implementation of the reverse tracing algorithm (and reflections): Python [[3](https://medium.com/swlh/ray-tracing-from-scratch-in-python-41670e6a96f9)] \(beginner\), Julia [[4](https://www.youtube.com/watch?v=MkkZb5V6HqM),[5](https://computationalthinking.mit.edu/Fall20/hw7/)] \(intermediate\).
* Explanation of several concepts were taken from [scratchapixel](https://www.scratchapixel.com), in particular the overview of ray tracing [[6](https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-overview/ray-tracing-rendering-technique-overview)] and ray tracing polygons [[7](https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-polygon-mesh)].
"""

# ╔═╡ Cell order:
# ╟─e1779dd0-4056-11eb-0e2d-b5b2899e9b47
# ╠═297c8c20-4058-11eb-1971-33d12e5164de
# ╟─2c27d600-4058-11eb-1b24-4bd3cab88d09
# ╟─7a325230-4058-11eb-0668-31cd724624c3
# ╠═cf690c80-4058-11eb-0651-378b92054e4d
# ╟─fee12600-4058-11eb-3eea-df7aed35a7c2
# ╠═f143e370-4058-11eb-24ca-3f867b1638f8
# ╟─120ed0fe-4059-11eb-2ed4-f33531ba8588
# ╠═30febd00-4059-11eb-15b6-57b68583a378
# ╠═1e363c70-4059-11eb-0d3d-5312bd042d56
# ╠═ac63f0f0-4059-11eb-0676-078ce8af6a46
# ╟─d36523e0-4059-11eb-3379-153b66651a92
# ╠═beee08f0-4059-11eb-16b1-73fca7023e32
# ╠═d1e38cf2-4059-11eb-266a-ddc98480544e
# ╟─b07eb3e0-405a-11eb-3c2a-65bd7c1b796b
# ╠═b5313f72-405a-11eb-22c7-6bd6f47cdc0b
# ╟─face23e0-405a-11eb-0e45-532725c7967a
# ╟─74f1e0b0-4067-11eb-1b5a-b9716a4b6d7f
# ╟─388758b0-4069-11eb-2cbb-19d5f2aa84df
# ╠═2846c3e2-405b-11eb-3a0e-f3686b82c142
# ╟─e8696900-406c-11eb-1a6c-c78c52b20ac5
# ╟─103d9170-406f-11eb-0a04-dd7f46ec64b2
# ╟─c3a18370-4f42-11eb-0bbd-f7c18b3dd76d
# ╟─68578a30-4f44-11eb-398c-91b744c83610
# ╟─23afba50-4081-11eb-3c62-e3d9c19ece56
