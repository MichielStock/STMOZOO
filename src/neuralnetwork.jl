module NeuralNetwork

include("data.jl")

using Flux
using Flux: onehotbatch, onecold
using Flux.Data: DataLoader
using Flux.Losses: logitcrossentropy
using MLDatasets

export get_example_data, get_nmist_data, get_loss_and_accuracy, train

# WIP
# 2D classification task
# 2 layer ReLU, 500 hidden units
# cross-entropy loss training for two different arrangements of the training points

function get_example_data(args)
	x_train, y_train = Data.get_moons()
	x_test, y_test = Data.get_moons()

	y_train, y_test = onehotbatch(y_train, [-1, 1]), onehotbatch(y_test, [-1, 1])

	println("example data dimensions", size(x_train), size(y_train))

	# create data loaders
	train_loader = DataLoader((x_train, y_train), batchsize = args.batchsize, shuffle = true)
	test_loader = DataLoader((x_test, y_test), batchsize = args.batchsize)

	return train_loader, test_loader
end

function get_nmist_data(args)
	# Loading Dataset	
	xtrain, ytrain = MLDatasets.MNIST.traindata(Float32)
	xtest, ytest = MLDatasets.MNIST.testdata(Float32)
	
	# Reshape Data in order to flatten each image into a linear array
	xtrain = Flux.flatten(xtrain)
	xtest = Flux.flatten(xtest)

	# One-hot-encode the labels
	ytrain, ytest = onehotbatch(ytrain, 0:9), onehotbatch(ytest, 0:9)

	println(size(xtrain), size(ytrain))
	# Create DataLoaders (mini-batch iterators)
	train_loader = DataLoader((xtrain, ytrain), batchsize=args.batchsize, shuffle=true)
	test_loader = DataLoader((xtest, ytest), batchsize=args.batchsize)

	return train_loader, test_loader
end

function get_loss_and_accuracy(data_loader, model)
	accuracy = 0
	loss = 0.0f0
	num = 0
	for (x, y) in data_loader
		ŷ = model(y)
		loss += logitcrossentropy(ŷ, y, agg = sum)
		accuracy += sum(onecold(ŷ) .== onecold(y))
		num += size(x)[end]
	end
	return loss / num, accuracy / num
end

function neural_network()
	return Chain(
		Dense(2, 300, relu),
		Dense(300, 2)
		# Dropout(0.7)
	)
end

Base.@kwdef mutable struct Args
	learning_rate::Float64 = 3e-2
    batchsize::Int = 50
    epochs::Int = 10
end

function train(args...)
	args = Args(args...)

	train_loader, test_loader = get_example_data(args) # get_nmist_data(args) # 

	model = neural_network()
	params = Flux.params(model)

	optimizer = ADAM(args.learning_rate)

	# training
	for epoch in 1:args.epochs
		for (x, y) in train_loader
			# println(size(x), size(y))
			# println(x, y)
			# compute gradient
			grad = gradient(() -> logitcrossentropy(model(x), y), params)
			Flux.Optimise.update!(optimizer, params, grad)
		end

		# Report on train and test
		train_loss, train_accuracy = get_loss_and_accuracy(train_loader, model)
		test_loss, test_accuracy = get_loss_and_accuracy(test_loader, model)
		println("Epoch $epoch")
		println("  train_loss = $train_loss, train_accuracy = $train_accuracy")
		println("  test_loss = $test_loss, test_accuracy = $test_accuracy")
	end
end

end