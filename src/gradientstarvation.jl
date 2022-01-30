module GradientStarvation

# activate environment
using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

using DataStructures
using PlotlyJS

include("experiments.jl")
include("figures.jl")
include("structs.jl")

# figure 1
Figures.create_figure_1("medium")

# figures 2-13
experiments = OrderedDict(
    "GD Δ0.5" => Experiment("GD", 0.5, false),
    "GD Δ1.0" => Experiment("GD", 1.0, false),
    "GD Δ0.5 + SD" => Experiment("GD", 0.5, true),
    "GD Δ1.0 + SD" => Experiment("GD", 1.0, true),

    "SGD Δ0.5" => Experiment("SGD", 0.5, false),
    "SGD Δ1.0" => Experiment("SGD", 1.0, false),
    "SGD Δ0.5 + SD" => Experiment("SGD", 0.5, true),
    "SGD Δ1.0 + SD" => Experiment("SGD", 1.0, true),

    "WD Δ0.5" => Experiment("WD", 0.5, false),
    "WD Δ1.0" => Experiment("WD", 1.0, false),
    "WD Δ0.5 + SD" => Experiment("WD", 0.5, true),
    "WD Δ1.0 + SD" => Experiment("WD", 1.0, true),

    "ADAM Δ1.0" => Experiment("ADAM", 1.0, false),
    "ADAM Δ0.5" => Experiment("ADAM", 0.5, false),
    "ADAM Δ0.5 + SD" => Experiment("ADAM", 0.5, true),
    "ADAM Δ1.0 + SD" => Experiment("ADAM", 1.0, true),
)
Experiments.run_experiments(experiments, show_plots = false, random_moons = false)

# additional experiments
# figure 14
Experiments.run_experiments(
    OrderedDict("GD Δ0.5 + SD 10000" => Experiment("GD", 0.5, true)),
    show_plots = false, random_moons = false, epochs = 10000
)

# figure 15, 16
add_exp_adam = OrderedDict("ADAM Δ0.5 + SD" => Experiment("ADAM", 0.5, true))
Experiments.run_experiments(add_exp_adam, show_plots = false, random_moons = false, learning_rate = 1e-4, prefix = "1e-4")
Experiments.run_experiments(add_exp_adam, show_plots = false, random_moons = false, learning_rate = 1e-3, prefix = "1e-3")

end
