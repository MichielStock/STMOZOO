# testset for the Fridge.jl package
@testset "Fridge" begin
    using Fridge

    testList = ["cheese","potato","tomato","cabbage"]
    testDict = Dict("fries" => ["potato","salt"], 
        "macaroni" => ["cheese", "salt", "jambon"], 
        "salad" => ["cabbage","tomato","oil","horseradish"],
        "chocolatemilk" => ["chocolate","milk"])

    testDict2 = Dict("fries" => ["potato","salt"], 
        "macaroni" => ["cheese", "salt", "jambon"])

    @testset "checkIngredients" begin
        # check if all ingredients are passed if no replacement is needed
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) == testList 

        # test for type
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) isa Vector{String}
    end

    @testset "fridgeObjective" begin
        # test objective for one recipe
        @test fridgeObjective([0,1,0,1,2]) == 16

        # test objective for multiple recipes
        @test fridgeObjective([[0,1,0,1,2],[1,0,0,0,3]]) == 40
        @test fridgeObjective([[0,1,0,1,2],[1,1,0,0,3]]) == Inf
    end

    @testset "greedyFindCombo" begin
        # test max number of recipes end
        @test greedyFindCombo(testList, testDict, 2) == Dict("salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

        # test all ingredients used end
        @test greedyFindCombo(testList, testDict, 3) == Dict("macaroni" => [1,0,0,0,2], "salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

        # test no recipes left end
        @test greedyFindCombo(testList, testDict2, 3) == Dict("macaroni" => [1,0,0,0,2], "fries" => [0,1,0,0,1])
    end

end