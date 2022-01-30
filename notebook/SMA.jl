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

# ╔═╡ 0efef0ae-1de8-40e0-b689-e473ef9183e8
using Random, Distributions, PlutoUI, StatsBase, Plots, StatsPlots

# ╔═╡ 40272dcb-7ff1-4a5d-b201-9dc548d81d8c
md"""
# Slime Mould Algorithm
**Natan Tourne**\
**STMO 2021-2022**\
**Final Project**

**Note: This notebook takes a few minutes to fully initialize. Some cells have been disabled by default and some values have been lowered to ease this process.**

## The Slime Mold
### Background
Slime Molds are a group of **Amoebozoa** (protists) classified under the infraphylum **Mycetozoa**, although the term has been used less strictly in the past. Within this group, there are three classes: **Myxogastria, Dictyosteliida, and Protosteloids**. (This classification is still disputed and likely to change.)

Slime molds are noted because of their special characteristics. Slime molds from the Protosteloids group are amoebae capable of making fruiting bodies and spores. Species from the group Dicotyosteliida are referred to as **cellular** slime molds. When food is available they feed and divide as normal unicellular amoebae. However, when food becomes limited these individuals aggregate to form a **pseudoplasmodium** or **grex**. This multicellular complex can then move like a slug with a greatly increased capacity to migrate. When conditions are suitable this grex differentiates further into a **sorocarp** or fruiting body used to spread spores. This unique life cycle (shown in the figure) challenges the concepts of unicellularity, multicellularity, and what makes up an individual.


![Dictyostelium Life Cycle](https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Dicty_Life_Cycle_H01.svg/1024px-Dicty_Life_Cycle_H01.svg.png)


Lastly, the species in the group of Myxogastria are known as **acellular** slime molds. They can have multiple different morphological phases like microscopic individual cells, and fruiting bodies, but they are most recognized in their slimy amorphous form shown in the figure. Despite their ability to grow to a size of up to a meter and weigh multiple kg's, they are still made up of only a single cell. **Physarum polycephalum**, a species from this last group, will be the focus of this work.

![slime](https://upload.wikimedia.org/wikipedia/commons/6/6d/Physarum_polycephalum_plasmodium.jpg)

### Problem Solving
**Physarum polycephalum**  has complex behavior and seems to be able to solve complex problems despite being only a single cell and lacking any kind of neurons let alone a brain. This behavior has been studied thoroughly and has been used to solve multiple real-world problems. A well-known example is the use of P. polycephalum to plan an optimal rail network for Tokyo. 
![Tokyo1](https://i.natgeofe.com/n/2ae10c00-c10d-40d4-bfd9-57e1c5f2d12d/Slime_mould-Tokyo.jpg?w=795&h=602.5)
![Tokyo2](https://i.natgeofe.com/n/845a27dc-d800-4998-b0a5-4ff406a5611b/Mould_Tokyo.jpg?w=795&h=473.75)
(**Reference:** Tero et al. 2010. Rules for Biologically Inspired Adaptive Network Design. Science 10.1126/science.1177894)

This complex behavior seems to be mostly possible because of the oscillating behavior of the slime mold's plasma membrane. The organism has rhythmic contractions that are synchronized over the entire organism. This causes streaming of the protoplasm which seems to be the main form of signal transduction. Complex modifications to the oscillating pattern at the periphery when interacting with the environment (for instance food or a harmful chemical) seem to direct the behavior. This system is especially able to deal with multiple food sources and will allocate resources according to food quality. Furthermore, the organism has a form of memory and is able to learn and anticipate periodic events.

![slime2](https://biohaviour.com/wp-content/uploads/2020/11/SlimeMold.gif)

**Further reading and sources:** 

**-**Saigusa et al. 2008. **Amoebae Anticipate Periodic Events.** Phys. Rev. Lett.
10.1103/PhysRevLett.100.018101 

**-**Beekman et al. 2015. **Brainless but Multi-Headed: Decision Making by the Acellular Slime Mould Physarum polycephalum.** Journal of Molecular Biology. 10.1016/j.jmb.2015.07.007 

**-**Shirakawa et al. 2011. **An associative learning experiment using the plasmodium of Physarum polycephalum.** Nano Communication Networks. 10.1016/j.nancom.2011.05.002 

**-**Kobayashi et al. 2006. **Mathematical Model for Rhythmic Protoplasmic Movement in the True Slime Mold.** J. Math. Biol. 10.1007/s00285-006-0007-0 

**-**Tero et al. 2005. **A coupled-oscillator model with a conservation law for the rhythmic amoeboid movements of plasmodial slime molds.** Physica D: Nonlinear Phenomena. 10.1016/j.physd.2005.01.010 

**-**Takagi et al. 2008. **Emergence and transitions of dynamic patterns of thickness oscillation of the plasmodium of the true slime mold Physarum polycephalum.** Physica D: Nonlinear Phenomena. 10.1016/j.physd.2007.09.012 

"""

# ╔═╡ facf73a4-255a-4bf3-baa0-ef20f692e0bd
md"""
## Slime Mold Algorithm
In this notebook, we will explore the concept of a smile mold (or mould) algorithm (**SMA**). Using **Physarum polycephalum** itself to solve problems has already proven useful. The SMA attempts to incorporate some of the defining characteristics of P. polycephalum, in the hope of harnassing the organism's problem-solving prowess to solve a wider field of problems. 

### Algorithms Inspired By Biology
As discussed in the course material closed-form solutions, gradient descent algorithms, deterministic algorithms, etc are very useful and efficient in solving a certain set of problems. These are mostly linear problems with a known solution space. However, when confronted with complex non-linear real-world challenges where the solutions space and gradient information is unknown these algorithms can struggle. Finding a deterministic answer to these problems is often impossible or can take unrealistic amounts of computation. An example is the graph coloring problem from the course. The only way to truly verify which answer is the global optimum is by testing all possible combinations. This quickly becomes unmanageable for complex problems. Consequently, metaheuristic algorithms are often used instead. These algorithms can not guarantee that they find the global optimum, however, they are able to quickly find good solutions. These algorithms often have stochastic elements that provide randomness that can be used to escape local optima and increase the chance of finding the global optimum. Inspiration for such algorithms can often be found in nature. 

Organisms in nature have been finding solutions to complex problems for millions of years without the use of deterministic algorithms and complex mathematics. These solutions in nature can sometimes be used directly as is the case in biomimicry. Well-known examples include the shape of high-speed trains inspired by the king fishers' beak and velcro inspired by the seed dispersion mechanism of plants like Arctium lappa ("grote klis" a common plant in Belgium). 

Similarly, some algorithms are created by mimicking the behavior of natural species. Mostly swarm-based techniques are used where many individuals interact both with their environment and with the other individuals in the swarm. 
These techniques are often inspired by social insects. 
Some examples include:\
	-Particle Swarm Optimization\
	-Fruit Fly Optimization\
	-Ant Colony Optimization\
	-Artificial Bee Colony

SMA is such an algorithm. Uniquely, as described above, Physarum polycephalum is actually a single cell despite its sometimes impressive size. Despite this, a swarm-based technique is still used to mimic its behavior. This is actually pretty natural as the slime mold does not possess a central brain. Its intelligence arises in a similar way to the swarm intelligence of social insect species. The different "individuals" in the "population" can actually be understood as different parts of the same slime mold. 

(Finally, for completeness, the natural concept of evolution is also used as inspiration for genetic algorithms.)
"""

# ╔═╡ 55d82d37-b380-44a5-a234-504329b58e3f
md"""
### Mathematical Basis
**The algorithm discussed in this notebook was developed by Li et al in 2020. (Reference: Li et al. 2020. Slime mould algorithm: A new method for stochastic optimization. Future Generation Computer Systems. 10.1016/j.future.2020.03.055) This algorithm was implemented in Python by the original authors. However, because of the different design philosophies of Python (object-oriented) and Julia, the implementation is quite different.**


The main principles of the SMA are shown in the following figure (From the original paper):
![SMA](https://upload.wikimedia.org/wikipedia/commons/1/13/Slime_mould_algorithm_logic.png)

As can be seen, the model shows three different modes of behavior: Wrapping Food, Approaching Food, and Finding Food. The equations for these different behaviors are shown below.

**Finding Food:**

$\overrightarrow{X(t+1)} = rand(UB-LB) + LB$

Where *UB* and *LB* represent the upper and lower boundaries for the search parameters. When this mode is used the individual is placed at a random location in the solution space. This provides a random sampling of the design space. 

**Approaching Food:**

$\overrightarrow{X(t+1)} = \overrightarrow{X_b(t)} +\overrightarrow{vb}(W \times \overrightarrow{X_A(t)} -\overrightarrow{X_B(t)})$

Where $\overrightarrow{X_b}$ is the location of the individual with the best fitness score, $\overrightarrow{X_A}$ and $\overrightarrow{X_B}$ are random individuals from the population, W is the weight of the slime mold and $\overrightarrow{vb}$ is an occilating function (see further). W is calculated using the following equation:
```math
\overrightarrow{W}=
\begin{cases}
1 + r \times log\left(\dfrac{bF-S(i)}{bF-wF} +1\right) & \quad \text{Half of population with best Fitness}\\ 
1 - r \times log\left(\dfrac{bF-S(i)}{bF-wF} +1\right) & \quad \text{Other}
\end{cases}
```

With *bF* and *wF* the best and worst fitness of the current generation, *S(i)* the fitness of the current individual and *r* an oscillating function (see further).


**Wrapping Food:**

$\overrightarrow{X(t+1)} = \overrightarrow{vc} \times \overrightarrow{X(t)}$

Where $\overrightarrow{vc}$ is an oscillating function (see further).

Which of these modes of behavior is used depends on two stochastic decisions. First **$rand < z$**, where rand is a random value between [0,1] and z is a preset variable, is used to decide between the *Finding Food* mode and the other two modes. If this condition is not satisfied $r < p$ is used to decide between the *Approaching Food* and *Wrapping Food* modes. Here *r* is a value between [0,1] and *p* is calculated using the following formula:

$p = tanh|S(i) - DF|$

Where S(i) is the fitness of the individual and DF is the best fitness over all generations. The reasoning behind this decision boundary is illustrated in the figure below. 
"""

# ╔═╡ fb5e61c6-aae4-42c1-a088-ce87afe3ea01
begin
	# tanh()
	plot(
		-10:0.1:10, 
		[tanh(i) for i in -10:0.1:10], 
		lw = 2, 
		label = "tanh()"
	)

	# tanh(abs())
	plot!(
		-10:0.1:10, 
		[tanh(abs(i)) for i in -10:0.1:10], 
		lw = 2, 
		line=([:dot],5), 
		label = "tanh(abs())",
		xlabel = "x",
		ylabel = "y"
	)
