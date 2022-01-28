### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 29377c58-c5da-4e22-9502-58270c97745c
using Plots, PlutoUI, Zygote, LinearAlgebra

# ╔═╡ 1549aa30-6e24-11ec-3f44-93d0c99f8ba9
md"# PeptFold2D.jl: Optimization of peptide folding in 2D off-lattice model
**STMO**

2021-2022

project by Thomas Van De Velde"

# ╔═╡ bb39a6da-989b-42a9-a380-201dcd72218c
md"**PeptFold2D** provides a simplified off-lattice model for peptide folding in 2D space. Using an off-lattice model allows to fully query the available geometric space. 
- A peptide structure is generated based on an amino acid (AA) sequence and a (random) vector θ of bond angles. Starting from a specified coordinate (e.g. [0,0]), the bond angle in combination with a fixed bond length is sufficient to position an amino acid in relation to the previous amino acid.
- To optimize the position of the amino acids in the peptide based on this initial structure, their potential energy is evaluated as the sum of pairwise interactions with all other non-bonded amino acids. The potential energy function is defined by a coulomb electrostatic interaction term and a Lennard-Jones vanderwaals interaction term between non-bonded AAs. 
- To constrain the simulation space, the potential energy function is fed to a loss function. This loss function adds a penalty for exceeding the limits of the simulation box. The size of the box is set by the user.
- A 2 step optimization (initial solution + simulated annealing) is applied to this structure to minimize its potential energy by optimizing the bond angles between the peptide AAs. "

# ╔═╡ 83705cac-b851-4c6e-bd7a-72f9c5a08553
md"## Part 1: Generate initial peptide structure"

# ╔═╡ 07ec7e0f-07c5-44e8-8d9d-471e63dcff44
md"A 2D peptide is represented as a string of AAs in which each AA is simplified as a single charged body. Peptides are created as a vector of charges using $$create\_peptide()$$. From this peptide, a structure is generated using $$generate\_structure()$$, taking a vector of charges and a vector of bond angles $$θ$$ as arguments (bond length is an optional argument). A vector of n random bond angles can be generated using $$θ\_generator()$$. The function $$structure\_to\_peptide()$$ is a wrapper for these functions taking only a peptide string as argument. To visualize the structure $$plot\_structure()$$ is used."

# ╔═╡ 9c00dddd-3f2c-4599-a0e2-953356136970
peptide="DNKFREFPEWTHILKD"

# ╔═╡ 8d3464f9-7338-498b-8851-870f75864877
md"Box size:"

# ╔═╡ 440996c3-ba7a-4a95-9934-b8dca2475fa9
@bind box confirm(Slider(1:1:10,default=4, show_value=true))

# ╔═╡ e41723bc-b953-4f06-b81a-f0d8168431b5
md"## Part 2: Geometric optimization "

# ╔═╡ 8934a844-db04-4d1f-bdc6-e5edc6b2c41b
md"Geometric optimization is minimizing a potential energy function. The potential energy function is the sum of 2 interaction terms over all non-bonded AAs. Electrostatic  interaction is calculated based on the coulomb law in $$pot\_coulomb()$$, while vanderwaals interaction is calculated based on Lennard-Jones interaction in $$pot\_LJ()$$ as the sum of pairwise interactions. To constrain the optimization within a certain simulation box, $$loss\_θ()$$ applies a penalty on top of the total potential energy for exceeding the box limits (box size is an optional argument). 

A two step geometric optimization is applied. First, $$random\_opt()$$ generates an initial solution from n random bond angle vectors. Next, $$sim\_anneal\_opt()$$ takes the best solution into a simulated annealing method to further reduce the loss objective. This method generates \"good\" neighbors by selecting 1 residue and evaluating the objective for the full [-π,π] range of bond angles."

# ╔═╡ 40ea5ed6-86b5-4ac3-b79a-bfd0864b76c0
md"### Step 1: Initial optimization
*Finding an initial structure for the peptide by random sampling of the 2D space*"

