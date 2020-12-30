# Bram Spanoghe
# Ya got triangles?


# all your code is part of the module you are implementing
# and that's on that
module polygon

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using Images, Colors, Plots, Random
import Base: in

export Triangle, drawtriangle, olddrawtriangle, colordiffsum, samesideofline, triangleevolution, generatetriangle

"""
A type Shape so the code can be made to work with e.g. rectangles as well. For now, only triangles are supported.
"""
abstract type Shape end

"""
I define triangles with the coordinates of their 3 points and a color.
"""
struct Triangle <: Shape
    p1::ComplexF64 
    p2::ComplexF64
    p3::ComplexF64
    color::RGB{Float64} # I think RGB is an abstract type, so RGB{Float64} # Done
end

"""
    samesideofline(point::Complex, trianglepoint::Complex, line::Complex)

Computes whether point and trianglepoint are on the same side of the line "line".
x value of a point is represented with the real part of a complex number, y value by the imaginary part.
"""
function samesideofline(point::Complex, trianglepoint::Complex, line::Tuple)
    p1 = line[1]
    p2 = line[2]
    x1, y1 = real(p1), imag(p1)
    x2, y2 = real(p2), imag(p2)
    
    # making the lines equation from the given 2 points: y = ax + b
    if x1 != x2 #not a vertical line
        a = (y2 - y1) / (x2 - x1)
        # intercept from y = ax + b => b = y_1 - ax_1 
        b = y1 - a*x1

        # substract y-value from line at point's x-value from points y-value 
        linediff_point = imag(point) - (a * real(point) + b)
        linediff_trianglepoint = imag(trianglepoint) - (a * real(trianglepoint) + b)
        # if a point is above the line, this value will be positive, if it's beneath the line, the value will be negative
        # if both points are on the same side of the line, both values will have the same sign
        # if we multiply the values, a positive sign will indicate they're on the same side and a negative sign means they're on separate sides

        return sign(linediff_point) == sign(linediff_trianglepoint)

    else #x1 == x2: A vertical line: a cannot be calculated (division by 0)
        #equation is now x = b
        b = x1
        linediff_point = real(point) - b
        linediff_trianglepoint = real(trianglepoint) - b
        # Difference between point's x-value and line's x-value
        # Same principle as above
        return sign(linediff_point) == sign(linediff_trianglepoint)  # I like this better # Accepted as replacement for linediff_point*linediff_trianglepoint ≥ 0
    end  

end

# using LinearAlgebra

# function sameside((p1, p2), p3, p)
#     x1, y1 = p1
#     x2, y2 = p2
#     n = [x1-x2, y2-y1] 
#     return (n ⋅ p3) * (n ⋅ p) > 0.0
# end

"""
    in(point::Complex, triangle::Triangle)
Computes whether your point is inside of your triangle
"""
function in(point::Complex, triangle::Triangle)
    # Checks whether the point on a canvas is part of the triangle
    tpoints = (triangle.p1, triangle.p2, triangle.p3)
    
    #checks = Vector{Bool}(undef, 3)
    # for i in 1:3  # FIXEDME: if you hardcode it using `&&` it will be much faster # hardcoded: increased speed of algorithm by 150%! Glorious!
    #     line = tpoints[1:3 .!= i] # e.g. points 2 and 3 if i = 1
    #     trianglepoint = tpoints[i] #e.g. point 1 if i = 1
        
    #     checks[i] = samesideofline(point, trianglepoint, line)
    # end
    # check = all(checks)

    check = samesideofline(point, tpoints[1], tpoints[2:3]) && samesideofline(point, tpoints[2], tpoints[[1, 3]]) && samesideofline(point, tpoints[3], tpoints[1:2])

    return check
end

in((x, y), shape::Shape) = in(complex(x, y), shape)



"""
Unused function. Easy to understand, but very inefficient. 
The real drawtriangle functions is quite difficult to understand, so reading this first will probably help.
It simply goes over all pixels in the rectangle defined by the vertices of the triangle and checks if the pixel belongs the the triangle.
"""
# function olddrawtriangle(triangle::Triangle, img0)
#     m = length(img0[:, 1]) # y-values
#     n = length(img0[1, :]) # x-values
#     img = deepcopy(img0)

