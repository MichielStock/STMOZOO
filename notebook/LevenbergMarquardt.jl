### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ a48ee3a5-eecd-4dff-8c23-98d9c4a37f0a
using ForwardDiff

# ╔═╡ 37e9829f-541b-455f-ad30-6d2494693784
using LinearAlgebra

# ╔═╡ 5b421980-7fa6-11ec-2205-adead1588dca
md"""# Levenberg-Marquardt algorithm
STMO Project by **Thiemen Mussche**
"""

# ╔═╡ ca4d4bb8-2f6d-4a69-a6b1-6cc0fc8b5b99
md""" Named after Kenneth Levenberg who first published the algorithm in 1944 and Donald Marquardt who made significant contributions to it in 1963, the so longly named Levenberg-Marquardt algorithm (LMA) is an adaptation of the Gauss-Newton algorithm (GNA), which itself is the main method to solve nonlinear least squares problems in nonlinear regression. 

Unlike linear regression, finding the optimal parameter values to a nonlinear model does not have a closed-form solution and is done iteratively, which requires an initial guess. This is where LMA differs from GNA by being more robust to initial conditions. It will find a solution even if it starts far from the final minimum.

In this notebook we will build the LMA from the ground up so to fundamentally understand the reasoning behind it.

In 'poetic' words that would make more sense after reading: using the Gauss-Newton algorithm to solve nonlinear least-squares is like eating a metaphorical icecream cone, while LMA is the serviette you get with your icecream cone to stop the ice from dripping.
"""


# ╔═╡ b38660ed-9b17-47d3-860c-d65d63f862b2
md"""## Linear regression and least-squares"""

# ╔═╡ e4e4e45d-cb4a-4413-8587-9aab8974813b
md""" From regression to LMA is quite a big leap and although you surely know what regression is, we will recapitulate some important differences at the fundamental level to really understand what LMA is trying to do. Let's start at the beginning.

Regression estimates the relation between a response variable and one or more predictors. There are different ways to do this, partly based on how observational data is presumed to behave. 
In the commonly used linear regression a model is set up in which the observational data is a linear combination of the predictors and their parameters. By fitting a line through the data, the parameters can be estimated with the famous least squares method.
"""

# ╔═╡ f0ea984f-3c02-40ac-acfb-ca62dbdfcd1d
md""" The linear regression model can be represented in matrix form as $$Y = Xβ + ϵ$$, where $$Y$$ and $$ϵ$$ are $$n*1$$ matrices of response values and residuals respectively. $$X$$ is the $$n*p$$ design matrix and $$β$$ is the $$p*1$$ matrix of unknown parameters.
When there are more data points than predictors, $$n > p$$, there is no way to fit a line through all the data points. Instead, we want to find the $$β$$ for which the residual sum of squares is as low as possible.
This results in minimizing the following objective function $$S$$ with respect to β.
```math
S(β) = ||Y - Xβ||²
```
By deriving $$S$$ to $$β$$, setting the derivative to $$0$$ and solving for $$β$$, we find the value for $$β$$ where $$S$$ does not change. In other words, where $$S$$ reaches a local minimum or maximum.
"""

# ╔═╡ afb431a1-a2e0-4411-8092-5ebf0d78fdfd
md"""
```math
dS(β) / dβ = (Y - Xβ)^T (Y-Xβ) / dβ 
```
```math
0 = -2X^T(Y-Xβ)
```
```math
β̂ = (X^T X)⁻¹ X^T Y
```
"""

# ╔═╡ ed9840c8-700d-4b60-a584-c923b766fd48
md""" We can show that $β$ is in fact a global minimum and not a local minimum or maximum because the hessian of $$S(β)$$ is positive-definite (non-negative over all values of $$β$$). This makes $$S(β)$$ a convex function. It only curves upward and could never have a maximum, or local minima. Showing the proof would bring us too far. 
"""

# ╔═╡ 61da80dc-7d49-4ec5-a0f2-78dee48853ce
md"""## Nonlinear regression and Gauss-Newton"""