# ╔═╡ ca93f680-2ab9-44a5-9f6a-25f57e6a7410
md"### Step 2: Apply simulated annealing to the structure optimized in step 1
*Applying simulated annealing to optimize the initial structure using a loss function 
taking into account interactions between AAs and box size*"

# ╔═╡ a259f48c-da82-4aa8-976e-512dd7cd5569
md"### Conclusion"

# ╔═╡ 7f365bd7-e407-4d59-a70e-2639aee0a4f4
md"In conclusion, when starting from a given peptide sequence with randomly generated bond angles, PeptFold2D successfully 'folds' the peptide according to electrostatic and vanderwaals interactions within the limits of the simulation box. PeptFold2D does not guarantee the optimal solution, but finds a correct solution in a very large simulation space. Longer simulation time will deliver more optimal solutions. Performing simulations of many initial peptide structures in parallel can reveil possible convergence of a peptide to a certain consensus structure."

# ╔═╡ 26a8a15b-d503-4cd3-a769-d632f859c1b6
md"# Addendum: atomic interactions
**Electrostatic interaction** is described by the Coulomb law based on distance $r$ between the AA bodies and their respective charge $q1$ and $q2$. Potential energy $U$ is positive for equally charged AAs, while it is negative for opposite charged AAs."


# ╔═╡ c2f78f6c-62fa-4c3f-bc23-0429af8277a4
@bind q1 Slider(-10:0.01:10, show_value=true,default=-1)

# ╔═╡ 77a8c80a-6480-4041-8de1-122a6fdc85aa
@bind q2 Slider(-10:0.01:10, show_value=true;default=1)

# ╔═╡ 10ce01e8-d034-4881-9449-41e7469ed2e1
f(r)=8.9e9*q1*q2/r

# ╔═╡ d8de0f65-7428-4c95-9ab8-3f11b678d617
plot(f,1,10, title="Electrostatic coulomb potential U in function of r",xlabel="r",ylabel="U_coulomb",label="U(r)")

# ╔═╡ e388313b-65a4-4bc6-b9a8-0d105b625918
md"**Vanderwaals interactions** can be modelled by the Lennard-Jones potential $U$ based on distance $r$ between AA bodies and parameters $ϵ$ and $σ$, where dispersion energy $ϵ$ corresponds to the depth of the energy well and $σ$ corresponds to the distance where the potential is zero. The potential models how two interacting AAs repel each other at very close distance, attract each other at moderate distance, and do not interact at infinite distance."

# ╔═╡ 2f255247-c9fd-414e-875a-054d92141e1e
@bind ϵ Slider(-10:1:10, show_value=true,default=2)

# ╔═╡ c960b5f5-78ee-427d-b376-434679c757d4
@bind σ Slider(-1000:1:1000, show_value=true,default=-1)

# ╔═╡ 4e2a059a-1ee8-4f3e-9157-57af428307ef
g(r)=4*ϵ*((σ/r)^12-(σ/r)^6)

# ╔═╡ 4d7e19c6-37bc-4202-8b70-275dd649b87e
plot(g,1,10, title="Lennard-Jones potential U in function of r",xlabel="r",ylabel="U_LJ",label="U(r)")

# ╔═╡ 20392b28-aa24-4c64-93a2-d2a01a8cdb05
md"# Appendix"

# ╔═╡ 541f920e-d30d-4031-b7ca-152a4545376e
md"## Appendix -  Part 1: Generate initial peptide structure"

# ╔═╡ 0e353069-78a3-4630-adc4-7e622ddd4568
"""
get\\_AA_charge(AA::String)

Lookup amino acid charge.

Input:
- AA: amino acid query
Output:
- AA_charge: amino acid charge
"""		
function get_AA_charge(AA)		
	AA_charge=Dict{String,Float64}("G"=>0.0,"A"=>0.0,"L"=>0.0,"M"=>0.0,"F"=>0.0,"W"=>0.0,"K"=>1.0,"Q"=>0.0,"E"=>-1.0,"S"=>0.0,"P"=>0.0,"V"=>0.0,"I"=>0.0,"C"=>0.0,"Y"=>0.0,"H"=>1.0,"R"=>1.0,"N"=>0.0,"D"=>-1.0,"T"=>0.0)
	return AA_charge[AA]
