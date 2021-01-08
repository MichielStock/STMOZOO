### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 071d90a0-5022-11eb-14e4-4fa157ca26cd
using STMOZOO.polygon, Images, Plots, ImageMagick

# ╔═╡ 15c58bda-5022-11eb-14f6-a7bc04afeebc


# ╔═╡ 70543f9a-501f-11eb-316a-8fcc43b9720e
md"""
# It's Triangle Time
## Welcome to the polygon module
**By Bram Spanoghe**

So, imagine you've gotten into your abstractionism phase, or you just joined the illuminati, and you've taken a liking to triangles. Happens to everyone. And you're looking at an image and you're thinking: "Well it's *nice*, but it isn't *triangles*."

Well my friend, then this is the module for you. Because believe me, *it's got triangles*.

Let's take a look at an example. Let's say you're still in the christmas spirit:

![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/Christmastime.png)

First of all: it's january already. Second of all: *what if it was triangles?*

Bam.

![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/chringus.png)

*"How did you do that?!"*, you must be thinking now, *"He made it triangles. I want triangles!"*

One function my friend: **triangleevolution**. The golden goose of this module, the star itself. Allow me to introduce you to it. 

## Introduction to the algorithm

triangleevolution is an evolutionary algorithm with the single goal to approximate a given target image with, you guessed it, triangles. So, an evolutionary algorithm, how does it work?
Luckily for you, I have a gif showcasing the process of my algorithm (cool, I know).
Let's have a look.

![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/chrismus.gif)

As you can see, the algorithm starts off with a bunch of random triangle people (a bunch of triangles), which it has generated itself, and evolves them generation by generation. Important to note is that this gif only shows the best *individual* (triangle person) of every generation. Every generation consists of a population of many individuals (a village full of triangle people). And every one of these triangle people gets a score assigned to them, based on how closely they resemble the target image. This score represents a "fitness" of the individual. In this case, a lower score is a better match to the image, and thus a higher fitness.

After generating your first population at random, the evolution starts happening. The algorithm starts off with picking the best individuals of your generation (the elite) and transferring them directly to the new population (the winners' bucket). They survive by default. Then the battle begins. In order to get into the new population, a tournament selection is held between all individuals from the original population. Two randomly chosen individuals face off, and the one with the lowest (= best) score gets to the new population. A brutal tournament. We keep adding individuals to the new population this way until it's almost the size of the original population.

Then, the last part of the new population is filled in with new, randomly generated individuals. These are migrant triangles settling down in your triangle village.
Finally, all individuals in this new population, aka the winners' bucket, get the chance to live out their lives peacefully. They did it. They survived.

As the years go by, the triangle people find someone they like and start a family together. Triangle kids are born. These triangle kids receive their genes from their 2 parents (a gene is a triangle, remember that triangle people consists of a whole buch of triangles not just one). However, the triangle people use way too much CFK's and have made a hole in the ozon layer, which makes the kids' genes also randomly mutate: some triangles from the individuals of the children population change slightly in position and color.

These mutant kids grow up and ultimately form the starting population of the next generation: the cycle of life continues.

## Try it yourself

It's time to evolve your own population of triangle people!
Start by finding yourself an image on google search you like. Make sure it's a rather small image, or it will take forever (under 200x200 is recommended for use on the notebook, if you run the source code locally under 500x500 is recommended).
Fill in the image location in the following cell:
"""

# ╔═╡ 8601cd72-5035-11eb-3f3d-c55adde433bc
mycoolimage =  "https://i.pinimg.com/originals/5b/4d/f2/5b4df26cd69db57d2a3e1bd02c9e051a.jpg" # Replace with an image of your liking!

# ╔═╡ 8b1ec382-5035-11eb-3d3b-0f8b74714d90
mycoolimg = mktemp() do fn,f
    download(mycoolimage, fn)
    load(fn)
end

# ╔═╡ 96127d14-5035-11eb-1e26-2bb14a0e00e9
md"""
Now for the algorithm itself!
"""

# ╔═╡ d1f6b424-5035-11eb-0e3f-5567f1a70960
mycooltriangleimg = triangleevolution(mycoolimage) # Will take a while

# ╔═╡ 618f8e30-5036-11eb-240e-31b5ce847da2
plot(mycooltriangleimg[1][2]) # Plot the best individual (number 1, so [1]) his image (individual consists of 3 elements: list of triangles, image made up of these triangles and its score, so [2])

