module Experiments

using PlotlyJS

include("data.jl")
include("neuralnetwork.jl")
include("plotlib.jl")
include("structs.jl")

function run_experiments(experiments; prefix = "", show_plots = true, save_plots = true, plot_size = "medium")
    plot_width, plot_height = get_plot_resolution(plot_size)

    for (name, def) in experiments
        # load data
        train_loader = Data.get_moon_data_loader(offset = def.offset)

        # create and train the model
        model, stats = NeuralNetwork.train(train_loader, def.optimizer, def.sd)

        # create plots
        p1 = PlotLib.plot_decision_boundary(train_loader, model, title = name)
        p2 = PlotLib.plot_loss_and_accuracy(stats["loss"], stats["accuracy"])
		# combine subplots
        p = [p1 p2]
		# make background and plots transparent (looks better in dark-styled browsers)
        PlotlyJS.relayout!(p, paper_bgcolor = "rgba(0, 0, 0, 0)", plot_bgcolor = "rgba(0, 0, 0, 0)")
        
		# save and/or display decision boundary and performance stats
        if save_plots 
			p_name = "plots/$(prefix)" * replace(name, " " => "_") * ".png"
			PlotlyJS.savefig(p, p_name, width = plot_width, height = plot_height) 
		end

        if show_plots 
			display(p) 
		end
    end
	@info "Finished $(length(experiments)) experiments."
end

end