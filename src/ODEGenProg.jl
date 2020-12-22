# Michael Van de Voorde
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module ODEGenProg

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager

# export all functions that are relevant for the user
export foo_bar

function foo_bar(x::Int64,y::Int64)
    return x+y
end

end