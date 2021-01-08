# example of a unit test in Julia
# runs a test for a certain module
# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`

# wrap all your tests and subgroups in a `@testset` block
@testset "BeesAlgorithm" begin
    using STMOZOO.BeesAlgorithm  # load YOUR module
    using STMOZOO.BeesAlgorithm: initialize_population
    using STMOZOO.BeesAlgorithm: compute_objective
    using STMOZOO.BeesAlgorithm: compute_fitness
    using STMOZOO.BeesAlgorithm: employed_bee_phase
    using STMOZOO.BeesAlgorithm: scouting_phase
    using STMOZOO.BeesAlgorithm: onlooker_bee_phase
    using STMOZOO.BeesAlgorithm: foodsource_info_prob
    using STMOZOO.BeesAlgorithm: create_newsolution

    S = 24
    bounds_lower = [-100,-100,-100,-100]
    bounds_upper = [100,100,100,100]
    D = 4
    limit = D * (S/2)
    T = 500
    n = Int8(S/2)

    @testset "initialize_population" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        @test length(population) == n
        @test all([bounds_lower <= population[i] <= bounds_upper for i in 1:length(population)])

    end

    @testset "compute_objective" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        objectives = compute_objective(population,sphere)
        @test length(objectives) == length(population)

    end

    @testset "compute_fitness" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        objectives = compute_objective(population,sphere)
        fitness = compute_fitness(objectives)
        @test length(fitness) == length(objectives) == length(population)

    end

    @testset "foodsource_info_prob" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        objectives = compute_objective(population,sphere)
        fitness = compute_fitness(objectives)
        probab = foodsource_info_prob(fitness)
        @test length(probab) == length(fitness)
        @test all(0 .≤ probab .≤ 1)

    end    

    @testset "create_newsolution" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        solution = [4, 0, 1, 4]
        new_solution = create_newsolution(solution, population, bounds_lower, bounds_upper)
        @test length(new_solution) == length(solution)
        @test sum(new_solution .==  solution) == D-1

    end   

    @testset "employed_bee_phase" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        trial = zeros(size(population)[1])
        population_new_evolved, fitness_new_evolved, objective_new_evolved, newtrial = employed_bee_phase(population, bounds_lower, bounds_upper, trial,n ,sphere)
        
        @test length(population_new_evolved) == length(population)
        @test length(newtrial) == length(trial)
    end  

    @testset "onlooker_bee_phase" begin

        population = initialize_population(D, bounds_lower, bounds_upper, n)
        trial = zeros(size(population)[1])
        population_new_evolved, fitness_new_evolved, objective_new_evolved, newtrial = onlooker_bee_phase(population, bounds_lower, bounds_upper, trial,n ,sphere)
        
        @test length(population_new_evolved) == length(population)
        @test length(newtrial) == length(trial)
    end

    @testset "scouting_phase" begin
        
        population = initialize_population(D, bounds_lower, bounds_upper, n)
        trial = ones(size(population)[1])
        objective= compute_objective(population,sphere)
        fitness = compute_fitness(objective)
        population_new_evolved, fitness_new_evolved, objective_new_evolved, newtrial  = scouting_phase(population, bounds_lower, bounds_upper,D, trial, fitness, objective, 0, sphere)
        
        @test length(objective) == length(fitness)
        @test length(population_new_evolved) == length(population)
        @test length(newtrial) == length(trial)
    end

    @testset "ArtificialBeeColonization" begin

        optimal_solution,populations,best_fitness_tracker = ArtificialBeeColonization(D, bounds_lower, bounds_upper, S, T, limit, sphere)

        @test length(optimal_solution) == length(bounds_lower) == length(bounds_upper) == D  
        @test optimal_solution isa Vector
        @test optimal_solution >= bounds_lower
        @test optimal_solution <= bounds_upper

    end


end