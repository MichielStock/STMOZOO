# testset for the Fridge.jl package
@testset "Fridge" begin
    using Fridge

    testList = ["cheese","potato","tomato","cabbage"]

    @testset "checkIngredients" begin
        # check if all ingredients are passed if no replacement is needed
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) == testList 

        # test for type
        @test checkIngredients(testList,["cheese","salt","tomato","chocolate"]) isa Vector{String}
    end

end