module NeuralNetwork

include("data.jl")
include("plotutils.jl")
include("regularization.jl")

using Flux
using Flux: onehotbatch, onecold
using Flux.Data: DataLoader
using Flux.Losses: logitcrossentropy
using MLDatasets
using Plots
using PlotlyJS
using ProgressMeter
using Statistics

export get_moon_data, get_nmist_data, get_loss_and_accuracy, train

function get_moon_data(args)
	x_train, y_train = Data.get_moons(300, offset = 0.5)
	x_test, y_test = Data.get_moons(300, offset = 0.5, seed = 0) # Data.get_moons_from_publication()

	x_train, x_test = transpose(x_train), transpose(x_test)
	y_train, y_test = onehotbatch(y_train, 0:1), onehotbatch(y_test, 0:1)

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

	# Create DataLoaders (mini-batch iterators)
	train_loader = DataLoader((xtrain, ytrain), batchsize=args.batchsize, shuffle=true)
	test_loader = DataLoader((xtest, ytest), batchsize=args.batchsize)

	return train_loader, test_loader
end

function get_loss_and_accuracy(data_loader::Flux.Data.DataLoader, model; args...)
	args = Args(args...)
	accuracy = 0.0f0
	loss = 0.0f0
	num = 0
	for (x, y) in data_loader
		ŷ = model(y)
		loss += Regularization.spectral_decoupling(ŷ, y, args.λ) # logitcrossentropy(ŷ, y, agg = sum)
		accuracy += sum(onecold(ŷ) .== onecold(y))
		num += size(x)[end]
	end
	return loss, accuracy / num
end

function neural_network()
	return Chain(
		Dense(2, 500, relu),
		Dense(500, 2)
	)
end

Base.@kwdef mutable struct Args
	learning_rate::Float64 = 0.1
    batchsize::Int = 300
    epochs::Int = 1000
	λ::Float64 = 3e-1
end

function plot_train_and_test_data(train_loader::Flux.Data.DataLoader, test_loader::Flux.Data.DataLoader)
	# plot train and test data sets
	p_train = Plots.scatter(
		train_loader.data[1][1,:], train_loader.data[1][2,:],
			c = PlotUtils.map_bool_to_color(train_loader.data[2][1,:], "blue", "red")
	)
	p_test = Plots.scatter(
		test_loader.data[1][1,:], test_loader.data[1][2,:],
		c = PlotUtils.map_bool_to_color(test_loader.data[2][1,:], "blue", "red")
	)
	display(Plots.plot(p_train, p_test, layout = (1, 2)))
end

function train(train_loader::Flux.Data.DataLoader, test_loader::Flux.Data.DataLoader; args...)
	args = Args(args...)

	model = neural_network()
	params = Flux.params(model)
	# optimizer = ADAM(args.learning_rate) 
	optimizer = Descent(args.learning_rate)
	# optimizer = Optimiser(WeightDecay(), Decent(args.learning_rate))

	# training
	prog = Progress(args.epochs, 0.25, "Training... ", 75)
	for epoch in 1:args.epochs
		# loss(x, y) = logitcrossentropy(model(x), y)
		loss(x, y) = Regularization.spectral_decoupling(model(x), y, args.λ)
		Flux.train!(loss, params, train_loader, optimizer)

		# evaluate train and test loss and accuracy 
		train_loss, train_accuracy = get_loss_and_accuracy(train_loader, model)
		test_loss, test_accuracy = get_loss_and_accuracy(test_loader, model)

		ProgressMeter.next!(prog; showvalues = [
			(:epoch, epoch), 
			(:train_loss, train_loss), (:test_loss, test_loss),
			(:train_accuracy, train_accuracy), (:test_accuracy, test_accuracy)
			])
	end

	return model
end

function plot_decision_boundary(loader, model; title = "")
	# grid and range step size
	n = 100
	# determine limits of given data
	x_max = maximum(loader.data[1][1,:]) + .25
	y_max = maximum(loader.data[1][2,:]) + .25
	x_min = minimum(loader.data[1][1,:]) - .25
	y_min = minimum(loader.data[1][2,:]) - .25

	# upper = ceil(maximum([x_max, y_max]), digits = 1, base = 2)
	# lower = floor(minimum([x_min, y_min]), digits = 1, base = 2)

	r_x = LinRange(x_min, x_max, n)
	r_y = LinRange(y_min, y_max, n)

	# create grid to be used for the contours
	d1 = collect(Iterators.flatten(vcat([fill(v, (n, 1)) for v in r_x])))
	d2 = collect(Iterators.flatten(vcat([reshape(r_y, 1, :) for _ in 1:n])))
	grid = hcat(d1, d2)

	# use model to predict decision boundary based on grid
	gr_pred = model(grid')
	gr_pred = reshape(gr_pred[1,:], (n, n))

	# map classes (Boolean) to integers to be used as colors
	cols = PlotUtils.map_bool_to_color(loader.data[2][1,:], "#FF0000", "#0000FF")
	opacity = 0.90

	PlotlyJS.plot([
		# data points
		PlotlyJS.scatter(
			x = loader.data[1][1,:], y = loader.data[1][2,:], 
			mode = "markers", marker = attr(color = cols, line_width = 1)
		),
		# actual contours
		PlotlyJS.contour(
			x = r_x, y = r_y, z = gr_pred, 
			contours_start = -50, contours_end = 50, contours_size = 5, 
			contours_coloring = "heatmap", colorscale = PlotUtils.get_custom_rdbu_scale(opacity), 
			opacity = opacity
		),
		# highlight decision boundary line
		PlotlyJS.contour(
			x = r_x, y = r_y, z = gr_pred, 
			contours_start = 0, contours_end = 0, contours_size = 0,
			contours_coloring = "lines", colorscale = [[0, "black"], [1, "black"]], 
			showscale = false, line = attr(width = 3)
		)],
		Layout(
			title = title,
			width = 500, height = 500, autosize = true,
			xaxis_showgrid = false, yaxis_showgrid = false,
			xaxis_range = [x_min, x_max], yaxis_range = [y_min, y_max],
			xaxis = attr(zeroline = true, zerolinewidth = 1, zerolinecolor = "black", automargin = true),
			yaxis = attr(zeroline = true, zerolinewidth = 1, zerolinecolor = "black", automargin = true),
			margin = attr(l = 50, r = 50, b = 50, t = 50, pad = 0),
			plot_bgcolor = "rgba(0, 0, 0, 0)"
		),
		config = PlotConfig(
			scrollZoom = false
		)
	)
end

end