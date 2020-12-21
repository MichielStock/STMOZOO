# Unit test on the Cuckoo module

@testset "Cuckoo" begin
    using STMOZOO.Cuckoo 
    using STMOZOO.Cuckoo: levy_step, get_random_nest_index, check_limits

    @testset "initialize nests" begin
        n = 5
        xlims=((-10,10), (-20,20), (-10,10))
        extr_lims=((-10,-10),(-10,-10))
        wrong_lims_1=((10,-10), (-10,10))
        wrong_lims_2=(5, (-10,10))
        wrong_lims_3=((-5,5,5), (-10,10))

        #type test
        @test init_nests(n, xlims[1], xlims[2], xlims[3], xlims[3]) isa Array
        @test init_nests(n, extr_lims[1], extr_lims[2]) isa Array 
        @test init_nests(2, xlims[1], xlims[2], xlims[3]) isa Array 

        #dimension test
        @test length(init_nests(n, xlims[1], xlims[2], xlims[3])) == n

        #correctness first point
        @test all([point[1] >= xlims[1][1] for point in init_nests(n, xlims[1], xlims[2], xlims[3])]) 
        @test all([point[1] <= xlims[1][2] for point in init_nests(n, xlims[1], xlims[2], xlims[3])]) 

        #correctness last point
        @test all([point[length(xlims)] >= last(xlims)[1] for point in init_nests(n, xlims[1], xlims[2], xlims[3])]) 
        @test all([point[length(xlims)] <= last(xlims)[2] for point in init_nests(n, xlims[1], xlims[2], xlims[3])]) 

        #assertion errors
        @test_throws AssertionError init_nests(n, wrong_lims_1[1], wrong_lims_1[2]) 
        @test_throws AssertionError init_nests(n, wrong_lims_2[1], wrong_lims_2[2]) 
        @test_throws AssertionError init_nests(n, wrong_lims_3[1], wrong_lims_3[2]) 
        @test_throws AssertionError init_nests(1, xlims[1], xlims[2], xlims[3])
    end

    d = 3
    lambda= 3/2
    @test levy_step(d, lambda) isa Array
   
    @testset "Get random nest index" begin
        n=3
        @test get_random_nest_index(n) isa Int

        @test get_random_nest_index(n, not=Set([1])) isa Int
        @test get_random_nest_index(n, not=Set([1,2])) == 3

        @test_throws AssertionError get_random_nest_index(n, not=Set([1,2,3]))

    end

    @testset "Check limits" begin
        wrong_pos = [1.23, 2.34, -1.2]
        pos_in=[5.0, 5.0]
        pos_out_down_one=[-11.0, 5.0]
        pos_out_up_two=[5.0, 11.0]
        pos_out_all=[-11.0,11.0]
        xlims=((-10,10),(-10,10))


        @test check_limits(pos_in, xlims[1], xlims[2]) isa Array{Float64}

        @test check_limits(pos_in, xlims[1], xlims[2]) == pos_in
        @test check_limits(pos_out_down_one, xlims[1], xlims[2]) == [-10.0,5.0]
        @test check_limits(pos_out_up_two, xlims[1], xlims[2]) == [5.0,10.0]
        @test check_limits(pos_out_all, xlims[1], xlims[2]) == [-10.0,10.0]

        @test_throws AssertionError check_limits(wrong_pos, xlims[1], xlims[2])
    end

    @testset "Cuckoo method" begin
        function ackley(x; a=20, b=0.2, c=2π) 
            d = length(x)     
        return -a * exp(-b*sqrt(sum(x.^2)/d)) - exp(sum(cos.(c .* x))/d) 
        end 

        x1lims = (-10, 10) 
        x2lims = (-10, 10) 
      
        population = init_nests(25, x1lims, x2lims)  

        @test cuckoo!(ackley, population, x1lims, x2lims) isa Tuple 
        @test cuckoo!(ackley, population, x1lims, x2lims)[1][1] ≈ 0  atol=0.1
        @test cuckoo!(ackley, population, x1lims, x2lims)[1][2] ≈ 0  atol=0.1

        #parameters?
        #types?

    end

end
