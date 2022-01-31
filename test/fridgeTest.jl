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

    testDict3 = Dict("fries" => ["potato","salt"], 
        "macaroni" => ["cheese", "salt", "jambon"], 
        "salad" => ["cabbage","tomato","oil","horseradish"])

    testDict4 = Dict("fries" => ["potato","salt"], 
    "macaroni" => ["cheese", "salt", "jambon"], 
    "salad" => ["cabbage","tomato","oil","horseradish"],
    "chocolatemilk" => ["chocolate","milk"],
    "waffle" => ["sugar", "eggs", "milk"],
    "thea" => ["herbs", "water"],
    "coffee" => ["coffeebeans", "water"])

    testSolution = Dict("salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

    @testset "checkIngredients" begin
        # check if all ingredients are passed if no replacement is needed
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) == testList 

        # test for type
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) isa Vector{String}
    end

    @testset "greedyFindCombo" begin
        # test max number of recipes end
        @test greedyFindCombo(testList, testDict, 2) == Dict("salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

        # test all ingredients used end
        @test greedyFindCombo(testList, testDict, 3) == Dict("macaroni" => [1,0,0,0,2], "salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

        # test no recipes left end
        @test greedyFindCombo(testList, testDict2, 3) == Dict("macaroni" => [1,0,0,0,2], "fries" => [0,1,0,0,1])

        # test no recipes left that use ingredients from the fridge
        @test greedyFindCombo(testList, testDict, 4) == Dict("macaroni" => [1,0,0,0,2], "salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])
    end

    @testset "randomCombo" begin
        # test all ingredients used end
        @test randomCombo(testList, testDict3, 3) == Dict("macaroni" => [1,0,0,0,2], "salad" => [0,0,1,1,2], "fries" => [0,1,0,0,1])

        # test no recipes left end
        @test randomCombo(testList, testDict2, 3) == Dict("macaroni" => [1,0,0,0,2], "fries" => [0,1,0,0,1])

        # test length of max number recipes end
        @test length(values(randomCombo(testList, testDict, 2))) == 2
    end

    @testset "Neighbour" begin
        # test not random with empty tabuList
        @test "macaroni" in keys(Neighbour(testSolution, testList, testDict, 2, [], false))

        # test not random with tabuList
        @test !in("macaroni",keys(Neighbour(testSolution, testList, testDict, 2, ["macaroni"], false)))

        # test length of random with empty tabuList
        @test length(values(Neighbour(testSolution, testList, testDict, 2, [], true))) == 2
    end

    @testset "SAFindCombo" begin
        # test output type
        @test typeof(SAFindCombo(testSolution,  testList, testDict4, 2, true, tabulength=1)) == Dict{Any, Any}

        # test output length
        @test length(values(SAFindCombo(testSolution,  testList, testDict4, 2, true, tabulength=1))) == 2
    end
end