end

# ╔═╡ f614543b-ccea-401e-a0ad-a74eb9076b40
md"""
When the fitness of the individual is far from DF (best fitness over all generations) the factor *p* will quickly approach 1. Consequently, the chance of satisfying $r < p$ becomes increasingly large and the position of $\overrightarrow{X(t)}$ will be updated according to the position of $\overrightarrow{X_b}$ (*Approaching Food* mode)(and an oscillating impact of $\overrightarrow{X_A}$ and $\overrightarrow{X_B}$) more often than according to its own position (*Wrapping Food* mode).

This is further illustrated by the interactive figure below. This figure shows the chance of a certain behavioral mode being chosen according to the fitness of the individual relative to best fitness over all generations.
"""

# ╔═╡ 664dd767-0469-4118-9a28-c5be0271c374
begin
	z_slider = @bind d_z Slider(1:100, default = 30)
	lb_slider = @bind d_lb Slider(-100:-1, default = -1, show_value=true)
	ub_slider = @bind d_ub Slider(1:100, default = 7, show_value=true)
	s_slider = @bind d_s Slider(-100:100, default = 2, show_value=true)
	
	md"""
	z: $(z_slider)\
	Lower Bound: $(lb_slider)\
	Upper Bound: $(ub_slider)\
	DF: $(s_slider)\
	"""	
end

# ╔═╡ 8b78148a-2dbb-49c1-830c-1d770514a10e
begin
	
	plot(d_lb:((d_ub-d_lb)/1000):d_ub, 
		[1 for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :green), 
		label = "Finding Food")
		
	plot!(d_lb:((d_ub-d_lb)/1000):d_ub, 
		[(1 - d_z/1000) for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :lightblue), 
		label = "Wrapping Food")
		
	plot!(d_lb:((d_ub-d_lb)/1000):d_ub, 
		[tanh(abs(i-d_s))*(1-(d_z/1000)) for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :orange), 
		label = "Approaching Food",
		xlabel = "Fitness",
		ylabel = "Chance")
	vline!([d_s], lw = 3, label = "DF", color = [:red])
end

# ╔═╡ fd57b639-eed9-4849-b2f7-6f8a57aaa468
md"""
Below a similar graph is made but this time in function of the distance in one-dimensional space instead of the fitness. The fitness function itself is also shown. 

"""

# ╔═╡ 7e9ea8b0-a2e9-442a-80c6-812160766196
md"""
It can be seen that the chance of displaying *Wrapping Food* behavior is small until a local or global minimum is near. Each time the fitness function reaches near a minimum, individuals at this location are likely to display *Wrapping Food* behavior, where oscillating changes to the location are made to finetune the fit.

The full equation for the locations is as follows:
```math
\overrightarrow{X(t+1)}=
\begin{cases}
rand(UB-LB) + LB & \quad \text{$rand < z$}\\ 
\overrightarrow{X_b(t)} +\overrightarrow{vb}(W \times \overrightarrow{X_A(t)} -\overrightarrow{X_B(t)}) & \quad \text{$r < p$} \\
\overrightarrow{vc} \times \overrightarrow{X(t)} & \quad \text{$r \geq p$}
\end{cases}
```

"""

# ╔═╡ 55be43e0-f38e-4d28-a89d-af250bc60852
md"""
Slime molds are able to accomplish much of their complex behavior because of the oscillation of their membranes. Or more accurately, because of the changes to the oscillation based on their environment. SMA tries to replicate some of these advantages by using multiple oscillating functions. Specifically the functions $\overrightarrow{vb}$, $\overrightarrow{vc}$ and $W$. The equations for $\overrightarrow{vb}$ and $\overrightarrow{vc}$ are as follows:

$\overrightarrow{vb} = \left[-arctanh(-\left(\dfrac{t}{max_t}\right) + 1), arctanh(-\left(\dfrac{t}{max_t}\right) + 1)\right]$

$\overrightarrow{vc} = \left[-(1-\left(\dfrac{t}{max_t}\right)), 1-\left(\dfrac{t}{max_t}\right)\right]$

Where *t* is the current generation and *max_t* is the maximum amount of generations.

The figure below shows the behavior of these two functions when sampling a single point for each generation.


"""

# ╔═╡ ed971d92-5489-4237-915d-ef89e66c66f8
plot(
	[1:1000], 
	[
		[rand(Uniform(-atanh(-(s / 1001) + 1),atanh(-(s / 1001) + 1))) for s in 1:1000],
		[rand(Uniform(-(1 - (s/1001)),(1 - (s/1001)))) for s in 1:1000]
	], 
	label = ["vb" "vc"], 
	xlabel = "Generation", 
	ylabel = "Variation", 
	title = "Oscillating functions"
)

# ╔═╡ 6da844ef-1900-4556-9318-01cc257bc05e
md"""
From this figure, it is clear that the behavior is not only modified by the fitness but also by the current generation relative to the maximum amount of generations. In early generations, the behavior is more erratic with higher oscillations. This results in a wider exploration of the solution space. In later generations, the oscillation decreases, and the changes to the locations will be smaller and trend more towards the (local) optima.

*r* in the formula for $W$ is a random sampling for the following interval:

$r = \left[0, 1\right]$

Unlike the other oscillating mechanisms, this oscillation is not modulated by the generation. Instead, it is modified by the fitness of the current individual in the formula for W.
"""

# ╔═╡ 91106045-43a1-427c-a300-e5200ad112ff
md"""
The algorithm itself was implemented mostly according to the following pseudocode (from the original paper):


	Initialize Population Size: N, Maximum Iterations: max_t;
	Initialize positions of individuals X_i(i = 1,2,...,N);
	While t < max_t)
		-Calculate fitness of all Slime Molds
		-update bF, X_b
		-Calculate W
		For each Individual
			-update p, vb, vc
			-update position
		End For
		t = t + 1
	End While
	Return bF, Xb:


"""

# ╔═╡ 8663be81-9919-46a8-977a-1c11bbed0f73
md"""
#### ⚠️Modifications to the original method⚠️
I was confused that the original paper uses the above formulas to calculate the new locations instead of using the results as a search direction for the individuals. In order to make sure I understood the method correctly I looked at the original Python and Matlab implementation of the algorithm by the original authors. This confirmed that the results of these formulas should indeed be used as the new locations. This is a strange decision for a number of reasons. 

-First, when displaying the *Wrapping Food* behavioral mode the location is meant to be oscillated by *vc*. However, *vc* approaches 0 in later generations which means that the *wrapping food* formula doesn't oscillate around the original point, but oscillates between the original location and zero. This gives the algorithm a tendency towards zero. This effect is masked by the fact that many of the benchmark functions have their optimal value at 0. Below, I tested this original implementation with a fitness function with an optimum at a different location. It can be seen that there is often a stray population of individuals around 0, which is not even a local optimum in this case. The original paper included a figure of the search history using the same fitness function but using two dimensions. This figure shows a similar renegade population around 0.

-Second, the formula used in *Approaching food* uses the *W*eight (related to fitness) of the individual in the formula. However, the original location, for which the weight was calculated, is not used. Instead, the fitness of the location is used to modulate how far from the location with the best fitness the new location is.

**Modifications:**
The first point could be solved by changing the formula for *Wrapping Food* to the following:

$\overrightarrow{X(t+1)} = \overrightarrow{X(t)} + \overrightarrow{vc} \times \overrightarrow{X(t)}$

I did test this, and the issue seemed to be resolved. (Not shown) However, in order to also incorporate the fitness information and to make the mechanism of the algorithm more intuitive I made further modifications. Instead of using the resulting locations as the new location directly, they are treated as target points. The vector needed to move the old location to the new location is then calculated. The fitness is used to determine how far along this vector the individual should move. I used p (see earlier) as this factor. This is an arbitrary choice made to not introduce additional complexity. In reality, this is likely not the best function and different options should be tested before a definite implementation is made. *p* approaches 1 very quickly when the location deviates from the optimum. As a result, the new positions for individuals with low fitness will be close to the values attained without using this additional modification. Additionally, it is likely a good idea to also introduce stochastic behavior in this step. Optimally each step should be modulated by a scaling factor relative to the fitness and an oscillating function modulated by the iteration. Currently, the new locations are calculated using the following approach:

```math
\overrightarrow{X_{virtual}}=
\begin{cases}
rand(UB-LB) + LB & \quad \text{$rand < z$}\\ 
\overrightarrow{X_b(t)} +\overrightarrow{vb}(W \times \overrightarrow{X_A(t)} -\overrightarrow{X_B(t)}) & \quad \text{$r < p$} \\
\overrightarrow{X(t)} + \overrightarrow{vc} \times \overrightarrow{X(t)} & \quad \text{$r \geq p$}
\end{cases}
```

```math
\overrightarrow{X(t+1)} = \overrightarrow{X(t)} + tanh|S(i) - DF| \times (\overrightarrow{X_{virtual}} - \overrightarrow{X(t)})
```
Finally, the last modification is the use of the same behavioral mode for every dimension of an individual instead of evaluating the condition for each dimension separately.

The two versions of this algorithm are first visually compared. Later, a simulation study is done to compare the performance and see if these modifications lead to better results. 



"""

# ╔═╡ 6992e045-0daf-46bf-a17d-62ca7945e4af
md"""
### Implementation
The implementation of the SMA is provided in a hidden cell below. (Expand to view) The data structures, fitness functions, W function, result processing functions, as well as the original implementation of the SMA are provided in the appendix at the bottom of this page. 

"""

# ╔═╡ 2cb438ee-ae5e-4421-bf5c-369154aaef81
md"""
### Results
First, we will look at the behavior of the algorithm in a one-dimensional setting. Working in one dimension makes it easier to visualize the behavior and reduces the computation need, however, the algorithm itself does not have a limit for the dimensions. Later we will also see a two-dimensional example.

The following fitness functions were used to test the behavior.

**Ackley Function:**

$$f(x_0 \cdots x_n) = -20 exp(-0.2 \sqrt{\frac{1}{n} \sum_{i=1}^n x_i^2}) - exp(\frac{1}{n} \sum_{i=1}^n cos(2\pi x_i)) + 20 + e$$

With n the amount of dimensions. This function was only used for the 1D setting.

**$f_8$:**

$$f_8(x_0 \cdots x_n) = \sum_{i=1}^n ( −x_i \times sin(\sqrt{| x_i |}))$$

With n the mount of dimensions. This function was used for both the 1D and 2D settings. This function is called $f_8$ according to the name used in the original paper. This function was selected because it has many local minima and because the global minimum is not located at the origin. This latter characteristic is usefull to show the problem with the original implementation. 

Note that these two fitness functions are symmetric in the dimensions. This is not a requirement and different dimensions can be evaluated using different functions as long as the end procuct of the method is a single fitness value. 
#### 1D Ackley Function

"""