end

# ╔═╡ b62c1464-4b31-47f9-b6de-4477c79497ad
"""
create_peptide(peptide::String)

Generate a peptide as a vector of charges based on AA sequence using charges defined per AA by get\\_AA_charge()

Input:
- peptide: AA string
Output:
- charge: vector of AA charges
"""
function create_peptide(peptide::String)
	n=length(peptide)
	charge=Vector{Float64}()
	for i in 1:n
		push!(charge,get_AA_charge(string(peptide[i])))
	end
	return charge
end

# ╔═╡ 67d22567-a606-4d97-8073-e4b56fd8604b
"""
θ_generator(n::Int64)

Generate n random values for bond angle θ [-π,π]

Input:
- n: number of bond angles to generate

Output:
- θ: vector or bond angles
"""
function θ_generator(n::Int64)
	θ=Vector{Float64}()
	for i in 1:n
		push!(θ,rand((-π:0.01:π)))
	end
	return θ
end

# ╔═╡ ba70f808-08e0-44b0-8139-5c0219605145
"""
update_position(pos::Vector{Float64},θ::Float64;l::Float64=1.0)

Determine new [x,y] coordinate starting from [x,y] coordinate of the previous residue, bond angle and bond length

Input:
- pos: position previous residue as [x,y] coordinate
- θ: bond angle
- l: fixed bond length
Output:
- new_pos: position current residue as [x,y] coordinate
"""
function update_position(pos::Vector{Float64},θ::Float64;l::Float64=1.0)
	new_pos=pos.+[l*cos(θ),l*sin(θ)]
	return new_pos
end

# ╔═╡ a17f6544-0969-4426-bb70-e9423bf717c7
"""
generate_structure(charge::Vector{Float64},θ::Vector{Float64};l::Float64=1.0,start::Vector{Float64}=[0.0,0.0])

Generate a peptide stucture from a vector of amino acid charges and a vector of bond angles. Bond length and start coordinates are optional arguments. A structure is defined as a vector of [charge, bond angle] for each residue]. The [x,y] coordinates are also returned for plotting purposes.

Input:
- charge: a vector of AA charges
- θ: a vector of bond angles
- l: fixed bond length
- start: coordinate of first AA in peptide

Output:
- structure: a vector of [charge,bond angle] per AA in peptide
- coords: a vector of [x,y] coordinates per AA in peptide

"""
function generate_structure(charge::Vector{Float64},θ::Vector{Float64};l::Float64=1.0,start::Vector{Float64}=[0.0,0.0])
	n=length(peptide)
	structure=[[charge[1],θ[1]]]
	coords=[start]
	for i in 2:n
		next=[charge[i],θ[i]]
		pos_new=update_position(coords[i-1],θ[i-1])
		push!(structure,next)
		push!(coords,pos_new)
	end
	return structure,coords
end

# ╔═╡ 700344b3-b793-4ad4-a4d9-3d4620ae77b5
"""
structure\\_from\\_peptide(peptide::String;θ::Vector{Float64}=θ_generator(length(peptide)))

Generate 2D structure from peptide sequence. Bond angle vector is an optional argument. Random bond angles are generated by default. Generates a charge vector using *create_peptide()* and generates structure using *generate_structure()*.

Input:
- peptide: AA string
- θ: vector of bond angles (default is a random vector)

Output:
- structure: [charge, bond angle] per AA in peptide
- coords: [x,y] coordinates per AA in peptide
"""
function structure_from_peptide(peptide::String;θ::Vector{Float64}=θ_generator(length(peptide)))
	p=create_peptide(peptide)
	structure,coords=generate_structure(p,θ)
	return structure,coords
end

# ╔═╡ 6c84ae9e-0f7d-4c51-9441-8f462b564126
structure,coords=structure_from_peptide(peptide)

