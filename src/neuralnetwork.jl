module NeuralNetwork

include("structs.jl")
include("regularization.jl")

using Flux
using Flux: onecold
using Flux: Optimiser
using Flux.Losses: binarycrossentropy, crossentropy, logitcrossentropy, logitbinarycrossentropy
using LinearAlgebra
using MLDatasets
using ProgressMeter
using Statistics

export get_loss_and_accuracy, train

"""
	get_loss_and_accuracy(data_loader, model, spectral_decoupling; args...)

Calculates loss and accuracy of the given data for the input model.

# Examples
```julia-repl
julia> get_loss_and_accuracy(train_loader, model)
(0.1337, 1.0f0)
```
"""
function get_loss_and_accuracy(data_loader::Flux.Data.DataLoader, model, spectral_decoupling::Bool = false; args...)
	args = Args(; args...)
	@assert !(spectral_decoupling && isa(args.sd_λ, Float64)) "sd_λ must be specified if spectral decoupling is used"

	accuracy = 0.0f0
	loss = 0.0f0
	num = 0

	# iterate over batches
	for (x, y) in data_loader
		ŷ = model(y)		
		loss += spectral_decoupling ? 
			Regularization.spectral_decoupling(ŷ, y, args.sd_λ) : 
			logitcrossentropy(ŷ, y, agg = sum)
		accuracy += sum(onecold(ŷ) .== onecold(y))
		num += size(x)[end]
	end

	# divide metrics cumulated over batches by number of total data points
	return spectral_decoupling ? loss : loss / num, accuracy / num
end

"""
	neural_network(500)

Creates a Flux neural network according to the topology used by Pezeshki et al.
That is a NN with 2 hidden layers, 500 units each and ReLU activation. The hidden
layer dimensions can be adjusted by the first and only parameter.
"""
function neural_network(hidden_dim::Int64 = 500)
	return Chain(
		Dense(2, hidden_dim, relu),
		Dense(hidden_dim, 2)
	)
end

"""
    train(train_loader, test_loader, optimizer, spectral_decoupling; args...)

Creates and trains a neural network as defined in [`neural_network`](@ref) using cross-entropy loss with 
the specified optimizer and additionally spectral decoupling as a loss regularization.

# Examples
```julia-repl
julia> train(train_loader, test_loader, "SGD", false)
[ Info: opt = SGD, sd = false, lr = 0.01, bs = 50
Training... 100%|███████████████████████████████████████████████████████████████████████████| Time: 0:00:05
  epoch:     1000
  loss:      0.1337
  accuracy:  1.0
```
"""
function train(data_loader::Flux.Data.DataLoader, optimizer::String = "SGD", spectral_decoupling::Bool = false; args...)
	args = Args(; args...)

	@info "opt = $optimizer, sd = $spectral_decoupling, lr = $(args.learning_rate), bs = $(args.batchsize)" * 
		(spectral_decoupling ? ", sd_λ = $(args.sd_λ)" : "") * (optimizer == "WD" ? ", wd_λ = $(args.wd_λ)" : "")

	model = neural_network()
	params = Flux.params(model)
	optimizer = get_optimizer(args.learning_rate, optimizer; args.wd_λ)

	# record loss and accuracy progression over epochs
	loss_prog, accuracy_prog = [], []
	# record weight evolution of learned features
	z1_prog, z2_prog = [], []

	# training
	prog = Progress(args.epochs, 0.25, "Training... ", 75)
	for epoch in 1:args.epochs
		for (x, y) in data_loader
			grads = Flux.gradient(params) do
				spectral_decoupling ? 
					Regularization.spectral_decoupling(model(x), y, args.sd_λ) : 
					logitcrossentropy(model(x), y)
			end

			Flux.Optimise.update!(optimizer, params, grads)
			# evaluate learned features
			# Y = Diagonal(y)
			# Φ = ? --> NTK regime, unable to obtain NTRF matrix to perform SVD
			# U = U of singular value decomposition

			# workaround
			# can only be done if hidden_dim == batchsize
			if (size(model.layers[1].W, 1) == size(x, 2))
				U = transpose(model.layers[1].W) .* model.layers[2].W
				zs = U .* model(x)
				push!(z1_prog, sum(abs.(zs[1,:])))
				push!(z2_prog, sum(abs.(zs[2,:])))
			end
		end

		# evaluate loss and accuracy 
		loss, accuracy = get_loss_and_accuracy(data_loader, model)
		push!(loss_prog, loss)
		push!(accuracy_prog, accuracy)
		
		# show neat progress bar
		ProgressMeter.next!(prog; showvalues = [
			(:epoch, epoch), 
			(:loss, loss),
			(:accuracy, accuracy)
			]
		)
	end

	return model, Dict("loss" => loss_prog, "accuracy" => accuracy_prog, "z1" => z1_prog, "z2" => z2_prog)
end

"""
	get_optimizer(learning_rate, optimizer, wd_λ)

Returns a Flux.Optimiser according to the one requested by acronym with fixed parameters except 
for the given learning rate. Supported optimizers are:
	- Adaptive Moment Estimation (ADAM)
	- Gradient Descent (GD)
	- Stochastic Gradient Descent (SGD)
	- Weight Decay (WD)
"""
function get_optimizer(learning_rate::Float64, optimizer::String = "SGD"; args...)
	args = Args(; args...)
	optimizer = uppercase(optimizer)
	@assert optimizer in ["ADAM", "GD", "SGD", "WD"] "Requested optimizer '$optimizer' is not supported."
	if optimizer == "WD"
		@assert isa(args.wd_λ, Float64) "wd_λ must be specified if WD is used"
	end

	if optimizer == "ADAM"
		return ADAM(learning_rate) 
	elseif optimizer == "GD"
		return Descent(learning_rate)
	elseif optimizer == "SGD"
		# stochastic gradient descent
		return Momentum(learning_rate, 0.9) 
	elseif optimizer == "WD"
		return Optimiser(WeightDecay(args.wd_λ), Descent(learning_rate))
	end
end

end