# ╔═╡ 0f532a5b-741e-4c7c-8742-6108859ebd58
md"""
**NOTE: The figures are generated based on a random run of the algorithm. A new solution can be generated by re-running cells like the one below! The results will be slightly different. Running the algorithm multiple times will show the true range of possible behavior.**
"""

# ╔═╡ daf5a973-e73e-4a2b-8c6a-15a60f461a07
md"""
#### 1D F8 - with the modified algorithm
"""

# ╔═╡ ab416867-38df-466f-a7bf-e36d74070e32
md"""
#### 1D F8 - with the original implementation
"""

# ╔═╡ af816df6-6212-44bf-9301-a3dc4e7bf764
md"""
The problem with the original algorithm becomes very clear when you compare these results with the results of the modified algorithm. Both manage to find the true optimum but for the original implementation, there is an additional population around 0 for later generations. This means that the performance of the algorithm is dependent on the exact fitness function. Simply translating the function along one of the dimensions will cause a different fitness at the origin and change the behavior of the original implementation. It is important to note that it is not necessarily a problem that not all individuals end up in the same local (or global) optimum, only the lowest fitness value for the entire population dictates the performance. We will later look at a simulation study to investigate global performance.

"""

# ╔═╡ d0170f42-ce09-41c6-a7e4-86fbca1749ab
md"""
#### 2D F8 - With the modified algorithm
"""

# ╔═╡ 306f5d53-df88-4af3-bbec-25c947c0cb9f
md"""
Despite the oscillating and stochastic nature of the algorithm, it does sometimes get stuck in local optima. It is advised to look at different runs (by re-running the cell below) to see the full range of behavior. Changing the number of iterations and the population size help avoid this behavior.

**Note: While the algorithm is very fast, creating the figures takes around 3 minutes on my machine.**
"""

# ╔═╡ ea6fb2f4-6455-44af-a574-3768bad151a9
md"""
**The following figures take around 2 minutes to generate each so one has been disable by default to save time.**
"""

# ╔═╡ bad4cc28-ad6a-4d1e-9b72-642f394f2374
md"""
#### Comparing performance
In addition to the original implementation and the modified algorithm, a third algorithm was also included in this comparison. This version indicated as "Modified_2" only includes the change to the *Wrapping Food* function without the other modifications.

**Note: Running these simulations is time-consuming so the default number of iterations is kept very low. This makes loading the notebook easier, however, the results are not representative. Please increase the number of iterations (to at least 1000) for accurate results.**

"""

# ╔═╡ c2e2ec60-4433-43b9-b08e-ecb577900bc4
begin
	#@bind SIM1_max_iter NumberField(25:10000, default=25)
	SIM1_max_iter_button = @bind SIM1_max_iter_run Button("rerun")
	
	md"""
	##### Simulation 1
	
	**Design Space:** 2D \
	**Range:** -500, 500 \
	**Fitness Function:** F8 \
	**Population:** 50 \
	**Generations:** 50 \
	**Iterations:** $(@bind SIM1_max_iter NumberField(25:10000, default=25)) $(SIM1_max_iter_button) (Only use whole numbers)
	"""
end

# ╔═╡ 6583d269-9eab-4a0c-b81e-a25d18b3a5c8
SIM1_max_iter[1]

# ╔═╡ 6fb1c386-ef44-458e-b3f5-8929309758eb
begin
	SIM2_max_iter_button = @bind SIM2_max_iter_run Button("rerun")
	
	md"""
	##### Simulation 2
	
	**Design Space:** 15D \
	**Range:** 100, 10000 \
	**Fitness Function:** F8 \
	**Population:** 50 \
	**Generations:** 50 \
	**Iterations:** $(@bind SIM2_max_iter NumberField(25:10000, default=25)) $(SIM2_max_iter_button) (Only use whole numbers)
	"""
end

# ╔═╡ 1b5114d9-37b0-469a-ab16-02574a5803a0
begin
	SIM3_max_iter_button = @bind SIM3_max_iter_run Button("rerun")
	
	md"""
	##### Simulation 3
	
	**Design Space:** 5D \
	**Range:** 100, 1000 \
	**Fitness Function:** F8 \
	**Population:** 50 \
	**Generations:** 500 \
	**Iterations:** $(@bind SIM3_max_iter NumberField(25:10000, default=25)) $(SIM3_max_iter_button) (Only use whole numbers)
	"""
end

# ╔═╡ bfef39eb-e71f-4342-b0b8-6357d00f96c6
md"""
To further investigate the effect of maxt and the population size, the median fitness was generated for 25 algorithm runs for a number of different maxt and population sizes. **These cells are disabled by default because of the long run time.**

"""

# ╔═╡ 67ded75a-be8a-4989-976b-d0d9e6b1a3e1
md"""
##### Conclusion:
Despite the strange behavior of the original algorithm, it does perform better than the modified version especially when using a large number of generations. The population size seems to have less of an impact. Likely the less erratic behavior of the modified version makes it more likely to get stuck in a local minimum. This is supported by the fact that the performance of the version of the algorithm where only the *Wrapping Food* behavior is modified does not seem to be impacted in a similar way. When fitness is very high (local optimum) the modified version impacts the movement for all behavioral modes. Consequently, the *Searching Food* mode is not allowing a full exploration of the design space. When the amount of generations increases the chance for the original algorithm to escape the local minimum because of this mechanism increases as well. For the modified version, on the other hand, this mechanism is suppressed. It would be interesting to further test the modified version with different modulation of the movement vector. (for instance a different function or excluding *Searching Food* mode from the modulation) It would also be interesting to create a version of the modified algorithm where the behavior decision is made for each dimension separate (as is the case for the other two versions) as this might have an impact as well.

"""

# ╔═╡ 094c3ae9-7af0-4dc4-874e-fdad2c18c10d
md"""
## Appendix
"""

# ╔═╡ f6e1875e-8780-457b-b7bc-beff24c5ceb9
md"""
### Multi Dimentional Implementation:
#### Data Structures

"""

# ╔═╡ 955d45f8-6040-4904-9fc9-ff13ffa41193
begin
	# This structure holds the information of a single generation
	struct IterationRecordMulti
		iteration::Int
		slimes::Vector{Vector{Float64}}
		fitness::Vector{Float64}
		DF::Float64
		DF_value::Vector{Float64}
		bF::Float64
		wF::Float64
		Xb::Vector{Float64}
	end

	# This structure hold the information of the full algorithm run
	struct SolutionRecordMulti
		iteration::Vector{Float64}
		slimes::Vector{Vector{Vector{Float64}}}
		fitness::Vector{Vector{Float64}}
		mean_fitness::Vector{Float64}
		DF::Vector{Float64}
		DF_value::Vector{Vector{Float64}}
		bF::Vector{Float64}
		wF::Vector{Float64}
		Xb::Vector{Vector{Float64}}
	end

end

# ╔═╡ f13d0c05-44bc-41aa-9476-3f8cd74200f1
md"""
#### Multi Dimentional SMA

"""

# ╔═╡ 1a2cc51d-b97f-4192-9284-f94eff0853ba
md"""
The function below is the original implementation according to the paper. This is not the same as the final version used above!

"""

# ╔═╡ 3f9ee27d-f128-4d42-a144-d3f8856de4d3
md"""
#### Help Functions
"""

# ╔═╡ 5e62b60e-6c00-11ec-34fa-4b57e5168947
"""
    W(fitness, bF, wF, condition, iteration, max_iteration)

Calculates the weight of the current individual

Inputs:

	- fitness: Fitness of the current individual
	- bF: best fitness in the generation
	- wF: worst fitness in the generation
	- condition: If the individual is in the best or worst halve of the population in terms of fitness
	- iteration: the current iteration
	- max_iteration: the maximum amount of iterations

Outputs:

	- output: The weight of the current individual

"""
function W(fitness, bF, wF, condition, iteration, max_iteration)
	if condition
		output = 1 + rand(Uniform(0, 1)) * log10(((bF - fitness)/(bF-wF + 10e-100)) + 1)
	else
		output = 1 - rand(Uniform(0, 1)) * log10(((bF - fitness)/(bF-wF + 10e-100)) + 1)
	end
	return output
end

# ╔═╡ 4862cfb9-364b-4d34-9a30-38ce48ce069d
"""
    SMA(fitness_function, lb, ub, maxt, N; z=0.03)

The modified Slime Mould Algorithm

Inputs:

	- fitness_function: The fitness function (takes single coordinate as input with no limit on dimentions)
	- lb: lower bound: vector of lower bounds for each dimention
	- ub: upper bound: vector of upper bounds for each dimention (should match lb)
	- maxt: Maximum number of generations
	- N: Population size
	- z: Change of searching food behavior (0.03 by default)

Outputs:

	- iteration_history: contains information on iteration, location of individuals, fitness of individuals, best fitness, worst fitness, best overall fitness for each iteration of the algorithm.

"""
function SMA(fitness_function, lb, ub, maxt, N; z=0.03)

	# Initialize vectors
	slime_array = [rand(lb[d]:ub[d]) for k = 1:N, d = 1:length(lb)] # initialize slimes with random positions
	slime_list = [slime_array[i,:] for i in 1:N] # change to a vector of vectors
	DF::Float64 = 10e100 # initialize the best fitness
	DF_value = [float(1) for i in 1:length(lb)] # Initilize DF result vector
	iteration_history = Vector{IterationRecordMulti}(undef, maxt) # initialize result vector

	# cycle through all the generations
	for current_iteration in 1:maxt
		# calculate fitness
		fitness_list = [fitness_function(slime_list[s]) for s in 1:N]

		# update bestFitness Xb, worstFitness and DF
		bF, Xb = (findmin(fitness_list)[1], slime_list[findmin(fitness_list)[2]])
		wF = maximum(fitness_list)
		if bF < DF
			DF = bF
			DF_value = Xb
		end
		
		# Calculate the weights
		boundary = N/2
		weight_list = []
		for (rank,s) in enumerate(sortperm(fitness_list))
			push!(
				weight_list, 
				W(
					fitness_list[s], 
					bF, 
					wF, 
					(rank < boundary), 
					current_iteration, 
					maxt
				)
			)
		end

		# update p, vb and vc
		a = max(atanh(-(current_iteration / maxt) + 1), 10e-100)
		b = max((1 - (current_iteration)/maxt), 10e-100)
		vb = Uniform(-a,a)
		vc = Uniform(-b,b)


		slime_list_temp = []
		for s in 1:N
			if rand(Uniform(0, 1)) < z
				# Searching Food behavior
				push!(
					slime_list_temp, 
					[rand(Uniform(lb[i],ub[i])) for i in 1:length(lb)]
				)
			else
				p = tanh(fitness_list[s] - DF)
				temp_individual = []
				if rand(Uniform(0, 1)) < p
					# Approaching Food behavior
					XA_ID, XB_ID = sample(1:N, 2, replace = false)
					temp_individual = clamp.(Xb .+ rand(vb, length(ub)).*(weight_list[s] .* slime_list[XA_ID] .- slime_list[XB_ID]), lb, ub)
				else
					# Wrapping Food behavior
					temp_individual = clamp.(slime_list[s] .+ slime_list[s] .* rand(vc, length(ub)), lb, ub)
				end
				push!(slime_list_temp, slime_list[s].+tanh(fitness_list[s] - bF).*(temp_individual .- slime_list[s]))
			end
		end
		iteration_history[current_iteration] = IterationRecordMulti(
			current_iteration, 
			slime_list, 
			fitness_list, 
			DF, DF_value, 
			bF, wF, Xb
		)
		slime_list = deepcopy(slime_list_temp)
	end
	return iteration_history