# ╔═╡ f8f58d2d-a25e-481c-a1f0-b4abf524f0f9
"""
plot_structure(coords::Vector{Vector{Float64}}, structure::Vector{Vector{Float64}}, peptide::String; box::Int64=box)

Generator 2D peptide plot

Input:
- coords: vector of [x,y] coordinates per AA in peptide
- structure: vector of [charge,bond angle] per AA in peptide
- peptide: string of AA
- box: size of simulation box

Output:
- 2D peptide plot
"""
function plot_structure(coords::Vector{Vector{Float64}},structure::Vector{Vector{Float64}},peptide::String;box::Int64=box)
	plot([coords[i][1] for i in 1:length(coords)],[coords[i][2] for i 	in 1:length(coords)],seriestype = :path,series_annotations =[string(i) for i in 	peptide],legend=false,title="Peptide: $peptide",seriescolor="black")
	
	plot!([coords[i][1] for i in 1:length(coords)],[coords[i][2] for 	i in 1:length(coords)],seriestype =:scatter,series_annotations =[string(i) for i in peptide],markersize=15*abs.([structure[i][1] for i in 1:length(structure)]),markercolor=[structure[i][1]>0 ? 1 : 0 for i in 1:length(structure)],markeralpha=0.65)

hline!([-box,box],color="red")
vline!([-box,box],color="red")
end

# ╔═╡ d1b6e47d-22a1-4cb1-bdbe-f30fdf1e6eb6
plot_structure(coords,structure,peptide)

# ╔═╡ 9b265be1-c5e5-4538-a959-50b2602714d0
md"## Appendix - Part 2: Geometric optimization "

# ╔═╡ d99cfd3a-f897-40cf-81a0-adb135b20157
"""
distances_θ(θ::Vector{Float64};l::Float64=1.0)

Calculate pairwise distance between non-identical AAs in peptide as a function of bond angle. Returns a n x n distance matrix.

Input:
- θ: vector of bond angles
- l: fixed bond length
- start: (x,y) coordinates of start position

Output:
- distance: n x n distance matrix with n=length(θ)

"""
function distances_θ(θ::Vector{Float64};l::Float64=1.0)
	n=length(θ)
	x=Zygote.Buffer(zeros(n))
	y=Zygote.Buffer(zeros(n))
	distance=Zygote.Buffer(zeros(n,n))
    x[1],y[1]=0.0, 0.0
	n=length(θ)
	for i in 2:n
		x[i],y[i]=x[i-1] + l * cos(θ[i-1]),y[i-1] + l * sin(θ[i-1])
	end
	for i in 1:n
		for j in i+1:n
			distance[i,j]=sqrt((x[i]-x[j])^2+(y[i]-y[j])^2)
		end
	end
	return copy(distance)
end

# ╔═╡ 45432928-803b-48ec-bddf-fd5d934299d8
"""
pot_coulomb(structure::Vector{Vector{Float64}})

Calculate total potential electrostatic energy between AA pairs in peptide as a function of bond angle

Input
- structure: vector of [charge,bond angle] per AA in peptide

Output:
- pot: total potential electrostatic energy

"""
function pot_coulomb(structure::Vector{Vector{Float64}})
	charge=[structure[i][1] for i in 1:length(structure)]
	θ=[structure[i][2] for i in 1:length(structure)]
	dist=distances_θ(θ)
	pot=0
	for i in 1:length(structure)
		for j in i+2:length(structure)
			pot+=charge[i]*charge[j]/dist[i,j]
		end
	end
	return pot*100
end

# ╔═╡ 11be636d-713a-4efe-b37a-99bf364a9a86
"""
pot_LJ(structure::Vector{Vector{Float64}})

Calculate total potential vanderwaals energy between AA pairs in peptide as a function of bond angle

Input
- structure: vector of [charge,bond angle] per AA in peptide

Output:
- pot: total potential vanderwaals energy

"""
function pot_LJ(structure::Vector{Vector{Float64}})
	θ=[structure[i][2] for i in 1:length(structure)]
	dist=distances_θ(θ)
	pot=0
	for i in 1:length(structure)
		for j in i+2:length(structure)
			pot+=dist[i,j]^(-12)-dist[i,j]^(-6)
		end
	end
	return pot/500
end