#     xmin = Int(min(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
#     xmin = max(xmin, 1) # In case xmin = 0
#     xmax = Int(max(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
#     xmax = min(xmax, n) # In case xmax > canvas width
#     ymin = Int(min(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
#     ymin = max(ymin, 1)
#     ymax = Int(max(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
#     ymax = min(ymax, m)

#     for i in ymin:ymax # y
#         for j in xmin:xmax # x
#             if complex(j, i) in triangle
#                 img[i, j] = triangle.color
#             end
#         end
#     end

#     return img
# end

"""
    getboundaries(triangle::Triangle, m::Int, n::Int)

Establishes the place of the box around a triangle 
"""
function getboundaries(triangle::Triangle, m::Int, n::Int)
    xmin, xmax = Int(extrema([real(triangle.p1), real(triangle.p2), real(triangle.p3)]))
    xmin = max(xmin, 1) # In case a point of the triangle is outside of the canvas
    xmax = min(xmax, n) # In case a point of the triangle is outside of the canvas

    ymin, ymax = Int(extrema([imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)]))
    ymin = max(ymin, 1) # Idem
    ymax = min(ymax, m) # Idem

    return xmin, xmax, ymin, ymax
end

"""
    drawtriangle(triangle::Triangle, img0::Array)

An absolute unit of a function. Should probably have been split into multiple smaller functions, but it functions so well as it is.
This function uses some tricks to prevent going over every single pixel in the rectangle encapsulating your triangle.
Rather than checking every pixel in a line, it searches for the left-most and right-most points of the triangle on a certain height, and then fills in all points between these 2 as "part of the triangle".
By calculating the slopes of the sides of the triangle, it calculates where these points should be.
However, a pixelated line can vary by 1, and the slope will change when you reach a vertex of the triangle, which is why you have to
a) keep checking whether the point you expect to be part of the triangle based on the slope actually is
b) keep calculating the slope
By using these tricks, the function is about 30 times faster than olddrawtriangle.
"""
function drawtriangle(triangle::Triangle, img::Array)
    m, n = size(img)  # the original one needed to allocate memory
    
    #img = deepcopy(img0)  # QUESTION: why take a copy: just fill in image (preallocated memory), will be faster if you run this many times
    # @Michiel: This is to prevent the white canvas we use as img0 to get filled with triangles as well.
    # If I don't make a copy of it, I would have to generate a new white canvas every time I run drawtriangle
    # Would this be more efficient? Or is there a better way to retain img0 without making a copy of it?
    # For now I moved the copying to drawimage, since it's only really necessary there and it makes for less copies. 

    # FIXEDME: this can be defined in a different function... # It certainly is a little neater now
    xmin, xmax, ymin, ymax = getboundaries(triangle, m, n)

    j_left = xmin
    j_right = xmax
    left_points = Vector{Int}(undef, 2)
    right_points = Vector{Int}(undef, 2)
    counter = 1
    ymin0 = ymin

    # QUESTION: is it not nearly as effecient to check the box around the triangle?
    # @Michiel Do you mean as was done in olddrawtriangle (above this one), where you just go over every pixel in the box around the triangle? 
    # That one was 30 times slower, and probably scales a lot worse with larger images. Or do you mean something else still?

    while counter <= 2 # We need the first 2 points of both sides of the triangle for their slopes

        j = xmin # Start at left side of line and go right
        while j <= xmax # Loop breaks if you find point in triangle or you reach end of line without finding anything
            if complex(j, ymin) in triangle # Left point of triangle found
                j_left = j
                left_points[counter] = j
                j = xmax # Get out of loop
            end
            j += 1 # x-value + 1 => We're going to the right looking for our noble triangle
        end

        j = xmax # Now we look for the right point, starting from the right-most point of the line and going left
        while j >= xmin
            if complex(j, ymin) in triangle
                j_right = j
                right_points[counter] = j
                j = xmin # Out of the loop
                img[ymin, j_left:j_right] .= triangle.color # Draw the line between the 2 points you found
                # We do this in the if statement because we don't want to draw a line if no point of the triangle was found on this line
                counter += 1 # We're looking for 2 points in the triangle, so also only count if a point in the triangle is found
            end
            j -= 1
        end
        ymin += 1
    end

    lastleft = left_points[2]
    leftslope = left_points[2] - left_points[1]
    leftslope = leftslope - 3*abs(leftslope)
    # The initial slope is very important. If it goes too much to the right, you'll end up INSIDE of the triangle rather than at an edge.
    # The reason this can happen is because some triangles are very weird around the top corner (e.g. one point separated from the rest of the triangle by a blank line).
    # To make sure this kind of thing doesn't ruin the whole triangle, we make the initial slope supersafe by making it go a bit more to the left than should be necessary

    lastright = right_points[2]
    rightslope = right_points[2] - right_points[1]
    rightslope = rightslope + 3*abs(rightslope)
    # The same here, but making the right slope safer means making it go a bit more to the right

    for i in ymin:ymax # The rest of the triangle can be done making use of the slopes

        j = lastleft + leftslope - 1 # You can now start at where your left point should be according to the slope and your last point, skipping a ton of checks!
        while j <= xmax # Loop breaks if you find point in triangle or you reach end of line without finding anything

            if complex(j, i) in triangle # Left point of triangle found

                j_left = j
                leftslope = j - lastleft # Can change (once) if you encounter a vertex of the triangle
                lastleft = j
                j = xmax # Get out of loop

            end
            j += 1 # x-value + 1 => We're going to the right looking for our noble triangle

        end

        j = lastright + rightslope + 1 # Now we look for the right point, starting from the right-most point of the line and going left
        while j >= xmin
            
            if complex(j, i) in triangle # Right point of triangle found

                j_right = j
                rightslope = j - lastright
                lastright = j
                j = xmin # Out of the loop
                j_left = max(j_left, 1)
                j_right = min(j_right, n)
                img[i, j_left:j_right] .= triangle.color # Draw the line between the 2 points you found
                # We do this in the if statement because we don't want to draw a line if no point of the triangle was found on this line

            end
            j -= 1
        end

    end

    return img
