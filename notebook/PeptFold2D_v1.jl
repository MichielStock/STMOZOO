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

# ╔═╡ aed97b7d-4d3f-4eb7-a021-8f0f752cc814
using BioSymbols,BioSequences, Plots, PlutoUI, Zygote, Flux, Distances, Statistics, GeometryTypes, LinearAlgebra

# ╔═╡ 4acfed7b-1e4f-4c20-978b-683330dbc2bb
md"# PeptFold2D.jl: Optimization of peptide folding in 2D off-lattice model
**STMO**

2021-2022

project by Thomas Van De Velde"

# ╔═╡ 3a994310-7ff4-470e-a758-c67576a9f9ee
md"The aim of this project is to create a simplified off-lattice model for peptide folding in 2D space. Using an off-lattice model allows to fully query the availabe geometric space. 
- First, an environment is created to generate peptide structures based on an AA sequence, a vector θ of angles and a specified bond length. 
- Next a gradient descent based approach is applied on this structure to minimize the potential energy of the structure by adapting the positions of the peptide AAs. This geometry optimization process needs to take constraints related to the peptide into account, such as bond length between bonded AAs, electrostatic interaction and Vanderwaals interactions between non-bonded AAs. "

# ╔═╡ 17bf1795-1b1f-4d68-aa57-a9d337dae674
md"## Part 1: Creating an environment for working with peptides"

# ╔═╡ 35a3679d-aa85-4091-91f3-e515582a2ffc
md"A peptide is represented by a [charge, position] vector in which each AA is simplified as a single body with a certain charge (\"AA\") at a certain (x,y) coordinate (\"AA\_pos\"). Peptides are created using create\_peptide(). From this peptide, a structure is generated using generate\_structure(), taking a peptide, a vector of bond angles $θ$ and a bond length as arguments. Plot\_structure() is used to visualize the structure."

# ╔═╡ a21a26a1-fb95-4968-91e9-983f9096d224
peptide="DDDDGGGGKKKK"

# ╔═╡ 99972864-da75-4dac-bc42-4ecab2555919
md"## Part 2: Geometric optimization "

# ╔═╡ 65de4d00-763e-403a-b254-ebcc8d1a2d3d
md"To optimize the geometry of a peptide structure in a simplified 2D space, the following aspects will be taken into account:
- Electrostatic coulomb interaction between non bonded AAs
- Vanderwaals interactions between non bonded AAs
- Bond length between bonded AAs
- Overlap of AAs and bonds

Geometric optimization will be based on a potential energy function. The potential energy function is comprised of a electrostatic coulomb interaction term. This potential energy function is transformed via a loss() function to include constraints (vanderwaals interaction, bond length, bond overlap). Gradient descent is applied to this loss function via opt_structure() to optimize the AA positions."

# ╔═╡ 5fefff00-4f1a-4f6a-bdba-a5670d8e6fb8
md"### Testing the potential energy function: electrostatic interaction"

# ╔═╡ 0317f477-f61d-4ee3-8147-cf0a3002b39e
md"Electrostatic interaction is described by the Coulomb law based on distance $r$ between the AA bodies and their respective charge $q1$ and $q2$. Potential energy is positive for equally charged AAs, while it is negative for opposite charged AAs."

# ╔═╡ 4e9c4e8e-d52a-4448-8767-39412e280ca2
md"Define the potential per AA and the total potential per structure via pot_coulomb()"

# ╔═╡ 20924ef5-1bc0-46b3-b4df-a3270118eacc
@bind q1 Slider(-10:0.01:10, show_value=true,default=-1)

# ╔═╡ 894f52ca-eb4f-4c1d-967e-fa026260e7f8
@bind q2 Slider(-10:0.01:10, show_value=true;default=1)

# ╔═╡ 024fc0e2-f9de-4325-9d11-ec4cb2f3d489
f(r)=8.9e9*q1*q2/r

# ╔═╡ 42b3333a-a813-4294-b378-169216305c1c
md"The method is tested below using \"DGK\" and \"DGD\" peptides as examples:"

# ╔═╡ ede1390f-69f0-43cc-8d4a-9a79e81d7f38
md"#### Opposite charges attract each other:"

# ╔═╡ 8442367a-dce0-42a5-990a-0b68019cc356
md"Before optimization"

# ╔═╡ dffb1062-ca90-4c0c-86ec-38e791aa41de
md"After optimization"

# ╔═╡ 0d04ca74-43ce-4e5f-9578-853b09e19f06
md"#### Equal charges repulse each other:"

# ╔═╡ e9298923-d2cf-4622-9224-96fbf3b3cf04
md"Before optimization"

# ╔═╡ 8d2f05d8-995b-4ae1-acf9-ec6108e42e6b
md"After optimization"

# ╔═╡ d55596d8-8d60-4cf5-bd5d-dbd9fc4c9f93
md"The examples above show attraction and repulsion based on charge. Next, we will apply this to a longer peptide DDDDGGGGKKKK, while including the vanderwaals interactions between non-bonded AAs."

# ╔═╡ 5f9cc38d-3159-42f7-ba85-b6a9e913f411
md"### Testing the potential energy function: vanderwaals interaction"

# ╔═╡ 6a17eea2-3df5-486c-a4c2-4adf9aa93c34
md"Vanderwaals interactions can be modelled by the Lennard-Jones potential based on distance $r$ between AA bodies and parameters $ϵ$ and $σ$."

# ╔═╡ c832e1a3-d1db-40b5-ae02-d45ddfe7b580
@bind ϵ Slider(-10:1:10, show_value=true,default=2)

# ╔═╡ 367fb191-4870-4239-920e-61d3fbda704a
@bind σ Slider(-1000:1:1000, show_value=true,default=-1)

# ╔═╡ 284fdece-8ef3-4353-979e-5f1e6aa3b333
g(r)=4*ϵ*((σ/r)^12-(σ/r)^6)

# ╔═╡ d445a56a-636e-463b-ae03-69bfa71562dd
md"The exact values of $ϵ$ and $σ$ differ for each pair of atoms and are possibly not reliable when simplifying AAs as charged bodies. The vanderwaals repulsion is therefore approximated in the loss_nonbonded() function by a penalty inversely proportional to the distance $r$.

The structure is initialized below with the $θ\_nb$ vector:"