# ╔═╡ af8f2266-4f37-46ba-9cb5-8078c472923c
md""" For nonlinear regression, the observational data is assumed to not have a linear relation with the predictor(s). Therefore, the function by which the data is modeled cannot be expressed as a linear combination of the parameter(s).

One important implication this has is the inability of least squares to formulate a closed-form expression for the best-fitting parameters. In other words, the equation $dS/dβ = 0$ cannot be solved analytically.
Numerical workarounds exist, among which the Gauss-Newton algorithm sticks out.
 
"""

# ╔═╡ 3e017df0-a35c-45cd-9f5e-f513ea745ad9
md""" ### Gauss-Newton algorithm
"""

# ╔═╡ 88a749da-38e3-40a0-bbd9-ae9b68824381
md""" We are living in a hypothetical world where our regression model $f(x, β)$ doesn't represent a line, but rather a curve. We cannot write $Y$ as a linear combination of the model parameters and our precious least squares screams and breaks as we try to fit the model in. 

Let's turn the thought process upside down. We guess an initial $β₀$, now we can solve the sum of squares as we know the one thing we couldn't know. There is no way this guessed $β$ is the optimal value though. How do we find a better solution $β₁ = β₀ + δ$, that minimizes $S(β)$?
Using $β₀ + δ$ as input, we arrive at the exact same problem. $dS(β₁) / d(β₁)$ cannot be solved for $β₁$. We need another way to represent the problem.

Sir Isaac Newton thought the same thing and the genius he is, found a solution in Taylor approximations. 
In case you need to refresh Taylor approximations, there's an intermezzo recapitulating it below.
"""

# ╔═╡ e7b7f5aa-2cb0-4737-a29d-5e4bf1fd7676
md""" ##### Linearization
"""

# ╔═╡ b9fa1c3b-16d7-4551-8508-4ee888371476
md""" To find β₁ we linearize $f(x,β)$ around β₀ with a first-order Taylor approximation. 
```math
f(x, β) ≈ f(x, β₀) + ∇f(x, β₀)(β - β₀)
```
We now know how $f(x, β)$ behaves linearly directly around β₀. If $δ$ is small, we can fill in  $β₀ + δ$ to find the approximate solution for β₁
```math
f(x, β₀ + δ) ≈ f(x, β₀) + ∇f(x, β₀)((β₀ + δ) - β₀)
```
```math
≈ f(x, β₀) + ∇f(x, β₀)δ
```
Note that $β₀$ is a constant in this equation. We only replace the variable $β$ with $β₀ + δ$
"""

# ╔═╡ 9dd7d5d1-e624-400d-b82d-cdd7fa576524
md"""
This linear approximation of $f(x, β)$ around β₀, for β₀ + δ CAN be used as input for least squares. 

Before implementing the least squares we introduce the Jacobian matrix into the equation, which represents the gradient of $f$ to $β$
```math
J = ∇f(x, β) ⇒ f(x, β₀ + δ) ≈ f(x, β₀) + Jδ
```

Finally, we are ready for least squares. 
```math
S(β) = ||Y - f(β)||²
```

```math
⇒ S(β + δ) ≈ ||Y - f(β) - Jδ||²
```
Normally, we would derive to $β$ and set the result to $0$. For the nonlinear case that would make no sense as we already know $β$. Instead, we are interested in the value of $δ$ that minimizes the sum of squares. Hence we derive $S(β + δ)$ to $δ$ and find its value where the derivative is zero.
```math
||Y - f(β) - Jδ||²
```
```math
= [Y - f(β) - Jδ]ᵀ[Y - f(β) - Jδ]
```
```math
= [Y - f(β)]ᵀ[Y - f(β)] - 2[Y - f(β)]ᵀJδ + δᵀJᵀJδ
```
Derived to $δ$ and setting to $0$ we get
```math
dS(β+δ)/dδ = - 2Jᵀ[Y - f(β)] + 2JᵀJδ
```
```math
[JᵀJ]δ = Jᵀ[Y - f(β)]
```
Notice that J has $n*p$ dimensions, with $n$ the number of data points and $p$ the parameters. $δ$ and $β$ are $p*1$ matrices and Y is an $n*1$ matrix.
"""

