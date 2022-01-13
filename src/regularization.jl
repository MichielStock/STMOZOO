module Regularization

using Flux: onecold
using Flux.Losses: logitcrossentropy, crossentropy
using LinearAlgebra
using Statistics

function spectral_decoupling(ŷ, y, λ)
	# ŷ, y = onecold(ŷ), onecold(y)
	# return mean(log.(1.0 .+ exp.(-ŷ .* y))) .+ λ * mean(ŷ .* 2)
	# println(mean(log.(1.0 .+ exp.(-ŷ .* y))) .+ λ * mean(ŷ .* 2).^2)

	# python: torch.log(1.0 + torch.exp(-ŷ * y)).mean() + λ * (ŷ ** 2).mean()
	# v = mean(log.(1.0 .+ exp.(-y .* ŷ))) .+ λ/2 * norm(ŷ, 2)^2
	# v = logitcrossentropy(ŷ, y) .+ (λ/2 * norm(ŷ, 2)^2)
	v = logitcrossentropy(ŷ, y) + λ * mean(ŷ .^ 2) 
	# v = mean(1.0 .* log.(1.0 .+ exp.(-ŷ .* y))) + λ * mean(ŷ .^ 2)
	# println(v)
	return v
end

end