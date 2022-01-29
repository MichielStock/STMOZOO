module GradientStarvation

# activate environment
using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

using DataStructures
using PlotlyJS

include("data.jl")
include("neuralnetwork.jl")
include("plotlib.jl")
include("structs.jl")

experiments = OrderedDict(
    "Δ1.0" => Experiment("SGD", 1.0, false),
    "Δ0.5" => Experiment("SGD", 0.5, false),
    "Δ0.5 + SD" => Experiment("SGD", 0.5, true),
)

plots = []
for (name, def) in experiments
    train_loader = Data.get_moon_data_loader(offset = def.offset)
    model, stats = NeuralNetwork.train(train_loader, def.optimizer, def.sd)

    p = PlotLib.plot_decision_boundary(train_loader, model, title = name)
    p_stats = PlotLib.plot_loss_and_accuracy(stats["loss"], stats["accuracy"])
    global plots = push!(plots, p, p_stats)
end

display([plots[1] plots[2]; plots[3] plots[4]; plots[5] plots[6]])
end