# ╔═╡ 01ec6ca9-fb36-445e-9623-7b2ec247658e
md""" We can now rewrite β₁ in terms of β₀
```math
β₁ = β₀ + [JᵀJ]⁻¹ . Jᵀ[Y - f(β₀)]
```
We must not forget that we approximated $f(x, β + δ)$ and hence $β₁$ is not guaranteed to deliver a minimum. We iterate the process until improvements of $S(β)$ fall under a certain threshold and accept this $β$ as our solution. 
"""

# ╔═╡ dde5dadf-9fe2-4955-8143-970365a27d40
md"""
##### intermezzo: Taylor approximation
Goal: approximate non-polynomial functions by a polynomial

Method:
Imagine $f(x)$ a non-polynomial, approximated by a polynomial: $c + bx + ax^2$
```math
⇒ f(x) ≈ c + bx + ax^2
```
for any value x. If $x = 0$, the polynomial should have the same value as $f(0)$.
```math
⇒ f(0) = c + b(0) + a(0)^2 = c
```
We could say that $f(x) ≈ f(0)$ around $0$. That looks pretty stupid, but it isn't. The approximating polynomial is a flat line that intersects with $f(x)$ at $x = 0$.  

Most likely though, $f(x)$ isn't a flat line at $x = 0$. It rises, or it drops according to its derivative. This looks abusable. Setting the slope of the polynomial to be the equal to that of $f(x)$ will improve the approximation around 0.
```math
⇒ f'(0) = b + 2a(0) = b
```
The process is predictable at this point. All derivatives of $f(x)$ say something about how the function moves around x. 
```math
 f''(0) = 2a ⇒ a = f''(0) / 2
```
Putting it all together, we can approximate $f(x)$ fairly well around $0$
```math
 f(x) ≈ f(0) + f'(0)x + (f''(0) / 2) x^2
```
By replacing $x$ with $x - t$ in the polynomial, we can approximate $f(x)$ for any value $t$ of $x$. Now all but one terms of the polynomial become $0$ when filling in $f(t). Replacing $x$ in the polynomial is possible because we determine how the function looks like. Our only requirements are that the function depends on $x$ and is a polynomial. Both are unaffected by replacing $x$ with $x-t$

Note that with each added derivative, the approximation improves. The further we stray from $x = t$, the less correct the approximation becomes. 
"""

# ╔═╡ e5bcd117-de88-452b-9984-64483c51c557
md""" ## Levenberg-Marquardt
The Gauss-Newton algorithm might seem like closure for nonlinear regression but it's not all puppies and sunshine in the world of mathematics. We've gone a bit loose on some assumptions that alter the interpretation and results of the algorithm. LMA adjusts a part of GNA, trying to tackle a couple of these issues, but definitely not all.
It is not the intention to give a detailed overview of all the intricacies that come with nonlinear least squares. We will discuss the problems that LMA tries to deal with or others that might be necessary for interpretation.

To begin, the solution of GNA is not a global minimum.
In most cases, the nonlinearity of $f(x, β)$ leads into S no longer being a convex function. The minima we find are most likely not global. With an informed initial guess, our chances might be higher.

Following, the sum of squares might not decrease at every iteration of GNA. $δ$ might overshoot the local minimum, after all we are working with an approximation that only works near β, for a small δ. 
Even if that is the case, δ is still a descent direction of S, meaning that its direction will always move us closer to a local minimum as long as our steps are small enough. A consequence of this property is that GNA might never converge at all, as δ keeps overshooting the actual local minimum.

"""

