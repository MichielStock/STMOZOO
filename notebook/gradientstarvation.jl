### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ df218f5d-042d-4ccb-8005-56b2ec073869
html"""
<big><span style="color:red">This is still work in progress!</span></big>
"""

# ╔═╡ 8bd774c7-1acf-4beb-bc99-4c303882d262
md"""
# Hungry Neurons - Neural Networks and Gradient Starvation

## Introduction

Artificial intelligence (AI) and machine learning are disciplines whose methods have become ubiquitously applied in a broad range of scientific domains, enabling the implicit learning of features inherent to a dataset. A common AI tool for self-learning of data characteristics by examples are neural networks (NNs) which attempt to mimic biological neurons. NNs are broadly applicable, e.g. for tasks such as image and speech recognition, weather forecasting, stock market prediction, robotics and data mining among many others. But how do these artificial neural networks learn?
There is a myriad of neural network subtypes and topologies, but in this notebook, I want to focus on the multi-layer perceptron (MLP). Basically speaking, a NN consists of multiple layers: an input layer, one or more hidden layers and an output layer (see figure 1).

"""

# ╔═╡ 8f0cdbf1-0174-4d18-9072-2a8c5f015177
html"""
<img 
	style="display: block; 
           margin-left: auto;
           margin-right: auto;
           width: 50%;"
	src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Artificial_neural_network.svg/538px-Artificial_neural_network.svg.png" 
    alt="An image visualizing a basic NN topology with an input layer, a single hidden layer and an output layer">
</img>
"""

# ╔═╡ 6a79cfe1-12f9-4ae0-a917-14b4f3a1b31b
md"""Figure 1: Basic NN/MLP topology with input, a single hidden and output layer.

CC-BY-SA 3.0. Source: [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Artificial_neural_network.svg)"""

# ╔═╡ 512e6240-76e7-11ec-2511-07ffc4b74d27
md"""
The input layer encodes the data presented to the network and feeds it weighted into the first hidden layer; all other layers consist of artificial neurons with non-linear activation functions. MLPs are fully connected, meaning that every node of one layer connects to every node of the next layer and each connection has a weight assigned to it. The weights can be understood as the actual learned parameters being adjusted as they get passed from layer to layer. The MLP learns supervised, i.e. by presentation of labelled training data. Without going into too much detail, I want to briefly formalize the learning process by the example of a classification task, that is deciding to which discrete class a given input belongs.
"""

# ╔═╡ 93bc80a8-673d-457b-96d8-e1bb0b09682e
md"""
### Supervised Learning – Learning from Examples

Supervised learning tries to learn a function which maps input to output values based on known input-output pairs (i.e. the pair (x, y); a correct classification y for a given input x). The observed outputs $y_i$ originate from an unknown function $f(x) = y$. Thus, the goal of the learning process is to approximate $f(x)$ by a hypothesis $h(x) \approx f(x)$. The loss is defined as the utility lost by substituting the correct classification $f(x) = y$ by the hypothesis $h(x) = \hat{y}$:

$L(x, y, ŷ) = 
Utility\\(result\ of\ using\ y\ given\ x\\) 
- Utility\\(result\ of\ using\ ŷ\ given\ x\\)$ 

Commonly applied loss functions are mean absolute error and mean squared error loss. Especially popular for classification tasks is the cross-entropy loss, also called logarithmic loss:

$L(y, ŷ) = -\sum_{i}y_i\cdot log(ŷ_i)$

The learning process maximizes the expected utility through choosing the optimal hypothesis by minimizing the loss function. In practice, this is estimated by the empirical loss observed on the set $X$ of $N$ training examples.

$EmpiricalLoss(h) = \frac{1}{N}\cdot\sum_{(x, y) \in X} L(y, h(x))$

But what about the weights I’ve introduced earlier as the “actual learned parameters”? Keep in mind that a hypothesis $h$ is a function and the weights simply represent the function coefficients. For the linear case that would mean $h(x) = w_1 x + w_0$.
In the multivariate case there is no closed-form solution for the minimum loss. Therefore, we are confronted with an optimization problem which can be solved by gradient descent. The weight update with learning rate $\alpha$ and the vector of weights $\bf{w}$:
 
$w_i = w_i - \alpha\cdot \frac{\partial}{\partial w_i}\cdot Loss(\bf{w})$

"""

# ╔═╡ 66a3b5cb-a465-42fb-a8c8-404d574312d2
md"""
### Regularization


> "Entities should not be multiplied beyond necessity." – William of Ockham
This quote, known as Ockham’s razor and usually paraphrased as “simple solutions are better solutions” captures the core idea of regularization. The aim is to find the hypothesis which minimizes the total cost, defined as the sum of empirical loss and its complexity:

$Cost(h) = EmpiricalLoss(h) + \lambda\cdot Complexity(h)$

Regularization penalizes complex hypotheses and favors more regular functions. The estimated best hypothesis $ĥ^*$ from the hypothesis space $\mathcal{H}$ as determined by regularization is:

$ĥ^* = \arg\min_{h \in \mathcal{H}} Cost(h)$
"""

