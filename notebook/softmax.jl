### A Pluto.jl notebook ###
# v0.12.4

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

# ╔═╡ 58c174f6-347c-11eb-3245-2b0f0eaaf5ac
using Plots, STMOZOO.Softmax, PlutoUI

# ╔═╡ e9eb4324-347b-11eb-3ba0-3948ac778eab
md"""
# Softmax as a MaxEnt model
The [[softmax]] is a popular activation function in machine learning and decision theory. In this project, we show how the softmax arises from a maximum entropy ([[MaxEnt]]) model. Furthermore, we show how we can efficiently sample from this distribution using the [[Gumbel-max trick]].
"""

# ╔═╡ 12e07860-347c-11eb-2620-89d253129c58
md"""
## Choosing items according to utility
Suppose we have a choice out of $n$ options. For example, we might need to choose what to have for dinner from our list or decide which of our many projects we want to spend time on. Not all these options are equally attractive: each option $i$ has an associated utility value $x_i$.

A straightforward decision model might just be choosing the option with the largest utility:

$$\max_{i\in{1,\ldots,n}} x_i\,.$$

This seems sensible though there are drawbacks with this approach:

- What if two options have nearly the same utility values? We would expect that both would have an approximately equal chance of being chosen. This is currently not the case.
- This is not a smooth function! Changing the utility values influences the decision process only if it changes the item with the largest utility value.
- We would like to have items with a lower utility value also be picked, at least some of the times!

In a different approach, we use optimization to choose a decision vector $\mathbf{q}\in\Delta^{n-1}$. In addition to maximizing the *average utility values* $\langle\mathbf{q},\mathbf{x}\rangle$, we also want to optimize the [[entropy]]:

$$H(\mathbf{q}) = -\sum_{i=1}^nq_i\log(q_i)\,.$$

This drives $\mathbf{q}$ to be as uniform as possible and there is a large history why this is a sensible approach. The [[Lagrangian]] of this problem is:

$$L(\mathbf{q};\kappa, \nu)=H(\mathbf{q}) + \kappa(\langle\mathbf{q},\mathbf{x}\rangle-u_\text{min}) + \nu(\sum_{i=1}^nx_i -1)\,.$$

Computing the partial derivative w.r.t. $q_i$:

$$\frac{\partial L(\mathbf{q};\kappa, \nu)}{\partial q^\star_i}=-\log(q^\star_i) - 1 + \kappa x_i + \nu=0$$

and setting equal to 0 we have

$$q^\star_i\propto \exp(\kappa x_i)\,.$$

So, keeping the $\mathbf{q}$ normalized, we obtain the *softmax*:

$$q_i = \frac{\exp(\kappa x_i)}{\sum_j\exp(\kappa x_j)}\,.$$

Here, $\kappa\ge 0$ is a tuning parameter that determines the dependency on utility.
"""

# ╔═╡ 60c00938-347c-11eb-2f77-4388badf9113
md"Here is an example using dinners with their respective preferences."

# ╔═╡ 36144028-347c-11eb-1734-f527482a6048
dinners_preference = [("rice-lentils", 10.0),
		("dhal", 6.0),
		("spaghetti", 8.5),
		("chinese", 7.5),
		("fries", 8.0),
		("ribhouse", 9.5),
		("hamburger", 8.0),
		("pitta", 6.0),
		("noodles", 7.0),
		("chicken", 8.0),
		("curry", 7.5),
		("pizza (veg)", 7.0),
		("pizza", 8.0)
	]

# ╔═╡ 418c6d2c-347c-11eb-0c11-db8d090c5953
dinners = first.(dinners_preference)

# ╔═╡ 50208e18-347c-11eb-1628-6d9587fdf00f
preferences = last.(dinners_preference)

# ╔═╡ 5d734344-347c-11eb-2c10-b5c0adfac424
bar(dinners, preferences)

# ╔═╡ a7bee2aa-347c-11eb-109b-f39f17158444
@bind κ Slider(0.01:0.1:10, default=1)

# ╔═╡ adc7a786-347c-11eb-175f-db354866f500
q = softmax(preferences; κ=κ)

# ╔═╡ d81e8afe-347c-11eb-2c13-a5a3219051ae
bar(dinners, q)

# ╔═╡ 997c7554-347c-11eb-322e-27691246c726
md"""
## Gumbel max trick

Given the optimal choice distribution $\mathbf{q}$, how can we sample choices from this?  Using the [[Gumbel-max trick]]! This is a simple way to [[sampling|sample]] form a discrete [[probability]] distributions determined by unnormalized log-probabilities, i.e.

$$p_k\sim \exp(x_k)$$

Just use

$$y=\text{argmax}_{i\in 1,\ldots, K} x_i + g_i$$

where $g_i$ follows a [[Gumbel distribution]].
"""

# ╔═╡ 73a46a84-347d-11eb-10fa-3365cbee1205
gumbel_max(dinners, preferences)

# ╔═╡ 80e7b656-347d-11eb-2546-a36f30213001
sampled_dinners = [gumbel_max(dinners, preferences) for i in 1:1000]

# ╔═╡ Cell order:
# ╟─e9eb4324-347b-11eb-3ba0-3948ac778eab
# ╟─12e07860-347c-11eb-2620-89d253129c58
# ╟─60c00938-347c-11eb-2f77-4388badf9113
# ╠═36144028-347c-11eb-1734-f527482a6048
# ╠═418c6d2c-347c-11eb-0c11-db8d090c5953
# ╠═50208e18-347c-11eb-1628-6d9587fdf00f
# ╠═58c174f6-347c-11eb-3245-2b0f0eaaf5ac
# ╠═5d734344-347c-11eb-2c10-b5c0adfac424
# ╠═a7bee2aa-347c-11eb-109b-f39f17158444
# ╠═adc7a786-347c-11eb-175f-db354866f500
# ╠═d81e8afe-347c-11eb-2c13-a5a3219051ae
# ╟─997c7554-347c-11eb-322e-27691246c726
# ╠═73a46a84-347d-11eb-10fa-3365cbee1205
# ╠═80e7b656-347d-11eb-2546-a36f30213001