end

#FIXEDME: draw*i*mage! # Yes sir (bless replace all)
# I think you should loop over all triangles within the function drawimage
# @Michiel But that's what it does? Or do you mean within drawtriangle?
# Or do you mean something like this? Because this one is very slow compared to the current version.

function alternatedrawimage(triangles::Array, canvas::Array)
    m = length(canvas[:, 1]) # y-values
    n = length(canvas[1, :]) # x-values
    img = deepcopy(canvas)

    for i in 1:m # y
        for j in 1:n # x
            for triangle in triangles
                if complex(j, i) in triangle
                    img[i, j] = triangle.color
                end
            end
        end
    end

    return img
end


"""
    drawimage(triangles::Array, canvas::Array)

Goes over all triangles in an array and draws them all on the same canvas, then returns the resulting image. 
"""
function drawimage(triangles::Array, canvas::Array)
    polyimg = copy(canvas)
    for triangle in triangles
        #print(triangle.p1, " ", triangle.p2, " ", triangle.p3, "\n")
        polyimg = drawtriangle(triangle, polyimg)
    end
    return polyimg
end



"""
    colordiffsum(img1::Array, img2::Array, m::Int, n::Int)

The objective function of the algorithm. Computes the difference between 2 images by computing the difference in color for every pixel.
"""
function colordiffsum(img1::Array, img2::Array, m::Int, n::Int)
    colsum = 0
    for i in 1:m
        for j in 1:n
            colsum += colordiff(img1[i, j], img2[i, j])
        end
    end
    return colsum
end

# or: colordiffsum(img1::Array, img2::Array, m::Int, n::Int) = sum(colordiff.(img1. img2))

