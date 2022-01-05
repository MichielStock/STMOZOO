# Michiel Stock
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module Softmax

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using Distributions: Gumbel

# export all functions that are relevant for the user
export softmax, gumbel_max

"""
    softmax(x::Vector; κ::Number=1.0)

Computes the softmax for a vector `x`. `κ` is a hyperparameter that
determines the trade-off between utility and entropy.
"""
function softmax(x::Vector; κ::Number=1.0)
	q = exp.(κ .* x)
	q ./= sum(q)
	return q
end

"""
    gumbel_max(items::Vector, x::Vector; κ::Number=1.0)

Samples an item from `items` using the softmax given utilities `x`.
`κ` is a hyperparameter that determines the trade-off between utility
and entropy.
"""
function gumbel_max(items::Vector, x::Vector; κ::Number=1.0)
    @assert length(items) == length(x) "length of `items` and `x` do not match"
    i = κ .* x .+ rand(Gumbel(), length(x)) |> argmax
    return items[i]
end

"""
    gumbel_max(x::Vector; κ::Number=1.0)

Samples an item using the softmax given utilities `x`.
Returns the indice of the chosen item.
`κ` is a hyperparameter that determines the trade-off between utility
and entropy.
"""
gumbel_max(x::Vector; κ::Number=1.0) = κ .* x .+ rand(Gumbel(), length(x)) |> argmax

end