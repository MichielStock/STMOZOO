### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 5c563230-df6e-4f65-a106-a707d2454fe7
using PlutoUI

# ╔═╡ 8bd774c7-1acf-4beb-bc99-4c303882d262
md"""
# Starving Neurons - Neural Networks and Gradient Starvation

Author: Peter Merseburger

## Introduction

Artificial intelligence (AI) and machine learning are disciplines whose methods have become ubiquitously applied in a broad range of scientific domains, enabling the implicit learning of features inherent to a dataset. A common AI tool for self-learning of data characteristics by examples are neural networks (NNs) which attempt to mimic biological neurons. NNs are broadly applicable, e.g. for tasks such as image and speech recognition, weather forecasting, stock market prediction, robotics and data mining among many others. But how do these artificial neural networks learn?
There is a myriad of neural network subtypes and topologies, but in this notebook, I want to focus on the multi-layer perceptron (MLP).

Basically speaking, a NN consists of multiple layers: an input layer, one or more hidden layers and an output layer (see fig. 1).

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
md"""
Figure 1: Basic NN/MLP topology with input, a single hidden and output layer. 
CC-BY-SA 3.0. Source: [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Artificial_neural_network.svg)
"""

# ╔═╡ 512e6240-76e7-11ec-2511-07ffc4b74d27
md"""
The input layer encodes the data presented to the network and feeds it weighted into the first hidden layer; all other layers consist of artificial neurons with non-linear activation functions. MLPs are fully connected, meaning that every node of one layer connects to every node of the next layer and each connection has a weight assigned to it. The weights can be understood as the actual learned parameters being adjusted as they get passed from layer to layer. The MLP learns supervised, i.e. by presentation of labelled training data. Without going into too much detail, I want to briefly formalize the learning process by the example of a classification task, that is deciding to which discrete class a given input belongs. This is exactly the use case we will evaluate later on.
"""

# ╔═╡ 93bc80a8-673d-457b-96d8-e1bb0b09682e
md"""
### Supervised Learning – Learning from Examples

Supervised learning tries to learn a function which maps input to output values based on known input-output pairs (i.e. the pair ($x$, $y$); a correct classification $y$ for a given input $x$). The observed outputs $y$ originate from an unknown function $f(x) = y$. Thus, the goal of the learning process is to approximate $f(x)$ by a hypothesis $h(x) \approx f(x)$ while minimizing the error of the approximation, referred to as loss. More formally, the loss is defined as the utility lost by substituting the correct classification $f(x) = y$ by the hypothesis $h(x) = \hat{y}$:

$L(x, y, ŷ) = \text{Utility(result of using}\ y\ \text{given}\ x\\) 
- \text{Utility(result of using}\ ŷ\ \text{given}\ x\\)$ 

Commonly applied loss functions are the mean absolute error and mean squared error loss. Especially popular for classification tasks is the cross-entropy loss, also called logarithmic loss:

$L(y, ŷ) = -\sum_{i}y_i\cdot \log(ŷ_i)$

The learning process maximizes the expected utility through choosing the optimal hypothesis by minimizing the loss function. In practice, this is estimated by the empirical loss observed on the set $X$ of $N$ training examples.

$\text{EmpiricalLoss}(h) = \frac{1}{N}\cdot\sum_{(x, y) \in X} L(y, h(x))$

But what about the weights I’ve introduced earlier as the “actual learned parameters”? Keep in mind that a hypothesis $h$ is a function and the weights simply represent the function coefficients. For the linear case that would mean $h(x) = w_1 x + w_0$.
In the multivariate case there is no closed-form solution for the minimum loss. Therefore, we are confronted with an optimization problem which can be solved by gradient descent. The weight update with learning rate $\alpha$ and the vector of weights $\bf{w}$ looks like this:
 
$w_i = w_i - \alpha\cdot \frac{\partial}{\partial w_i}\cdot \text{Loss}(\bf{w})$

"""

# ╔═╡ 66a3b5cb-a465-42fb-a8c8-404d574312d2
md"""
### Regularization

> "Entities should not be multiplied beyond necessity." – William of Ockham
This quote, known as Ockham’s razor and usually paraphrased as “simple solutions are better solutions” captures the core idea of regularization. The aim of regularization is to find the hypothesis which minimizes the total cost, defined as the sum of empirical loss and its complexity:

$\text{Cost}(h) = \text{EmpiricalLoss}(h) + \lambda\cdot \text{Complexity}(h)$