# FIXEDME: no capitals in function  names :s
"""
    checktriangle(triangle::Triangle, m::Int, n::Int)

Checks a triangle to make sure we don't have any STUPID triangles.
A stupid triangle is a triangle which:
- Is much too thin (a couple of pixels thin)
- Has all 3 points outside of the canvas
- Is very stretched out
These stupid triangles can all mess with the drawtriangle function, which is why checking for them and weeding them out is essential.
"""
function checktriangle(triangle::Triangle, m::Int, n::Int)
    # Rather than using the actual boundaries of the canvas, we use a slightly smaller rectangle for safety reasons
    s = 10 # safety factor
    x1, x2, x3 = real(triangle.p1), real(triangle.p2), real(triangle.p3)
    y1, y2, y3 = imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)

    max_y = max(y1, y2, y3)
    min_y = min(y1, y2, y3)
    max_delta_y = max_y - min_y
    YisStupid = max_delta_y <= s && return true # Too thin

    max_x = max(x1, x2, x3)
    min_x = min(x1, x2, x3)
    max_delta_x = max_x - min_x
    XisStupid = max_delta_x <= s && return true # Too thin

    p1_out_of_canvas = (x1 <= s || x1 >= (n - s)) || (y1 <= s || y1 >= (m - s))
    p2_out_of_canvas = (x2 <= s || x2 >= (n - s)) || (y2 <= s || y2 >= (m - s))
    p3_out_of_canvas = (x3 <= s || x3 >= (n - s)) || (y3 <= s || y3 >= (m - s))
    pointsAreStupid = all([p1_out_of_canvas, p2_out_of_canvas, p3_out_of_canvas]) && return true # All points are (almost) outside of the canvas, that's no bueno

    # Very elongated triangles cause trouble: check for these as well
    # Credit for idea of using the centroid: Her Magnificence, Gender Equality Expert Dr. Roets
    midpoint = (triangle.p1 + triangle.p2 + triangle.p3)/3
    dist1 = abs(triangle.p1 - midpoint)
    dist2 = abs(triangle.p2 - midpoint)
    dist3 = abs(triangle.p3 - midpoint)
    isStretchyBoi = max(dist1, dist2, dist3) > 2.1*min(dist1, dist2, dist3) && return true
    # An elongated triangle has a big difference in max distance from a point to the centroid to min distance from a point to the centroid (2 is a good threshhold)

    # isStupid = any([YisStupid, XisStupid, pointsAreStupid, isStretchyBoi])

    # FIXEDME: faster if you stop when you found that the triangle is stupid # Fast is good
    # YisStupid && return true (put this as early as possible)

    return false # Only gets to this return false if all the other returns true conidtions weren't met (and thus the triangle isnt stupid)
end

# FIXEDME: no capitals in function  names :s # Yessir
# FIXEDME: not sure if this matters, your GA will select visible triangles anyway # the checktriangle function is mainly to prevent glitchy triangles that cause errors in drawtriangle
"""
    generatetriangle(m::Int, n::Int)

Generates a random triangle.
"""
function generatetriangle(m::Int, n::Int)
    # Generate a triangle which is not stupid
    badTriangle = true
    t = nothing
    while badTriangle
        center = complex(rand()*1.1*n - 0.05*n, rand()*1.1*m - 0.05*m)
        deviations = complex.(rand(3)*n*4/5 .- n*2/5, rand(3)*m*4/5 .- m*2/5)
        points = Complex{Int}.(round.(center .+ deviations))
        # Points are allowed to be outside of canvas as long as part of the triangle is in the canvas
        # Prevents white borders
        col = RGB(rand(), rand(), rand())
        t = Triangle(points[1], points[2], points[3], col)
        badTriangle = checktriangle(t, m, n)
    end

    return t
end

"""
    generatepopulation(pop_size::Int, number_triangles::Int, img::Array)

Generates an entire population. The individuals of this population consist of a bunch of triangles, the image made from drawing all these triangles,
and the score of the individual, which is too say how much it differs from the target image, img.
"""
function generatepopulation(pop_size::Int, number_triangles::Int, img::Array)

    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)

    population = Vector{Array}(undef, pop_size)

    for i in 1:pop_size
        triangles = [generatetriangle(m, n) for i in 1:number_triangles]
        polyimg = drawimage(triangles, canvas)

        score = colordiffsum(polyimg, img, m, n)
        population[i] = [triangles, polyimg, score]
    end
    return population
end

# function rasterizedgeneratepopulation(pop_size, number_triangles, img)

#     m = length(img[:, 1])
#     n = length(img[1, :])
#     canvas = fill(RGB(1, 1, 1), m, n)
#     triangles_on_y_axis = Int(round(sqrt(number_triangles * m/n)))
#     triangles_on_x_axis = Int(round(number_triangles/triangles_on_y_axis))

#     deltay = Int(round(m/triangles_on_y_axis))
#     y0 = Int(round(deltay/2))
#     deltax = Int(round(n/triangles_on_x_axis))
#     x0 = Int(round(deltax/2))
    
#     population = Vector{Array}(undef, pop_size)