# ╔═╡ 59f21d67-94c5-4016-8622-56f10cd6fe29
"""
loss_θ(structure::Vector{Vector{Float64}};box::Int64=box)

Update the potential energy from pot\\_coulomb() and pot_LJ() to add constraints on the structure

Input
- structure: vector of [charge,bond angle] per AA in peptide
- box: size of the box constraint

Output:
- l: loss
"""
function loss_θ(structure::Vector{Vector{Float64}};box::Int64=box)
  	s = 0
	θ=[structure[i][2] for i in 1:length(structure)]
	dist=distances_θ(θ)	
	for i in 2:length(structure)
		if dist[1,i]-box>0          
		  s+=100*(dist[1,i]-box)        
		end
	end
	l =  s + pot_coulomb(structure) + pot_LJ(structure)                   
	return l
end

# ╔═╡ 47c024fc-6150-467b-81df-bcfe9e53e3a9
"""
random\\_opt(peptide::String,loss_θ::Function,n::Int64)

Generate n structures using *structure_from_peptide()* and retain more optimal structures based on the objective loss function. Returns an optimized structure and an objective tracker.

Input:
- peptide: string of amino acids
- loss_θ: loss function
- n: number of steps

Output:
- str_final: optimized structure
- obj_tracker: tracker of objective during optimization
"""
function random_opt(peptide::String,loss_θ::Function,n::Int64)
	str_final=Vector{Vector{Float64}}()
	obj_opt=Inf
	obj_tracker=Vector{Float64}()
	for i in 1:n
		structure,coords=structure_from_peptide(peptide)
		obj=loss_θ(structure)
		if obj<obj_opt
			obj_opt=obj
			push!(obj_tracker,obj_opt)
			str_final=deepcopy(structure)
		end
	end
	return str_final,obj_tracker
end

# ╔═╡ 69a138ef-7862-44c2-866e-b07eeb425d58
opt_str_rand,obj_tracker_rand=random_opt(peptide,loss_θ,100000)

# ╔═╡ 5650e4ca-2078-4f29-842b-fe0b88a50e6a
structure2,coords2=generate_structure([opt_str_rand[i][1] for i in 1:length(opt_str_rand)],[opt_str_rand[i][2] for i in 1:length(opt_str_rand)])

# ╔═╡ e3896e61-8321-4e49-ae5b-054e465c5e8a
plot_structure(coords2,structure2,peptide)

# ╔═╡ f8b90343-aab7-4859-88d9-9934d4ce8739
begin 
	plot(obj_tracker_rand,legend=false)
	steps=length(obj_tracker_rand)
	obj_tracker_rand_last=round(last(obj_tracker_rand),digits=3)
	title!("Objective tracker step 1: $obj_tracker_rand_last in $steps steps")
	xlabel!("Step")
	ylabel!("loss_θ(structure)")
end

# ╔═╡ 2f0314d2-5a00-4ba6-8f5a-f6426cc16266
"""
good\\_neighbor(structure::Vector{Vector{Float64}},loss\\_θ::Function;angle_step::Float64=0.1)

Generate a good neighbor by adapting a random bond angle with the value of θ that minimized the loss function and returning a new structure.

Input:
- structure: vector of [charge,bond angle] per AA in peptide
- loss_θ: loss function
- angle_step: step size for angles to evaluate

Output:
- str_opt: good neighbor of structure
"""
function good_neighbor(structure::Vector{Vector{Float64}},loss_θ::Function;angle_step::Float64=0.1)
	str=deepcopy(structure)
	str_opt=deepcopy(structure)
	n=length(str)
	obj_opt=loss_θ(str)
	θ=[str[i][2] for i in 1:length(str)]
	θ_new=θ
	charge=[str[i][1] for i in 1:length(str)]
	select_res=rand(1:n)
	angles=collect(-π:angle_step:π)
	for i in 1:length(angles)
		θ_new[select_res]=angles[i]
		str_neighbor,coords_neighbor=generate_structure(charge,θ_new)
		obj=loss_θ(str_neighbor)
		if obj<obj_opt
			obj_opt=obj
			str_opt=deepcopy(str_neighbor)
		end		
	end
	return str_opt