Regularization penalizes complex hypotheses (mind the added regularization term in the formula $\lambda\cdot \text{Complexity}(h)$) and favors more regular functions. It limits the values that the weights can take during the learning process. Therefore, regularization avoids overfitting of the data.
The estimated best hypothesis $ĥ^*$ from the hypothesis space $\mathcal{H}$ now becomes:

$ĥ^* = \arg\min_{h \in \mathcal{H}} \text{Cost}(h)$

### Optimization
Given the major workings of supervised learning, it should have become clear that learning is a mathematical optimization problem. A classic way to achieve the minimization of the cost is the application of gradient descent (GD). However, the path the gradient take on the surface of the solution space can limit its ability to find the global optimum. To conquer that, the steps can be modified by additional optimization methods. Common choices for that purpose are the addition of momentum, resulting in stochastic gradient descent (SGD); an adaptive learning rate, different forms of parameter initialization as well as normalization techniques.
"""

# ╔═╡ 4a14831d-7736-4af5-875f-05ae6e3cf7c4
md"""
### Side Effects of Gradient-based Learning
Despite its popularity, gradient descent learning in NNs can come with some unwanted side effects such as the vanishing gradient problem, which condenses down to the gradient being too small to effectively update a weight and thus preventing learning. This phenomenon is complemented in the other direction by exploding gradients.

