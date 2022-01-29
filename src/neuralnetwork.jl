module NeuralNetwork

include("structs.jl")
include("regularization.jl")

using Flux
using Flux: onecold
using Flux: Optimiser
using Flux.Losses: binarycrossentropy, crossentropy, logitcrossentropy, logitbinarycrossentropy
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
	@assert !(spectral_decoupling && isa(args.λ, Float64)) "λ must be specified if spectral decoupling is used"

	accuracy = 0.0f0
	loss = 0.0f0
	num = 0

	# iterate over batches
	for (x, y) in data_loader
		ŷ = model(y)		
		loss += spectral_decoupling ? 
			Regularization.spectral_decoupling(ŷ, y, args.λ) : 
			logitcrossentropy(ŷ, y, agg = sum)
		accuracy += sum(onecold(ŷ) .== onecold(y))
		num += size(x)[end]
	end

	# divide metrics cumulated over batches by number of total data points
	return spectral_decoupling ? loss : loss / num, accuracy / num
end

"""
	neural_network()

Creates a Flux neural network according to the topology used by Pezeshki et al.
That is a NN with 2 hidden layers, 500 units each and ReLU activation.
"""
function neural_network()
	return Chain(
		Dense(2, 500, relu),
		Dense(500, 2)
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
Training... 100%|███████████████████████████████████████████████████████████████████████████| Time: 0:00:42
  epoch:           1000
  train_loss:      0.1337
  test_loss:       0.1337
  train_accuracy:  1.0
  test_accuracy:   1.0
```
"""
function train(data_loader::Flux.Data.DataLoader, optimizer::String = "SGD", spectral_decoupling::Bool = false; args...)
	args = Args(; args...)

	@info "opt = $optimizer, sd = $spectral_decoupling, lr = $(args.learning_rate), bs = $(args.batchsize)" * (spectral_decoupling ? ", λ = $(args.λ)" : "")

	model = neural_network()
	params = Flux.params(model)
	optimizer = get_optimizer(args.learning_rate, optimizer)

	# record loss and accuracy progression over epochs
	loss_prog, accuracy_prog = [], []

	# training
	prog = Progress(args.epochs, 0.25, "Training... ", 75)
	for epoch in 1:args.epochs
		loss(x, y) = spectral_decoupling ? 
			Regularization.spectral_decoupling(model(x), y, args.λ) : 
			logitcrossentropy(model(x), y)

		Flux.train!(loss, params, data_loader, optimizer)

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

	return model, Dict("loss" => loss_prog, "accuracy" => accuracy_prog)
end

"""
	get_optimizer(learning_rate, optimizer)

Returns a Flux.Optimiser according to the one requested by acronym with fixed parameters except 
for the given learning rate. Supported optimizers are:
	- Adaptive Moment Estimation (ADAM)
	- Gradient Descent (GD)
	- Stochastic Gradient Descent (SGD)
	- Weight Decay (WD)
"""
function get_optimizer(learning_rate, optimizer = "SGD")
	optimizer = uppercase(optimizer)
	@assert optimizer in ["ADAM", "GD", "SGD", "WD"] "Requested optimizer '$optimizer' is not supported."

	if optimizer == "ADAM"
		return ADAM(learning_rate) 
	elseif optimizer == "GD"
		return Descent(learning_rate)
	elseif optimizer == "SGD"
		# stochastic gradient descent
		return Momentum(learning_rate, 0.9) 
	elseif optimizer == "WD"
		return Optimiser(WeightDecay(), Descent(learning_rate))
	end
end

end