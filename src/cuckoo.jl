module Cuckoo 

    # export functions relevant for the user
    export ackley, init_nests, cuckoo#, Nest, step 
    # nb do not export nest, step
 
    using Distributions 
    
    

    # d dimensional function 
    function ackley(x; a=20, b=0.2, c=2π)
        d = length(x)
        return -a * exp(-b*sqrt(sum(x.^2)/d)) -
            exp(sum(cos.(c .* x))/d)
    end
    

    # For testing purposes, to be removed and put in notebook
    #x1lims = (-10, 10)
    #x2lims = (-10, 10)
    #population = init_nests(10, x1lims, x2lims) 


    mutable struct Nest{T<:Array}
        position::T
        fitness::Float64
    end 

    function init_nests(n, lims...)    
        return [([(u - l) * rand() + l for (l, u) in lims]) for i in 1:n] 
    end 
    #init_nests(4,(1,2),(4,5),(6,7)) <- 4 points in 3 dimensions , each dimension has an upper/lower bound

    function step(alpha, lims...) 
        return [alpha*rand(truncated(Levy(),l,u)) for (l, u) in lims]
    end


    function cuckoo(f::Function, population, lims...; Pa=0.75, alpha=1)  
        nests = Nest.(population, f.(population))

        n = length(population) 
        max_it = 100 # parametrizza o sceltri altra termination condit 
        
        best_index = argmin([nests[i].fitness for i in 1:n]) 
        best_pos = nests[best_index].position
        best_fit = nests[best_index].fitness 

        while max_it > 0
            #repeat for each nest, to permorm a Levy flight from each of them
            for i in 1:n 
                new_pos = nests[i].position .+ step(alpha, lims...)
                new_fit = f(new_pos) 

                j = floor(Int, rand()*n + 1) #can use a different way?
                while j == i 
                    j = floor(Int, rand()*n + 1)
                end
                old_fit = nests[j].fitness 

                if new_fit < old_fit
                    nests[j].position = new_pos
                    nests[j].fitness = new_fit
                end


                if rand() < Pa
                    worst_index = argmax([nests[i].fitness for i in 1:n]) 
                    new_pos = population[worst_index] .+ step(alpha, lims...)
                    new_fit = f(new_pos)
                    nests[worst_index].position = new_pos
                    nests[worst_index].fitness = new_fit
                end
                
                best_index = argmin([nests[i].fitness for i in 1:n]) 
                best_pos = nests[best_index].position
                best_fit = nests[best_index].fitness 
            end

            print("Iteration ", 100-max_it+1, " completed!\n")
            max_it -= 1
        end 
    return best_pos, best_fit
    end
end