end

# ╔═╡ af296256-6662-49e9-b24d-c8550ce39c8d
"""
    SMA_APPENDIX_1(fitness_function, lb, ub, maxt, N; z=0.03)

A copy of the modified Slime Mould Algorithm

Inputs:

	- fitness_function: The fitness function (takes single coordinate as input with no limit on dimentions)
	- lb: lower bound: vector of lower bounds for each dimention
	- ub: upper bound: vector of upper bounds for each dimention (should match lb)
	- maxt: Maximum number of generations
	- N: Population size
	- z: Change of searching food behavior (0.03 by default)

Outputs:

	- iteration_history: contains information on iteration, location of individuals, fitness of individuals, best fitness, worst fitness, best overall fitness for each iteration of the algorithm.

"""
function SMA_APPENDIX_1(fitness_function, lb, ub, maxt, N; z=0.03)

	# Initialize vectors
	slime_array = [rand(lb[d]:ub[d]) for k = 1:N, d = 1:length(lb)] # initialize slimes with random positions
	slime_list = [slime_array[i,:] for i in 1:N] # change to a vector of vectors
	DF::Float64 = 10e100 # initialize the best fitness
	DF_value = [float(1) for i in 1:length(lb)] # Initilize DF result vector
	iteration_history = Vector{IterationRecordMulti}(undef, maxt) # initialize result vector

	# cycle through all the generations
	for current_iteration in 1:maxt
		# calculate fitness
		fitness_list = [fitness_function(slime_list[s]) for s in 1:N]

		# update bestFitness Xb, worstFitness and DF
		bF, Xb = (findmin(fitness_list)[1], slime_list[findmin(fitness_list)[2]])
		wF = maximum(fitness_list)
		if bF < DF
			DF = bF
			DF_value = Xb
		end
		
		# Calculate the weights
		boundary = N/2
		weight_list = []
		for (rank,s) in enumerate(sortperm(fitness_list))
			push!(
				weight_list, 
				W(
					fitness_list[s], 
					bF, 
					wF, 
					(rank < boundary), 
					current_iteration, 
					maxt
				)
			)
		end

		# update p, vb and vc
		a = max(atanh(-(current_iteration / maxt) + 1), 10e-100)
		b = max((1 - (current_iteration)/maxt), 10e-100)
		vb = Uniform(-a,a)
		vc = Uniform(-b,b)


		slime_list_temp = []
		for s in 1:N
			if rand(Uniform(0, 1)) < z
				# Searching Food behavior
				push!(
					slime_list_temp, 
					[rand(Uniform(lb[i],ub[i])) for i in 1:length(lb)]
				)
			else
				p = tanh(fitness_list[s] - DF)
				temp_individual = []
				if rand(Uniform(0, 1)) < p
					# Approaching Food behavior
					XA_ID, XB_ID = sample(1:N, 2, replace = false)
					temp_individual = clamp.(Xb .+ rand(vb, length(ub)).*(weight_list[s] .* slime_list[XA_ID] .- slime_list[XB_ID]), lb, ub)
				else
					# Wrapping Food behavior
					temp_individual = clamp.(slime_list[s] .+ slime_list[s] .* rand(vc, length(ub)), lb, ub)
				end
				push!(slime_list_temp, slime_list[s].+tanh(fitness_list[s] - bF).*(temp_individual .- slime_list[s]))
			end
		end
		iteration_history[current_iteration] = IterationRecordMulti(
			current_iteration, 
			slime_list, 
			fitness_list, 
			DF, DF_value, 
			bF, wF, Xb
		)
		slime_list = deepcopy(slime_list_temp)
	end
	return iteration_history
end

# ╔═╡ 0cebe58b-f1b2-4220-b15c-0f844cf22057
"""
    SMA_APPENDIX_2(fitness_function, lb, ub, maxt, N; z=0.03)

The original Slime Mould Algorithm

Inputs:

	- fitness_function: The fitness function (takes single coordinate as input with no limit on dimentions)
	- lb: lower bound: vector of lower bounds for each dimention
	- ub: upper bound: vector of upper bounds for each dimention (should match lb)
	- maxt: Maximum number of generations
	- N: Population size
	- z: Change of searching food behavior (0.03 by default)

Outputs:

	- iteration_history: contains information on iteration, location of individuals, fitness of individuals, best fitness, worst fitness, best overall fitness for each iteration of the algorithm.

"""
function SMA_APPENDIX_2(fitness_function, lb, ub, maxt, N; z=0.03)
	slime_array = [rand(lb[d]:ub[d]) for k = 1:N, d = 1:length(lb)] # initialize slimes with random positions
	slime_list = [slime_array[i,:] for i in 1:N] # put in list
	DF::Float64 = 10e100
	DF_value = [float(1) for i in 1:length(lb)]
	iteration_history = Vector{IterationRecordMulti}(undef, maxt) # initialize result vector
	for current_iteration in 1:maxt
		# calculate fitness
		fitness_list = [fitness_function(slime_list[s]) for s in 1:N]

		# update bestFitness Xb, worstFitness and DF
		bF, Xb = (findmin(fitness_list)[1], slime_list[findmin(fitness_list)[2]])
		wF = maximum(fitness_list)
		if bF < DF
			DF = bF
			DF_value = Xb
		end
		
		# Calculate the weights
		boundary = N/2
		weight_list = []
		for (rank,s) in enumerate(sortperm(fitness_list))
			push!(weight_list, W(fitness_list[s], bF, wF, (rank < boundary), current_iteration, maxt))
		end

		# update p, vb and vc
		a = max(atanh(-(current_iteration / maxt) + 1), 10e-100)
		b = max((1 - (current_iteration)/maxt), 10e-100)
		vb = Uniform(-a,a)
		vc = Uniform(-b,b)

		slime_list_temp = []
		for s in 1:N
			if rand(Uniform(0, 1)) < z
				# Searching Food
				push!(slime_list_temp, [rand(Uniform(lb[i],ub[i])) for i in 1:length(lb)])
			else
				p = tanh(fitness_list[s] - DF)
				temp_individual = []
				for dim in 1:length(ub)
					if rand(Uniform(0, 1)) < p
						# Approaching Food
						XA_ID, XB_ID = sample(1:N, 2, replace = false)
						push!(temp_individual, clamp(Xb[dim] + rand(vb)*(weight_list[s] * slime_list[XA_ID][dim] - slime_list[XB_ID][dim]), lb[dim], ub[dim]))

					else
						# Wrapping Food
						push!(temp_individual, clamp(slime_list[s][dim] * rand(vc), lb[dim], ub[dim]))

					end
				end
				push!(slime_list_temp, temp_individual)
			end
		end
		iteration_history[current_iteration] = IterationRecordMulti(current_iteration, slime_list, fitness_list, DF, DF_value, bF, wF, Xb)
		slime_list = deepcopy(slime_list_temp)
	end
	
	return iteration_history
end

# ╔═╡ 0241a8e7-2810-488e-bbc2-38c3da9a431e
"""
    SMA_APPENDIX_3(fitness_function, lb, ub, maxt, N; z=0.03)

A modified version of the SMA where only the Wrapping Food formula was changed

Inputs:

	- fitness_function: The fitness function (takes single coordinate as input with no limit on dimentions)
	- lb: lower bound: vector of lower bounds for each dimention
	- ub: upper bound: vector of upper bounds for each dimention (should match lb)
	- maxt: Maximum number of generations
	- N: Population size
	- z: Change of searching food behavior (0.03 by default)

Outputs:

	- iteration_history: contains information on iteration, location of individuals, fitness of individuals, best fitness, worst fitness, best overall fitness for each iteration of the algorithm.

"""
function SMA_APPENDIX_3(fitness_function, lb, ub, maxt, N; z=0.03)
	slime_array = [rand(lb[d]:ub[d]) for k = 1:N, d = 1:length(lb)] # initialize slimes with random positions
	slime_list = [slime_array[i,:] for i in 1:N] # put in list
	DF::Float64 = 10e100
	DF_value = [float(1) for i in 1:length(lb)]
	iteration_history = Vector{IterationRecordMulti}(undef, maxt) # initialize result vector
	for current_iteration in 1:maxt
		# calculate fitness
		fitness_list = [fitness_function(slime_list[s]) for s in 1:N]

		# update bestFitness Xb, worstFitness and DF
		bF, Xb = (findmin(fitness_list)[1], slime_list[findmin(fitness_list)[2]])
		wF = maximum(fitness_list)
		if bF < DF
			DF = bF
			DF_value = Xb
		end
		
		# Calculate the weights
		boundary = N/2
		weight_list = []
		for (rank,s) in enumerate(sortperm(fitness_list))
			push!(weight_list, W(fitness_list[s], bF, wF, (rank < boundary), current_iteration, maxt))
		end

		# update p, vb and vc
		a = max(atanh(-(current_iteration / maxt) + 1), 10e-100)
		b = max((1 - (current_iteration)/maxt), 10e-100)
		vb = Uniform(-a,a)
		vc = Uniform(-b,b)

		slime_list_temp = []
		for s in 1:N
			if rand(Uniform(0, 1)) < z
				# Searching Food
				push!(slime_list_temp, [rand(Uniform(lb[i],ub[i])) for i in 1:length(lb)])
			else
				p = tanh(fitness_list[s] - DF)
				temp_individual = []
				for dim in 1:length(ub)
					if rand(Uniform(0, 1)) < p
						# Approaching Food
						XA_ID, XB_ID = sample(1:N, 2, replace = false)
						push!(temp_individual, clamp(Xb[dim] + rand(vb)*(weight_list[s] * slime_list[XA_ID][dim] - slime_list[XB_ID][dim]), lb[dim], ub[dim]))

					else
						# MODIFIED Wrapping Food
						push!(temp_individual, clamp(slime_list[s][dim] * (1+rand(vc)), lb[dim], ub[dim]))

					end
				end
				push!(slime_list_temp, temp_individual)
			end
		end
		iteration_history[current_iteration] = IterationRecordMulti(current_iteration, slime_list, fitness_list, DF, DF_value, bF, wF, Xb)
		slime_list = deepcopy(slime_list_temp)
	end
	
	return iteration_history