end

# ╔═╡ ba0a420d-fc30-46e0-a7c9-939f6f547dc0
"""
sim\\_anneal\\_opt(structure::Vector{Vector{Float64}}, loss_θ::Function; Tmin::Float64=1.0, Tmax::Float64=100.0, kT::Int64=100, r::Float64=0.95)

Apply simulated annealing optimization to a structure. The method picks a random residue and uses *good_neighbor()* to evaluate the loss function for the full [-π,π] range of bond angles. The most optimal bond angle is retained. Use Tmin and Tmax to determine temperature range and r to set the cooling rate. kT determines the number of iterations.

Input:
- structure: vector of [charge,bond angle] per AA in peptide
- loss_θ: loss function
- Tmin: final temperature
- Tmax: starting temperature
- kT: number of iterations
- r: cooling rate

Output:
- str_opt: optimized structure
- obj_tracker: objective tracker
"""
function sim_anneal_opt(structure::Vector{Vector{Float64}}, loss_θ::Function; Tmin::Float64=1.0, Tmax::Float64=100.0, kT::Int64=100, r::Float64=0.95)
	str=deepcopy(structure)
	str_opt=deepcopy(structure)
	obj=loss_θ(str)
	obj_opt = obj
	obj_tracker=Vector{Float64}()
	push!(obj_tracker,obj_opt)
	T=Tmax
	while T>Tmin
		for _ in 1:kT
			str = good_neighbor(str,loss_θ)
			obj = loss_θ(str)
			if obj < obj_opt || rand() < exp(-(obj - obj_opt)/T)
				obj_opt = obj
				push!(obj_tracker,obj_opt)
				str_opt = deepcopy(str)
			end
		end
		T *= r
	end
	return str_opt,obj_tracker
end

# ╔═╡ cc445666-794a-49f8-a6b9-861adfc68696
opt_str_good,obj_tracker_good=sim_anneal_opt(opt_str_rand, loss_θ,Tmin=0.001, Tmax=1.0, kT=100, r=0.95)

# ╔═╡ 2b701598-4417-40ad-bf45-0bc2535481c5
structure3,coords3=generate_structure([opt_str_good[i][1] for i in 1:length(opt_str_good)],[opt_str_good[i][2] for i in 1:length(opt_str_good)])

# ╔═╡ a1db0450-0b17-4402-993a-5565eb817405
plot_structure(coords3,structure3,peptide)

# ╔═╡ 3a784b01-b37e-4472-a815-2c41812b8c87
begin 
	plot(obj_tracker_good,legend=false,xaxis=:log)
	steps_good=length(obj_tracker_good)
	obj_tracker_good_last=round(last(obj_tracker_good),digits=3)
	title!("Objective tracker step 2: $obj_tracker_good_last in $steps_good steps")
	xlabel!("Step")
	ylabel!("loss_θ(structure)")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
