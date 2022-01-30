module Experiments

include("data.jl")
include("neuralnetwork.jl")
include("plotlib.jl")
include("plotutils.jl")
include("structs.jl")

using DataStructures
using PlotlyJS

export run_experiments

plot_dir = "plots"

"""
	run_experiments(experiments, prefix = "exp_1", random_moons = true, show_plots = false, save_plots = true, plot_size = "medium", plot_type = "both", epochs = 500, batchsize = 42)

Runs all experiments as specified by an DataStructures.OrderedDict.
This includes the creation of moon data, the network, the training and the plotting of the results.
This function is the work horse to conduct any analyses for the notebook.
"""
function run_experiments(experiments::DataStructures.OrderedDict; prefix::String = "", random_moons::Bool = true, show_plots::Bool = true, save_plots::Bool = true, plot_size::String = "medium", plot_type::String = "both", args...)
	plot_type = lowercase(plot_type)
	@assert plot_type in ["boundary", "stats", "both"] "Requested plot type '$plot_type' is not supported."

    plot_width, plot_height = PlotUtils.get_plot_resolution(plot_size)

    for (name, def) in experiments
        # load data
		if random_moons
        	train_loader = Data.get_moon_data_loader(offset = def.offset)
		else
			train_loader = Data.get_moon_data_loader(offset = def.offset, seed = 1337)
		end

        # create and train the model
        model, stats = NeuralNetwork.train(train_loader, def.optimizer, def.sd; args...)

        # create plots
        p1 = PlotLib.plot_decision_boundary(train_loader, model, title = name)
        p2 = PlotLib.plot_loss_and_accuracy(stats["loss"], stats["accuracy"]; args...)

		if plot_type == "both"
			# combine subplots
			p = [p1 p2]
			# make background and plots transparent (looks better in dark-styled browsers)
			PlotlyJS.relayout!(p, paper_bgcolor = "rgba(0, 0, 0, 0)", plot_bgcolor = "rgba(0, 0, 0, 0)")
		elseif plot_type == "boundary"
			p = p1
		elseif plot_type == "stats"
			p = p2
		end
        
		# save requested plot
        if save_plots 
			p_name = "$plot_dir/$prefix" * (prefix != "" ? "_" : "") * replace(name, " " => "_") * (plot_type == "both" ? "" : plot_type) * ".png"
			PlotlyJS.savefig(p, p_name, width = plot_width, height = plot_height) 
		end

        if show_plots 
			display(p)
		end
    end

	@info "Finished $(length(experiments)) experiments."
end

end