module PlotLib

include("plotutils.jl")
include("structs.jl")

using Flux
using PlotlyJS
using Plots

export plot_train_and_test_data, plot_loss_and_accuracy, plot_features, plot_decision_boundary

title_font_size = 18
tick_font_size = 16

function plot_train_and_test_data(train_loader::Flux.Data.DataLoader, test_loader::Flux.Data.DataLoader)
	# plot train and test data sets next to each other
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

function plot_loss_and_accuracy(loss, accuracy; args...)
	args = Args(; args...)
	PlotlyJS.plot([
		PlotlyJS.scatter(y = loss, x = 1:args.epochs, mode = "lines", name = "loss"),
		PlotlyJS.scatter(y = accuracy, x = 1:args.epochs, mode = "lines", name = "accuracy")
		],
		Layout(
			title = attr(text = "Loss and Accuracy", font = attr(size = title_font_size)),
			width = 1000, height = 1000, autosize = false,
			xaxis = attr(
				showgrid = false, 
				ticks = "outside",
				tickfont = attr(size = tick_font_size)),
			yaxis = attr(
				range = [0, 1], dtick = 0.1, showgrid = false,
				ticks = "outside",
				tickfont = attr(size = tick_font_size)),
			legend = attr(font = attr(size = tick_font_size)),
			automargin = false,
			margin = attr(l = 0, r = 0, b = 0, t = 0, pad = 0),
			plot_bgcolor = "rgba(0, 0, 0, 0)",
			paper_bgcolor = "rgba(0, 0, 0, 0)"
		)
	)
end

function plot_features(z1, z2; args...)
	args = Args(; args...)
	PlotlyJS.plot([
		PlotlyJS.scatter(y = z1, x = 1:args.epochs, mode = "lines", name = "z1"), 
		PlotlyJS.scatter(y = z2, x = 1:args.epochs, mode = "lines", name = "z2")
		],
		Layout(
			title = attr(text = "Features", font = attr(size = title_font_size)),
			width = 1000, height = 1000, autosize = false,
			xaxis = attr(
				ticks = "outside",
				tickfont = attr(size = tick_font_size)),
			yaxis = attr(
				ticks = "outside",	
				tickfont = attr(size = tick_font_size)),
			legend = attr(font = attr(size = tick_font_size)),
			margin = attr(l = 0, r = 0, b = 0, t = 0, pad = 0),
			plot_bgcolor = "rgba(0, 0, 0, 0)",
			paper_bgcolor = "rgba(0, 0, 0, 0)"
		)
	)
end

function plot_decision_boundary(loader, model; title = "")
	# grid and range step size
	n = 100
	# determine limits of given data
	x_max = maximum(loader.data[1][1,:]) + .25
	y_max = maximum(loader.data[1][2,:]) + .25
	x_min = minimum(loader.data[1][1,:]) - .25
	y_min = minimum(loader.data[1][2,:]) - .25

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
			mode = "markers", marker = attr(color = cols, line_width = 1),
			showlegend = false
		),
		# actual contours
		PlotlyJS.contour(
			x = r_x, y = r_y, z = gr_pred, 
			contours_start = -10, contours_end = 10, contours_size = 1, 
			contours_coloring = "heatmap", colorscale = PlotUtils.get_custom_rdbu_scale(opacity), 
			colorbar = attr(thickness = 25, len = 0.9, y = 0.425), 
			opacity = opacity, showlegend = false
		),
		# highlight decision boundary line
		PlotlyJS.contour(
			x = r_x, y = r_y, z = gr_pred, 
			contours_start = 0, contours_end = 0, contours_size = 0,
			contours_coloring = "lines", colorscale = [[0, "black"], [1, "black"]], 
			showscale = false, showlegend = false, line = attr(width = 3)
		)],
		Layout(
			title = attr(text = title, font = attr(size = title_font_size)),
			width = 1000, height = 1000, autosize = false,
			xaxis = attr(
				range = [x_min, x_max],
				zeroline = true, zerolinewidth = 1, zerolinecolor = "black", 
				automargin = false, showgrid = false,
				tickfont = attr(size = tick_font_size)),
			yaxis = attr(
				range = [y_min, y_max],
				zeroline = true, zerolinewidth = 1, zerolinecolor = "black", 
				automargin = false, showgrid = false,
				tickfont = attr(size = tick_font_size)),
			legend = attr(font = attr(size = tick_font_size)),
			margin = attr(l = 0, r = 0, b = 0, t = 0, pad = 0),
			plot_bgcolor = "rgba(0, 0, 0, 0)",
			paper_bgcolor = "rgba(0, 0, 0, 0)"
		),
		config = PlotConfig(
			scrollZoom = false
		)
	)
end

end