# ╔═╡ a4a01416-190c-4560-8dac-79d789bad7cf
md"""
At long last, this is where LMA comes into play. 
Its method is copy-paste GNA, with the addition of a damping parameter in the equation for δ. Not surprisingly, LMA is also called damped least squares.

Gauss-Newton
```math
[JᵀJ]δ = Jᵀ[Y - f(β)]
```
Levenberg-Marquardt
```math
[JᵀJ + λI]δ = Jᵀ[Y - f(β)]
```
The non-negative damping factor determines the direction of $δ$. 

When $λ$ nears $0$, LMA is exactly GNA. In this case, $δ$ points in a direction where S gets smaller, but it might only get smaller for a very short bit before it starts increasing again. 

It's hard to get an intuitive view on this. See it as a result of linearizing $f(x, β)$ around $β₀$ and using this to approximate $f(x, β₀ + δ)$. The initial direction of $δ$ might be correct, because this direction is exactly the same for small and large $δ$ (the direction of a linear function does not change), but if the gradient of $f(x, β)$ changes drastically around $β₀$, values of the approximated $f(x, β₀ + δ)$ for large $δ$ will be far from the actual values. Extrapolating to the Gauss-Newton equation $[JᵀJ]δ = Jᵀ[Y - f(β)]$, we can assume δ points in the correct direction for a local minimum of $β + δ$ while the step size should be taken with a grain of salt.

We wandered off a bit there. So if $λ$ nears $0$, the Levenberg-Marquardt equation equals the Gauss-Newton equation. Conversely if $λ$ nears $+∞$, then $δ = [JᵀJ + λI]⁻¹Jᵀ[Y - f(β)]$, the term $JᵀJ$ in the inverse is negligible in comparison to $λI$. Hence the direction of $δ$ nears the direction of $Jᵀ[Y - f(β)]$. That is very useful indeed, because the gradient of $S$ with respect to $β$ equals $-2(Jᵀ[Y - f(β)])ᵀ$, so we can conclude that $δ$ points in the opposite direction of the gradient of $S$ when $λ$ nears $∞$

In other words, LMA changes the direction of $δ$ between its original direction and the direction of steepest/gradient descent based on the parameter $λ$.

We can write $β₁$ in term of $β₀$
```math
β₁ = β₀ + [JᵀJ + λI]⁻¹ . Jᵀ[Y - f(β₀)]
```
"""

# ╔═╡ ca803027-4063-4a34-86da-c41b667aee06
md"""
##### Gradient descent

If GNA isn't doing so hot, why don't we just use the direction of gradient descend to optimize β?

Gradient descent is an intuitive iterative optimization algorithm for finding local minima. Taking repeated steps in the opposite direction of the gradient of the function at each iteration point would eventually lead to a local minimum. This is the direction where $f(x)$ decreases the fastest.

The caveat comes in the speed of convergence. Gradient descent doesn't converge fast in functions where the curvature changes relatively fast. Again this is intuitive. Imagine a minimum lying in a narrow valley of a function. The algorthim can only move in the oppsite direction of the gradient. When the iteration starts entering the valley, it will most likely overshoot to the other side of the valley. Now the gradient has drastically changed, pointing in the opposite direction of last iteration. 

At first sight this might look like a good thing, the minimum lies in the middle of the valley where gradient descent is pointing to right? Not necessarily no, the valley might at its middle still move downwards, like a river between mountains running towards the lowest point of the valley by gravity. Gradient descent is terrible at recognizing these scenarios, constantly switching sides of the valley in a zigzag-pattern, very slowly going downhill until convergence.
"""