end

# ╔═╡ d1dca62c-788e-4d20-a528-dcb8f39a3d53
"""
    ProcessRecordVectorMulti(RecordVector)

Process the results from being a list of structs containing information about each iteration to a struct with information on location, fitness, and generation for the total algorithm run

Inputs:

	- RecordVector: a vector of IterationRecordMulti for each iteration

Outputs:

	- output: SolutionRecordMulti struct with information for the whole algorithm run

"""
function ProcessRecordVectorMulti(RecordVector)
	iterations = [i for i in 1:length(RecordVector)]
	DF_vector = []
	DF_value_vector = []
	slimes_vector = []
	fitness_vector = []
	mean_fitness_vector = []
	bF_vector = []
	wF_vector = []
	Xb_vector = []
	for i in 1:length(RecordVector)
		push!(DF_vector, RecordVector[i].DF)
		push!(DF_value_vector, RecordVector[i].DF_value)
		append!(slimes_vector, [RecordVector[i].slimes])
		append!(fitness_vector, [RecordVector[i].fitness])
		push!(mean_fitness_vector, mean(RecordVector[i].fitness))
		push!(bF_vector, RecordVector[i].bF)
		push!(wF_vector, RecordVector[i].wF)
		push!(Xb_vector, RecordVector[i].Xb)
	end
    return SolutionRecordMulti(iterations, slimes_vector, fitness_vector, mean_fitness_vector, DF_vector, DF_value_vector, bF_vector, wF_vector, Xb_vector)
end

# ╔═╡ a48e1156-fc46-4b58-b971-9b65b348d64b
"""
    fitness_multi(solution)

Multidimentional Ackley fitness function

Inputs:

	- solution: The coordinate for an individual

Outputs:

	- The fitness for these coordinates

"""
function fitness_multi(solution)
	a, b, c = 20, 0.2, 2 * pi
    d = length(solution)
    sum_1 = -a * exp(-b * sqrt(sum(solution.^2) / d))
    sum_2 = exp(sum(cos.(c .* solution)) / d)
    return sum_1 - sum_2 + a + exp(1)
end

# ╔═╡ ab975494-0a3e-46fe-b3cb-74fa87010018
begin
	Ackley_1D_record = SMA(fitness_multi, [-100], [100], 50, 20; z=0.03)
	Ackley_1D_results = ProcessRecordVectorMulti(Ackley_1D_record)
end

# ╔═╡ 1d12c6dd-7f0a-458c-ad43-9ffdc98acf31
begin
	gen_slider = @bind d_gen Slider(1:length(Ackley_1D_results.iteration), default = 5, show_value = true)
	md"""
	The figure above shows 4 plots. The **first figure** (top left) shows the evolution of the best fitness and the mean fitness throughout the generations. The lowest fitness quickly reaches its minimum value, however, there are still fluctuations in the mean fitness because of the oscillating character of the algorithm. The **second figure** (top right) shows the location of the population at a specific generation (the x-axis does not have meaning, the points were spread for better visualization). The **third figure** (bottom left) shows the fitness function. In this case the 1D Ackley function. The points on this figure show where the population of a certain generation is located on this fitness function. Finally, the **last figure** (bottom right) shows the locations of the individuals over all generations. This figure shows that initially the individuals are randomly spread out but quickly converge on the optimal position. In later generations, some individuals still deviate. These are likely the few individuals that display *searching food* behavior. This can help the SMA get out of local optima.
	
	**Below is an interactive version of this plot.**
	
	Generation: $(gen_slider)	
	"""
	
end

# ╔═╡ c9a1e998-a378-4d59-90c5-138257ac439e
begin
	local results
	local record
	local p1, p2, p3, p4

	results = Ackley_1D_results
	record = Ackley_1D_record
	
	Ackley_1D = @animate for i = 1:length(results.iteration)
		p1 = plot(
			results.iteration[1:i], 
			[results.mean_fitness[1:i], results.DF[1:i]],  
			title ="Fitness", 
			label = ["Mean" "Lowest"], 
			ylims=(-1, maximum(results.mean_fitness)), 
			xlims=(0, length(results.iteration)), 
			lw = 2, 
			xlabel = "Generation", 
			ylabel = "Fitness"
		)
		
	    p2 = scatter(
			[rand() for j in 1:length(record[1].slimes)], 
			sort(reduce(vcat,Ackley_1D_record[i].slimes)), 
			ylims=(-100, 100), 
			xlims=(0, 1), 
			title ="Locations in Gen: "*string(i), 
			xticks = false, 
			ylabel= "Location",
			legend = false
		)

		p3 = plot(
			-100:100, 
			[fitness_multi([s]) for s in -100:100], 
			title = "Fitness Function", 
			xlabel = "Location", 
			ylabel = "Fitness",
			ylim = (-1,20),
			legend = false
		)
		p3 = scatter!(
			reduce(vcat,Ackley_1D_record[i].slimes),
			[fitness_multi(Ackley_1D_record[i].slimes[s]) for s in 1:length(Ackley_1D_record[i].slimes)]		
		)

		p4 = scatter(
			results.iteration, 
			reduce(vcat,transpose.([[results.slimes[row][col][1] for col in 1:length(results.slimes[1])] for row in 1:length(results.slimes)])), 
			legend = false, 
			markercolor = [(s == i ? :red : :green) for s in results.iteration], 
			xlabel = "Generation", 
			ylabel = "Location", 
			title = "All Locations"
		)
		p4 = vline!([i], lw = 1, color = [:red])

		plot(p1, p2, p3, p4, layout = (2, 2))	
	end
	gif(Ackley_1D, fps = 5)
end

# ╔═╡ 60c3954b-d519-4f2b-9faa-efe85e34f774
begin
	local results
	local record
	local p1, p2, p3, p4
	local i
	
	i = d_gen
	results = Ackley_1D_results
	record = Ackley_1D_record
	
		p1 = plot(
			results.iteration[1:length(results.iteration)], 
			[results.mean_fitness[1:length(results.iteration)], results.DF[1:length(results.iteration)]],  
			title ="Fitness", 
			label = ["Mean" "Lowest"], 
			ylims=(-1, maximum(results.mean_fitness)), 
			xlims=(0, length(results.iteration)), 
			lw = 2, 
			xlabel = "Generation", 
			ylabel = "Fitness"
		)
		p1 = vline!([i], lw = 1, color = [:red], label = false)
		
	    p2 = scatter(
			[rand() for j in 1:length(record[1].slimes)], 
			sort(reduce(vcat,Ackley_1D_record[i].slimes)), 
			ylims=(-100, 100), 
			xlims=(0, 1), 
			title ="Locations in Gen: "*string(i), 
			xticks = false, 
			ylabel= "Location",
			legend = false
		)

		p3 = plot(
			-100:100, 
			[fitness_multi([s]) for s in -100:100], 
			title = "Fitness Function", 
			xlabel = "Location", 
			ylabel = "Fitness",
			ylim = (-1,21),
			legend = false
		)
		p3 = scatter!(
			reduce(vcat,Ackley_1D_record[i].slimes),
			[fitness_multi(Ackley_1D_record[i].slimes[s]) for s in 1:length(Ackley_1D_record[i].slimes)]
			
		)

		p4 = scatter(
			results.iteration, 
			reduce(vcat,transpose.([[results.slimes[row][col][1] for col in 1:length(results.slimes[1])] for row in 1:length(results.slimes)])), 
			legend = false, 
			markercolor = [(s == i ? :red : :green) for s in results.iteration], 
			xlabel = "Generation", 
			ylabel = "Location", 
			title = "All Locations"
		)
		p4 = vline!([i], lw = 1, color = [:red])

		plot(p1, p2, p3, p4, layout = (2, 2))
end

# ╔═╡ e6a3536e-dfc1-494b-9b46-c33e22ed79f0
"""
    fitness_2_multi(solution)

Multidimentional f8 function

Inputs:

	- solution: The coordinate for an individual

Outputs:

	- The fitness for these coordinates

"""
function fitness_2_multi(solution)
    return sum(-solution .* sin.(sqrt.(abs.(solution))))
end

# ╔═╡ 0ab5423b-3e36-4226-a690-e129aaa0f8c8
begin
	local d_lb
	local d_ub
	local d_s

	# settings
	d_lb = -200 # lower bound
	d_ub = 150 # upper bound
	d_s = fitness_2_multi([0]) # best fitness

	
	p_ex2_1 = plot(
		d_lb:((d_ub-d_lb)/1000):d_ub, 
		[1 for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :green), 
		label = "Finding Food"
	)
		
	p_ex2_1 = plot!(
		d_lb:((d_ub-d_lb)/1000):d_ub, 
		[(1 - d_z/1000) for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :lightblue), 
		label = "Wrapping Food"
	)
		
	p_ex2_1 = plot!(
		d_lb:((d_ub-d_lb)/1000):d_ub, 
		[tanh(abs(fitness_2_multi([i])-d_s))*(1-(d_z/1000)) for i in d_lb:((d_ub-d_lb)/1000):d_ub], 
		ylims= (0,1),
		xlims= (d_lb,d_ub),
		fill = (0, :orange), 
		label = "Approaching Food",
		title = "Chance Of Behavior",
		xlabel = "Location", 
		ylabel = "Chance"
	)


	p_ex2_2 = plot(
	d_lb:d_ub, 
	[abs(fitness_2_multi([s])) for s in d_lb:d_ub], 
	title = "Fitness Function",
	xlims= (d_lb,d_ub),
	xlabel = "Location", 
	ylabel = "Fitness"
	)


	plot(p_ex2_2, p_ex2_1, layout = (2, 1))
end

