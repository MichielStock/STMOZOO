### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ ab3fd4ba-3d6c-4298-8a12-295a1ff0af73
using PlutoUI, HTTP

# ╔═╡ 9c2b64cf-c236-46aa-a4d6-02a22c5b7faa
using Distributions

# ╔═╡ c5ef7103-4aca-49dc-b49b-4cf5ac157701
using Random.Random

# ╔═╡ f126a1f8-afc6-4b52-9021-39e946dd0ea2
md"""
# Cross-Entropy Method

STMO Exam Project by **Ceri-Anne Laureyssens**
"""

# ╔═╡ c629d020-2c17-477c-8517-68c39f46fbcb
md"""
### Cross-entropy

As the title states the method has to do with the cross-entropy. It's a metric used to measure the Kullback-Leibler (KL) distance between two probability distributions. These two distributions, as you will read later on, are in fact the original distribution (f) and the *upgraded* distribution based on elite samples (g). This KL distance or relative entropy can be easily used to derive the cross-entropy itself and is defined as follows:

```math 
\begin{equation}
D_{KL}(f,g) = E_f[\log\frac{f(X)}{g(X)}]
= \int_{x\in χ} f(x)\log f(x)dx - \int_{x\in χ} f(x)\log g(x)dx
\end{equation}
```

With D being the KL distance, E the expectation, and X a random variable with support χ. 

Minimizing this KL distance in between distribution f and g (parameterized by θ) is equivalent to choosing θ that minimizes the cross-entropy:

```math 
\begin{equation}
H(f,g) = H(f) + D_{KL}(f,g)
= -E_f[\log g(X)]
= -\int_{x\in χ} f(x)\log g(x|θ)dx
\end{equation}
```

With H(f) being the entropy of distribution f.

This assumes that f and g share the support χ and are continuous with respect to x. The minimization problem becomes the following:

```math 
\begin{equation}
minimize_θ - \int_{x\in χ} f(x)\log g(x|θ)dx
\end{equation}
```

Finding this minimum is the goal of the method explained in the next section.
"""

# ╔═╡ 2c923610-52c4-11ec-367b-2565c12740ab
md"""
### Method description and implementation

The cross-entropy or CE method is a Monte Carlo method for importance sampling and optimization.
Monte-Carlo algorithms rely on repeated sampling to obtain numerical results and use randomness as underlying concept to solve the given problem.

The CE method can be used for both combinatorial as continuous problems, with either a static or noisy objective, and is also a valuable asset in rare-event simulation. 

The simple two-step process involves generating a random data sample according to a specified mechanism and updating the parameters of the mechanism based on the data to produce a better sample in the next iteration as can be seen in the figure underneath.
"""

# ╔═╡ 7fff9ca4-73aa-462a-ab69-4d8b997e1d01
#begin
#	using Images
#	load("./figures/CE_visual.png")
#end

# ╔═╡ 9b4da26a-6136-4be7-b3d8-ad573a89c7f9
md"""
![](https://github.com/CeriAnneLaureyssens/CrossEntropy.jl/tree/master/notebook/figures/CE_visual.png)

We start with a specified distribution in the left panel from which a fixed amount of samples are randomly derived. These randomly derived samples can be seen in the middle panel. The cross-entropy method makes use of an objective function (S) which minimizes the cross-entropy between the known distribution f and a proposal distribution g parameterized by θ.

```math 
\begin{equation}
θ_g^* = \text{argmin}_{θ_g} - \int_{x\in χ} I_{(S(x)≥γ)}g(x|θ) \log g(x|θ_g)dx
= \text{argmin}_{θ_g} - E_θ[I_{(S(x)≥γ)} \log g(x|θ_g)]
\end{equation}
```

With I being the indicator function, and γ a threshold with which elite samples are determined.

The grey dots indicate the elite samples. One becomes the elite samples by sorting the outcome of the objective function (done for every sample in the distribution). These elite samples are then selected as the samples of the new distribution, which can be seen in the third panel, and the whole process, starting from the left panel, is repeated until the distribution is optimized.
"""