# ╔═╡ e8c7f84f-c856-41fa-b129-5dfef74b6ff0
md""" ##### Choice of damping parameter

When it all comes together, LMA tries to circumvent problems of approximation in GNA and problems of slow convergence in Gradient descent by switching between the direction of GNA whenever $S(β)$ keeps decreasing between iterations and the direction of gradient descent whenever $S(β)$ increases.

There's another intuitive way to determine your preferred $λ$. In the general sense, GNA is bad at finding a good value for $δ$ when it is far from a local minimum, because of the approximation. So if we don't have an informed initial guess, it is generally better to start with a relatively high $λ$. Conversely, Gradient descent is bad at convergence. When we get closer to a local minimum, it is thus generally better to have a lower value for $λ$.

Currently, there is no proven best method to determine $λ$.

* Marquardt's method
Marquardt recommended the following: you start with a value $λ₀$ and a factor $v > 1$.
In the first iteration, $S(β)$ is calculated with $λ = λ₀$ and $λ = λ₀ / v$. If both result in a higher value of $S(β)$, we increase damping by multiplying $λ₀$ by $v$ until $S(β)$ drops. The final damping factor is taken for the second iteration. If $λ₀ / v$ instead results in a lower value of $S(β)$, we accept it and use this damping factor for the second iteration. In the last scenario, when $λ₀ / v$ gives us a higher value of $S(β)$ while $λ₀$ improves it, the damping factor is left unchanged.

* Delayed gratification
A simpler method where $λ$ is increased a bit after each uphill step and decreased a lot after each downhill step.
We decrease more than we increase to avoid the gradient descent zigzag problem.
If you near a valley with a minimum far from where you entered the valley, step sizes are constricted in length and convergence will be slow.
"""

# ╔═╡ b46abd33-efe8-4d57-b276-c4b6a5b4dd32
md""" ## Implementation
"""

# ╔═╡ 2026d0c0-7c6b-48f6-a113-7c63138e6bc6
md""" 
Now we've finally made it through the theory, we can use LMA to solve a nonlinear least squares problem.

We will perform LMA on the Rosenbrock function, a non-convex function often used for  performance testing in optimization. This function has one global minimum with a very small valley leading to it. Logically, Gradient descent has a hard time converging for this function.
```math
f(x) = (a - x₁)² + b(x₂ - x₁²)²
```
GNA and LMA want to minimize a cost function that can be written as a sum of squares. The Rosenbrock function can be written as a sum of squares if we define:
```math
f₁(x) = a - x₁
```
```math
f₂(x) = √b(x₂ - x₁²) 
```
```math
⇒ f(x) = \sum_i (fᵢ)²
```
Note that $x$ here plays the role of the parameters $β$ in regression context. $f(x) ≈ S(β)$ and $fᵢ ≈ yᵢ - f(xᵢβ)$

The above expression can be written as the norm of a vector-valued function instead:
```math
f(x) = ||F(x)||²
```
with $F(x)$ a $2*1$ matrix of $f₁$ and $f₂$

For each iteration we linearize $F(x)$ around $x$ to approximate the value of $F(x + δ)$
```math
F(x + δ) ≈ F(x) + J(x)δ
```
and determine $δ$ by minimizing $f(x + δ)$ with respect to $δ$ and setting to zero
```math
f(x + δ) = ||F(x) + J(x)δ||²
```
```math
[JᵀJ]δ = - Jᵀ[F(x)]
```
"""

# ╔═╡ 96684e8a-dd4f-4497-8c06-3bd12bae357c
md"""
We compare GNA, LMA and gradient descent on the Rosenbrock function. 
For the parameters $a$ and $b$, we respectively take 1 and 100. Given these parameters, the Rosenbrock function has a global minimum for $(x, y) = (1, 1)$
"""

# ╔═╡ 28d90808-72fd-4795-9f07-d12b6a165880
md"""
The `GNA` function takes the following input:
- `F`: the objective function that will be used as input to the sum of squares
- `x₀`: an initial guess for $x$
- `k_max`: the maximum amount of iterations the algorithm is allowed to have
- `S_min`: In this particular scenario where we know the global minimum of $f(x)$, $S_min$ controls how close GNA has to get to the global minimum before the algorithm is cut short and $x$ is returned as solution.
"""

# ╔═╡ d917f63a-0580-4209-9e79-a1045c951c46
F(x, y) = [1 - x, 10(y - x^2)]