# ╔═╡ 72b1f589-cae8-4ffb-a4d7-a50aeb1898ce
begin
	f8_1D_record = SMA(fitness_2_multi, [-500], [500], 50, 20; z=0.03)
	f8_1D_results = ProcessRecordVectorMulti(f8_1D_record)
end

# ╔═╡ 79428f16-504e-4551-8289-83e5b86f53e2
begin
	gen_slider2 = @bind d_gen2 Slider(1:length(f8_1D_results.iteration), default = 5, show_value = true)
	md"""
	This fitness function is much harder than the Ackly function. There are many local optima where an algorithm might get stuck. 
	
	**Below is an interactive version of this plot.**
	
	Generation: $(gen_slider2)	
	"""
	
end

# ╔═╡ f595c7ab-5b6e-441a-b7b3-c804e8e0c7ab
begin
	local results
	local record
	local p1, p2, p3, p4
	
	results = f8_1D_results
	record = f8_1D_record
	
	f8_1D = @animate for i = 1:length(results.iteration)
		p1 = plot(
			results.iteration[1:i], 
			[results.mean_fitness[1:i], results.DF[1:i]],  
			title ="Fitness", 
			label = ["Mean" "Lowest"], 
			ylims=(-500, 500), 
			xlims=(0, length(results.iteration)), 
			lw = 2, 
			xlabel = "Generation", 
			ylabel = "Fitness"
		)
		
	    p2 = scatter(
			[rand() for j in 1:length(record[1].slimes)], 
			sort(reduce(vcat,record[i].slimes)), 
			ylims=(-500, 500), 
			xlims=(0, 1), 
			title ="Locations in Gen: "*string(i), 
			xticks = false, 
			ylabel= "Location",
			legend = false
		)

		p3 = plot(
			-500:500, 
			[fitness_2_multi([s]) for s in -500:500], 
			title = "Fitness Function", 
			xlabel = "Location", 
			ylabel = "Fitness",
			ylim = (-500,500),
			legend = false
		)
		p3 = scatter!(
			reduce(vcat,record[i].slimes),
			[fitness_2_multi(record[i].slimes[s]) for s in 1:length(record[i].slimes)]
			
		)

		p4 = scatter(
			results.iteration, 
			reduce(vcat,transpose.([[results.slimes[row][col][1] for col in 1:length(results.slimes[1])] for row in 1:length(results.slimes)])), 
			legend = false, 
			markercolor = [(s == i ? :red : :green) for s in results.iteration], 
			xlabel = "Generation", 
			ylabel = "Location", 
			title = "All Locations"
		)
		p4 = vline!([i], lw = 1, color = [:red])

		plot(p1, p2, p3, p4, layout = (2, 2))
	end
	gif(f8_1D, fps = 5)
end

# ╔═╡ b777ec82-953b-4688-936d-56c61c6794cd
begin
	local results
	local record
	local p1, p2, p3, p4
	local i
	
	i = d_gen2
	results = f8_1D_results
	record = f8_1D_record
	
		p1 = plot(
			results.iteration[1:length(results.iteration)], 
			[results.mean_fitness[1:length(results.iteration)], results.DF[1:length(results.iteration)]],  
			title ="Fitness", 
			label = ["Mean" "Lowest"], 
			ylims=(-500, 500), 
			xlims=(0, length(results.iteration)), 
			lw = 2, 
			xlabel = "Generation", 
			ylabel = "Fitness"
		)
		p1 = vline!([i], lw = 1, color = [:red], label = false)
		
	    p2 = scatter(
			[rand() for j in 1:length(record[1].slimes)], 
			sort(reduce(vcat,record[i].slimes)), 
			ylims=(-500, 500), 
			xlims=(0, 1), 
			title ="Locations in Gen: "*string(i), 
			xticks = false, 
			ylabel= "Location",
			legend = false
		)

		p3 = plot(
			-500:500, 
			[fitness_2_multi([s]) for s in -500:500], 
			title = "Fitness Function", 
			xlabel = "Location", 
			ylabel = "Fitness",
			ylim = (-500,500),
			legend = false
		)
		p3 = scatter!(
			reduce(vcat,record[i].slimes),
			[fitness_2_multi(record[i].slimes[s]) for s in 1:length(record[i].slimes)]
			
		)

		p4 = scatter(
			results.iteration, 
			reduce(vcat,transpose.([[results.slimes[row][col][1] for col in 1:length(results.slimes[1])] for row in 1:length(results.slimes)])), 
			legend = false, 
			markercolor = [(s == i ? :red : :green) for s in results.iteration], 
			xlabel = "Generation", 
			ylabel = "Location", 
			title = "All Locations"
		)
		p4 = vline!([i], lw = 1, color = [:red])

		plot(p1, p2, p3, p4, layout = (2, 2))
end

# ╔═╡ d8497cde-7c0c-4e7e-91e0-6afb8d8cb411
begin
	f8_1D_record_OG = SMA_APPENDIX_2(fitness_2_multi, [-500], [500], 50, 20; z=0.03)
	f8_1D_results_OG = ProcessRecordVectorMulti(f8_1D_record_OG)
end

# ╔═╡ c722ed1a-83dd-4634-ad4c-4d59738db97a
begin
	local results
	local record
	local p1, p2, p3, p4
	
	results = f8_1D_results_OG
	record = f8_1D_record_OG
	
	f8_1D_OG = @animate for i = 1:length(results.iteration)
		p1 = plot(
			results.iteration[1:i], 
			[results.mean_fitness[1:i], results.DF[1:i]],  
			title ="Fitness", 
			label = ["Mean" "Lowest"], 
			ylims=(-500, 500), 
			xlims=(0, length(results.iteration)), 
			lw = 2, 
			xlabel = "Generation", 
			ylabel = "Fitness"
		)
		
	    p2 = scatter(
			[rand() for j in 1:length(record[1].slimes)], 
			sort(reduce(vcat,record[i].slimes)), 
			ylims=(-500, 500), 
			xlims=(0, 1), 
			title ="Locations in Gen: "*string(i), 
			xticks = false, 
			ylabel= "Location",
			legend = false
		)

		p3 = plot(
			-500:500, 
			[fitness_2_multi([s]) for s in -500:500], 
			title = "Fitness Function", 
			xlabel = "Location", 
			ylabel = "Fitness",
			ylim = (-500,500),
			legend = false
		)
		p3 = scatter!(
			reduce(vcat,record[i].slimes),
			[fitness_2_multi(record[i].slimes[s]) for s in 1:length(record[i].slimes)]		
		)

		p4 = scatter(
			results.iteration, 
			reduce(vcat,transpose.([[results.slimes[row][col][1] for col in 1:length(results.slimes[1])] for row in 1:length(results.slimes)])), 
			legend = false, 
			markercolor = [(s == i ? :red : :green) for s in results.iteration], 
			xlabel = "Generation", 
			ylabel = "Location", 
			title = "All Locations"
		)
		p4 = vline!([i], lw = 1, color = [:red])

		plot(p1, p2, p3, p4, layout = (2, 2))	
	end
	gif(f8_1D_OG, fps = 5)
end

# ╔═╡ 6600061c-d18e-4699-beec-adb58de12f41
begin
	f8_2D_record = SMA(fitness_2_multi, [-500, -500], [500, 500], 50, 50; z=0.03)
	f8_2D_results = ProcessRecordVectorMulti(f8_2D_record)
end

# ╔═╡ 49a07a3d-51fa-4f38-b33d-e5127e744b04
begin
	local x
	local y
	local results
	local gen
	
	results = f8_2D_results
	x = [i for i in -600:600]
	y = [i for i in -600:600]
	
	f8_2D = @animate for gen = 1:length(results.iteration)
		f(x,y) = fitness_2_multi([x,y])
		f8_2D_contour = contour(x,y,f)
		f8_2D_contour = scatter!(
			[results.slimes[gen][i][1] for i in 1:length(results.slimes[1])],
			[results.slimes[gen][i][2] for i in 1:length(results.slimes[1])],
			xlim=(-600,600),
			ylim=(-600,600),
			legend = false,
			title="Fitness Contour Plot",
			xlabel = "Dimention 1",
			ylabel = "Dimention 2"
		)

	f8_2D_fitness = plot(
				results.iteration[1:gen], 
				[results.mean_fitness[1:gen], results.DF[1:gen]],  
				title ="Fitness", 
				label = ["Mean" "Lowest"], 
				ylims=(-1000, 500), 
				xlims=(0, length(results.iteration)), 
				lw = 2, 
				xlabel = "Generation", 
				ylabel = "Fitness"
	)

	plot(
		f8_2D_fitness, 
		f8_2D_contour, 
		layout = (1, 2),
		size=(800,300)
	)
		
	end
	gif(f8_2D, fps = 5)
end

# ╔═╡ 36a3a18f-7537-46cc-b4f4-1551ae939be5
begin
	local x
	local y
	local results
	local gen
	
	results = f8_2D_results
	x = [i for i in -600:600]
	y = [i for i in -600:600]
	f(x,y) = fitness_2_multi([x,y])
	f8_2D_3Dplot = @animate for gen = 1:length(results.iteration)
		temp_camera = 30 + gen/2
		
		f8_2D_scatter = plot(
			x,y,f,st=:surface,
			camera=(temp_camera,50),
			xlim=(-600,600),
			ylim=(-600,600),
			zlim=(-1000,1000)
		)
		
		f8_2D_scatter = scatter!(
			[[results.slimes[j][i][1] for i in 1:length(results.slimes[1])] for j in 1:length(results.iteration)],
			[[results.slimes[j][i][2] for i in 1:length(results.slimes[1])] for j in 1:length(results.iteration)],
			[[results.fitness[j][i] for i in 1:length(results.slimes[1])] for j in 1:length(results.iteration)],
			xlim=(-600,600),
			ylim=(-600,600),
			zlim=(-1000,1000),
			legend = false,
			color = :green,
			camera=(temp_camera,50)
		)
		
		f8_2D_scatter = scatter!(
			[results.slimes[gen][i][1] for i in 1:length(results.slimes[1])],
			[results.slimes[gen][i][2] for i in 1:length(results.slimes[1])],
			results.fitness[gen],
			xlim=(-600,600),
			ylim=(-600,600),
			zlim=(-1000,1000),
			legend = false,
			color = :red,
			camera= (temp_camera,50),
			title = "Fitness in generation: "*string(gen) 
		)
	end
	gif(f8_2D_3Dplot, fps = 5)
end

