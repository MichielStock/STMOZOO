module GradientStarvation

# activate environment
using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

using DataStructures
using PlotlyJS

include("experiments.jl")
include("structs.jl")

experiments = OrderedDict(
    "GD Δ1.0" => Experiment("GD", 1.0, false),
    "GD Δ0.5" => Experiment("GD", 0.5, false),
    "GD Δ0.5 + SD" => Experiment("GD", 0.5, true),

    "SGD Δ1.0" => Experiment("SGD", 1.0, false),
    "SGD Δ0.5" => Experiment("SGD", 0.5, false),
    "SGD Δ0.5 + SD" => Experiment("SGD", 0.5, true),

    "WD Δ1.0" => Experiment("WD", 1.0, false),
    "WD Δ0.5" => Experiment("WD", 0.5, false),
    "WD Δ0.5 + SD" => Experiment("WD", 0.5, true),

    "ADAM Δ1.0" => Experiment("ADAM", 1.0, false),
    "ADAM Δ0.5" => Experiment("ADAM", 0.5, false),
    "ADAM Δ0.5 + SD" => Experiment("ADAM", 0.5, true),
)

Experiments.run_experiments(experiments)

end
