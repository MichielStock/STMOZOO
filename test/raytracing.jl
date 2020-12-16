@testset "Raytracing" begin
    using STMOZOO.Raytracing

    w, h = 150, 100

    @testset "create_scene" begin
        scene = create_scene(w, h)

        @test scene isa Array
        @test size(scene) == (h,w)
        @test all(element == 1.0 for element in scene)
    end

end