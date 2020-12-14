@testset "MaximumFlow" begin
    using STMOZOO.MaximumFlow,LinearAlgebra
    test_mat = [0 8 2 0; 0 0 2 4;0 0 0 1;0 0 0 0]
    cur_mat = [0 1 1 0; 0 0 1 1;0 0 0 1;0 0 0 0]

    @testset "cap" begin
        @test cap(test_mat) isa Array # test type
        @test all(cap(test_mat) .>= 0) # test case
        @test length(cap(test_mat)) == 5 # test case
    end

    @testset "res_network" begin
        @test res_network(test_mat,cur_mat) isa Array{Int,2} # test type
        @test res_network(test_mat,test_mat) == test_mat' # test case
        @test all(res_network(test_mat,cur_mat) .>= 0) # test case
        @test tr(res_network(test_mat,cur_mat)) == 0 # test case
        @test res_network(test_mat,zeros(Int,4,4)) == test_mat # test case
        @test_throws AssertionError res_network(rand(Int,3,3),rand(Int,3,4))
        @test_throws AssertionError res_network(rand(Int,5,3),rand(Int,4,4))
        @test_throws AssertionError res_network(rand(Int,5,5),rand(Int,4,4))
    end


end