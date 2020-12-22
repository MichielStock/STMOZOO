@testset "EulerianPath" begin
    using STMOZOO.EulerianPath

    @testset "create_adj_list" begin
        
    @test create_adj_list([[1, 5], [1, 2], [1, 4], [1, 3], [5, 2], [2, 3], [2, 4], [3, 4], [3, 6], [4, 6]]) == {1: [5, 2, 4, 3], 5: [1, 2], 2: [1, 5, 3, 4], 4: [1, 2, 3, 6], 3: [1, 2, 4, 6], 6: [3, 4]}

    end
end