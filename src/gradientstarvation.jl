module GradientStarvation

include("neuralnetwork.jl")

train_loader, test_loader = NeuralNetwork.get_moon_data(NeuralNetwork.Args())
m = NeuralNetwork.train(train_loader, test_loader)

display(NeuralNetwork.plot_decision_boundary(train_loader, m, title = "Train"))
display(NeuralNetwork.plot_decision_boundary(test_loader, m, title = "Test"))

end