Plots = "~1.25.4"
PlutoUI = "~0.7.27"
Zygote = "~0.6.33"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9faf218ea18c51fcccaf956c8d39614c9d30fe8b"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRules]]
deps = ["ChainRulesCore", "Compat", "LinearAlgebra", "Random", "RealDot", "Statistics"]
git-tree-sha1 = "c6366ec79d9e62cd11030bba0945712eb4013712"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.17.0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d711603452231bad418bd5e0c91f1abd650cba71"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.3"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "9bc5dac3c8b6706b58ad5ce24cffd9861f07c94f"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.9.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "2b72a5624e289ee18256111657663721d59c143e"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.24"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b9a93bcdf34618031891ee56aad94cfff0843753"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "006127162a51f0effbdfaab5ac0c83f8eb7ea8f3"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.4"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "71d65e9242935132e71c4fbf084451579491166a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.4"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "de9e88179b584ba9cf3cc5edbb7a41f26ce42cda"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "IRTools", "InteractiveUtils", "LinearAlgebra", "MacroTools", "NaNMath", "Random", "Requires", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "78da1a0a69bcc86b33f7cb07bc1566c926412de3"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.33"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─29377c58-c5da-4e22-9502-58270c97745c
# ╟─1549aa30-6e24-11ec-3f44-93d0c99f8ba9
# ╟─bb39a6da-989b-42a9-a380-201dcd72218c
# ╟─83705cac-b851-4c6e-bd7a-72f9c5a08553
# ╟─07ec7e0f-07c5-44e8-8d9d-471e63dcff44
# ╠═9c00dddd-3f2c-4599-a0e2-953356136970
# ╠═6c84ae9e-0f7d-4c51-9441-8f462b564126
# ╟─8d3464f9-7338-498b-8851-870f75864877
# ╟─440996c3-ba7a-4a95-9934-b8dca2475fa9
# ╟─d1b6e47d-22a1-4cb1-bdbe-f30fdf1e6eb6
# ╟─e41723bc-b953-4f06-b81a-f0d8168431b5
# ╟─8934a844-db04-4d1f-bdc6-e5edc6b2c41b
# ╟─40ea5ed6-86b5-4ac3-b79a-bfd0864b76c0
# ╠═69a138ef-7862-44c2-866e-b07eeb425d58
# ╟─5650e4ca-2078-4f29-842b-fe0b88a50e6a
# ╟─e3896e61-8321-4e49-ae5b-054e465c5e8a
# ╟─f8b90343-aab7-4859-88d9-9934d4ce8739
# ╟─ca93f680-2ab9-44a5-9f6a-25f57e6a7410
# ╠═cc445666-794a-49f8-a6b9-861adfc68696
# ╟─2b701598-4417-40ad-bf45-0bc2535481c5
# ╟─a1db0450-0b17-4402-993a-5565eb817405
# ╟─3a784b01-b37e-4472-a815-2c41812b8c87
# ╟─a259f48c-da82-4aa8-976e-512dd7cd5569
# ╟─7f365bd7-e407-4d59-a70e-2639aee0a4f4
# ╟─26a8a15b-d503-4cd3-a769-d632f859c1b6
# ╠═c2f78f6c-62fa-4c3f-bc23-0429af8277a4
# ╠═77a8c80a-6480-4041-8de1-122a6fdc85aa
# ╠═10ce01e8-d034-4881-9449-41e7469ed2e1
# ╟─d8de0f65-7428-4c95-9ab8-3f11b678d617
# ╟─e388313b-65a4-4bc6-b9a8-0d105b625918
# ╠═2f255247-c9fd-414e-875a-054d92141e1e
# ╠═c960b5f5-78ee-427d-b376-434679c757d4
# ╠═4e2a059a-1ee8-4f3e-9157-57af428307ef
# ╟─4d7e19c6-37bc-4202-8b70-275dd649b87e
# ╟─20392b28-aa24-4c64-93a2-d2a01a8cdb05
# ╟─541f920e-d30d-4031-b7ca-152a4545376e
# ╟─0e353069-78a3-4630-adc4-7e622ddd4568
# ╟─b62c1464-4b31-47f9-b6de-4477c79497ad
# ╟─67d22567-a606-4d97-8073-e4b56fd8604b
# ╟─a17f6544-0969-4426-bb70-e9423bf717c7
# ╟─ba70f808-08e0-44b0-8139-5c0219605145
# ╟─700344b3-b793-4ad4-a4d9-3d4620ae77b5
# ╟─f8f58d2d-a25e-481c-a1f0-b4abf524f0f9
# ╟─9b265be1-c5e5-4538-a959-50b2602714d0
# ╟─d99cfd3a-f897-40cf-81a0-adb135b20157
# ╟─45432928-803b-48ec-bddf-fd5d934299d8
# ╟─11be636d-713a-4efe-b37a-99bf364a9a86
# ╟─59f21d67-94c5-4016-8622-56f10cd6fe29
# ╟─47c024fc-6150-467b-81df-bcfe9e53e3a9
# ╟─ba0a420d-fc30-46e0-a7c9-939f6f547dc0
# ╟─2f0314d2-5a00-4ba6-8f5a-f6426cc16266
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