#     for i in 1:pop_size
#         triangles = [generatetriangle(y0 + (i-1)*deltay, x0 + (j-1)*deltax) for i in 1:triangles_on_y_axis for j in 1:triangles_on_x_axis]
#         polyimg = drawimage(triangles, canvas)

#         score = colordiffsum(polyimg, img, m, n)
#         population[i] = [triangles, polyimg, score]
#     end
#     return population
# end



"""
    triangletournament(population0::Array, pop_size::Int)

Picks 2 random triangles from a population and returns the one with the best (lowest) score.
"""
function triangletournament(population0::Array, pop_size::Int)
    contestant1 = population0[Int(ceil(rand()*pop_size))] #Choose a random image from the population, using ceil because 0 is not a valid index
    contestant2 = population0[Int(ceil(rand()*pop_size))]
    if contestant1[3] <= contestant2[3] # Lower score than contestant 2 means he's better
        winner = contestant1
    else
        winner = contestant2
    end
    return winner
end

"""
    mutatetriangle(triangle::Triangle, m::Int, n::Int)

Mutates a single triangle, changing the position of its points and its color, while making sure this doesn't result in a stupid triangle.
"""
function mutatetriangle(triangle::Triangle, m::Int, n::Int)

    badTriangle = true
    p1 = nothing
    p2 = nothing
    p3 = nothing

    while badTriangle
        p1, p2, p3 = round.([triangle.p1, triangle.p2, triangle.p3] + (rand(3) .- 0.5)*(n/10) + (rand(3) .- 0.5)*(m/10)*im)
        # Position of all 3 points is changed, with the change in x and y value scaling with the width and height of the canvas respectively
        t = Triangle(p1, p2, p3, triangle.color)
        badTriangle = checktriangle(t, m, n)
    end

    col = triangle.color + RGB((rand() - 0.5)/2, (rand() - 0.5)/2, (rand() - 0.5)/2)
    col = parse(RGB{Float64}, string("#", hex(col))) # This looks a little weird but it just fixes any color with RGB values out of their bounds 
    # (by setting the value to the boundary it crossed) (the RGB type is hard to work with :( )
    return Triangle(p1, p2, p3, col)

end

"""
    mutatepopulation(population::Array, pop_size::Int, mutation_freq::Number, number_triangles::Int, m::Int, n::Int, img::Array, canvas::Array)

Mutates an entire population, going over every individual and randomly mutating some of their triangles.
Then, the new image based on the updated list of triangles is created and the score for this image is computed for every individual.
"""
function mutatepopulation(population::Array, pop_size::Int, mutation_freq::Number, number_triangles::Int, m::Int, n::Int, img::Array, canvas::Array)
    # Mutates an entire population of polygon images, by chance
    for i in 1:pop_size
        for j in 1:number_triangles
            if mutation_freq >= rand() # Mutation happens with a probability of the mtuation frequency
                population[i][1][j] = mutatetriangle(population[i][1][j], m, n)
            end
        end
        population[i][2] = drawimage(population[i][1], canvas) # Update mutated individual's image
        population[i][3] = colordiffsum(population[i][2], img, m, n) # Update mutated individual's score
    end

    return population
end

"""
    makechildpopulation(population1::Array, population2::Array, number_triangles::Int)

Takes 2 images and returns a new image with triangles randomly taken from both images.
The order of the triangles is retained since it plays a big role in how the image looks.
Only the triangle list is updated, not yet the matrix or score.
"""
function makechildpopulation(population1::Array, population2::Array, number_triangles::Int)
    childTriangles = Vector{Triangle}(undef, number_triangles)
    for i in 1:number_triangles
        if rand() > 0.5
            childTriangles[i] = population1[1][i]
        else
            childTriangles[i] = population2[1][i]
        end
    end

    child = [childTriangles, population1[2], population1[3]]
    # The matrix and score aren't updated yet but that's alright since it will happen in the next step of the old algorithm

    return child

end


"""
    horizontalgenetransfer(triangles1::Array, triangles2::Array, number_triangles::Int, HGT_rate::Number)

Alternative function for the makechildpopulation, in which HGT is simulated rather than good old having kids.
Current version of the algorithm is using makechildpopulation instead, this was implemented to test out how much the results would differ.
Not enough tests were done for a definitive conclusion.
"""
function horizontalgenetransfer(triangles1::Array, triangles2::Array, number_triangles::Int, HGT_rate::Number)
    triangles1_new = deepcopy(triangles1)
    triangles2_new = deepcopy(triangles2)

    for i in 1:number_triangles
        if HGT_rate > rand()
            triangles1_new[i] = triangles2[i]
            triangles2_new[i] = triangles1[i]
        end
    end

    return triangles1_new, triangles2_new

