module GradientStarvation

include("args.jl")
include("data.jl")
include("neuralnetwork.jl")

train_loader, test_loader = Data.get_moon_data_loader()
m = NeuralNetwork.train(train_loader, test_loader, "GD", false)

display(NeuralNetwork.plot_decision_boundary(train_loader, m, title = "Train"))
display(NeuralNetwork.plot_decision_boundary(test_loader, m, title = "Test"))

end