# ╔═╡ f9f4361c-ec29-4055-a1da-d3b0f5a20295
begin
	local ub
	local lb
	local maxt
	local N
	local max_iter
	
	max_iter = clamp(SIM1_max_iter,25,10000)
	lb = [-500, -500]
	ub = [500, 500]
	maxt = 50
	N = 50
	
	OG_results = []
	Modified_results = []
	Modified_2_results = []
	
	for i in 1:max_iter
		f8_2D_record_MODIFIED = SMA(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED = ProcessRecordVectorMulti(f8_2D_record_MODIFIED)
		push!(Modified_results,f8_2D_results_MODIFIED.DF[end])

		f8_2D_record_OG = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_OG = ProcessRecordVectorMulti(f8_2D_record_OG)
		push!(OG_results,f8_2D_results_OG.DF[end])

		f8_2D_record_MODIFIED_2 = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED_2 = ProcessRecordVectorMulti(f8_2D_record_MODIFIED_2)
		push!(Modified_2_results,f8_2D_results_MODIFIED_2.DF[end])
	end
	
	OG_results_mean = round(mean(OG_results))
	OG_results_minimum = round(minimum(OG_results))
	OG_results_median = round(median(OG_results))
	Modified_results_mean = round(mean(Modified_results))
	Modified_results_minimum = round(minimum(Modified_results))
	Modified_results_median = round(median(Modified_results))
	Modified_2_results_mean = round(mean(Modified_2_results))
	Modified_2_results_minimum = round(minimum(Modified_2_results))
	Modified_2_results_median = round(median(Modified_2_results))
	
	scatter(
		[[rand()/1.3 for j in 1:max_iter],[rand()/1.3+1 for j in 1:max_iter], [rand()/1.3+2 for j in 1:max_iter]], 
		[OG_results, Modified_results, Modified_2_results],  
		xlims=(-0.5, 3.5), 
		title ="Final fitness scores", 
		xticks = false, 
		ylabel= "Fitness",
		markeralpha = 0.7,
		labels = ["Original" "Modified" "Modified_2"]
	)
	
	boxplot!(
		[[0.5/1.3 for j in 1:max_iter],[0.5/1.3+1 for j in 1:max_iter],[0.5/1.3+2 for j in 1:max_iter]],
		[OG_results, Modified_results, Modified_2_results], 
		outliers = false,
		label=false, 
		fillalpha = 0.3,
		fillcolor = repeat([:blue :orange :green], outer = max_iter)
	)

end

# ╔═╡ ba12b93e-83d2-4c8d-91d9-ff98afff6f10
md"""
The results of this simulation are:\
**Original Algorithm:**\
Mean: $(OG_results_mean)\
Median: $(OG_results_median)\
Minimum: $(OG_results_minimum)\
**Modified Algorithm:**\
Mean: $(Modified_results_mean)\
Median: $(Modified_results_median)\
Minimum: $(Modified_results_minimum)\
**Modified_2 Algorithm:**\
Mean: $(Modified_2_results_mean)\
Median: $(Modified_2_results_median)\
Minimum: $(Modified_2_results_minimum)\

**Discussion:** For this low amount of dimensions and small intervals for the design space, all algorithms perform similarly. Most runs result either in the global optimum or one local optimum (which is why the boxplots look strange).
"""

# ╔═╡ 60cecddd-601e-4113-90c5-19d3d045136a
begin
	local ub, lb, maxt, N, max_iter
	local OG_results, Modified_results, Modified_2_results
	local OG_results_mean, OG_results_minimum, OG_results_median, Modified_results_mean, Modified_results_minimum, Modified_results_median, Modified_2_results_mean, Modified_2_results_minimum, Modified_2_results_median
	local simulation_figure
	SIM2_max_iter_button

	# Initiate algorithm settings
	max_iter = clamp(SIM2_max_iter,25,10000)
	lb = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
	ub = [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000]
	maxt = 50
	N = 50

	# Initiate result vectors
	OG_results = []
	Modified_results = []
	Modified_2_results = []
	
	for i in 1:max_iter
		# Modified algorithm
		f8_2D_record_MODIFIED = SMA(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED = ProcessRecordVectorMulti(f8_2D_record_MODIFIED)
		push!(Modified_results,f8_2D_results_MODIFIED.DF[end])

		# Original algorithm
		f8_2D_record_OG = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_OG = ProcessRecordVectorMulti(f8_2D_record_OG)
		push!(OG_results,f8_2D_results_OG.DF[end])

		# Modified_2 algorithm 
		f8_2D_record_MODIFIED_2 = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED_2 = ProcessRecordVectorMulti(f8_2D_record_MODIFIED_2)
		push!(Modified_2_results,f8_2D_results_MODIFIED_2.DF[end])
	end

	# Calculate performance metrics
	OG_results_mean = round(mean(OG_results))
	OG_results_minimum = round(minimum(OG_results))
	OG_results_median = round(median(OG_results))
	Modified_results_mean = round(mean(Modified_results))
	Modified_results_minimum = round(minimum(Modified_results))
	Modified_results_median = round(median(Modified_results))
	Modified_2_results_mean = round(mean(Modified_2_results))
	Modified_2_results_minimum = round(minimum(Modified_2_results))
	Modified_2_results_median = round(median(Modified_2_results))

	# Create the figure
	## first scatter the points
	simulation_figure = scatter(
		[
			[rand()/1.3 for j in 1:max_iter],
			[rand()/1.3+1 for j in 1:max_iter], 
			[rand()/1.3+2 for j in 1:max_iter]
		], 
		[OG_results, Modified_results, Modified_2_results],  
		xlims=(-0.5, 3.5), 
		title ="Final fitness scores", 
		xticks = false, 
		ylabel= "Fitness",
		markeralpha = 0.7,
		labels = ["Original" "Modified" "Modified_2"]
	)
	
	## Overlay the boxplots 
	simulation_figure = boxplot!(
		[
			[0.5/1.3 for j in 1:max_iter],
			[0.5/1.3+1 for j in 1:max_iter],
			[0.5/1.3+2 for j in 1:max_iter]
		],
		[OG_results, Modified_results, Modified_2_results], 
		outliers = false,
		label = false, 
		fillalpha = 0.3,
		fillcolor = repeat([:blue :orange :green], outer = max_iter)
	)
	
md"""
$(simulation_figure)

The results of this simulation are:\
**Original Algorithm:**\
Mean: $(OG_results_mean)\
Median: $(OG_results_median)\
Minimum: $(OG_results_minimum)\
**Modified Algorithm:**\
Mean: $(Modified_results_mean)\
Median: $(Modified_results_median)\
Minimum: $(Modified_results_minimum)\
**Modified_2 Algorithm:**\
Mean: $(Modified_2_results_mean)\
Median: $(Modified_2_results_median)\
Minimum: $(Modified_2_results_minimum)\

**Discussion:** We are now using a design space with 15 dimensions and much larger intervals. The fact that there is no large population of points at the lowest fitness value (and that the boxplots look so clean) indicates that none of the algorithms are consistently reaching the global minimum. This may be because of the low amount of generations for each run, or the limited population size, especially because of the high complexity of the 15D problem.
"""
end

# ╔═╡ 95f1d794-fba6-4743-862b-e2c0a5a0e1ed
begin
	local ub, lb, maxt, N, max_iter
	local OG_results, Modified_results, Modified_2_results
	local OG_results_mean, OG_results_minimum, OG_results_median, Modified_results_mean, Modified_results_minimum, Modified_results_median, Modified_2_results_mean, Modified_2_results_minimum, Modified_2_results_median
	local simulation_figure
	
	SIM3_max_iter_button
	
	max_iter = clamp(SIM3_max_iter,25,10000)
	lb = [100, 100, 100, 100, 100]
	ub = [10000, 10000, 10000, 10000, 10000]
	maxt = 500
	N = 50
	
	OG_results = []
	Modified_results = []
	Modified_2_results = []
	
	for i in 1:max_iter
		f8_2D_record_MODIFIED = SMA(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED = ProcessRecordVectorMulti(f8_2D_record_MODIFIED)
		push!(Modified_results,f8_2D_results_MODIFIED.DF[end])

		f8_2D_record_OG = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_OG = ProcessRecordVectorMulti(f8_2D_record_OG)
		push!(OG_results,f8_2D_results_OG.DF[end])

		f8_2D_record_MODIFIED_2 = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
		f8_2D_results_MODIFIED_2 = ProcessRecordVectorMulti(f8_2D_record_MODIFIED_2)
		push!(Modified_2_results,f8_2D_results_MODIFIED_2.DF[end])		
	end
	
	OG_results_mean = round(mean(OG_results))
	OG_results_minimum = round(minimum(OG_results))
	OG_results_median = round(median(OG_results))
	Modified_results_mean = round(mean(Modified_results))
	Modified_results_minimum = round(minimum(Modified_results))
	Modified_results_median = round(median(Modified_results))
	Modified_2_results_mean = round(mean(Modified_2_results))
	Modified_2_results_minimum = round(minimum(Modified_2_results))
	Modified_2_results_median = round(median(Modified_2_results))
	
	simulation_figure = scatter(
		[[rand()/1.3 for j in 1:max_iter],[rand()/1.3+1 for j in 1:max_iter], [rand()/1.3+2 for j in 1:max_iter]], 
		[OG_results, Modified_results, Modified_2_results],  
		xlims=(-0.5, 3.5), 
		title ="Final fitness scores", 
		xticks = false, 
		ylabel= "Fitness",
		markeralpha = 0.7,
		labels = ["Original" "Modified" "Modified_2"]
	)
	
	simulation_figure = boxplot!(
		[[0.5/1.3 for j in 1:max_iter],[0.5/1.3+1 for j in 1:max_iter],[0.5/1.3+2 for j in 1:max_iter]],
		[OG_results, Modified_results, Modified_2_results], 
		outliers = false,
		label=false, 
		fillalpha = 0.3,
		fillcolor = repeat([:blue :orange :green], outer = max_iter)
	)
md"""
$(simulation_figure)

The results of this simulation are:\
**Original Algorithm:**\
Mean: $(OG_results_mean)\
Median: $(OG_results_median)\
Minimum: $(OG_results_minimum)\
**Modified Algorithm:**\
Mean: $(Modified_results_mean)\
Median: $(Modified_results_median)\
Minimum: $(Modified_results_minimum)\
**Modified_2 Algorithm:**\
Mean: $(Modified_2_results_mean)\
Median: $(Modified_2_results_median)\
Minimum: $(Modified_2_results_minimum)\

**Discussion:** Here we have increased the amount of generations from 50 to 500 and we see a clear advantage for the original algorithm.
"""
end

# ╔═╡ ed950215-5b2c-4216-b377-881b094f5c91
begin
	local ub, lb, maxt, N, max_iter
	local OG_results, Modified_results, Modified_2_results
	local OG_results_mean, OG_results_minimum, OG_results_median, Modified_results_mean, Modified_results_minimum, Modified_results_median, Modified_2_results_mean, Modified_2_results_minimum, Modified_2_results_median
	local simulation_figure
	
	
	max_iter = 25
	lb = [100, 100, 100, 100, 100]
	ub = [10000, 10000, 10000, 10000, 10000]
	maxt = 50
	N = 50
	
	OG_results = []
	Modified_results = []
	Modified_2_results = []
	
	for j in 25:20:500
		maxt=j
		OG_results_temp = []
		Modified_results_temp = []
		Modified_2_results_temp = []
		for i in 1:max_iter
			f8_2D_record_MODIFIED = SMA(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_MODIFIED = ProcessRecordVectorMulti(f8_2D_record_MODIFIED)
			push!(Modified_results_temp,f8_2D_results_MODIFIED.DF[end])

			f8_2D_record_OG = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_OG = ProcessRecordVectorMulti(f8_2D_record_OG)
			push!(OG_results_temp,f8_2D_results_OG.DF[end])

			f8_2D_record_MODIFIED_2 = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_MODIFIED_2 = ProcessRecordVectorMulti(f8_2D_record_MODIFIED_2)
			push!(Modified_2_results_temp,f8_2D_results_MODIFIED_2.DF[end])
		end
		push!(Modified_results, Modified_results_temp)
		push!(Modified_2_results, [Modified_2_results_temp])
		push!(OG_results, [OG_results_temp])
	end
	plot(
		[25:20:500],
		[
			[median(i) for i in OG_results],
			[median(i) for i in Modified_results],
			[median(i) for i in Modified_2_results]
		],
		title = "Median Fitness for Different maxt values",
		ylabel = "Median Fitness",
		xlabel = "maxt",
		labels = ["Original" "Modified" "Modified_2"]
	)
end

# ╔═╡ 96d04bb5-b8db-4fb3-b4b0-64150fb76a99
begin
	local ub, lb, maxt, N, max_iter
	local OG_results, Modified_results, Modified_2_results
	local OG_results_mean, OG_results_minimum, OG_results_median, Modified_results_mean, Modified_results_minimum, Modified_results_median, Modified_2_results_mean, Modified_2_results_minimum, Modified_2_results_median
	local simulation_figure
	
	
	max_iter = 25
	lb = [100, 100, 100, 100, 100]
	ub = [10000, 10000, 10000, 10000, 10000]
	maxt = 50
	N = 50
	
	OG_results = []
	Modified_results = []
	Modified_2_results = []
	
	for j in 25:20:500
		maxt=N
		OG_results_temp = []
		Modified_results_temp = []
		Modified_2_results_temp = []
		for i in 1:max_iter
			f8_2D_record_MODIFIED = SMA(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_MODIFIED = ProcessRecordVectorMulti(f8_2D_record_MODIFIED)
			push!(Modified_results_temp,f8_2D_results_MODIFIED.DF[end])

			f8_2D_record_OG = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_OG = ProcessRecordVectorMulti(f8_2D_record_OG)
			push!(OG_results_temp,f8_2D_results_OG.DF[end])

			f8_2D_record_MODIFIED_2 = SMA_APPENDIX_2(fitness_2_multi, lb, ub, maxt, N; z=0.03)
			f8_2D_results_MODIFIED_2 = ProcessRecordVectorMulti(f8_2D_record_MODIFIED_2)
			push!(Modified_2_results_temp,f8_2D_results_MODIFIED_2.DF[end])
		end
		push!(Modified_results, Modified_results_temp)
		push!(Modified_2_results, [Modified_2_results_temp])
		push!(OG_results, [OG_results_temp])
	end
	plot(
		[25:20:500],
		[
			[median(i) for i in OG_results],
			[median(i) for i in Modified_results],
			[median(i) for i in Modified_2_results]
		],
		title = "Median Fitness for Different Population Sizes",
		ylabel = "Median Fitness",
		xlabel = "Population size",
		labels = ["Original" "Modified" "Modified_2"]
	)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
Distributions = "~0.25.41"
Plots = "~1.25.5"
PlutoUI = "~0.7.32"
StatsBase = "~0.33.14"
StatsPlots = "~0.14.30"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

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

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "54fc4400de6e5c3e27be6047da2ef6ba355511f8"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.6"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "6b6f04f93710c71550ec7e16b650c1b9a612d0b6"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.16.0"

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

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "5863b0b10512ed4add2b5ec07e335dc6121065a5"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.41"

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

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "4a740db447aae0fbeb3ee730de1afbb14ac798a1"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa22e1ee9e722f1da183eb33370df4c1aeb6c2cd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.1+0"

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

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

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
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

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

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

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

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

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

[[MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "648107615c15d4e09f7eca16307bc821c1f718d8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.13+0"

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

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

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
git-tree-sha1 = "6f1b25e8ea06279b5689263cc538f51331d7ca17"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.3"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "68e602f447344154f3b80f7d14bfb459a0f4dadf"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.5"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

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

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

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

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "15dfe6b103c2a993be24404124b8791a09460983"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.11"

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
git-tree-sha1 = "e6bf188613555c78062842777b116905a9f9dd49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "2884859916598f974858ff01df7dfc6c708dd895"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.3.3"

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

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f35e1879a71cca95f4826a14cdbf0b9e253ed918"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.15"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "e1e5ed9669d5521d4bbdd4fab9f0945a0ffceba2"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.30"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "d21f2c564b21a202f4677c0fba5b5ee431058544"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.4"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

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

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

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
# ╠═0efef0ae-1de8-40e0-b689-e473ef9183e8
# ╟─40272dcb-7ff1-4a5d-b201-9dc548d81d8c
# ╟─facf73a4-255a-4bf3-baa0-ef20f692e0bd
# ╟─55d82d37-b380-44a5-a234-504329b58e3f
# ╟─fb5e61c6-aae4-42c1-a088-ce87afe3ea01
# ╟─f614543b-ccea-401e-a0ad-a74eb9076b40
# ╟─664dd767-0469-4118-9a28-c5be0271c374
# ╟─8b78148a-2dbb-49c1-830c-1d770514a10e
# ╟─fd57b639-eed9-4849-b2f7-6f8a57aaa468
# ╟─0ab5423b-3e36-4226-a690-e129aaa0f8c8
# ╟─7e9ea8b0-a2e9-442a-80c6-812160766196
# ╟─55be43e0-f38e-4d28-a89d-af250bc60852
# ╟─ed971d92-5489-4237-915d-ef89e66c66f8
# ╟─6da844ef-1900-4556-9318-01cc257bc05e
# ╟─91106045-43a1-427c-a300-e5200ad112ff
# ╟─8663be81-9919-46a8-977a-1c11bbed0f73
# ╟─6992e045-0daf-46bf-a17d-62ca7945e4af
# ╟─4862cfb9-364b-4d34-9a30-38ce48ce069d
# ╟─2cb438ee-ae5e-4421-bf5c-369154aaef81
# ╟─0f532a5b-741e-4c7c-8742-6108859ebd58
# ╠═ab975494-0a3e-46fe-b3cb-74fa87010018
# ╟─c9a1e998-a378-4d59-90c5-138257ac439e
# ╟─1d12c6dd-7f0a-458c-ad43-9ffdc98acf31
# ╟─60c3954b-d519-4f2b-9faa-efe85e34f774
# ╟─daf5a973-e73e-4a2b-8c6a-15a60f461a07
# ╠═72b1f589-cae8-4ffb-a4d7-a50aeb1898ce
# ╟─f595c7ab-5b6e-441a-b7b3-c804e8e0c7ab
# ╟─79428f16-504e-4551-8289-83e5b86f53e2
# ╟─b777ec82-953b-4688-936d-56c61c6794cd
# ╟─ab416867-38df-466f-a7bf-e36d74070e32
# ╠═d8497cde-7c0c-4e7e-91e0-6afb8d8cb411
# ╟─c722ed1a-83dd-4634-ad4c-4d59738db97a
# ╟─af816df6-6212-44bf-9301-a3dc4e7bf764
# ╟─d0170f42-ce09-41c6-a7e4-86fbca1749ab
# ╟─306f5d53-df88-4af3-bbec-25c947c0cb9f
# ╠═6600061c-d18e-4699-beec-adb58de12f41
# ╟─ea6fb2f4-6455-44af-a574-3768bad151a9
# ╟─49a07a3d-51fa-4f38-b33d-e5127e744b04
# ╠═36a3a18f-7537-46cc-b4f4-1551ae939be5
# ╟─bad4cc28-ad6a-4d1e-9b72-642f394f2374
# ╟─c2e2ec60-4433-43b9-b08e-ecb577900bc4
# ╟─6583d269-9eab-4a0c-b81e-a25d18b3a5c8
# ╟─f9f4361c-ec29-4055-a1da-d3b0f5a20295
# ╟─ba12b93e-83d2-4c8d-91d9-ff98afff6f10
# ╟─6fb1c386-ef44-458e-b3f5-8929309758eb
# ╟─60cecddd-601e-4113-90c5-19d3d045136a
# ╟─1b5114d9-37b0-469a-ab16-02574a5803a0
# ╟─95f1d794-fba6-4743-862b-e2c0a5a0e1ed
# ╟─bfef39eb-e71f-4342-b0b8-6357d00f96c6
# ╟─ed950215-5b2c-4216-b377-881b094f5c91
# ╟─96d04bb5-b8db-4fb3-b4b0-64150fb76a99
# ╟─67ded75a-be8a-4989-976b-d0d9e6b1a3e1
# ╟─094c3ae9-7af0-4dc4-874e-fdad2c18c10d
# ╟─f6e1875e-8780-457b-b7bc-beff24c5ceb9
# ╠═955d45f8-6040-4904-9fc9-ff13ffa41193
# ╟─f13d0c05-44bc-41aa-9476-3f8cd74200f1
# ╟─1a2cc51d-b97f-4192-9284-f94eff0853ba
# ╟─af296256-6662-49e9-b24d-c8550ce39c8d
# ╟─0cebe58b-f1b2-4220-b15c-0f844cf22057
# ╟─0241a8e7-2810-488e-bbc2-38c3da9a431e
# ╟─3f9ee27d-f128-4d42-a144-d3f8856de4d3
# ╟─5e62b60e-6c00-11ec-34fa-4b57e5168947
# ╟─d1dca62c-788e-4d20-a528-dcb8f39a3d53
# ╟─a48e1156-fc46-4b58-b971-9b65b348d64b
# ╟─e6a3536e-dfc1-494b-9b46-c33e22ed79f0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
