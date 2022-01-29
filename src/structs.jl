Base.@kwdef mutable struct Args
	learning_rate::Float64 = 1e-2
    batchsize::Int = 50
    epochs::Int = 1000
	λ::Float64 = 3e-1
end

struct Experiment
    optimizer::String
    offset::Float64
    sd::Bool
end
