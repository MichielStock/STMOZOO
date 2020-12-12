module Cuckoo 

    # export functions relevant for the user
    export ackley, init_nests, cuckoo, check_boundaries, get_random_nest# Nest, step 
    # nb do not export nest, step
 
    using Distributions, SpecialFunctions
    
    

    # d dimensional function 
    function ackley(x; a=20, b=0.2, c=2π)
        d = length(x)
        return -a * exp(-b*sqrt(sum(x.^2)/d)) -
            exp(sum(cos.(c .* x))/d)
    end
    

    # For testing purposes, to be removed and put in notebook
    #x1lims = (-10, 10)
    #x2lims = (-10, 10)
    #population = init_nests(6, x1lims, x2lims) 


    mutable struct Nest{T<:Array}
        position::T
        fitness::Float64
    end 

    function init_nests(n, lims...)    
        return [([(u - l) * rand() + l for (l, u) in lims]) for i in 1:n] 
    end 
    #init_nests(4,(1,2),(4,5),(6,7)) <- 4 points in 3 dimensions , each dimension has an upper/lower bound

    function levy(d)  
        #choice of random direction from uniform distribution
        dir = [rand() for x in 1:d]
        
        #generation of steps obeying Lévy distribution with Mantegna algorithm
        beta=3/2
        sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);

        u=rand(Normal(0,sigma))
        v=rand(Normal(0,1))
        step=u./abs(v).^(1/beta)
 
        return step.*dir
        #return [rand(truncated(Levy(mu),l,u)) for (l, u) in lims]
    end

    function heaviside(x) 
        return ifelse(x < 0, zero(x), ifelse(x > 0, one(x), oftype(x,0.5)))
    end

    function get_random_nest(n ;not::Int=0)        
        new_nest = floor(Int, rand(1:n))
        while new_nest == not 
            new_nest = floor(Int, rand(1:n))
        end
        return new_nest
    end

    function check_boundaries(new_pos, lims...)
        @assert length(new_pos) == length(lims) "The number of dimensions doesn't correspond to the number of dimension boundaries"
        
        n = length(new_pos)
        new_pos = [ifelse(new_pos[d] < lims[d][1], lims[d][1], ifelse(new_pos[d] > lims[d][2], lims[d][2], new_pos[d])) for d in 1:n]        
        return new_pos
    end

    #alpha=scaling parameter (positive), s=stepsize, pa=discoverity rate of alien eggs
    function cuckoo(f::Function, population, lims...; mu=1, max_it=1000, Pa=0.5, alpha=1, s=1)  
        nests = Nest.(population, f.(population))

        n = length(population)  
        d = length(lims)
        
        best_index = argmin([nests[i].fitness for i in 1:n]) 
        best_pos = nests[best_index].position
        best_fit = nests[best_index].fitness 

        while max_it > 0
            #get index for an existing cuckoo solution randomly
            i = floor(Int, rand()*n + 1) 

            #generate a new solution with Lévy flights
            new_pos = nests[i].position .+ alpha*levy(d)
            new_pos = check_boundaries(new_pos, lims...)
            new_fit = f(new_pos) 

            #choose a nest randomly, different from i -> SHOULD I AVOID IT IF J IS BEST?
            j = get_random_nest(n, not=i)
            old_fit = nests[j].fitness 

            #replace j by new solution i
            if new_fit < old_fit
                nests[j].position = new_pos
                nests[j].fitness = new_fit
            end

            #a fraction Pa of nests are abandoned
            abandon = floor(Int, n*Pa)
            sorted_indexes = sort([(nests[i].fitness, i) for i in 1:n], rev=true) 

            #new solutions are generated with Heaviside function 
            i = 1
            while i < abandon
                j = get_random_nest(n)
                k = get_random_nest(n, not=j)
                nj = nests[j].position 
                nk = nests[k].position 
                new_pos = nests[i].position .+ alpha*s.*heaviside(Pa-rand()).*(nj-nk) #needs to be bounded
                new_pos = check_boundaries(new_pos, lims...)
                new_fit = f(new_pos)
                
                nests[i].position = new_pos
                nests[i].fitness = new_fit
                i += 1
            end
                
            best_index = argmin([nests[i].fitness for i in 1:n]) 
            best_pos = nests[best_index].position
            best_fit = nests[best_index].fitness 

            #print(best_pos, "\t",best_fit, "\n")
        
            max_it -= 1
        end 
    return best_pos, best_fit
    end
end