# ╔═╡ f76a5b3f-d352-4f3d-bd4d-a7d68fadc8b5
md"""
LMA is implemented with Marquardt's method for determining λ

The `LMA` function takes the following input:
- `F`: the objective function that will be used as input to the sum of squares
- `x₀`: an initial guess for $x$
- `λ`: an initial value for the damping parameter. A good start value is 1
- `v`: Marquardt's factor of the damping parameter. A good default value is 2
- `k_max`: the maximum amount of iterations the algorithm is allowed to have
- `S_min`: In this particular scenario where we know the global minimum of $f(x)$, $S_min$ controls how close LMA has to get to the global minimum before the algorithm is cut short and $x$ is returned as solution.
"""

# ╔═╡ e311f58d-28a1-4b0b-81d8-25149dfd9392
md""" For gradient descent with an initial guess $x₀$:
```math
x₁ = x₀ - γ∇f(x₀)
```
We take for $γ$ an arbitrary parameter which we decrease when the step size overshoots the minimum.

Unlike GNA and LMA, gradient descent does not have to be applied to sum of square functions. We do not have to write $f(x)$ as a sum of squares function to be able to minimize it.
```math
f(x, y) = (1 - x)² + 100(y - x²)²
```
"""


# ╔═╡ 95b20450-2f9a-4506-936f-5a9039c67dfe
md"""
The `GD` function takes the following input:
- `f`: the objective function
- `x₀`: an initial guess for $x$
- `k_max`: the maximum amount of iterations the algorithm is allowed to have
- `γ`: controls the step size. A descent initial value is $γ$ = 0.05
- `f_min`: In this particular scenario where we know the global minimum of $f(x)$, $f_min$ controls how close Gradient descent has to get to the global minimum before the algorithm is cut short and $x$ is returned as solution.
"""

# ╔═╡ ba7d60d9-b038-4550-aa00-93eae148dae0
f(x, y) = (1 - x)^2 + 100(y - x^2)^2

# ╔═╡ 472e0d90-3145-47c2-9f47-6fb063dec578
function GD(f, x₀; k_max=100, γ=0.05, f_min = 0.1)
	k = 0
	xₖ = x₀
	stopcrit = true
	while k < k_max && stopcrit
		grad = ForwardDiff.gradient(x ->f(x[1],x[2]), xₖ)
		xₗ = xₖ -γ * grad	
		if f(xₗ[1], xₗ[2]) < f(xₖ[1], xₖ[2])
			γ = γ * 2
			xₖ = xₗ
			if f(xₖ[1], xₖ[2]) < f_min
				stopcrit = false
			end
		else
			γ = γ / 2
		end
		k = k + 1
	end
	return xₖ, k
end

# ╔═╡ 3c658ee9-f2c2-4117-bf4d-8bba8ee62906
GD(f, [3, 3])

# ╔═╡ a5dd9cdb-87e5-4d5e-8329-e4681d8db518
GD(f, [-500, 600])

# ╔═╡ 4bce6531-3e78-46b7-92ba-1a042151d4a0
md"""
The functions return the estimated best value for $x$ and the number of iterations it took to get there.

GNA performs significantly better than both LMA and GD, for values close to the minimum and for values further away.

We can explain this result. GNA performs poorly whenever the approximation for $f(x, β + δ)$ is far from the actual value. For lowly complex functions, like the Rosenbrock function, having a large $δ$ does not have an extreme effect on the approximation. When we're from the actual minimum, having a lowly complex function might even be in GNA's favor as it will take large steps.

The Rosenbrock function is the nightmare of Gradient descent. The narrow valley where the minimum resides leads to infinite converging. As LMA interpolates between Gradient descent and GNA, it is not surprising that the algorithm doesn't perform as well as GNA. While LMA takes good qualities of both algorithms it also takes some bad ones, on top of that GNA has its bad qualities nullified because of the function it is performed on.

In that logic, we can predict that LMA will need more iterations with increasing initial value for $λ$
"""


# ╔═╡ 03670555-b517-42cf-8144-3c007a66aa55
md"""
We conclude that a good understanding of the objective function is needed to choose the best-performing algorithm.
In either case, LMA provides the best of both worlds and with proper choice of parameters will always be at least as good as GNA or Gradient descent.
	"""