# ╔═╡ aba389ff-77b4-4683-9e41-35e8dc429797
md"""
*θ gstar* is estimated iteratively via the algorithm underneath which runs *max_iter* times. The parameters *θ iteration'* are defined based on the parameter *θ iteration*. The threshold *γ iteration* becomes smaller than its initial value, artificially making events less rare under X ~ g(x|*θ iteration*).
"""

# ╔═╡ 4115dcd8-9931-4871-bc32-5e6e08450242
md"""
### Tests
"""

# ╔═╡ 04ef2558-ff4b-4a2d-9f59-2f8b6edde3f0
md"""
# Appendices
"""

# ╔═╡ abb2b875-0439-49f8-accd-5475ae388a67
function Distributions.logpdf(d::Dict{Symbol, Vector{Sampleable}}, x, i)
    sum([logpdf(d[k][i], x[k][i]) for k in keys(d)])
end

# ╔═╡ dbcf3ddc-f4ad-40ed-8c0f-3d7ace8b5069
function Distributions.logpdf(d::Dict{Symbol, Vector{Sampleable}}, x)
    sum([logpdf(d, x, i) for i=1:length(first(x)[2])])
end

# ╔═╡ aeb1f33e-1b4b-4808-bcee-79e8c5e4438f
function Distributions.logpdf(d::Dict{Symbol, Tuple{Sampleable, Int64}}, x, i)
    sum([logpdf(d[k][1], x[k][i]) for k in keys(d)])
end

# ╔═╡ fcb9f3ce-c23a-41ee-9ad2-eaea4699d5bd
function Distributions.logpdf(d::Dict{Symbol, Tuple{Sampleable, Int64}}, x)
    sum([logpdf(d, x, i) for i=1:length(first(x)[2])])
end

# ╔═╡ c81f3bd0-b576-467c-8621-21e75fa587a5
function Base.rand(rng::AbstractRNG, d::Dict{Symbol, Vector{Sampleable}})
    Dict(k => rand.(Ref(rng), d[k]) for k in keys(d))
end

# ╔═╡ 452fb99f-349e-45b0-bdf8-ada524b6d0db
function Base.rand(rng::AbstractRNG, d::Dict{Symbol, Tuple{Sampleable, Int64}})
    Dict(k => rand(rng, d[k][1], d[k][2]) for k in keys(d))
end

# ╔═╡ 05cf58ae-b9f7-4f69-b7e7-64586f1e27a8
function Base.rand(rng::AbstractRNG, d::Dict{Symbol, Vector{Sampleable}}, N::Int)
    [rand(rng, d) for i=1:N]
end

# ╔═╡ 88ea50a3-02bd-4a90-8d72-cf571273ba7f
function Base.rand(rng::AbstractRNG, d::Dict{Symbol, Tuple{Sampleable, Int64}}, N::Int)
    [rand(rng, d) for i=1:N]
end

# ╔═╡ 028f3359-5335-4a13-9b3d-f23084087b8e
function Distributions.fit(d::Dict{Symbol, Vector{Sampleable}}, samples, weights; add_entropy = (x) -> x)
    N = length(samples)
    new_d = Dict{Symbol, Vector{Sampleable}}()
    for s in keys(d)
        dtype = typeof(d[s][1])
        m = length(d[s])
        new_d[s] = [add_entropy(fit(dtype, [samples[j][s][i] for j=1:N], weights)) for i=1:m]
    end
    new_d
end

# ╔═╡ 199c2691-aeb2-4d0a-b30e-2dd130493038
function Distributions.fit(d::Dict{Symbol, Tuple{Sampleable, Int64}}, samples, weights; add_entropy = (x)->x)
    N = length(samples)
    new_d = Dict{Symbol, Tuple{Sampleable, Int64}}()
    for s in keys(d)
        dtype = typeof(d[s][1])
        m = d[s][2]
        all_samples = vcat([samples[j][s][:] for j=1:N]...)
        all_weights = vcat([fill(weights[j], length(samples[j][s][:])) for j=1:N]...)
        new_d[s] = (add_entropy(fit(dtype, all_samples, all_weights)), m)
    end
    new_d
end

# ╔═╡ 6259dd44-2c35-4faf-b340-c69070e7fc48
# This version uses a vector of distributions for sampling
# N is the number of samples taken
# m is the length of the vector

