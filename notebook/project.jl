### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 132aa06a-a321-4f78-a4a5-b24f02bf9742
# main loop
function SMA(N, maxt)
	
	# initialize some things
	current_iteration = 0
	slime_list = [(1,1) for k in 1:N] # initialize slimes with position, change to more usefull default values.
	fitness_list = [0 for k in 1:N]
	weight_list = [0 for k in 1:N]
	p_list = [0 for k in 1:N]
	
	# keep going until max iterations
	while current_iteration < maxt
		current_iteration += 1
		
		# cycle through all the different slimes
		for s in 1:N
			fitness_list[s] =
			weight_list[s] = 	
		end

		# update p, vb and vc
		a = atanh(-(current_iteration / maxt) + 1)
		b = 1 - (current_iteration + 1) / maxt
		DF = max(fitness_list)
		for s in 1:N # mooier doen met list comprehension?
			p_list = tanh(fitness_list - DF)
		end		
		
		# update positions
		# om animatie te maken (of iets visueel te doen) best alle tussentijdse posities opslaan? Hoe? dump naar file? of gewoon in memory?
		for s in 1:N
			slime_list[s] = 
		end
	end
	return Xb, bestFitness
end

# ╔═╡ 5e62b60e-6c00-11ec-34fa-4b57e5168947
# fitness weight of slime mold
function W()


end

# ╔═╡ 31e9357a-d037-41f5-8eac-2f7cc0089ed1
# fitness function
function S()

	
end

# ╔═╡ 18212ee5-c042-4956-995d-375b90f90840
# update location
function X_update()

	
end

# ╔═╡ 70fce88d-210f-41a1-9be4-bb4b91a480a8
[(1,1) for k in 1:10]

# ╔═╡ 26dc9cc9-bbbf-45d6-8ebd-67c22d580108
# HOE VISUALISATION?
# makie package?

# ╔═╡ Cell order:
# ╠═132aa06a-a321-4f78-a4a5-b24f02bf9742
# ╠═5e62b60e-6c00-11ec-34fa-4b57e5168947
# ╠═31e9357a-d037-41f5-8eac-2f7cc0089ed1
# ╠═18212ee5-c042-4956-995d-375b90f90840
# ╠═70fce88d-210f-41a1-9be4-bb4b91a480a8
# ╠═26dc9cc9-bbbf-45d6-8ebd-67c22d580108