end

"""
    triangleevolution(image::String, number_triangles::Int, generations::Int)

The actual algorithm. An evolutionary algorithm with the goal to approximate a given image
as well as possible with a bunch of triangles.
Parameters still require optimizing.
There is a variant making use of the HGT and a varian making use of children.
Currently the variant with children is performing better, but the HGT's parameters may be unoptimal.
"""
function triangleevolution(image::String = "src/figures/TotoroTester4.jpeg"; gifname::String = "no_gif", number_triangles::Int = 25, generations::Int = 50, pop_size::Int = 70, elitism_freq::Number = 0.15, newblood_freq::Number =  0.03, mutation_freq::Number = 0.05)
    
    #generations = 10  # FIXEDME: these should be keyword arguments with default values
    #number_triangles = 25
    #pop_size = 50
    #elitism_freq = 0.1 # best x percent of population always gets through to the next generation
    #newblood_freq = 0.05 # A certain percent of the population gets replaced by newcomes every generation, to keep our gene pool fresh and sparkly
    # HGT_freq = 0.5
    # HGT_rate = 0.2

    #mutation_freq = 0.10
    #image = "src/figures/TotoroTester4.jpeg"

    makegif = gifname != "no_gif" # Only make the result into a gif if the user enters a name for it

    elite_size = Int(round(pop_size*elitism_freq))
    newblood_size = Int(round(pop_size*newblood_freq))

    img = load(image)
    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)
    childPopulation = Vector{Array}(undef, pop_size)
    if makegif
        anim = Plots.Animation()
    end

    population0 = generatepopulation(pop_size, number_triangles, img)
    sort!(population0, by = x -> x[3]) # sort population by score

    for i in 1:generations
        population = population0[1:elite_size] # First transfer the elite to the next generation
        #population = vcat(population, population0[1:elite_size])

        for i in (elite_size+1):(pop_size-newblood_size) # Generate the next part of the population by means of A GRAND TOURNAMENT! MOSTLY THE STRONG SHALL WIN!
            winner = triangletournament(population0, pop_size)
            population = vcat(population, [winner])
        end

        population = vcat(population, generatepopulation(newblood_size, number_triangles, img)) # The last part of the population is made up of new people! Yay!

        # The winners gain the ultimate price! Children! (For the child-version)
        couples = [shuffle(1:pop_size) shuffle(1:pop_size)] # Two list of all the people of the population in a random order make up our array of couples

        for i in 1:pop_size
            parent1 = population[couples[i, 1]]
            parent2 = population[couples[i, 2]] 
            childPopulation[i] = makechildpopulation(parent1, parent2, number_triangles)
        end

        # Or, for the HGT version, switched genes! Marvelous!
        
        # childPopulation = population
        # for i in 1:pop_size
        #     if HGT_freq > rand()
        #         partner1 = childPopulation[couples[i, 1]]
        #         partner2 = childPopulation[couples[i, 2]]

        #         childPopulation[couples[i, 1]][1], childPopulation[couples[i, 2]][1] = horizontalgenetransfer!(partner1[1], partner2[1], number_triangles, HGT_rate)
        #     end
        # end

        # The children gain random mutations because of UV-radiation. Damn you Ozon hole!
        childPopulation = mutatepopulation(childPopulation, pop_size, mutation_freq, number_triangles, m, n, img, canvas)
        population0 = sort(childPopulation, by = x -> x[3]) # The children grow up and become the new population0. The cycle of life continues.
        print(i, " ", population0[1][3], "\n")
        if makegif
            bestscore = population0[1][3]
            plot(population0[1][2], title = "Generation $i, score: $bestscore")
            Plots.frame(anim)
        end
    end

    if makegif
        gif(anim, gifname, fps = 2)  # do I want to know what this is?
    end
    # @Michiel It's a gif of the progression of the evolution (best individual of every generation)! You can watch the example triangledance on my github branch!

    return population0
end

end