# ╔═╡ e681b90e-e229-4b39-a903-d1335f884b66
md""" ### Appendix
"""

# ╔═╡ 2fce2374-23f6-4b9e-81f1-ecbc4e2de012
#calculates the sum of squares for a given vector-valued function and point x
function S(F, x)
	return transpose(F(x[1], x[2])) * F(x[1], x[2])
end

# ╔═╡ b941fa95-de33-4b33-a3f9-c3c9e963b5c8
#calculate the jacobian of a given function at a given point
function Jac(F, x)
	return ForwardDiff.jacobian(x->F(x[1], x[2]), x)
end

# ╔═╡ 70057178-c54b-42e6-bcba-f35eecb442cd
function GNA(F, x₀; k_max = 100, S_min = 0.1)
	k = 0
	xₖ = x₀
	Sₖ = S(F, x₀) #calculate sum of squares
	stopcrit = true
	while k < k_max && stopcrit
		J = Jac(F, xₖ) #calculate Jacobian
		δ = -inv(transpose(J) * J) * transpose(J) * F(xₖ[1], xₖ[2]) #Calculate δ for 		which f(x + δ) is a local minimum
		xₗ = xₖ .+ δ #improved x
		Sₗ = S(F, xₗ)	#improved sum of squares 
		if Sₗ < Sₖ && Sₗ < S_min #stopping criteria
			stopcrit = false
		end
		xₖ = xₗ
		Sₖ = Sₗ 
		k = k + 1
	end
	return xₖ, k
end

# ╔═╡ 85280aeb-b780-42c9-9304-ad77ca1de944
GNA(F, [3, 3])

# ╔═╡ 99fdc41b-1033-4c1c-89d7-dde6adfbb986
GNA(F, [-500, 600])

# ╔═╡ 6e213301-4852-4d44-904e-a69ad6c18f3d
function LMA(F, x₀; λ=1, v=2, k_max=100, S_min = 0.1)
	k = 0
	xₖ = x₀
	Sₖ = S(F, x₀) #calculating sum of squares
	I_m = Matrix(I, length(x₀), length(x₀))
	stopcrit = true
	while k < k_max && stopcrit
		J = Jac(F, xₖ) #Calculate Jacobian
		δ = -inv(transpose(J) * J .+ (λ * I_m)) * transpose(J) * F(xₖ[1], xₖ[2]) #Calculate δ for which f(x + δ) is a local minimum
		xₗ = xₖ .+ δ #improved x
		Sₗ = S(F, xₗ) #improved sum of squares 
		if Sₗ < Sₖ
			λ = λ / v
			if Sₗ < S_min
				stopcrit = false
			end
		else
			λ = v * λ
		end
		xₖ = xₗ
		Sₖ = Sₗ
		k = k + 1
	end
	return xₖ, k
end

# ╔═╡ 2808e2da-0cc8-4e55-bbbd-b6ae87f8fb27
LMA(F, [3, 3])

# ╔═╡ e07bfae5-fef2-483c-8b57-1d834c235495
LMA(F, [-500, 600])

# ╔═╡ ff66c650-1097-4d14-aed0-11790576e75f
LMA(F, [-500, 600], λ=0) #equivalent to GNA

# ╔═╡ c3149763-c5b8-41d7-adf9-1f14da76b2f2
LMA(F, [-500, 600], λ=1)

# ╔═╡ 6c337a56-625a-4c35-a7d6-cc71d36c9742
LMA(F, [-500, 600], λ=10)

