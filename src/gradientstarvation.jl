module GradientStarvation

# activate environment
using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end

include("args.jl")
include("data.jl")
include("neuralnetwork.jl")

train_loader, test_loader = Data.get_moon_data_loader()

m_gd = NeuralNetwork.train(train_loader, test_loader, "GD", false)

p1 = NeuralNetwork.plot_decision_boundary(train_loader, m_gd, title = "GD Train")
p2 = NeuralNetwork.plot_decision_boundary(test_loader, m_gd, title = "GD Test")

m_sgd = NeuralNetwork.train(train_loader, test_loader, "SGD", false)

p3 = NeuralNetwork.plot_decision_boundary(train_loader, m_sgd, title = "SGD Train")
p4 = NeuralNetwork.plot_decision_boundary(test_loader, m_sgd, title = "SGD Test")

# same with SD
m_gd_sd = NeuralNetwork.train(train_loader, test_loader, "GD", true)

p5 = NeuralNetwork.plot_decision_boundary(train_loader, m_gd_sd, title = "GD + SD Train")
p6 = NeuralNetwork.plot_decision_boundary(test_loader, m_gd_sd, title = "GD + SD Test")

m_sgd_sd = NeuralNetwork.train(train_loader, test_loader, "SGD", true)

p7 = NeuralNetwork.plot_decision_boundary(train_loader, m_sgd_sd, title = "SGD + SD Train")
p8 = NeuralNetwork.plot_decision_boundary(test_loader, m_sgd_sd, title = "SGD + SD Test")

display([p1 p2
p3 p4
p5 p6
p7 p8])

end
