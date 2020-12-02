# Michiel Stock
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module Softmax

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager

# export all functions that are relevant for the user
export softmax

function softmax(x::Vector; κ::Number=1.0)
	q = exp.(x)
	q ./= sum(q)
	return q
end

function gumbel_max(items::Vector, x::Vector; κ::Number=1.0)
    @assert length(items) == length(x) "length of `items` and `x` do not match"
    i = κ .* x .+ rand(Gumbel(), length(x)) |> argmax
    return items[i]
end

end