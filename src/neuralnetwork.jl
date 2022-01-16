module NeuralNetwork

include("args.jl")
include("plotutils.jl")
include("regularization.jl")

using Flux
using Flux: onecold
using Flux.Losses: logitcrossentropy
using MLDatasets
using Plots
using PlotlyJS
using ProgressMeter
using Statistics

export get_loss_and_accuracy, train

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

function train(train_loader::Flux.Data.DataLoader, test_loader::Flux.Data.DataLoader, optimizer::String = "SGD", spectral_decoupling::Bool = false; args...)
	args = Args(args...)

	@info "opt = $optimizer, sd = $spectral_decoupling, lr = $(args.learning_rate), bs = $(args.batchsize)" * (spectral_decoupling ? "λ = $(args.λ)" : "")

	model = neural_network()
	params = Flux.params(model)
	optimizer = get_optimizer(args.learning_rate, optimizer)

	# training
	prog = Progress(args.epochs, 0.25, "Training... ", 75)
	for epoch in 1:args.epochs
		loss(x, y) = spectral_decoupling ? 
			Regularization.spectral_decoupling(model(x), y, args.λ) : 
			logitcrossentropy(model(x), y)

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
		return Optimiser(WeightDecay(), Decent(learning_rate))
	end
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
			contours_start = -10, contours_end = 10, contours_size = 1, 
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