# ╔═╡ 4a14831d-7736-4af5-875f-05ae6e3cf7c4
md"""
### Side Effects of Gradient-based Learning

Given the major workings of supervised learning, it should have become clear that learning is a mathematical optimization problem. A classic way to achieve the minimization of the loss is the application of gradient descent.

Despite its popularity, gradient descent learning in NNs can come with some unwanted side effects such as the vanishing gradient problem, which condenses down to the gradient being too small to effectively update a weight and thus preventing learning.

Another not yet published but currently in preprint described observation is the effect of **Gradient Starvation (GS)**. Pezeshki et al. coined and formalized this phenomenon of over-parameterized NNs in their work. According to them, _Gradient Starvation_ is a predisposition of NNs learned by cross-entropy, which occurs when the loss minimization is driven by only a feature subset regardless of the presence of other meaningful features. Thus, the NN becomes biased towards superficial features. Beyond demonstrating the effects of GS, Pezeshki et al. introduce _Spectral Decoupling_ (SD) regularization as a means to counteract gradient starvation.
"""

# ╔═╡ 00d4161d-6f8f-42d6-8f13-7d5aa7e70ab3
md"""
### Objective

My project and thereby this notebook aims to reproduce and demonstrate the effects of Gradient Starvation on a simple 2D classification task. Furthermore, the proposed regularization method of Spectral Decoupling is implemented and compared to other regularization methods. Finally, the framework is extended to a more complex task on the well-known MNIST dataset.

"""

# ╔═╡ ac02597f-a7ca-4ede-ab8a-c0739c60d0d5
md"""
## Experiments

### 2D Classification
A modified version of the [Moons dataset](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.make_moons.html) was used with two different topologies. The first represents the fully linearly separable case, thus allows to differentiate the two moons by a straight line along one axis. The second topolgy uses an offset to interleave both moons which only allows to separate them by learning a curved classification boundary. Pezeshki et al. 
"""

# ╔═╡ 85591d79-dec2-45fa-a0a9-d95d84edda51
md"""
## Implementation
The implementation of the NN is closely related to the one of Pezeshki et al. who realized theirs with Python and PyTorch. The implementation provided here is based on [Flux](https://fluxml.ai/), a ML framework for Julia. The NN consists of two hidden layers with 500 nodes each. Rectified Linear Unit (ReLu) is used as an activation function and learning is facilitated with cross-entropy loss.
"""

# ╔═╡ 92cca2d8-c2b6-4046-9b86-26c5c9d64ee3
md"## Conclusion"

# ╔═╡ 88b30b55-4f98-474a-aaca-a1197d2886fd
md"## Code"

# ╔═╡ c95db58c-9d47-4ef0-9ede-234d7a693f41
md"""
### References
Pezeshki, M., Kaba, S. O., Bengio, Y., Courville, A., Precup, D., & Lajoie, G. (2020). Gradient starvation: A learning proclivity in neural networks. arXiv preprint arXiv:2011.09468.

Pizurica, A. (2020). E016330: Artificial Intelligence – Learning from examples [PDF course notes]. Ufora.

Pizurica, A. (2020). E016330: Artificial Intelligence - Neural networks [PDF course notes]. Ufora.

Russell, S., & Norvig, P. (2002). Artificial intelligence: a modern approach. 
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[deps]
"""

# ╔═╡ Cell order:
# ╟─df218f5d-042d-4ccb-8005-56b2ec073869
# ╟─8bd774c7-1acf-4beb-bc99-4c303882d262
# ╟─8f0cdbf1-0174-4d18-9072-2a8c5f015177
# ╟─6a79cfe1-12f9-4ae0-a917-14b4f3a1b31b
# ╟─512e6240-76e7-11ec-2511-07ffc4b74d27
# ╟─93bc80a8-673d-457b-96d8-e1bb0b09682e
# ╟─66a3b5cb-a465-42fb-a8c8-404d574312d2
# ╠═4a14831d-7736-4af5-875f-05ae6e3cf7c4
# ╟─00d4161d-6f8f-42d6-8f13-7d5aa7e70ab3
# ╠═ac02597f-a7ca-4ede-ab8a-c0739c60d0d5
# ╠═85591d79-dec2-45fa-a0a9-d95d84edda51
# ╠═92cca2d8-c2b6-4046-9b86-26c5c9d64ee3
# ╠═88b30b55-4f98-474a-aaca-a1197d2886fd
# ╟─c95db58c-9d47-4ef0-9ede-234d7a693f41
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
