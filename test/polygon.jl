# example of a unit test in Julia
# runs a test for a certain module
# to run the tests, first open the package manager (`]` in REPL), 
# activate the project if not done so and then enter `test`

# wrap all your tests and subgroups in a `@testset` block
@testset "Polygon" begin
    using STMOZOO.polygon, Colors  # load YOUR module

    @testset "sameSideOfLine" begin
        line = [1 + 1im, 2 + 3im]
        point1 = 0 + 3im #left of line
        point2 = 1 + 4im #left
        point3 = 2 + 3.3im #left
        point4 = 1.5 + 1im #right
        point5 = 4 + 3im #right
        point6 = 4 + 4im #right

        # points = [point1, point2, point3, point4, point5, point6]
        # p = plot(-1:5, -1:5, label = false)
        # plot!([real(line[1]), real(line[2])], [imag(line[1]), imag(line[2])], label = false)
        # for i in 1:6
        #     scatter!([real(points[i])], [imag(points[i])], label = "$i")
        # end
        # display(p)

        @test sameSideOfLine(point1, point2, line) == true
        @test sameSideOfLine(point1, point3, line) == true
        @test sameSideOfLine(point1, point4, line) == false
        @test sameSideOfLine(point1, point5, line) == false
        @test sameSideOfLine(point1, point6, line) == false
        @test sameSideOfLine(point3, point4, line) == false
        @test sameSideOfLine(point5, point6, line) == true


    end

    @testset "in triangle" begin
        T1 = Triangle(3 + 2im, 4 + 4im, 5 + 0im, RGB(0, 0, 1))
        testpoint1 = Vector{Complex}(undef, 8)
        testpoint1[1] = 1 + 3im # not in T1
        testpoint1[2] = 5 + 2im # not in T1
        testpoint1[3] = 4 + 5im # not
        testpoint1[4] = 0.9 + 2im # no
        testpoint1[5] = 3 + 2im # in T1 (on edge)
        testpoint1[6] = 4 + 3im # in T1
        testpoint1[7] = 4.5 + 1im # in
        testpoint1[8] = 3.5 + 2.5im # yes
        
        T2 = Triangle(3 + 2im, 3 + 4im, 5 + 1im, RGB(0, 0, 1))
        testpoint2 = Vector{Complex}(undef, 8)
        testpoint2[1] = 4 + 1im #not
        testpoint2[2] = 3 + 0.5im #not
        testpoint2[3] = 5 + 3im #not
        testpoint2[4] = 1 + 2im #not
        testpoint2[5] = 4 + 2im #yes
        testpoint2[6] = 3 + 2im #yes
        testpoint2[7] = 3.5 + 2.5im #yes
        testpoint2[8] = 3.1 + 3.5im #yes

        for i in 1:4
            @test (testpoint1[i] in T1) == false
            @test (testpoint2[i] in T2) == false
        end
        for i in 5:8
            @test (testpoint1[i] in T1) == true
            @test (testpoint2[i] in T2) == true
        end 
    end

    @testset "checkTriangle" begin
        m = 232
        n = 412
        testtriangle = Vector{Triangle}(undef, 10)
        testtriangle[1] = Triangle(20 + 30im, 400 + 250im, 450 + 120im, RGB(1, 0, 0)) # Good triangle
        testtriangle[2] = Triangle(20 + 30im, 100 + 100im, 50 + 120im, RGB(1, 1, 0)) # Good triangle
        testtriangle[3] = Triangle(300 + 450im, 100 + 100im, 60 + 400im, RGB(1, 0, 1)) # Good triangle
        testtriangle[4] = Triangle(300 + 100im, 300 + 400im, 60 + 100im, RGB(0, 1, 0)) # Good triangle
        testtriangle[5] = Triangle(-100 + 50im, 200 + 150im, 100 + 250im, RGB(0.5, 0, 0)) # Good triangle

        testtriangle[6] = Triangle(446 + 193im, 401 + 246im, 495 + 298im, RGB(1, 0, 0)) # STUPID triangle (all points outside of canvas)
        testtriangle[7] = Triangle(59 + 189im, 58 + 270im, 57 + 5im, RGB(1, 0, 1)) # STUPID triangle (too thin)
        testtriangle[8] = Triangle(-59 + 189im, -20 + 63im, -200 + 69im, RGB(1, 0, 1)) # STUPID triangle (points outside of canvas, all x are wrong)
        testtriangle[9] = Triangle(40 + 150im, 239 + 151im, 20 + 150im, RGB(1, 0, 1)) # STUPID triangle (too thin)
        testtriangle[10] = Triangle(211 + 209im, 338 + 334im, 544 + 534im, RGB(1, 0, 0)) # STUPID triangle (very elongated)

        for i in 1:5
            @test checkTriangle(testtriangle[i], m, n) == false # These are not stupid triangles
        end

        for i in 6:10
            @test checkTriangle(testtriangle[i], m, n) == true # These are stupid triangles
        end
    end


end