Another not yet published but currently in preprint described observation is the effect of [**_Gradient Starvation_ (GS)**](https://arxiv.org/abs/2011.09468). Pezeshki et al. coined and formalized this phenomenon of over-parameterized NNs in their work. According to them, _Gradient Starvation_ is a predisposition of NNs learned by cross-entropy, which occurs when the loss minimization is driven by only a feature subset regardless of the presence of other meaningful features. Thus, the NN becomes biased towards superficial features. Beyond demonstrating the effects of GS, Pezeshki et al. introduce **_Spectral Decoupling_ (SD)** regularization as a means to counteract gradient starvation.
"""

# ╔═╡ 60905936-9373-44de-96e6-cb5d6dd72d33
md"""
### Spectral Decoupling
Proceeding from the popular "ridge-regularized cross entropy":

$\mathcal{L}(\boldsymbol{θ}) = \boldsymbol{1} \cdot \log(1 + \exp(-\boldsymbol{Y}\boldsymbol{ŷ})) + \frac{λ}{2} ||\boldsymbol{θ}||^2$

with $\boldsymbol{Y}$ the diagonal matrix of $y$ and $\boldsymbol{θ}$ the concatenation of all layer's weights, SD is a variation where the L2 regularization term is replaced by a penalty on the raw predictions $\boldsymbol{ŷ}$:

$\mathcal{L}(\boldsymbol{θ}) = \boldsymbol{1} \cdot \log(1 + \exp(-\boldsymbol{Y}\boldsymbol{ŷ})) + \frac{λ}{2} ||\boldsymbol{ŷ}||^2$

This, as stated by the Pezeshki et al., uncouples the learning of multiple features. According to their work, a feature trained close to its optimum inhibits (starves) the training of other features which is thus prevented by SD.
"""

# ╔═╡ 00d4161d-6f8f-42d6-8f13-7d5aa7e70ab3
md"""
### Objective

My project and thereby this notebook aims to reproduce and demonstrate the effects of GS on a simple 2D classification task. Furthermore, the proposed SD regularization method is implemented and compared to other methods. On top of that, spectral decoupling is not only applied in the context of SGD but all other investigated optimization approaches.
"""

# ╔═╡ ac02597f-a7ca-4ede-ab8a-c0739c60d0d5
md"""
### Waning or Waxing Moon? A 2D Classification Experiment
A modified version of the [Moons dataset](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.make_moons.html) was used with two different topologies as exemplified in figure 1.
The first topology allows to draw a line by a very small margin between the two moons. Therefore, it represents the fully linearly separable case (fig. 1, left). The second one applies a smaller offset to interleave both moons which only allows to separate them by learning a curved classification boundary (fig. 1, right). The task of the NN is to discriminate if a given data point belongs to the waning (blue) or waxing moon (red).
"""

# ╔═╡ 2f766a9c-de6e-4f95-aa73-aacb486aaf61
md"""
$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/figure_1_edited.png"))
Figure 1: Two moons topologies; one linear separable (offset Δ1.0), the other separable by a curved boundary (offset Δ0.5).
"""

# ╔═╡ 7f7ed965-fa08-4d6f-8908-dfc8876bdd02
md"""
The reasoning of the researchers was that in the linear separable case the NN is not encouraged to learn a curved decision boundary because the loss becomes negligible by only discriminating the two moons along one axis, therefore learning only one feature and neglecting the other. In contrast to that, the interleaved moons can only be separated by learning both features which better accommodates the curvatures of the data structure in general.
They observed that a different choice of regularization and optimization methods like weight decay (WD) and _Adaptive Moment Estimation_ (ADAM), among others, are not able to stimulate the NN to learn a curved decision boundary.
Moreover, Pezeshki et al. explained that circumstance by cross-entropy loss learning which starves the gradients from the other feature, only reinforcing the superficial one.

#### Repercussions of Gradient Starvation
Why does the shape of the decision boundary even matter as long as it discriminates the data points confidently? As stated by the authors, GS results in a very small distance between the data points and the boundary which translates into a lack of robustness when generalizing to new data. Contrarily, GS could also have a positive effect in terms of preventing overfitting by not learning non-dominant features. The authors made the comparison to the aformentioned Ockham's razor: GS leads to simpler decision boundaries and hence NNs that generalize better, thus GS being a form of implicit regularization.

#### Implementation
The implementation is based on [Flux](https://fluxml.ai/), a ML framework for Julia. The NN consists of two hidden layers with 500 nodes each. Rectified Linear Unit (ReLu) is used as an activation function and learning is facilitated by cross-entropy loss for 1000 epochs on a data set with 300 observations (150 blue and 150 red points). In contrast to Pezeshki et al., I've opted to train in batches of 50 (6 batches in total) since this is a common practice for training NNs.
All networks are trained with gradient descent but with different regularization and optimization approaches. This yields the following different setups:
- Gradient descent (GD; no regularization/optimization)
- Gradient descent with momentum (stochastic gradient descent (SGD); no regularization)
- Gradient descent with weight decay (WD; L2 regularization)
- Gradient descent with _Adaptive Moment Estimation_ (ADAM; no regularization)

Different sets of hyperparameters were evaluated while tinkering with the NNs. However, since the main objective is to reproduce the research conducted by Pezeshki et al., their set of hyperparameters were used:
- learning rate = 0.01
- weight decay coefficient = 0.01
- spectral decoupling coefficient = 0.003
"""

# ╔═╡ 88ddf822-622b-4d46-a0a4-a7d749c8bc48
md"""
#### Results
"""

# ╔═╡ 884bc572-9daa-40ad-8d76-56ec58728f63
md"""
##### Linear separable case
$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/GD_%CE%941.0.png"))
Figure 2: GD, moon offset = Δ1.0. The decision boundary is almost linear and the loss continuously falls while training. Accuracy reaches 100%.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/SGD_%CE%941.0.png"))
Figure 3: SGD, moon offset = Δ1.0. The decision boundary is similar to the one learned with GD but equally distant from both classes. Loss declines quicker and reaches an overall lower level compared to GD. Accuracy reaches 100% after less training.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/WD_%CE%941.0.png"))
Figure 4: WD, moon offset = Δ1.0, WD coefficient = 0.01. The boundary is similar to GD without WD.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/ADAM_%CE%941.0.png"))
Figure 5: ADAM, moon offset = Δ1.0. The decision boundary is slightly curved around the data points closest to the boundary. Loss converges to zero almost immediately while full accuracy is attained. 
"""

# ╔═╡ ac453412-0f71-45ee-aefb-0cc519467c6c
md"""
As we can see from figures 2 to 5, the decision boundaries of all networks exhibit some specificities. The GD network learned an almost linear decision boundary which appears to be closer to the blue-labeled moon. The boundary looks similar with SGD, but its distance to both moons is equal. Only the network with ADAM optimization learns a slight curvature around the points closest to the boundary. Furthermore, the ADAM classification learned the fastest as can be seen from the rapid decrease in loss and increase in accuracy. At the same time, the contour lines all closely condense around the decision boundary which indicates that the ADAM network is most confident in discriminating both classes.
"""

# ╔═╡ 5e282e1a-62fc-4911-9b7e-f2631eeb2669
md"""
##### Linear inseparable case

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/GD_%CE%940.5.png"))
Figure 6: GD, moon offset = Δ0.5. The network fails to learn a decision boundary to separate the two classes within the 1000 training iterations.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/SGD_%CE%940.5.png"))
Figure 7: SGD, moon offset = Δ0.5. The network learns a curved decision boundary which is very close to the interleaving data points. Loss becomes negligible during learning.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/WD_%CE%940.5.png"))
Figure 8: WD, moon offset = Δ0.5. The network fails to learn a decision boundary to separate the two classes. Again, similar result compared to GD.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/ADAM_%CE%940.5.png"))
Figure 9: ADAM, moon offset = Δ0.5. The network learns a curved decision boundary. Loss fluctuates especially during the early iterations of training.
"""

# ╔═╡ f7bae71f-885a-404d-985b-92d612e1f3d6
md"""
SGD and ADAM are able to learn a curved decision boundary (fig. 7 and 9) while GD and WD fail to do so (fig. 6 and 8). Moreover, the decision boundary learned by ADAM better resembles the data structure. The contours of the ADAM network show a very strong confidence on the networks classification. This contrasts the results from the GS paper, where ADAM was not able to learn a decision boundary as curved and well-fitting the data structure as shown in fig. 9.
"""

# ╔═╡ 2bfb5f10-cb87-41a4-9dca-f3f0b1157c6f
md"""
#### Spectral Decoupling

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/GD_%CE%940.5_%2B_SD.png"))
Figure 10: GD with SD, moon offset = Δ0.5. No curved decision boundary is learned but the loss also did not converge.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/SGD_%CE%940.5_%2B_SD.png"))
Figure 11: SGD with SD, moon offset = Δ0.5. The network learns a curved decision boundary which greatly resembles the moon data structure and shows invaginations at the data points of both moons closest to the boundary. Loss converges to ~15%.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/WD_%CE%940.5_%2B_SD.png"))
Figure 12: WD with SD, moon offset = Δ0.5. NN fails to separate the two data classes. Similar to GD with SD, loss could still be lowered with further training.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/ADAM_%CE%940.5_%2B_SD.png"))
Figure 13: ADAM with SD, moon offset = Δ0.5. The network learns a curved decision boundary which greatly resembles the data structure. Loss heavily oscillates and steadily increases with longer training. Interestingly, all data points of each respective class belong to the same contour.
"""

# ╔═╡ 7460f609-c32b-4704-a361-71c98bb626cd
md"""
SD, originally applied as a regularization by Pezeshki et al. only with SGD, is able to yield curved decision boundaries which greatly resemble the data structure of the two moons in combination with SGD and ADAM optimization. While SGD learns a more angular boundary with low loss, ADAM learns a smoother one but exhibits a high loss with strong oscillations. Interestingly, ADAM learns to group all data points of a class within the same contour (fig. 13). GD and WD do not profit from SD regularization and don't learn a curved boundary. However, their loss profiles suggest improvement with further learning.
"""

# ╔═╡ 87cc8172-d5cc-49ff-9a0e-fa734e1010c1
md"""
#### Additional experiments
Given that the loss did not converge for GD + SD after 1000 epochs, the network was trained for 10000 iterations.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/GD_%CE%940.5_%2B_SD_10000.png"))
Figure 14: GD with SD, moon offset = Δ0.5. NN was trained 10 times longer (10000 iterations). The learned curved decision boundary resembles the result obtained with SGD + SD.

To conquer the overfitting observed with ADAM + SD lower learning rates were evaluated.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/1e-3_ADAM_%CE%940.5_%2B_SD.png"))
Figure 15: ADAM with SD on the moons with offset = Δ0.5 and a learning rate of 0.001 still suffers from severe overfitting. Nonetheless, oscillations in loss are dampened.

$(Resource("https://raw.githubusercontent.com/justinsane1337/GradientStarvation/master/plots/1e-4_ADAM_%CE%940.5_%2B_SD.png"))
Figure 16: ADAM with SD on the moons with offset = Δ0.5 and a learning rate of 0.0001 shows lower loss compared to 0.001 but a decision boundary with a smaller margin.

The additional experiments show that GD with SD performs equally well compared to SGD with SD but needs much more training for that.
The overfitting problem with ADAM + SD can be successfully conquered with lower learning rates. However, the shape of the decision boundary suffers with learning rates as low as 0.0001. From all three ADAM + SD experiments, the one learning at a rate of 0.001 performed best.
"""

# ╔═╡ 2c740919-1fd4-45c4-91d1-ef3d3e081139
md"""
## Discussion
Pezeshki et al. described gradient starvation as a learning proclivity that can exhibit both negative and positive effects on neural network learning. Considering the 2D classification task discussed in this notebook, the effect of learning a decision boundary with a small margin, thus supposedly hardly robust, could be exemplified for stochastic gradient descent. Combining SGD with spectral decoupling regularization was greatly able to enlarge the margin, therefore yielding a more robust network that not only focussed on a single dominant feature. On the other hand, the potential negative effect of overfitting by precisely learning less dominant features as well became evident through higher losses (SGD: 8.61% without vs. 13.37% with SD; ADAM: 2.00% without vs. 68.16%).
Contrarily to the results from Pezeshki et al., the here used neural network was perfectly able to learn curved decision boundaries featuring a large margin between the data points using ADAM without SD. While Pezeshki et al. trained their ADAM network with rates of 0.0001 and 0.001, I trained all networks under the same conditions, hence both SGD and ADAM with a learning rate of 0.01. Despite the higher learning rate, ADAM showed no sign of overfitting without SD. However, with SD the overfitting was extreme but ADAM coupled with SD regularization was also a combination of methods not assessed by the researchers.
Regarding the same matter, my approach to apply SD not only to SGD but all other optimizers simultaneously offered limited insight. First of all, the combination of WD (L2 regularization) and SD was expected to not work well since both methods are somewhat conflicting. ADAM performed well with SD but suffered from overfitting which can be conquered by a lower learning rate as demonstrated. Nonetheless, the network with purportedly lower loss learns a boundary with a smaller margin.

All in all, the results of Pezeshki et al. could be reproduced with the exception of the network using ADAM, which was able to learn decision boundaries with similar characteristics as the ones learned by SGD with SD.

Finally, it must be mentioned that Pezeshki et al. not only exemplified GS on the rather synthetical moon classification task but showed GS ramifications and the potential of SD as a regularization technique on more complex, well-established datasets like CIFAR, colored MNIST and CelebA which was sadly out of scope of this project.
"""

# ╔═╡ 21854d7b-13ce-477c-bc61-1cb15536e24f
md"""
### Conclusion
Gradient starvation is another relevant side effect of gradient descent-learned neural networks that may be worth the attention in the optimization process of NNs. However, if GS is a blessing or a curse depends on the use case. Starved models, i.e. models concentrating on superficial features during learning, can be less prone to overfitting while adressing GS promises to increase robustness.
"""

# ╔═╡ c95db58c-9d47-4ef0-9ede-234d7a693f41
md"""
### References
Pezeshki, M., Kaba, S. O., Bengio, Y., Courville, A., Precup, D., & Lajoie, G. (2020). Gradient starvation: A learning proclivity in neural networks. arXiv preprint arXiv:2011.09468.

Pizurica, A. (2020). E016330: Artificial Intelligence – Learning from examples [PDF course notes]. Ufora.

Pizurica, A. (2020). E016330: Artificial Intelligence - Neural networks [PDF course notes]. Ufora.

Russell, S., & Norvig, P. (2002). Artificial intelligence: a modern approach. 

Kingma, D. P., & Ba, J. (2014). Adam: A method for stochastic optimization. arXiv preprint arXiv:1412.6980.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.0"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0b5cfbb704034b5b4c1869e36634438a047df065"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "ae6145ca68947569058866e443df69587acc1806"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.32"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─5c563230-df6e-4f65-a106-a707d2454fe7
# ╟─8bd774c7-1acf-4beb-bc99-4c303882d262
# ╟─8f0cdbf1-0174-4d18-9072-2a8c5f015177
# ╟─6a79cfe1-12f9-4ae0-a917-14b4f3a1b31b
# ╟─512e6240-76e7-11ec-2511-07ffc4b74d27
# ╟─93bc80a8-673d-457b-96d8-e1bb0b09682e
# ╟─66a3b5cb-a465-42fb-a8c8-404d574312d2
# ╟─4a14831d-7736-4af5-875f-05ae6e3cf7c4
# ╟─60905936-9373-44de-96e6-cb5d6dd72d33
# ╟─00d4161d-6f8f-42d6-8f13-7d5aa7e70ab3
# ╟─ac02597f-a7ca-4ede-ab8a-c0739c60d0d5
# ╟─2f766a9c-de6e-4f95-aa73-aacb486aaf61
# ╟─7f7ed965-fa08-4d6f-8908-dfc8876bdd02
# ╟─88ddf822-622b-4d46-a0a4-a7d749c8bc48
# ╟─884bc572-9daa-40ad-8d76-56ec58728f63
# ╟─ac453412-0f71-45ee-aefb-0cc519467c6c
# ╟─5e282e1a-62fc-4911-9b7e-f2631eeb2669
# ╟─f7bae71f-885a-404d-985b-92d612e1f3d6
# ╟─2bfb5f10-cb87-41a4-9dca-f3f0b1157c6f
# ╟─7460f609-c32b-4704-a361-71c98bb626cd
# ╟─87cc8172-d5cc-49ff-9a0e-fa734e1010c1
# ╟─2c740919-1fd4-45c4-91d1-ef3d3e081139
# ╟─21854d7b-13ce-477c-bc61-1cb15536e24f
# ╟─c95db58c-9d47-4ef0-9ede-234d7a693f41
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