# ╔═╡ 4eb4c9a6-503b-11eb-399e-edc05c7608ac
md"""
As you can see, that probably did not produce the greatest results. The default parameters were set for a quick-ish result, with a pretty low amount of generations and population size. For better results, change the parameters.

I filled in the default parameters down here, you can change them to your liking. For better results, increasing generations and pop_size works best for most images. But feel free to experiment what changing the other parameters does!
"""

# ╔═╡ f869b13c-503b-11eb-15f6-dd14c5e9afe3
begin
	number_triangles = 25 # Amount of triangles per individual (default 25)
	generations = 50 # Amount of generations (default 50)
	pop_size = 70 # Amount of individuals in one population (default 70)
	elitism_freq = 0.10 # Fraction of population that's elite (default 0.10)
	newblood_freq = 0.03 
	# Fraction of population that gets replaced by new individuals (default 0.03)
	mutation_freq = 0.07 # Frequency of mutations (default 0.07)
	mutation_intensity = 0.1 # The maximum fraction of the canvas size your triangle points move at every mutation
	mutation_intensity_color = 0.5 # The intensity of color change every mutation
	gifname = "mycoolgif.gif"
	# If you enter a gifname ("coolgif.gif"), it will save the process as a gif 		(default nothing)
	fps = 2 # fps of said gif (default 2)
end

# ╔═╡ 81dfc1a4-503c-11eb-1cab-131124513e22
mycustomizedtriangleimg = triangleevolution(mycoolimage, number_triangles = number_triangles, generations = generations, pop_size = pop_size, elitism_freq = elitism_freq, newblood_freq = newblood_freq, mutation_freq = mutation_freq, mutation_intensity = mutation_intensity, mutation_intensity_color = mutation_intensity_color, gifname = gifname, fps = fps)

# ╔═╡ bf112874-503c-11eb-027c-df10ccb762b6
plot(mycustomizedtriangleimg[1][2])

# ╔═╡ be36a202-503f-11eb-280e-0f9115b8665d
md"""
## The end
Well, that was it. Hope you enjoyed the triangle zone. I'm going to finish this off with some more triangulated images to show off that the algorithm can actually produce something similar-ish to the original image if you bump up the amount of generations. I'd like to think if you run it with 100+ triangles, a population size of 100+ and a couple thousand generations you'll actually get good results, but I don't have a supercomputer at home to test that.

Feel free to add a triangulated image of your own to this list!
"""

# ╔═╡ 48cf63f0-5047-11eb-3e5b-8b87ce2b12eb
"Mini Totoros (Studio Ghibli), 200 generations (Bram)"

# ╔═╡ 99d8aafe-5047-11eb-03be-33e217a7a166
md"""
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/TotoroTester.jpeg)
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/TotoroTesterTriangled.png)
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/TotoroTime.gif)
"""

# ╔═╡ d22c1f10-5049-11eb-270c-21770eb7b95d
"Rectangles? idk much about abstract art (Mondrian), 200 generations (Bram)"

# ╔═╡ 04ae1760-504a-11eb-3514-0ba30c36e3d6
md"""
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/mondrian.png)
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/triangledmondrian.png)
![](https://raw.githubusercontent.com/bspanoghe/STMOZOO/polygon/notebook/examplefigures/mondrian.gif)
"""

# ╔═╡ Cell order:
# ╟─15c58bda-5022-11eb-14f6-a7bc04afeebc
# ╠═071d90a0-5022-11eb-14e4-4fa157ca26cd
# ╟─70543f9a-501f-11eb-316a-8fcc43b9720e
# ╠═8601cd72-5035-11eb-3f3d-c55adde433bc
# ╠═8b1ec382-5035-11eb-3d3b-0f8b74714d90
# ╟─96127d14-5035-11eb-1e26-2bb14a0e00e9
# ╠═d1f6b424-5035-11eb-0e3f-5567f1a70960
# ╠═618f8e30-5036-11eb-240e-31b5ce847da2
# ╟─4eb4c9a6-503b-11eb-399e-edc05c7608ac
# ╠═f869b13c-503b-11eb-15f6-dd14c5e9afe3
# ╠═81dfc1a4-503c-11eb-1cab-131124513e22
# ╠═bf112874-503c-11eb-027c-df10ccb762b6
# ╟─be36a202-503f-11eb-280e-0f9115b8665d
# ╟─48cf63f0-5047-11eb-3e5b-8b87ce2b12eb
# ╟─99d8aafe-5047-11eb-03be-33e217a7a166
# ╟─d22c1f10-5049-11eb-270c-21770eb7b95d
# ╟─04ae1760-504a-11eb-3514-0ba30c36e3d6
