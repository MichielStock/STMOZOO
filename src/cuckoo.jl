module Cuckoo 

    # export functions relevant for the user
    export init_nests, cuckoo!  
 
    # import external packages
    using SpecialFunctions
 
    """
        Nest

    Hold each solution and its fitness.       
    """
    mutable struct Nest
        position::Array{Float64}
        fitness::Float64
    end 


    """
        init_nests(n::Int, lims...)

    Create an array of `n` random solutions.
        
    Each dimension of the solution is constrained by an upper and a lower bound provided in
    the `lims` parameter which automatically collects in a tuple all the couples of bounds 
    passed for each dimension.
 
    # Examples

    Create a population of 5 where each point has 2 dimensions, respectively having as lower 
    and upper bound `x1lims = (-10, 10)` and `x2lims=(-15, 15)`.

    ```julia
    julia> x1lims=(-10,10)
    julia> x2lims=(-15,15)
    julia> p=init_nests(5,x1lims,x2lims)
    5-element Array{Array{Float64,1},1}:
    [3.2506269365826235, -13.904103441708813]
    [7.6966755817918155, 0.019170453403416943]
    [9.177999793081582, -7.738154316325958]
    [1.0837999423638358, 14.655548441822855]
    [6.640425508361417, -4.823307495174905]
    ```
    """
    function init_nests(n::Int, lims...)    
        @assert all([length(lim)==2 for lim in lims]) "Every bound should be composed of a lower and an upper limit." 
        @assert all([l <= u for (l, u) in lims]) "Every bound should be defined with the lower one as first element and the upper one as second"
        @assert n>1 "The population should be composed of at least two individuals"

        return [([(u - l) * rand() + l for (l, u) in lims]) for i in 1:n] 
    end  

    
    """
        levy_step(d::Int, lambda::AbstractFloat)
        
    Return the step to be added to an existing solution. 
    
    The step direction is randomly picked from a uniform distribution and the stepsize is 
    drawn from a Lévy distribution with exponent `lambda`, obtained through implementing a
    simplified version of Mantegna algorithm. This allows to simulate a Lévy flight 
    performed by a cuckoo to reach a new nest. The parameter `d` indicates the number of 
    dimensions of the solution.
    """
    function levy_step(d::Int, lambda::AbstractFloat)
        #choice of random direction
        dir = [rand() for x in 1:d]
        
        #generation of stepsize  
        sigma = (gamma(1 + lambda) * sin(pi * lambda/2)/
            (gamma((1 + lambda) / 2) * lambda * 2^((lambda - 1)/2)))^(1 / lambda)

        steps = Vector{Float64}(undef, d)
        for x in 1:d
            u = sigma*randn()
            v = randn()
            steps[x] = u ./ abs(v) .^ (1/lambda)
        end
 
        return steps .* dir  
    end


    """
        get_random_nest_index(n::Int; not::Set{Int}=Set([0])) 

    Return a random index between 1 and `n`, representing one of the nests. 
    
    If `not` is specified, the returned index must be different from any element in it.
    """
    function get_random_nest_index(n::Int; not::Set{Int}=Set([0])) 
        @assert length(not)<n "Not possible to find an index not in the set"  #avoids infinite loops      
        new_nest = floor(Int, rand(1:n))
        while new_nest in not 
            new_nest = floor(Int, rand(1:n))
        end
        return new_nest
    end


    """
        check_limits(new_pos::Array{Float64}, lims...)

    Check if a newly generated solution `new_pos` is within the limits `lims`, if not 
    return the solution having as values the limits that were violated.
    """
    function check_limits(new_pos::Array{Float64}, lims...)
        @assert length(new_pos) == length(lims) "The number of dimensions doesn't 
                                            correspond to the number of dimension limits"
        
        n = length(new_pos)
        new_pos = [ifelse(new_pos[d] < lims[d][1], Float64(lims[d][1]), ifelse(new_pos[d] > lims[d][2], Float64(lims[d][2]), new_pos[d])) for d in 1:n]        
        return new_pos
    end


    """ 
        cuckoo(f::Function, population::Array, lims...;
                            gen::Int=40,
                            Pa::AbstractFloat=0.25,
                            alpha::AbstractFloat=1.0,
                            lambda::AbstractFloat=1.5)    

    Implement the backbone of the cuckoo search method and return a tuple containing the
    solution and its fitness.     
    
    At each iteration these two optimization steps are carried out:

    - Starting from the egg (solution) contained in each nest a Lévy flight is simulated to create a new solution. To preserve the total number of nests, this egg takes the place of a randomly chosen nest, but only if it has a better fitness. This step allows to diversify the exploration of the search space by performing a farfield optimization improved by the fact that the Lévy distribution is an heavy-tailed distribution;

    - A fraction `Pa` of worst eggs (bad solution) gets discovered by the host bird and the nest is abandoned. A new nest with a new solution is generated, biased toward two good quality eggs randomly picked from the population. This step allows to perform more of a locally intensified search by exploiting the neighborhood of current solutions.

    # Arguments
    - `f:Function` function to minimize.
    - `population::Array` array obtained from running the function [`init_nests`](@ref).
    - `lims...` a number of parameters corresponding to the problem dimensionality, each is a couple (arrays/tuples) of lower and upper bounds.
    - `gen::Int=40` number of generations.
    - `Pa::AbstractFloat=0.25` rate of cuckoo eggs which gets discovered and abandoned at each generation.
    - `alpha::AbstractFloat=1.0` a positive scaling parameter for step size.
    - `lambda::AbstractFloat=1.5` the exponentiation parameter for the Lévy distribution.

    # Examples
    ```julia
    julia> x1lims = (-10,10)
    julia> x2lims = (-15,15)
    julia> population = init_nests(5,x1lims,x2lims)
    julia> cuckoo!(function_name, population, x1lims, x2lims, gen=50, Pa=0.5, alpha=0.5, lambda=2.0)
    ([-0.00401120574383079, 0.00046356024376423543], -22.706426805416967)  
    ``` 
    """
    function cuckoo!(f::Function, population::Array, lims...;
                                        gen::Int=40,
                                        Pa::AbstractFloat=0.25,
                                        alpha::AbstractFloat=1.0,
                                        lambda::AbstractFloat=1.5)      
        @assert (lambda<=3.0 && lambda>=1.0) "Lambda should be between 1 and 3 (included)"
        @assert (alpha>0.0) "Alpha should be a positive value"
        @assert (Pa<=1.0 && Pa>=0.0) "Pa should be a value between 0 and 1 (included)"
        
        n = length(population) #number of nests 
        d = length(lims) #problem dimensionality
         
        #create array of Nest structs to hold both the position and the fitness
        nests = Nest.(population, f.(population))

        #save current best solution
        best_index = argmin([nests[i].fitness for i in 1:n]) 
        best_pos = nests[best_index].position
        best_fit = nests[best_index].fitness 

        #main loop for number of generations
        while gen > 0
            #from each nest a cuckoo performs a flight to a new position
            for i in 1:n
                #generate a new solution with Lévy flights 
                new_pos = nests[i].position .+ alpha*levy_step(d, lambda) 
                new_pos = check_limits(new_pos, lims...)
                new_fit = f(new_pos) 

                #choose a nest randomly, different from i 
                j = get_random_nest_index(n, not=Set(i))
                old_fit = nests[j].fitness 

                #replace j by new solution i if the fitness improves
                if new_fit < old_fit
                    nests[j].position = new_pos
                    nests[j].fitness = new_fit
                end
  
            end

            #sort from worst to best solution 
            sort!(nests, by = n -> n.fitness, rev=true)

            #a fraction Pa of worst nests (high fitness) gets discovered by the host bird 
            #and abandoned (at least two nests are not discovered)
            n_worst = floor(Int, n * Pa)
            n_worst = n_worst > n-2 ? n-2 : n_worst
 
            i = 1
            while i < n_worst  
                #randomly pick two (different) good solutions
                j = get_random_nest_index(n, not=Set(1:n_worst))
                k = get_random_nest_index(n, not=push!(Set(1:n_worst),j))
                nj = nests[j].position 
                nk = nests[k].position 

                #new solution generated by combining the two random good solutions
                new_pos = nests[i].position .+ alpha.*rand().*(nj .- nk)  
                new_pos = check_limits(new_pos, lims...)
                new_fit = f(new_pos)
                    
                nests[i].position = new_pos
                nests[i].fitness = new_fit
                
                i +=1
            end
               
            #save best solution
            best_index = argmin([nests[i].fitness for i in 1:n]) 
            best_pos = nests[best_index].position
            best_fit = nests[best_index].fitness 
            
            #for visualization purposes
            population .= [nests[i].position for i in 1:n] 
        
            gen -= 1
        end 
    return best_pos, best_fit
    end
end