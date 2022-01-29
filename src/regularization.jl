module Regularization

using Flux.Losses: crossentropy, logitcrossentropy, logitbinarycrossentropy
using Statistics

function spectral_decoupling(ŷ, y, λ)
	# return mean(1.0 .* log.(1.0 .+ exp.(-ŷ .* y))) + λ * mean(ŷ .^ 2)
	return logitcrossentropy(ŷ, y) + λ * mean(ŷ .^ 2) 
end

end