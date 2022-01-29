module Experiments

using PlotlyJS

include("data.jl")
include("neuralnetwork.jl")
include("plotlib.jl")
include("structs.jl")

function run_experiments(experiments; prefix = "exp", show_plots = true, save_plots = true, plot_size = "medium")
    plot_width, plot_height = get_plot_resolution(plot_size)
	
    for (name, def) in experiments
        # load data
        train_loader = Data.get_moon_data_loader(offset = def.offset)

        # create and train the model
        model, stats = NeuralNetwork.train(train_loader, def.optimizer, def.sd)

        # create plots
        p1 = PlotLib.plot_decision_boundary(train_loader, model, title = name)
        p2 = PlotLib.plot_loss_and_accuracy(stats["loss"], stats["accuracy"])
        p = [p1 p2]
        PlotlyJS.relayout!(p, paper_bgcolor = "rgba(0, 0, 0, 0)")
        
		# plot/save decision boundary and performance stats
        if save_plots 
			p_name = "plots/$(prefix)_" * replace(name, " " => "_") * ".png"
			PlotlyJS.savefig(p, p_name, width = plot_width, height = plot_height) 
		end

        if show_plots 
			display(p) 
		end
    end
	@info "Finished $(length(experiments)) experiments."
end

function get_plot_resolution(size)
	size = lowercase(size)
	@assert size in ["small", "medium", "large", "xlarge"] "Requested plot size '$size' is not supported."

	if size == "small"
		# 16:9 360p
		return 640, 360
	elseif size == "medium"
		# 16:9 480p
		return 854, 480
	elseif size == "large"
		# 16:9 720p
		return 1280, 720
	elseif size == "xlarge"
		# 16:9 1080p
		return 1920, 1080
	end
end