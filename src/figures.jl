module Figures

include("data.jl")
include("plotlib.jl")
include("plotutils.jl")

using PlotlyJS

export create_figure_1

plot_dir = "plots"

"""
	create_figure_1("medium")

Convenience function to create figure 1 of the notebook.
"""
function create_figure_1(plot_size::String)
	width, height = PlotUtils.get_plot_resolution(plot_size)
	loader_1 = Data.get_moon_data_loader(offset = 1.0, seed = 1337)
	loader_2 = Data.get_moon_data_loader(offset = 0.5, seed = 1337)
	p = PlotLib.plot_train_and_test_data(loader_1, loader_2; train_title = "Δ0.5", test_title = "Δ1.0")
	PlotlyJS.savefig(p, "$(plot_dir)/figure_1.png", width = width, height = height)
end

end