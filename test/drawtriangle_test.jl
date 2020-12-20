using STMOZOO.polygon, Images, Colors

img = load("src/figures/Bubberduck.jpg")

m = length(img[:, 1])
n = length(img[1, :])

polyimg = fill(RGB(1, 1, 1), m, n)

testtriangle = Triangle(20 + 30im, 400 + 250im, 450 + 120im, RGB(1, 0, 0))
testtriangle2 = Triangle(20 + 30im, 100 + 100im, 50 + 120im, RGB(1, 1, 0))
testtriangle3 = Triangle(300 + 450im, 100 + 100im, 60 + 400im, RGB(1, 0, 1))
testtriangle4 = Triangle(300 + 100im, 300 + 400im, 60 + 100im, RGB(0, 1, 0))
testtriangle5 = Triangle(-100 + 50im, 200 + 150im, 100 + 250im, RGB(0.5, 0, 0))

olddrawtriangle(testtriangle5, polyimg)
drawtriangle(testtriangle5, polyimg)


@time begin
    for i in 1:100
        drawtriangle(testtriangle, polyimg)
        drawtriangle(testtriangle2, polyimg)
        drawtriangle(testtriangle3, polyimg)
        drawtriangle(testtriangle4, polyimg)
    end
end
@time begin
    for i in 1:100
        olddrawtriangle(testtriangle, polyimg)
        olddrawtriangle(testtriangle2, polyimg)
        olddrawtriangle(testtriangle3, polyimg)
        olddrawtriangle(testtriangle4, polyimg)
    end
end

while true
    triangle = generateTriangle(m, n)
    print(triangle.p1, " ", triangle.p2, " ", triangle.p3, "\n")
    #olddrawtriangle(triangle, polyimg)
    drawtriangle(triangle, polyimg)
end

eviltriangle = Triangle(98.0 + 169.0im, 385.0 + 64.0im, 10.0 + 189.0im, RGB{Float64}(0.680213559428791,0.6246788812289452,0.24755073288687024))
olddrawtriangle(eviltriangle, polyimg)
drawtriangle(eviltriangle, polyimg)

evillertriangle = Triangle(343 + 12im, 276 + 13im, 336 + 12im, RGB(1, 0, 0))
olddrawtriangle(evillertriangle, polyimg)
drawtriangle(evillertriangle, polyimg)

primeevil = Triangle(446 + 193im, 401 + 246im, 495 + 298im, RGB(1, 0, 0))
olddrawtriangle(primeevil, polyimg)

trueevil = Triangle(211 + 209im, 338 + 334im, 544 + 534im, RGB(1, 0, 0))
olddrawtriangle(trueevil, polyimg)

eh = Triangle(271 + 165im, 302 + 62im, 304 + 55im, RGB(0, 1, 1))