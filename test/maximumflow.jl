@testset "MaximumFlow" begin
    using STMOZOO.MaximumFlow
    test_mat = test_mat = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0]

    @testset "res_network" begin
        @test res_network(test_mat,test_mat) == test_mat'
    end


end