# ╔═╡ 20063cbc-7970-40a9-822c-ec674647f8a7
LMA(F, [-500, 600], λ=100)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
ForwardDiff = "~0.10.25"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f9982ef575e19b0e5c7a98c6e75ee496c0f73a93"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.12.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

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
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "84083a5136b6abf426174a58325ffd159dd6d94f"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.9.1"

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

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "1bd6fc0c344fc0cbee1f42f8d2e7ec8253dda2d2"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.25"

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
git-tree-sha1 = "22df5b96feef82434b07327e2d3c770a9b21e023"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.0"

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

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

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

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

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

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─5b421980-7fa6-11ec-2205-adead1588dca
# ╟─ca4d4bb8-2f6d-4a69-a6b1-6cc0fc8b5b99
# ╟─b38660ed-9b17-47d3-860c-d65d63f862b2
# ╟─e4e4e45d-cb4a-4413-8587-9aab8974813b
# ╟─f0ea984f-3c02-40ac-acfb-ca62dbdfcd1d
# ╟─afb431a1-a2e0-4411-8092-5ebf0d78fdfd
# ╟─ed9840c8-700d-4b60-a584-c923b766fd48
# ╟─61da80dc-7d49-4ec5-a0f2-78dee48853ce
# ╟─af8f2266-4f37-46ba-9cb5-8078c472923c
# ╟─3e017df0-a35c-45cd-9f5e-f513ea745ad9
# ╟─88a749da-38e3-40a0-bbd9-ae9b68824381
# ╟─e7b7f5aa-2cb0-4737-a29d-5e4bf1fd7676
# ╟─b9fa1c3b-16d7-4551-8508-4ee888371476
# ╟─9dd7d5d1-e624-400d-b82d-cdd7fa576524
# ╟─01ec6ca9-fb36-445e-9623-7b2ec247658e
# ╟─dde5dadf-9fe2-4955-8143-970365a27d40
# ╟─e5bcd117-de88-452b-9984-64483c51c557
# ╟─a4a01416-190c-4560-8dac-79d789bad7cf
# ╟─ca803027-4063-4a34-86da-c41b667aee06
# ╟─e8c7f84f-c856-41fa-b129-5dfef74b6ff0
# ╟─b46abd33-efe8-4d57-b276-c4b6a5b4dd32
# ╟─2026d0c0-7c6b-48f6-a113-7c63138e6bc6
# ╟─96684e8a-dd4f-4497-8c06-3bd12bae357c
# ╠═28d90808-72fd-4795-9f07-d12b6a165880
# ╠═d917f63a-0580-4209-9e79-a1045c951c46
# ╠═70057178-c54b-42e6-bcba-f35eecb442cd
# ╟─f76a5b3f-d352-4f3d-bd4d-a7d68fadc8b5
# ╠═6e213301-4852-4d44-904e-a69ad6c18f3d
# ╟─e311f58d-28a1-4b0b-81d8-25149dfd9392
# ╟─95b20450-2f9a-4506-936f-5a9039c67dfe
# ╠═ba7d60d9-b038-4550-aa00-93eae148dae0
# ╠═472e0d90-3145-47c2-9f47-6fb063dec578
# ╠═85280aeb-b780-42c9-9304-ad77ca1de944
# ╠═2808e2da-0cc8-4e55-bbbd-b6ae87f8fb27
# ╠═3c658ee9-f2c2-4117-bf4d-8bba8ee62906
# ╠═99fdc41b-1033-4c1c-89d7-dde6adfbb986
# ╠═e07bfae5-fef2-483c-8b57-1d834c235495
# ╠═a5dd9cdb-87e5-4d5e-8329-e4681d8db518
# ╟─4bce6531-3e78-46b7-92ba-1a042151d4a0
# ╠═ff66c650-1097-4d14-aed0-11790576e75f
# ╠═c3149763-c5b8-41d7-adf9-1f14da76b2f2
# ╠═6c337a56-625a-4c35-a7d6-cc71d36c9742
# ╠═20063cbc-7970-40a9-822c-ec674647f8a7
# ╟─03670555-b517-42cf-8144-3c007a66aa55
# ╟─e681b90e-e229-4b39-a903-d1335f884b66
# ╠═a48ee3a5-eecd-4dff-8c23-98d9c4a37f0a
# ╠═37e9829f-541b-455f-ad30-6d2494693784
# ╠═2fce2374-23f6-4b9e-81f1-ecbc4e2de012
# ╠═b941fa95-de33-4b33-a3f9-c3c9e963b5c8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
