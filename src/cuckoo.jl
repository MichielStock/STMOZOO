module Cuckoo 

    # export functions relevant for the user
    export init_nests, cuckoo!  
 
    # import external packages
    using Distributions, SpecialFunctions
 
    """
        Nest{T<:Array}
    
    Each nest holds one solution, which is characterized by an array of floats containing for each dimension of the
    problem the value of the solution (stored in `position`) and the `fitness` of the solution evaluated in the 
    objective function.        
    """
    mutable struct Nest
        position::Array{Float64}
        fitness::Float64
    end 


    """
        init_nests(n::Int, lims...)
        
    Initializes `n` random solutions, each dimension of the solution is constrained by an upper and a lower bound 
    contained in the `lims` parameter which automatically collects in a tuple all the couples of bounds passed for
    each dimension.
    """
    function init_nests(n::Int, lims...)    
        @assert all([length(lim)==2 for lim in lims]) "Every bound should be composed of a lower and an upper limit." 
        @assert all([l <= u for (l, u) in lims]) "Every bound should be defined with the lower one as first element and the upper one as second"
        @assert n>1 "The population should be composed of at least two individuals"

        return [([(u - l) * rand() + l for (l, u) in lims]) for i in 1:n] 
    end  

    
    """
        levy_step(d::Int, lambda::AbstractFloat)
        
    Returns the step to add to a current solution. The parameter `d` indicates the number of dimensions of the solution.
    The direction is randomly picked from a uniform distribution and the stepsize is drawn from a Lévy distribution with 
    exponent`lambda`, obtained through implementing a simplified version of Mantegna algorithm. This allows to simulate 
    a Lévy flight performed by a cuckoo to reach a new nest.
    """
    function levy_step(d::Int, lambda::AbstractFloat)
        #choice of random direction
        dir = [rand() for x in 1:d]
        
        #generation of stepsize  
        sigma=(gamma(1+ lambda)*sin(pi* lambda/2)/(gamma((1+ lambda)/2)* lambda*2^(( lambda-1)/2)))^(1/ lambda)

        steps = Vector{Float64}()
        for x in 1:d
            u=rand(Normal(0,sigma))
            v=rand(Normal(0,1))
            push!(steps, u./abs(v).^(1/lambda))
        end
 
        return steps.*dir  
    end


    """
        get_random_nest_index(n::Int; not::Set{Int}=Set([0])) 

    Randomly returns an index between 1 and `n` representing one of the nests. If `not` is specified, the returned index must be
    different from any element in it.
    """
    function get_random_nest_index(n::Int; not::Set{Int}=Set([0])) 
        @assert length(not)<n "Not possible to find an index not in the set"       
        new_nest = floor(Int, rand(1:n))
        while new_nest in not 
            new_nest = floor(Int, rand(1:n))
        end
        return new_nest
    end


    """
        check_limits(new_pos::Array{Float64}, lims...)

    Checks if a newly generated solution is within the limits, if not the solution is returned having as values the limits 
    that were violated.
    """
    function check_limits(new_pos::Array{Float64}, lims...)
        @assert length(new_pos) == length(lims) "The number of dimensions doesn't correspond to the number of dimension limits"
        
        n = length(new_pos)
        new_pos = [ifelse(new_pos[d] < lims[d][1], Float64(lims[d][1]), ifelse(new_pos[d] > lims[d][2], Float64(lims[d][2]), new_pos[d])) for d in 1:n]        
        return new_pos
    end


    """ 
        cuckoo(f::Function, population::Array, lims...; gen::Int=40, Pa::AbstractFloat=0.25, alpha::AbstractFloat=1.0, lambda::AbstractFloat=1.5)    

    Implementation of the cuckoo search method. It takes as input the objective function to minimize, the population obtained from
    running the function `init_nests` and couples (both arrays or tuples) of lower and upper limits for each dimension of the problem. 

    Optional parameters are: `gen` number of generations, `Pa` rate of cuckoo eggs which gets discovered and abandoned at each 
    generation, a positive scaling parameter `alpha` for step size and the exponentiation parameter for the Lévy distribution `lambda` 
    
    The algorithm runs for `gen` generations and at each iteration these two steps of optimization are carried out:

    * Starting from the egg (solution) contained in each nest a Lévy flight is simulated to create a new solution. To preserve the total number of nests, this egg takes the place of a randomly chosen nest, but only if it has a better fitness. This step allows to diversify the exploration of the search space by performing a farfield optimization improved by the fact that the Lévy distribution is an heavy-tailed distribution;

    * A fraction `Pa` of worst eggs (bad solution) gets discovered by the host bird and the nest is abandoned. A new nest with a new solution is generated, biased toward two good quality eggs randomly picked from the population. This step allows to perform more of a locally intensified search by exploiting the neighborhood of current solutions.
    """
    function cuckoo!(f::Function, population::Array, lims...; gen::Int=40, Pa::AbstractFloat=0.25, alpha::AbstractFloat=1.0, lambda::AbstractFloat=1.5)      
        
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
            sorted_indexes = sort([(nests[i].fitness, i) for i in 1:n], rev=true) 

            #a fraction Pa of worst nests (high fitness) are eligible for being discovered by the host bird (at least two nests are not eligible)
            n_worst = floor(Int, n*Pa)
            n_worst = ifelse(n_worst > n-2, n-2, n_worst)

            bad_nests = [s[2] for s in sorted_indexes[1:n_worst]]
 
            i = 1
            while i < n_worst 
                #cuckoo egg is discovered and abandoned with probability Pa
                if rand() < Pa
                    worst_index = bad_nests[i]

                    #randomly pick two (different) good solutions
                    j = get_random_nest_index(n, not=Set(bad_nests))
                    k = get_random_nest_index(n, not=push!(Set(bad_nests),j))
                    nj = nests[j].position 
                    nk = nests[k].position 

                    #new solution generated by combining the two random good solutions
                    new_pos = nests[worst_index].position .+ alpha.*rand().*(nj .- nk)  
                    new_pos = check_limits(new_pos, lims...)
                    new_fit = f(new_pos)
                    
                    nests[worst_index].position = new_pos
                    nests[worst_index].fitness = new_fit
                end 
                i +=1
            end
               
            #save best solution
            best_index = argmin([nests[i].fitness for i in 1:n]) 
            best_pos = nests[best_index].position
            best_fit = nests[best_index].fitness 

            #print(best_pos, "\t",best_fit, "\n")

            population .= [nests[i].position for i in 1:n] 
        
            gen -= 1
        end 
    return best_pos, best_fit
    end
end