# ╔═╡ 7b68ef54-3b10-4a31-872b-5368c2c9381e
md"Without vanderwaals interactions in the model, the optimal structure indeed optimizes charge interaction, but AAs are overlapping, which is physically not possible due to repulsion by the nuclei."

# ╔═╡ 95a92d37-cc60-42b1-bf9c-4f7941ff8f86
md"Inluding vanderwaals interactions in the model shows repulsion between overlapping AAs. The previous structure is therefore disencouraged, resulting in a more realistic structure below. The penalty factor in loss_nonbonding() determines the magnitude of the correction."

# ╔═╡ b3e11412-9cc7-4c81-beb2-9c2408a0e464
md"The structure above contains AAs overlapping with AA bonds and bond length is variable. Therefore additional constraints are added to the loss function as penalty functions."

# ╔═╡ 6fc4f763-21ad-4342-b530-9f52fbae81f9
md"### Adding additional constraints to the model: bond length and overlap"

# ╔═╡ d88890d1-83b8-4c2d-bf5d-5c0c328a1213
md"The bond length between bonded AAs is restricted to the length specified by the user in loss_bonded() via a penalty function. The magnitude of the correction is dependent on the penalty factor."

# ╔═╡ 756b0681-557b-48d1-8b7e-44df44cc46e1
md"Constraining the bond length via a penalty function in loss\_bonded() reduces the variation on the set bond length within acceptable boundaries. The average deviation from the set bond length reduced from 2.5 to 0.44 when applying such constraint as demonstrated below."

# ╔═╡ 16e75a37-680f-4d8b-a319-a04bdfb34ea1
md"To avoid bonds intersecting in a 2D plane, the loss_overlap() function gives a penalty when 2 line segments between 4 nonidentical AAs intersect."

# ╔═╡ 336c8967-d5ce-4bd6-bda6-4149b448bc20
md"The loss\_overlap() function doesn't seem to work for now, as bonds are still overlapping. The method relies on balancing the 4 penalties (weights) of the different constraints in loss\_overlap(), so this should be further optimized."

# ╔═╡ 98a9ca21-d4b9-4917-baf0-a730f80c06b7
md"## Geometric optimization starting from a set of initial structures"

# ╔═╡ bbe087b6-f9b9-4b8f-a955-638457da5ae7
md"The structure optimization remains quite conservative to the initial structure though. Maybe the method could benefit from generating a set of initial structures to be optimized in parallel. Using the function θ\_generator(), initial\_θ() and initial\_structure(), a set of structures is generated. These are visualized via plot\_structures(). The function opt_structures() performs the geometric optimization for a set of initial structures."

# ╔═╡ e6e2db90-9628-4ec4-985f-29c78b345c27
md"A set of 12 structures is generated next to test whether optimizing different initial structures of the same peptide would lead to structural convergence."

# ╔═╡ 9a6b2eb1-0879-4337-98fd-7c1f2552cc22
md"Using loss\_bonded(), all initial structures show peptide-like geometric optimization based on charge. This comparison shows the dependency of the optimized structure on the initial structure, as no overall  convergence is observed. However, the methods lacks a penalty for overlapping bonds. Increasing the number of steps could improve chances for convergence as the search space is large."

