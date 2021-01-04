@testset "Raytracing" begin
    using STMOZOO.Raytracing, Plots

    w, h = 80, 60
    @testset "create_scene" begin
        # Create empty scene
        scene = create_scene(w, h)
        @test scene isa Matrix
        @test size(scene) == (h,w)
        @test all(element == 1.0 for element in scene)

        # Create scene with one object
        circle = draw_circle(3, 25, 45)
        scene = create_scene(w, h, circle, 0.5)
        @test count(x == 0.5 for x in scene) == length(circle)

        # Create scene with two objects
        circles = draw_circle.([15,10], [50,0], [30,40]);
        scene = create_scene(w, h, circles, [0.7, 0.9])
        @test count(x == 0.7 for x in scene) == length(circles[1])
        @test count(x == 0.9 for x in scene) == count((i > 0 &&
            j > 0 && i < h && j < w for (i,j) in circles[2]))
    end

    @testset "draw_circle" begin
        r, w_center, h_center = 10, 25, 15
        circle = draw_circle(r, w_center, h_center)
        @test circle isa Set
        @test count((x-h_center)^2+(y-w_center)^2 <= (r+0.5)^2
                    for (x,y) in circle) == length(circle)

    end
    
    @testset "add_objects!" begin
        scene = create_scene(w, h)

        # Add single object
        circle = draw_circle(3, 25, 45)
        add_objects!(scene, circle, 0.5)
        @test scene isa Matrix
        @test count(x == 0.5 for x in scene) == length(circle)

        # Add two objects
        circles = draw_circle.([15,10], [50,0], [30,40]);
        add_objects!(scene, circles, [0.7, 0.9])
        @test count(x == 0.7 for x in scene) == length(circles[1])
        @test count(x == 0.9 for x in scene) == count((i > 0 &&
            j > 0 && i < h && j < w for (i,j) in circles[2]))
   
    end
    
    @testset "get_neighbors" begin
        scene = create_scene(3,3)
        @test length(get_neighbors(scene, (1,1))) == 3
        @test length(get_neighbors(scene, (1,2))) == 5
        @test length(get_neighbors(scene, (2,1))) == 5
        @test length(get_neighbors(scene, (2,2))) == 8
    end

    @testset "dijkstra" begin
        scene = create_scene(40, 30, draw_circle(10, 25, 15), 0.75)
        source, sink = (10, 1), (16, 40)
        distances, previous = dijkstra(scene, source, sink)
        path = reconstruct_path(previous, source, sink)

        # This is compared with the old implementation where the scene was an adjacency list
        @test distances[sink] ≈ 35.821067811865476
        @test path == [(10, 1), (10, 2), (10, 3), (10, 4), (10, 5), (10, 6), (10, 7), (11, 8),
        (12, 9), (12, 10), (12, 11), (12, 12), (12, 13), (12, 14), (12, 15), (12, 16), (13, 17),
        (13, 18), (13, 19), (13, 20), (13, 21), (13, 22), (13, 23), (13, 24), (13, 25), (13, 26),
        (13, 27), (13, 28), (13, 29), (13, 30), (13, 31), (13, 32), (13, 33), (14, 34), (15, 35),
        (16, 36), (16, 37), (16, 38), (16, 39), (16, 40)]

        @test reconstruct_path(previous, (20,10), sink) == Array{Tuple{Int64,Int64},1}()
        @test reconstruct_path(previous, (50,70), sink) == Array{Tuple{Int64,Int64},1}()
    end

    w, h = 20, 10
    scene = create_scene(w, h)
    @testset "plot_pixel_edges!" begin
        p = plot()
        plot_pixel_edges!(p, scene)
        @test p isa Plots.Plot
        p[1][1][:linealpha] == 0.3

        p = plot()
        plot_pixel_edges!(p, scene; linealpha=0.7, yflip=true)
        @test p[1][1][:linealpha] == 0.7
        @test p[1][:yaxis][:flip] == true
    end

    @testset "plot_pixels!" begin
        p = plot()
        plot_pixels!(p, scene)
        @test p isa Plots.Plot
        @test p[1][1][:markersize] == 50/h

        p = plot()
        plot_pixels!(p, scene;  xlims=(0,w+1), xticks=0:5:w+1, markersize=8)
        @test Plots.get_ticks(p[1], p[1][:xaxis])[2] == string.(0:5:w+1)
        @test p[1][1][:markersize] == 8
    end

    @testset "plot_circle!" begin
        r, w_center, h_center = 3, 10, 5
        p = plot()
        plot_circle!(p, r, w_center, h_center)
        @test p isa Plots.Plot
        @test p[1][1][:seriestype] == :shape
        @test p[1][1][:x] ≈ w_center .+ r*sin.(LinRange(0, 2π, 500))

        p = plot()
        plot_circle!(p, r, w_center, h_center, true; markeralpha=0.8)
        @test p[1][1][:seriestype] == :scatter
        @test p[1][1][:markeralpha] == 0.8
        @test p[1][1][:x] == last.(draw_circle(r, w_center, h_center))

    end

    @testset "plot_paths!" begin
        test_circle = draw_circle(20, 45, 30)
        w,h = 80,60
        scene = create_scene(w, h, test_circle, 0.7)
        source, sink = (h÷2,1), (45, w)
        path = [reconstruct_path(dijkstra(scene, source, sink)[2],
                source, sink)]

        p = plot()
        plot_paths!(p, path; ylims=(0,h+1), yticks=0:5:h+1)
        @test p isa Plots.Plot
        @test p[1][1][:x] == last.(path[1][1:2])
        @test p[1][1][:linecolor] == RGBA{Float64}(1.0,0.0,0.0,1.0)
        @test Plots.get_ticks(p[1], p[1][:yaxis])[2] == string.(0:5:h+1)
    end
end