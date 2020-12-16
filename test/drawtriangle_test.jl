img = load("STMOZOO/src/figures/Bubberduck.jpg")

m = length(img[:, 1])
n = length(img[1, :])

polyimg = fill(RGB(1, 1, 1), m, n)


polyimg = fill(RGB(1, 1, 1), m, n)
testtriangle = Triangle(20 + 30im, 400 + 250im, 450 + 120im, RGB(1, 0, 0))
testtriangle2 = Triangle(20 + 30im, 100 + 100im, 50 + 120im, RGB(1, 1, 0))
testtriangle3 = Triangle(300 + 450im, 100 + 100im, 60 + 400im, RGB(1, 0, 1))

#drawtriangle(testtriangle, polyimg)
drawtriangle(testtriangle2, polyimg)
drawtriangle(testtriangle3, polyimg)