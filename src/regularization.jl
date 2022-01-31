module Regularization

using Flux.Losses: logitcrossentropy
using Statistics

"""
	spectral_decoupling(ŷ, y, λ)

Logitcrossentropy extended with spectral decoupling regularization as proposed by
[Pezeshki et al.](https://arxiv.org/abs/2011.09468). The implementation here somewhat differs from the formula presented
in the paper but the methodology is consistent with the python code provided by the authors.
"""
function spectral_decoupling(ŷ, y, λ)
	return logitcrossentropy(ŷ, y) + λ * mean(ŷ .^ 2) 
end

end