# ╔═╡ da193625-7ad1-4364-99ab-2628a88710a9
md"## Vragen Michiel
- Origineel zat het AA (vb. \"G\") zelf ook in de AA en AA\_pos structuur, maar dit gaf problemen in de Zygote.gradient() functie in opt\_structure() \"Zygote.gradient(loss,str_opt)\". Kan ik specifiëren dat ik enkel de gradient over de positie nodig heb? (dus negeer AA en charge)

- In loss_overlap() probeer ik overlappende binding te elimineren door een penalty te geven bij bond intersect. Dit lijkt nog niet goed te werken en is computationeel intensief. Ik vermoed dat de verhouding tussen de verschillende penalties goed moet zitten. Probeer ik op deze weg door te gaan of lijkt het je beter om de constraints in objectief te verwerken?

- Door een off-lattice model te gebruiken is de search space vrij groot. Daarom beperk ik de gradient descent method tot een bepaald aantal stappen. Kan het nuttig zijn om hier een metaheuristic zoals simulated annealing aan te te voegen om locale minima te vermijden?

- In het ideale geval kan ik aantonen dat als ik start van verschillende initiële structuren, enkele van deze structuren convergeren. Of zou je een ander doel proberen?"

# ╔═╡ 373316d9-48af-4f9a-9650-e7c6414e9aad
md"## todo's/ideas for improvement:
- use tracker to follow obj
- combine loss functions in one in loss_x() to allow easier tuning of penalty factors
- what if you start from a linear peptide? is this method generally applicable? try different peptides
- introduce random moves?
- use simulated annealing,... to allow escape of local minima?
- add terms to energy function instead of penalties in loss function?
- switch to optimizing over θ instead of (x,y) coords
- try the model on a model for peptide folding? Containing charged residues?
- compare to hydrophobic/hydrophilic interaction like AB off-lattice model
- go from 2D to 3D
- compare results to PEP-FOLD or other peptide structure preduction tools?
- inverse peptide folding, what sequence is required for a certain geometry?"

# ╔═╡ 5206ac46-b21c-4cce-b984-2a0010c00edc
md"# Appendix"

# ╔═╡ 748f83d0-61da-11ec-3b32-cd7947823794
struct AA
  	#aminoacid::String > did not work out with Zygote.gradient, so omit for now
	charge::Float64
end

# ╔═╡ 13c02ad5-6f42-4ad4-a115-fc985e186c42
struct AA_pos
	#AA::AA > did not work out with Zygote.gradient, so omit for now
	charge::Float64
	pos::Vector{Float64}
end

# ╔═╡ 7e13789d-e8cb-430a-a11d-acf28a6f9ba1
function get_AA_charge(AA)		
	AA_charge=Dict{String,Int64}("G"=>0,"A"=>0,"L"=>0,"M"=>0,"F"=>0,"W"=>0,"K"=>1,"Q"=>0,"E"=>-1,"S"=>0,"P"=>0,"V"=>0,"I"=>0,"C"=>0,"Y"=>0,"H"=>1,"R"=>1,"N"=>0,"D"=>-1,"T"=>0)
	return AA_charge[AA] #randn()
end

# ╔═╡ 8aca45e0-41cd-480d-bf9b-91a4d80a6ec9
"""
create_peptide(peptide)

Generate a peptide as a vector of charges based on AA sequence using charges defined per AA by get_AA_charge()

Inputs:
- peptide: AA string
Outputs:
- peptide_AA: vector of AA charges
"""
function create_peptide(peptide)
	n=length(peptide)
	peptide_AA=[]
	for i in 1:n
		push!(peptide_AA,get_AA_charge(string(peptide[i])))
		#push!(peptide_AA,AA(string(peptide[i]),get_AA_charge(string(peptide[i]))))
	end
	return peptide_AA
end

# ╔═╡ cf812b21-aa42-49e6-92aa-3d7a95bd182a
p=create_peptide(peptide)

# ╔═╡ ad2bd196-894d-4c7a-a860-8999aabb73b6
function θ_generator(n)
	θ=[]
	for i in 1:n
		push!(θ,rand((-π:π)))
	end
	return θ
end

# ╔═╡ 45e4cccd-5bfd-45dd-90dd-4046caef3db5
θ_test=θ_generator(length(peptide))

# ╔═╡ 6dab2e8b-7426-4c26-b743-a2000eef02b8
"""
generate_structure(peptide,θ,bond_length;start=[0.0,0.0])


Input:
- peptide: a vector of AA charges
- θ: a vector of bond angles
- bond length: fixed distance between bonded AAs
- start: coordinate of first AA in peptide

Output:
- structure: a vector of AA_pos

"""
function generate_structure(peptide,θ,bond_length;start=[0.0,0.0])
	n=length(peptide)
	structure=[AA_pos(peptide[1],start)]
	for i in 2:n
		next=AA_pos(peptide[i],structure[i-1].pos.+[bond_length*cos(θ[i-1]), bond_length*sin(θ[i-1])])
		push!(structure,next)
	end
	return structure::Vector{AA_pos}
end

# ╔═╡ 312b7343-318f-4d63-b056-82ce41419299
structure=generate_structure(p,θ_test,3)

# ╔═╡ 5949bb24-b377-43dd-9e8e-60141b701051
function initial_θ(n,m)
	θs=[]
	for i in 1:m
		push!(θs,θ_generator(n))
	end
	return θs
end

# ╔═╡ 3e3ca602-b701-4e3c-8200-25f1cbe0b2e2
function initial_structure(peptide,m,bond_length)
	p=create_peptide(peptide)
	n=length(p)
	θs=initial_θ(n,m)
	str_list=[]
	for i in 1:length(θs)
		push!(str_list,generate_structure(p,θs[i],bond_length))
	end
	return str_list
end

# ╔═╡ 65c64a31-3f0c-4318-b681-8f42c16443eb
set=initial_structure(peptide,12,3)

# ╔═╡ 6fe059df-de43-46ce-bfc7-ec55d1401802
function pot_coulomb(a::AA_pos, b::AA_pos) 
	coulomb_cst=8.9e9
 	#return coulomb_cst*a.AA.charge*b.AA.charge/(sqrt(sum(abs2.(a.pos .- b.pos))))
	return coulomb_cst*a.charge*b.charge/(sqrt(sum(abs2.(a.pos .- b.pos))))
end

# ╔═╡ 20e35579-1886-4d76-84ba-f89607dd7e4a
function pot_coulomb(structure::Vector{AA_pos})
	pot = 0
  	for i in 1:length(structure)
    	for j in i+1:length(structure)
      			pot = pot+pot_coulomb(structure[i],structure[j])
    	end
	end
	return pot
end

# ╔═╡ c0151f15-9d00-4f8a-b5c0-a1e1665bdfb4
function opt_structure(loss,structure,t,n)
	str_opt=deepcopy(structure)
	str_final=[]
	obj_opt=loss(str_opt)
	for i in 1:n
		grad=Zygote.gradient(loss,str_opt)
		pos_diff=[grad[1][i].pos for i in 1:length(grad[1])]
		for i in 1:length(pos_diff)
			str_opt[i].pos.-=t.*pos_diff[i]
		end
		obj=loss(str_opt)
		if obj<obj_opt #or relaxation?
			obj_opt=obj
			str_final=deepcopy(str_opt)
		end
	end
	return str_final
end


# ╔═╡ da9e52fc-539a-409b-af7a-f4d1e822ffe1
function opt_structures(loss,structure_set,t,n)
	opt_set=[]
	for i in 1:length(structure_set)
		push!(opt_set,opt_structure(loss,structure_set[i],t,n))
	end
	return opt_set
end

# ╔═╡ fed977b5-44ad-47ac-ae3a-fabbc2151699
function get_AA_hydrophobicity(AA)
	#hydrophobic=1, others=-1
	AA_hydrophobicity=Dict{String,Int64}("G"=>1,"A"=>1,"L"=>1,"M"=>1,"F"=>0.5,"W"=>0.5,"K"=>0.5,"Q"=>0.5,"E"=>0.5,"S"=>0.5,"P"=>1,"V"=>1,"I"=>1,"C"=>1,"Y"=>0.5,"H"=>0.5,"R"=>-1,"N"=>0.5,"D"=>0.5,"T"=>0.5)
	return AA_hydrophobicity[AA]
end

# ╔═╡ 995d343e-840e-4f15-a985-33dc20307a2b
function pot_nonbonded(a::AA_pos, AA_a::String, b::AA_pos, AA_b::String) 
	#include Lennard-Jones potential term 	
	coulomb_cst=8.9e9
	r=sqrt(sum(abs2.(a.pos .- b.pos)))
	U_coulomb=coulomb_cst*a.charge*b.charge/r
	ϵ=get_AA_hydrophobicity(AA_a)*get_AA_hydrophobicity(AA_b) 
	U_LJ=4*ϵ*((1/r)^12-(1/r)^6)
	return U_coulomb+U_LJ
end

# ╔═╡ 1f10e2fe-316d-48b2-98ad-04706481773e
function pot_nonbonded(structure::Vector{AA_pos})
	pot = 0
  	for i in 1:length(structure)
    	for j in i+1:length(structure)
      			pot = pot+pot_nonbonded(structure[i],structure[j])
    	end
	end
	return pot
end

# ╔═╡ fce8cb8e-c22a-4ddf-971b-9bbbc305be5a
function opt_structure_nonbonded(loss,structure,t,n)
	str_opt=deepcopy(structure)
	str_final=[]
	obj_opt=pot_nonbonded(str_opt)
	for i in 1:n
		grad=Zygote.gradient(loss,str_opt)
		pos_diff=[grad[1][i].pos for i in 1:length(grad[1])]
		for i in 1:length(pos_diff)
			str_opt[i].pos.-=t.*pos_diff[i]
		end
		obj=pot_nonbonded(str_opt)
		if obj<obj_opt
			obj_opt=obj
			str_final=deepcopy(str_opt)
		end
	end
	return str_final
end

# ╔═╡ ae2fc352-64e0-4dd5-9325-9e5ab4651bc0
function distance(x,y)
	dist=sqrt(sum(abs2.(x .- y)))
	return dist
end

# ╔═╡ 144cc0ef-03a2-46d7-80f5-140520d3134b
function loss(structure)
  s = 0
  for i in 1: length(structure)
	if distance(structure[i].pos,[0.0,0.0])-10>0          
	  s = s+100*(distance(structure[i].pos,[0.0,0.0])-10)        
	end
  end
  l =  s + 1.0e-9*pot_coulomb(structure)                      
  return l
end

# ╔═╡ c4da2c0f-4005-4bc0-bbd5-eef7feb4606d
function loss_nonbonded(structure)
  s = 0
  for i in 1: length(structure)
	if distance(structure[i].pos,[0.0,0.0])-10>0          
	  s = s+100*(distance(structure[i].pos,[0.0,0.0])-10)        
	end
	for j in i+1:length(structure)
		if abs(j-i)!=1 && distance(structure[i].pos,structure[j].pos)<1.5
			s = s+20*(1/distance(structure[i].pos,structure[j].pos))     
		end
	end
  end
  l =  s + 1.0e-9*pot_coulomb(structure)                      
  return l
end

# ╔═╡ 6b585213-d808-4fe6-b8f8-4f5a6ef33254
function loss_bonded(structure)
  s = 0
  for i in 1: length(structure)
	if distance(structure[i].pos,[0.0,0.0])-10>0          
	  s = s+100*(distance(structure[i].pos,[0.0,0.0])-10)        
	end
	for j in i+1:length(structure)
		if abs(j-i)!=1 && distance(structure[i].pos,structure[j].pos)<1.5
			s = s+20*(1/distance(structure[i].pos,structure[j].pos))     
		end
		if abs(j-i)==1 && abs(distance(structure[i].pos,structure[j].pos)-3)>0.3
			s = s+5*(abs((distance(structure[i].pos,structure[j].pos))-3))    
		end
	end	
	end
  l =  s + 1.0e-9*pot_coulomb(structure)                      
  return l
end

# ╔═╡ f61bd33f-a9dc-4c01-8040-8e22d7dbff1f
set_opt=opt_structures(loss_bonded,set,0.01,1000)

# ╔═╡ ffca3487-de78-420a-b9e7-7e204ca9e0ff
function loss_overlap(structure)
  s = 0
  count=0
  for i in 1: length(structure)
	if distance(structure[i].pos,[0.0,0.0])-10>0          
	  s = s+100*(distance(structure[i].pos,[0.0,0.0])-10)        
	end
	for j in i+1:length(structure)
		if abs(j-i)!=1 && distance(structure[i].pos,structure[j].pos)<1.5
			s = s+20*(1/distance(structure[i].pos,structure[j].pos))     
		end
		if abs(j-i)==1 && abs(distance(structure[i].pos,structure[j].pos)-3)>0.3
			s = s+5*(abs((distance(structure[i].pos,structure[j].pos))-3))    
		end
		for k in 1:length(structure)
			for l in k+1:length(structure)
				if ((i!=k && j!=l) && (i!=l && j!=k))
					line1=LineSegment(Point2f0(structure[i].pos),Point2f0(structure[j].pos))	
line2=LineSegment(Point2f0(structure[k].pos),Point2f0(structure[l].pos))
					if intersects(line1,line2)[1]==true
						count+=1
					end
				end
			end
		end
	end
end
	s=s+count*3
  l =  s + 1.0e-9*pot_coulomb(structure)                      
  return l
end

# ╔═╡ 7dfd0296-2586-43ab-b0f2-dd83031e3792
function loss_x(structure;x::Int64=0,bond_length::Int64=3,pen1::Int64=100,pen2::Int64=20,pen3::Int64=5,pen4::Int64=3,box_size::Int64=10,vdw_cutoff::Float64=1.5,bl_cutoff::Float64=0.3)
	s = 0
	count=0
	for i in 1: length(structure)
		if distance(structure[i].pos,[0.0,0.0])-box_size>0          
		  s = s+pen1*(distance(structure[i].pos,[0.0,0.0])-box_size)        
		end
		if x>0
			for j in i+1:length(structure)
				if abs(j-i)!=1 && distance(structure[i].pos,structure[j].pos)<vdw_cutoff
					s = s+pen2*(1/distance(structure[i].pos,structure[j].pos))     
				end
				if x>1 && abs(j-i)==1 && abs(distance(structure[i].pos,structure[j].pos)-bond-length)>bl_cutoff
					s = s+pen3*(abs((distance(structure[i].pos,structure[j].pos))-bond_length))   
				end 
				if x>2
					for k in 1:length(structure)
						for l in k+1:length(structure)
							if ((i!=k && j!=l) && (i!=l && j!=k))
								line1=LineSegment(Point2f0(structure[i].pos),Point2f0(structure[j].pos))
								line2=LineSegment(Point2f0(structure[k].pos),Point2f0(structure[l].pos))
								if intersects(line1,line2)[1]==true
									count+=1
								end
							end
						end
					end
				end
			end
		end	
	end
	s=s+count*pen4
	l =  s + 1.0e-9*pot_coulomb(structure)                      
	return l
end

# ╔═╡ 4f0ee2a5-f969-4f0d-84b7-6c5218cc57e5
function dist_to_line(AA1,AA2,AA3)
	return abs((AA2[1]-AA1[1])*(AA1[2]-AA3[2])-(AA1[1]-AA3[1])*(AA2[2]-AA3[2]))/sqrt((AA2[1]-AA1[1])^2+(AA2[2]-AA1[2])^2)
end

# ╔═╡ eb85c176-0ef3-4e49-9f1f-c0324daf50dc
md"### Tracker (under construction)"

# ╔═╡ d101b040-a730-4dc7-842f-1f0328be39e9
abstract type Tracker end

# ╔═╡ 3c54fcf5-9dd4-4b57-9230-0cf480054f07
struct NoTracking <: Tracker end

# ╔═╡ a3f1f006-54f7-485f-8c30-0cc212fbd4f9
notrack = NoTracking()

# ╔═╡ 72774fc3-cee4-4dac-a43e-07f9ad0519ed
struct TrackSolutions{T} <: Tracker
		solutions::Vector{T}
		TrackSolutions(s) = new{typeof(s)}([])
	end

# ╔═╡ e6f77a64-04b3-45d8-9371-b119c36ab1fd
struct TrackObj{T} <: Tracker
		objectives::Vector{T}
		TrackObj(T::Type=Float64) = new{T}([])
	end

# ╔═╡ ba821829-5f2c-45fc-91f2-eb1293c3d87c
track!(::NoTracking, f, edges, s, t) = nothing

# ╔═╡ 82b735cd-293e-4d3c-9833-23dd0b26049d
track!(tracker::TrackObj, f, edges, s, t) = push!(tracker.objectives, f(edges, s, t))

# ╔═╡ f39a7e42-5b0c-4e24-b4c7-747bd07a7356
Plots.plot(tracker::TrackObj; kwargs...) = plot(tracker.objectives, xlabel="iteration", label="objective", lw=2, color=myred, legend=:bottomright; kwargs...)

# ╔═╡ 17200be7-05f2-4d8c-9815-e25dd7a54fa1
plot(f,1,10, title="Electrostatic coulomb potential U in function of r",xlabel="r",ylabel="U",label="U(r)")

# ╔═╡ 9c63a380-b865-4043-9bd1-3db051ef088a
plot(g,1,10, title="Lennard-Jones potential U in function of r",xlabel="r",ylabel="U_LJ",label="U(r)")

# ╔═╡ 2889fc02-c872-4ded-b13c-4f3c4cc57719
function plot_structure(structure,peptide)
	plot([structure[i].pos[1] for i in 1:length(structure)],[structure[i].pos[2] for i 	in 1:length(structure)],seriestype = :path,series_annotations =[string(i) for i in 	peptide],legend=false,title=peptide,seriescolor="black")
	
	plot!([structure[i].pos[1] for i in 1:length(structure)],[structure[i].pos[2] for 	i in 1:length(structure)],seriestype =:scatter,series_annotations =[string(i) for i in peptide],markersize=15*abs.([structure[i].charge for i in 1:length(structure)]),markercolor=[structure[i].charge>0 ? 1 : 0 for i in 1:length(structure)],markeralpha=0.65)

hline!([-10,10],color="red")
vline!([-10,10],color="red")
end

# ╔═╡ d3cef59f-09e8-4527-b37d-ea500a53dfde
plot_structure(structure,peptide)

# ╔═╡ a28be567-e447-43cd-aa07-282d745f3339
begin 
	θ_attract=[0.5,-1.5,1.2]
	peptide_attract="DGK"
	p_attract=create_peptide(peptide_attract)
	structure_attract=generate_structure(p_attract,θ_attract,5)
	plot_structure(structure_attract,peptide_attract)
end

# ╔═╡ 3ada512a-7442-40e6-aa95-875b1b10d1ff
begin 
	opt_str_attract=opt_structure(loss,structure_attract,0.1,100)
	plot_structure(opt_str_attract,peptide_attract)
end

# ╔═╡ 1e91d0d2-effa-43c2-a163-1491cbd75e01
begin
	θ_repulse=[1.5,-1.5,1.2]
	peptide_repulse="DGD"
	p_repulse=create_peptide(peptide_repulse)
	structure_repulse=generate_structure(p_repulse,θ_repulse,5)
	plot_structure(structure_repulse,peptide_repulse)
end

# ╔═╡ 5cbe055f-75ce-45cb-961e-10b50668524c
begin
	opt_str_repulse=opt_structure(loss,structure_repulse,0.1,100)
	plot_structure(opt_str_repulse,peptide_repulse)
end

# ╔═╡ 3d8026f7-4872-4d02-b542-6a707da7178a
begin
	θ_nb=[1.5,-1.5,1.5,-1.5,1.5,-1.5,1.5,-1.5,1.5,-1.5,1.5,-1.5]
	peptide_nb="DDDDGGGGKKKK"
	p_nb=create_peptide(peptide_nb)
	structure_nb=generate_structure(p_nb,θ_nb,5)
	plot_structure(structure_nb,peptide_nb)
end

# ╔═╡ 7a1f8bc3-ea8e-45e5-9b30-5d9161beecdf
begin
	opt_str=opt_structure(loss,structure_nb,0.01,100)
	plot_structure(opt_str,peptide_nb)
end

# ╔═╡ 33ccee08-bf5c-405f-ab76-0230ac0d5faa
begin
	opt_str_nb=opt_structure(loss_nonbonded,structure_nb,0.001,1000)
	plot_structure(opt_str_nb,peptide_nb)
end

# ╔═╡ 162dc653-603a-4f72-bcf6-903d97c2610a
average_bondvar_nb=mean([abs(distance(opt_str_nb[i].pos,opt_str_nb[j].pos)-3) for i in 1:length(opt_str_nb) for j in i+1:length(opt_str_nb) if abs(j-i)==1])

# ╔═╡ 409a45f9-0b64-4e8b-bba6-e5942487212f
histogram([abs(distance(opt_str_nb[i].pos,opt_str_nb[j].pos)-3) for i in 1:length(opt_str_nb) for j in i+1:length(opt_str_nb) if abs(j-i)==1],title="Variation of bond length without constraint",xlabel="Bond length",legend=false)

# ╔═╡ 63f67577-97cd-4999-b3ce-9de20cc99ca1
begin
	opt_str_b=opt_structure(loss_bonded,structure_nb,0.0001,10000)
	plot_structure(opt_str_b,peptide_nb)
end

# ╔═╡ 44db4525-1fab-49a5-89fc-414848a425b1
average_bondvar_b=mean([abs(distance(opt_str_b[i].pos,opt_str_b[j].pos)-3) for i in 1:length(opt_str_b) for j in i+1:length(opt_str_b) if abs(j-i)==1])

# ╔═╡ b2a09a6f-81c7-45da-b312-ef8f0a719fbd
histogram([abs(distance(opt_str_b[i].pos,opt_str_b[j].pos)-3) for i in 1:length(opt_str_b) for j in i+1:length(opt_str_b) if abs(j-i)==1],title="Variation of bond length with bond length constraint",xlabel="Bond length",legend=false)

# ╔═╡ d3b30a0a-2c97-41c4-8df7-73f694701d04
begin
	line3=LineSegment(Point2f0(opt_str_b[4].pos),Point2f0(opt_str_b[5].pos))
	line4=LineSegment(Point2f0(opt_str_b[6].pos),Point2f0(opt_str_b[7].pos))
	truth2=intersects(line3,line4)
end

# ╔═╡ 4c30886e-298b-45af-afc1-83e14bd12e63
begin
	opt_str_overlap=opt_structure(loss_overlap,structure_nb,0.1,10)
	plot_structure(opt_str_overlap,peptide_nb)
end

# ╔═╡ 8baa50d4-2f1f-45fa-8526-3b68bb2bc47b
function plot_structures(structure_set,peptide)
	n=length(structure_set)
	plot([[structure_set[i][j].pos[1] for j in 1:length(structure_set[i])] for i in 1:length(structure_set)],[[structure_set[i][j].pos[2] for j in 1:length(structure_set[i])] for i in 1:length(structure_set)],seriestype = :path,series_annotations =[string(i) for i in 	peptide],legend=false,seriescolor="black",layout=n)#,xlim=[-10,10],ylim=[-10,10])
		
		plot!([[structure_set[i][j].pos[1] for j in 1:length(structure_set[i])] for i in 1:length(structure_set)],[[structure_set[i][j].pos[2] for j in 1:length(structure_set[i])] for i in 1:length(structure_set)],seriestype =:scatter,markeralpha=0.65,layout=n,markercolor=[set[1][j].charge>0 ? 1 : 0 for j in 1:length(set[1])],markersize=10*[abs(structure_set[1][j].charge) for j in 1:length(structure_set[1])])
end

# ╔═╡ bd6c6ced-cc39-4a53-888a-d0a2fca9107c
plot_structures(set,peptide)

# ╔═╡ a8617ff6-dcf3-4d56-9b84-3ff77b9fcc95
plot_structures(set_opt,peptide)

# ╔═╡ 038dfcd4-df22-4b45-bcec-1ea0825de0ab
begin
x=[0.0,0.0]
y=[5.0,5.0]
d=[3.0,2.5]
e=[2.0,4.0]
h(z)=x[2]+(y[2]-x[2])/(y[1]-x[1])*(z-x[1])
i(z)=d[2]+(e[2]-d[2])/(e[1]-d[1])*(z-d[1])
plot([x[1],y[1],d[1],e[1]],[x[2],y[2],d[2],e[2]],seriestype =:scatter,markersize=5)
plot!(h,0,5)
plot!(i,0,5)
line1=LineSegment(Point2f0(0.0,0.0),Point2f0(5.0,5.0))
line2=LineSegment(Point2f0(3.0,2.5),Point2f0(2.0,4.0))
truth=intersects(line1,line2)
end

# ╔═╡ c5426123-0945-4536-bc56-53799c18a7e6
md"### Optional: Testing BioSequence.jl as alternative"

# ╔═╡ d2c77fcb-f624-4e51-9c67-e0686600c5aa
struct AA_bj          # create an amino acid data type
  	aminoacid::BioSymbols.AminoAcid
	charge::Int64
end

# ╔═╡ ebe41353-4975-4337-8073-128d27b4aac0
alphabet(AminoAcid)

# ╔═╡ 2f987e8e-d5b4-4778-aa5b-b10bbb235934
peptide_bj=LongSequence{AminoAcidAlphabet}("RTYQLILD")

# ╔═╡ adf44663-ed9f-416f-b6d3-0d3b1a4c99fa
peptide_bj[1]

# ╔═╡ d892d423-a957-43cf-8dd5-79394d0639d2
a=AA_bj(peptide_bj[1],2)

# ╔═╡ 1d21b8e0-5794-4531-9bdb-42db21a7c7db
a.aminoacid

# ╔═╡ aceff59b-ea6f-4c7a-9945-400498e8b316
#Bio3Dview package for visualization?

# ╔═╡ 4ecdf4b1-73ba-4563-8528-e7450559035a
md"# References"

# ╔═╡ aba0fe28-58fb-4000-8d73-71fbab48bfe0
#todo

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BioSequences = "7e6ae17a-c86d-528c-b3b9-7f778a29fe59"
BioSymbols = "3c28c6f8-a34d-59c4-9654-267d177fcfa9"
Distances = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
Flux = "587475ba-b771-5e3f-ad9e-33799f191a9c"
GeometryTypes = "4d00f742-c7ba-57c2-abde-4428a4b178cb"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
BioSequences = "~2.0.5"
BioSymbols = "~4.0.4"
Distances = "~0.10.7"
Flux = "~0.12.8"
GeometryTypes = "~0.8.5"
Plots = "~1.0.14"
PlutoUI = "~0.7.1"
Zygote = "~0.6.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "265b06e2b1f6a216e0e8f183d28e4d354eab3220"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.2.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BioGenerics]]
deps = ["TranscodingStreams"]
git-tree-sha1 = "6d3f3b474b3df2e83dc67ad12ec63aee4eb5241b"
uuid = "47718e42-2ac5-11e9-14af-e5595289c2ea"
version = "0.1.1"

[[BioSequences]]
deps = ["BioGenerics", "BioSymbols", "Combinatorics", "IndexableBitVectors", "Printf", "Random", "StableRNGs", "Twiddle"]
git-tree-sha1 = "093ccb9211bdc71924abf8e74a0790af11da35a7"
uuid = "7e6ae17a-c86d-528c-b3b9-7f778a29fe59"
version = "2.0.5"

[[BioSymbols]]
deps = ["Automa"]
git-tree-sha1 = "ec77888ac3e78f9d372c2b533bdb52668f9e2b09"
uuid = "3c28c6f8-a34d-59c4-9654-267d177fcfa9"
version = "4.0.4"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "2c8329f16addffd09e6ca84c556e2185a4933c64"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.5.0"

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
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

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

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

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

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "c82bef6fc01e30d500f588cd01d29bdd44f1924e"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.3.0"

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

[[Flux]]
deps = ["AbstractTrees", "Adapt", "ArrayInterface", "CUDA", "CodecZlib", "Colors", "DelimitedFiles", "Functors", "Juno", "LinearAlgebra", "MacroTools", "NNlib", "NNlibCUDA", "Pkg", "Printf", "Random", "Reexport", "SHA", "SparseArrays", "Statistics", "StatsBase", "Test", "ZipFile", "Zygote"]
git-tree-sha1 = "e8b37bb43c01eed0418821d1f9d20eca5ba6ab21"
uuid = "587475ba-b771-5e3f-ad9e-33799f191a9c"
version = "0.12.8"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

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

[[Functors]]
git-tree-sha1 = "e4768c3b7f597d5a352afa09874d16e3c3f6ead2"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.2.7"

[[GPUArrays]]
deps = ["Adapt", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "7772508f17f1d482fe0df72cabc5b55bec06bbe0"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.1.2"

[[GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "2cac236070c2c4b36de54ae9146b55ee2c34ac7a"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.13.10"

[[GR]]
deps = ["Base64", "DelimitedFiles", "LinearAlgebra", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "7ea6f715b7caa10d7ee16f1cfcd12f3ccc74116a"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.48.0"

[[GeometryTypes]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "d796f7be0383b5416cd403420ce0af083b0f9b28"
uuid = "4d00f742-c7ba-57c2-abde-4428a4b178cb"
version = "0.8.5"

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

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "006127162a51f0effbdfaab5ac0c83f8eb7ea8f3"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.4"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[IndexableBitVectors]]
deps = ["Random", "Test"]
git-tree-sha1 = "b7f5e42dc867b8a8654a5f899064632dac05bc82"
uuid = "1cb3b9ac-1ffd-5777-9e6b-a3d42300664d"
version = "1.0.0"

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

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "7cc22e69995e2329cc047a879395b2b74647ab5f"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.7.0"

[[LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c5fc4bef251ecd37685bea1c4068a9cfa41e8b9a"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.13+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NNlib]]
deps = ["Adapt", "ChainRulesCore", "Compat", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "2eb305b13eaed91d7da14269bf17ce6664bfee3d"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.7.31"

[[NNlibCUDA]]
deps = ["CUDA", "LinearAlgebra", "NNlib", "Random", "Statistics"]
git-tree-sha1 = "a2dc748c9f6615197b6b97c10bcce829830574c9"
uuid = "a00861dc-f156-4864-bf3c-e6376f28a68d"
version = "0.1.11"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

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
git-tree-sha1 = "87a4ea7f8c350d87d3a8ca9052663b633c0b2722"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "1.0.3"

[[PlotUtils]]
deps = ["Colors", "Dates", "Printf", "Random", "Reexport"]
git-tree-sha1 = "51e742162c97d35f714f9611619db6975e19384b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "0.6.5"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryTypes", "JSON", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "484ade6d734feb43c06721c689155eb4aa3259f5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.0.14"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "Logging", "Markdown", "Random", "Suppressor"]
git-tree-sha1 = "45ce174d36d3931cd4e37a47f93e07d1455f038d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Random123]]
deps = ["Libdl", "Random", "RandomNumbers"]
git-tree-sha1 = "0e8b146557ad1c6deb1367655e052276690e71a3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.4.2"

[[RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

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
git-tree-sha1 = "4a325c9bcc2d8e62a8f975b9666d0251d53b63b9"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.1.13"

[[Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SIMD]]
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "ee010d8f103468309b8afac4abb9be2e18ff1182"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "0.3.2"

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
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "b57c4216b6c163a3a9d674f6b9f7b99cdccdb959"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "0.1.2"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "7f5a513baec6f122401abfc8e9c074fdac54f6c1"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[Twiddle]]
git-tree-sha1 = "29509c4862bfb5da9e76eb6937125ab93986270a"
uuid = "7200193e-83a8-5a55-b20d-5d36d44a0795"
version = "1.1.2"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "IRTools", "InteractiveUtils", "LinearAlgebra", "MacroTools", "NaNMath", "Random", "Requires", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "76475a5aa0be302c689fd319cd257cd1a512fb3c"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.32"

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
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

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
"""

# ╔═╡ Cell order:
# ╟─aed97b7d-4d3f-4eb7-a021-8f0f752cc814
# ╟─4acfed7b-1e4f-4c20-978b-683330dbc2bb
# ╟─3a994310-7ff4-470e-a758-c67576a9f9ee
# ╟─17bf1795-1b1f-4d68-aa57-a9d337dae674
# ╟─35a3679d-aa85-4091-91f3-e515582a2ffc
# ╠═a21a26a1-fb95-4968-91e9-983f9096d224
# ╠═cf812b21-aa42-49e6-92aa-3d7a95bd182a
# ╠═45e4cccd-5bfd-45dd-90dd-4046caef3db5
# ╠═312b7343-318f-4d63-b056-82ce41419299
# ╟─d3cef59f-09e8-4527-b37d-ea500a53dfde
# ╟─99972864-da75-4dac-bc42-4ecab2555919
# ╟─65de4d00-763e-403a-b254-ebcc8d1a2d3d
# ╟─5fefff00-4f1a-4f6a-bdba-a5670d8e6fb8
# ╟─0317f477-f61d-4ee3-8147-cf0a3002b39e
# ╟─4e9c4e8e-d52a-4448-8767-39412e280ca2
# ╠═20924ef5-1bc0-46b3-b4df-a3270118eacc
# ╠═894f52ca-eb4f-4c1d-967e-fa026260e7f8
# ╠═024fc0e2-f9de-4325-9d11-ec4cb2f3d489
# ╟─17200be7-05f2-4d8c-9815-e25dd7a54fa1
# ╟─42b3333a-a813-4294-b378-169216305c1c
# ╟─ede1390f-69f0-43cc-8d4a-9a79e81d7f38
# ╟─8442367a-dce0-42a5-990a-0b68019cc356
# ╟─a28be567-e447-43cd-aa07-282d745f3339
# ╟─dffb1062-ca90-4c0c-86ec-38e791aa41de
# ╟─3ada512a-7442-40e6-aa95-875b1b10d1ff
# ╟─0d04ca74-43ce-4e5f-9578-853b09e19f06
# ╟─e9298923-d2cf-4622-9224-96fbf3b3cf04
# ╟─1e91d0d2-effa-43c2-a163-1491cbd75e01
# ╟─8d2f05d8-995b-4ae1-acf9-ec6108e42e6b
# ╟─5cbe055f-75ce-45cb-961e-10b50668524c
# ╟─d55596d8-8d60-4cf5-bd5d-dbd9fc4c9f93
# ╟─5f9cc38d-3159-42f7-ba85-b6a9e913f411
# ╟─6a17eea2-3df5-486c-a4c2-4adf9aa93c34
# ╠═c832e1a3-d1db-40b5-ae02-d45ddfe7b580
# ╠═367fb191-4870-4239-920e-61d3fbda704a
# ╠═284fdece-8ef3-4353-979e-5f1e6aa3b333
# ╟─9c63a380-b865-4043-9bd1-3db051ef088a
# ╟─d445a56a-636e-463b-ae03-69bfa71562dd
# ╟─3d8026f7-4872-4d02-b542-6a707da7178a
# ╟─7b68ef54-3b10-4a31-872b-5368c2c9381e
# ╟─7a1f8bc3-ea8e-45e5-9b30-5d9161beecdf
# ╟─95a92d37-cc60-42b1-bf9c-4f7941ff8f86
# ╟─33ccee08-bf5c-405f-ab76-0230ac0d5faa
# ╟─b3e11412-9cc7-4c81-beb2-9c2408a0e464
# ╟─6fc4f763-21ad-4342-b530-9f52fbae81f9
# ╟─d88890d1-83b8-4c2d-bf5d-5c0c328a1213
# ╟─63f67577-97cd-4999-b3ce-9de20cc99ca1
# ╟─756b0681-557b-48d1-8b7e-44df44cc46e1
# ╟─162dc653-603a-4f72-bcf6-903d97c2610a
# ╟─409a45f9-0b64-4e8b-bba6-e5942487212f
# ╟─44db4525-1fab-49a5-89fc-414848a425b1
# ╟─b2a09a6f-81c7-45da-b312-ef8f0a719fbd
# ╟─16e75a37-680f-4d8b-a319-a04bdfb34ea1
# ╟─4c30886e-298b-45af-afc1-83e14bd12e63
# ╟─336c8967-d5ce-4bd6-bda6-4149b448bc20
# ╟─98a9ca21-d4b9-4917-baf0-a730f80c06b7
# ╟─bbe087b6-f9b9-4b8f-a955-638457da5ae7
# ╟─e6e2db90-9628-4ec4-985f-29c78b345c27
# ╠═65c64a31-3f0c-4318-b681-8f42c16443eb
# ╟─bd6c6ced-cc39-4a53-888a-d0a2fca9107c
# ╠═f61bd33f-a9dc-4c01-8040-8e22d7dbff1f
# ╟─a8617ff6-dcf3-4d56-9b84-3ff77b9fcc95
# ╟─9a6b2eb1-0879-4337-98fd-7c1f2552cc22
# ╟─da193625-7ad1-4364-99ab-2628a88710a9
# ╟─373316d9-48af-4f9a-9650-e7c6414e9aad
# ╟─5206ac46-b21c-4cce-b984-2a0010c00edc
# ╠═748f83d0-61da-11ec-3b32-cd7947823794
# ╠═13c02ad5-6f42-4ad4-a115-fc985e186c42
# ╠═7e13789d-e8cb-430a-a11d-acf28a6f9ba1
# ╠═8aca45e0-41cd-480d-bf9b-91a4d80a6ec9
# ╠═ad2bd196-894d-4c7a-a860-8999aabb73b6
# ╠═6dab2e8b-7426-4c26-b743-a2000eef02b8
# ╠═5949bb24-b377-43dd-9e8e-60141b701051
# ╠═3e3ca602-b701-4e3c-8200-25f1cbe0b2e2
# ╠═6fe059df-de43-46ce-bfc7-ec55d1401802
# ╠═20e35579-1886-4d76-84ba-f89607dd7e4a
# ╠═144cc0ef-03a2-46d7-80f5-140520d3134b
# ╠═c4da2c0f-4005-4bc0-bbd5-eef7feb4606d
# ╠═6b585213-d808-4fe6-b8f8-4f5a6ef33254
# ╠═ffca3487-de78-420a-b9e7-7e204ca9e0ff
# ╠═7dfd0296-2586-43ab-b0f2-dd83031e3792
# ╠═c0151f15-9d00-4f8a-b5c0-a1e1665bdfb4
# ╠═da9e52fc-539a-409b-af7a-f4d1e822ffe1
# ╠═2889fc02-c872-4ded-b13c-4f3c4cc57719
# ╠═8baa50d4-2f1f-45fa-8526-3b68bb2bc47b
# ╠═fed977b5-44ad-47ac-ae3a-fabbc2151699
# ╠═995d343e-840e-4f15-a985-33dc20307a2b
# ╠═1f10e2fe-316d-48b2-98ad-04706481773e
# ╠═fce8cb8e-c22a-4ddf-971b-9bbbc305be5a
# ╠═ae2fc352-64e0-4dd5-9325-9e5ab4651bc0
# ╠═4f0ee2a5-f969-4f0d-84b7-6c5218cc57e5
# ╠═038dfcd4-df22-4b45-bcec-1ea0825de0ab
# ╠═d3b30a0a-2c97-41c4-8df7-73f694701d04
# ╟─eb85c176-0ef3-4e49-9f1f-c0324daf50dc
# ╠═d101b040-a730-4dc7-842f-1f0328be39e9
# ╠═3c54fcf5-9dd4-4b57-9230-0cf480054f07
# ╠═a3f1f006-54f7-485f-8c30-0cc212fbd4f9
# ╠═72774fc3-cee4-4dac-a43e-07f9ad0519ed
# ╠═e6f77a64-04b3-45d8-9371-b119c36ab1fd
# ╠═ba821829-5f2c-45fc-91f2-eb1293c3d87c
# ╠═82b735cd-293e-4d3c-9833-23dd0b26049d
# ╠═f39a7e42-5b0c-4e24-b4c7-747bd07a7356
# ╠═c5426123-0945-4536-bc56-53799c18a7e6
# ╠═d2c77fcb-f624-4e51-9c67-e0686600c5aa
# ╠═ebe41353-4975-4337-8073-128d27b4aac0
# ╠═2f987e8e-d5b4-4778-aa5b-b10bbb235934
# ╠═adf44663-ed9f-416f-b6d3-0d3b1a4c99fa
# ╠═d892d423-a957-43cf-8dd5-79394d0639d2
# ╠═1d21b8e0-5794-4531-9bdb-42db21a7c7db
# ╠═aceff59b-ea6f-4c7a-9945-400498e8b316
# ╟─4ecdf4b1-73ba-4563-8528-e7450559035a
# ╠═aba0fe28-58fb-4000-8d73-71fbab48bfe0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
