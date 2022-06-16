using Documenter
using GradientStarvation.Data
using GradientStarvation.Figures
using GradientStarvation.Experiments
using GradientStarvation.NeuralNetwork
using GradientStarvation.PlotLib
using GradientStarvation.PlotUtils
using GradientStarvation.Regularization

makedocs(
    sitename = "Gradient Starvation",
    format = Documenter.HTML(),
    modules = [
        GradientStarvation.Data, 
        GradientStarvation.Figures, 
        GradientStarvation.Experiments, 
        GradientStarvation.NeuralNetwork, 
        GradientStarvation.PlotLib, 
        GradientStarvation.PlotUtils,
        GradientStarvation.Regularization
    ],
    pages = Any[
        "Data" => "man/data.md",
        "Figures" => "man/figures.md",
        "Experiments" => "man/experiments.md",
        "Neural Network" => "man/neuralnetwork.md",
        "Plots" => "man/plotlib.md",
        "Plot Utils" => "man/plotutils.md",
        "Regularization" => "man/regularization.md"
    ]
)

#=
deploydocs(
            repo = "github.com/justinsane1337/GradientStarvation.git",
        )
=#