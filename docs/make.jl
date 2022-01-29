using Documenter

using GradientStarvation
using GradientStarvation.Data
using GradientStarvation.NeuralNetwork

makedocs(
    sitename = "Gradient Starvation - An STMO ZOO Project",
    format = Documenter.HTML(),
    modules = [Data, NeuralNetwork],
    pages = Any[
        "Data" => "man/data.md",
        "Neural Network" => "man/neuralnetwork.md"
    ]
)

#=
deploydocs(
            repo = "github.com/justinsane1337/GradientStarvation.git",
        )
=#