# if batched is set to true, loss function must return an array containing loss values for each sample   
function cross_entropy_method(loss,
                              d_in;
                              max_iter,
                              N=100,
                              elite_thresh = -0.99,
                              min_elite_samples = floor(Int, 0.1*N),
                              max_elite_samples = typemax(Int64),
                              weight_fn = (d,x) -> 1.,
                              rng::AbstractRNG = Random.GLOBAL_RNG,
                              verbose = false,
                              show_progress = false,
                              batched = false,
                              add_entropy = (x)->x
                             )
    d = deepcopy(d_in)
    show_progress ? progress = Progress(max_iter) : nothing

    for iteration in 1:max_iter
        # Get samples -> Nxm
        samples = rand(rng, d, N)

        # sort the samples by loss and select elite number
        if batched
            losses = loss(d,samples)
        else
            losses = [loss(d, s) for s in samples]    
        end
        
        order = sortperm(losses)
        losses = losses[order]
        N_elite = losses[end] < elite_thresh ? N : findfirst(losses .> elite_thresh) - 1
        N_elite = min(max(N_elite, min_elite_samples), max_elite_samples)

        verbose && println("iteration ", iteration, " of ", max_iter, " N_elite: ", N_elite)

        # Update based on elite samples
        elite_samples = samples[order[1:N_elite]]
        weights = [weight_fn(d, s) for s in elite_samples]
        if all(abs.(weights) .< 1e8)
            println("Warning: all weights are zero")
        end
        d = fit(d, elite_samples, weights, add_entropy = add_entropy)
        show_progress && next!(progress)
    end
    d
end

# ╔═╡ d60f308c-72c0-4eff-8b21-23ef6803be8d
# Gets a function that adds entropy h to categorical distribution c
function add_categorical_entropy(h::Vector{Float64})
    function add_entropy(c::Categorical)
        p = h
        p[1:length(c.p)] .+= c.p
        Categorical(p ./ sum(p))
    end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Distributions = "~0.25.37"
HTTP = "~0.9.17"
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

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

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "6a8dc9f82e5ce28279b6e3e2cea9421154f5bd0d"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.37"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

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

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "ee26b350276c51697c9c2d88a072b339f9f03d73"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.5"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "92f91ba9e5941fc781fecf5494ac1da87bdac775"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

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

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

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

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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
git-tree-sha1 = "bedb3e17cc1d94ce0e6e66d3afa47157978ba404"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.14"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

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

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═ab3fd4ba-3d6c-4298-8a12-295a1ff0af73
# ╟─f126a1f8-afc6-4b52-9021-39e946dd0ea2
# ╟─c629d020-2c17-477c-8517-68c39f46fbcb
# ╟─2c923610-52c4-11ec-367b-2565c12740ab
# ╠═7fff9ca4-73aa-462a-ab69-4d8b997e1d01
# ╠═9b4da26a-6136-4be7-b3d8-ad573a89c7f9
# ╟─aba389ff-77b4-4683-9e41-35e8dc429797
# ╠═6259dd44-2c35-4faf-b340-c69070e7fc48
# ╟─4115dcd8-9931-4871-bc32-5e6e08450242
# ╟─04ef2558-ff4b-4a2d-9f59-2f8b6edde3f0
# ╠═9c2b64cf-c236-46aa-a4d6-02a22c5b7faa
# ╠═abb2b875-0439-49f8-accd-5475ae388a67
# ╠═dbcf3ddc-f4ad-40ed-8c0f-3d7ace8b5069
# ╠═aeb1f33e-1b4b-4808-bcee-79e8c5e4438f
# ╠═fcb9f3ce-c23a-41ee-9ad2-eaea4699d5bd
# ╠═c5ef7103-4aca-49dc-b49b-4cf5ac157701
# ╠═c81f3bd0-b576-467c-8621-21e75fa587a5
# ╠═452fb99f-349e-45b0-bdf8-ada524b6d0db
# ╠═05cf58ae-b9f7-4f69-b7e7-64586f1e27a8
# ╠═88ea50a3-02bd-4a90-8d72-cf571273ba7f
# ╠═028f3359-5335-4a13-9b3d-f23084087b8e
# ╠═199c2691-aeb2-4d0a-b30e-2dd130493038
# ╠═d60f308c-72c0-4eff-8b21-23ef6803be8d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
