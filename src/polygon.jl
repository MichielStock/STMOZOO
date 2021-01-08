# Bram Spanoghe

module polygon

using Images, Colors, Plots, Random, ImageMagick
import Base: in

export triangleevolution

"""
A type Shape so the code can be made to work with e.g. rectangles as well. For now, only triangles are supported.
"""
abstract type Shape end

"""
    Triangle <: Shape

Triangles are defined with the coordinates of their 3 points and a color.

Complex numbers are used to represent coordinates. The real part represents the x-value, and the imaginary part represents the y-value.
"""
struct Triangle <: Shape
    p1::ComplexF64 
    p2::ComplexF64
    p3::ComplexF64
    color::RGB{Float64}
end

"""
    samesideofline(point::Complex, trianglepoint::Complex, line::Tuple)

Computes whether point and trianglepoint are on the same side of a line, defined as a tuple of 2 points.
Returns true if the points are on the same side of a line and false if they are not.
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

        return linediff_point*linediff_trianglepoint >= 0
        # This is the same as sign(linediff_point) == sign(linediff_trianglepoint)
        # But if the point is ON the line it also returns true (which the sign(...) == sign(...) thing does not for some reason)
        # And it should do that. A point on the line of a triangle is part of the triangle.

    else #x1 == x2: A vertical line: a cannot be calculated (division by 0)
        #equation is now x = b
        b = x1
        linediff_point = real(point) - b
        linediff_trianglepoint = real(trianglepoint) - b
        # Difference between point's x-value and line's x-value
        # Same principle as above
        return linediff_point*linediff_trianglepoint >= 0
    end  

end

"""
    in(point::Complex, triangle::Triangle)

Computes whether a point is inside of a triangle, returning either true or false.

In order to do this, it checks whether the point is on the same side of a certain line of the triangle (defined by two of the triangle's points)
as the remaining point of the triangle. If this is true for every side of the triangle, the point is inside of the triangle.
"""
function in(point::Complex, triangle::Triangle)
    # Checks whether the point on a canvas is part of the triangle
    tpoints = (triangle.p1, triangle.p2, triangle.p3)
    
    check = samesideofline(point, tpoints[1], tpoints[2:3]) && samesideofline(point, tpoints[2], tpoints[[1, 3]]) && samesideofline(point, tpoints[3], tpoints[1:2])

    return check
end

in((x, y), shape::Shape) = in(complex(x, y), shape)

"""
    getboundaries(triangle::Triangle, m::Int, n::Int)

Returns the minimum and maximum x-values and y-values of a triangle. m and n are the height and width of the target image.

The leftmost point of a triangle has the minimum x-value of the entire triangle, the rightmost point the maximum x-value,
the topmost point has the lowest y-value (our image is defined as a matrix, so y-value increases going down) and the bottommost point has the highest y-value.
If any of these values are outside of the canvas, return the limit it's breaching instead.
Example: If the right most point of your triangle has an x-value of 530 but the canvas width is only 500, it will return 500 as maximum x-value.
"""
function getboundaries(triangle::Triangle, m::Int, n::Int)

    xmin = Int(min(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    xmin = max(xmin, 1) # In case xmin = 0
    xmax = Int(max(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    xmax = min(xmax, n) # In case xmax > canvas width
    ymin = Int(min(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymin = max(ymin, 1)
    ymax = Int(max(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymax = min(ymax, m)

    return xmin, xmax, ymin, ymax
end

"""
    drawtriangle(triangle::Triangle, img::Array)

Fills in all points of an image (an array of RGB points) wich are inside of the triangle with the color of the triangle, then returns this new image.

This function uses some tricks to prevent going over every single pixel in the rectangle encapsulating your triangle.
Rather than checking every pixel in a line, it searches for the left-most and right-most points of the triangle on a certain height,
and then fills in all points between these 2 as "part of the triangle".
By calculating the slopes of the sides of the triangle, it calculates where these points should be.
However, a pixelated line can vary by 1, and the slope will change when you reach a vertex of the triangle, which is why you have to
a) keep checking whether the point you expect to be part of the triangle based on the slope actually is
b) keep calculating the slope
By using these tricks, the function is about 30 times faster than going over every pixel in the box around your triangle.
"""
function drawtriangle(triangle::Triangle, img::Array)
    m, n = size(img)  # the original one needed to allocate memory
    
    xmin, xmax, ymin, ymax = getboundaries(triangle, m, n)

    j_left = xmin
    j_right = xmax
    left_points = Vector{Int}(undef, 2)
    right_points = Vector{Int}(undef, 2)
    counter = 1
    ymin0 = ymin

    while counter <= 2 && ymin <= ymax # We need the first 2 points of both sides of the triangle for their slopes, && ymin <= ymax is to prevent getting stuck

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
            if complex(j, ymin) in triangle # Right point of triangle found
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

"""
    drawimage(triangles::Array, canvas::Array)

Goes over all triangles in an array and draws them all on the same canvas, then returns the resulting image. 
"""
function drawimage(triangles::Array, canvas::Array)
    polyimg = copy(canvas)
    for triangle in triangles
        polyimg = drawtriangle(triangle, polyimg)
    end
    return polyimg
end

"""
    colordiffsum(img1::Array, img2::Array, m::Int, n::Int)

The objective function of the algorithm. Computes the difference between 2 images by computing the difference in color for every pixel, then returns this value.
m and n are the height and width of the target image.
"""
colordiffsum(img1::Array, img2::Array) = sum(colordiff.(img1, img2))

"""
    checktriangle(triangle::Triangle, m::Int, n::Int)

Returns whether a triangle is stupid (true or false). m and n are the height and width of the target image.

A stupid triangle is a triangle which:
- Is much too thin (a couple of pixels thin)
- Has all 3 points outside of the canvas
- Is very stretched out
These stupid triangles can all mess with the drawtriangle function, which is why checking for them and weeding them out is essential.
Otherwise we get errors and boy do we hate errors.
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
    isStretchyBoi = max(dist1, dist2, dist3) > 2*min(dist1, dist2, dist3) && return true
    # An elongated triangle has a big difference in max distance from a point to the centroid to min distance from a point to the centroid (2 is a good threshhold)

    return false # Only gets to this return false if all the other returns true coniditions weren't met (and thus the triangle isnt stupid)
end

"""
    generatetriangle(m::Int, n::Int)

Returns a random triangle. m and n are the height and width of the target image.

The functions also checks whether the random triangle is stupid, and if it is, generates a different one.
"""
function generatetriangle(m::Int, n::Int)
    badTriangle = true
    t = nothing
    while badTriangle
        center = complex(rand()*1.1*n - 0.05*n, rand()*1.1*m - 0.05*m) # Choose a random point somewhere in x ∈ [-0.05*n, 1.05*n] and y ∈ [-0.05*m, 1.05*m]
        # This will be the centre of the triangle
        deviations = complex.(rand(3)*n*4/5 .- n*2/5, rand(3)*m*4/5 .- m*2/5) # Choose 3 random distances in x ∈ [-0.4*n, 0.4*n] and y ∈ [-0.4*m, 0.4*m]
        points = Complex{Int}.(round.(center .+ deviations)) # The points of the triangle are a distance "deviations" away from the center
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

Generates a population of images filled with triangles. 

pop_size: Amount of individuals in the population
number_triangles: Amount of triangles per individual
img: Starting image on which the individuals are drawn. (e.g. a white rectangle = an array of white RGB values)

The individuals of this population consist of:
- An array of triangles (remember, a triangle is simply 3 xy coordinates of points and a color, not yet an image)
- The image made from drawing all these triangles onto a white canvas (array of triangles converted to an image)
- The score of the individual, which is too say how much its image differs from the target image.
"""
function generatepopulation(pop_size::Int, number_triangles::Int, img::Array)

    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)

    population = Vector{Array}(undef, pop_size)

    for i in 1:pop_size
        triangles = [generatetriangle(m, n) for i in 1:number_triangles]
        polyimg = drawimage(triangles, canvas)

        score = colordiffsum(polyimg, img)
        population[i] = [triangles, polyimg, score]
    end
    return population
end


"""
    triangletournament(population0::Array, pop_size::Int)

Picks 2 random individuals from a population and returns the one with the best (= lowest) score.
"""
function triangletournament(population0::Array, pop_size::Int)
    contestant1 = population0[Int(ceil(rand()*pop_size))] #Choose a random image from the population, using ceil because 0 is not a valid index
    contestant2 = population0[Int(ceil(rand()*pop_size))]

    while contestant1 == contestant2 #If it happened to pick the same individual twice, change it until you have 2 unique individuals
        contestant2 = population0[Int(ceil(rand()*pop_size))]
    end

    if contestant1[3] <= contestant2[3] # Lower score than contestant 2 means he's better
        winner = contestant1
    else
        winner = contestant2
    end
    return winner
end

"""
    mutatetriangle(triangle::Triangle, m::Int, n::Int)

Mutates a single triangle, changing the position of its points and its color, while making sure this doesn't result in a stupid triangle, then returns it.
m and n are the height and width of the target image.
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

Mutates an entire population. 

Goes over every individual and randomly mutates some of their triangles.
Then, the new image based on the updated list of triangles is created and the score for this image is computed for every individual.
The mutated population is returned.

Inputs:
- population: An array of individuals. 
And individual in its turn is an array of: 1) An array of Triangles 2) An image consisting of these triangles 3) The score of the individual.
- pop_size: The amount of individuals in the population (length of population)
- mutation_freq: The chance for a random triangle to get mutated
- number_triangles: The amount of triangles per individual (length of the first element of an individual)
- m and n: Height and width of the target image
- img: The target image (Array of RGB values)
- canvas: A starting image on which the triangles are drawn, which is an array of RGB values.
"""
function mutatepopulation(population::Array, pop_size::Int, mutation_freq::Number, number_triangles::Int, m::Int, n::Int, img::Array, canvas::Array)
    for i in 1:pop_size
        for j in 1:number_triangles
            if mutation_freq >= rand() # Mutation happens with a probability of the mtuation frequency
                population[i][1][j] = mutatetriangle(population[i][1][j], m, n)
            end
        end
        population[i][2] = drawimage(population[i][1], canvas) # Update mutated individual's image
        population[i][3] = colordiffsum(population[i][2], img) # Update mutated individual's score
    end

    return population
end

"""
    makechildpopulation(individual1::Array, individual2::Array, number_triangles::Int)

Takes 2 individuals and returns a new individual with triangles randomly taken from both images.

The order of the triangles is retained.
Only the triangle list is updated, not yet the image or score.
The returned individual has a new list of triangles, but the image formed from these triangles and the score are one of the parents'.
"""
function makechildpopulation(individual1::Array, individual2::Array, number_triangles::Int)
    childTriangles = Vector{Triangle}(undef, number_triangles)
    for i in 1:number_triangles
        if rand() > 0.5
            childTriangles[i] = individual1[1][i]
        else
            childTriangles[i] = individual2[1][i]
        end
    end

    child = [childTriangles, individual1[2], individual1[3]]
    # The image and score aren't updated yet but that's alright since it will happen in the next step of the algorithm

    return child

end


"""
    triangleevolution(image::String, number_triangles::Int, generations::Int)

An evolutionary algorithm with the goal to approximate a given image as well as possible with a bunch of triangles.
If a name for a gif is given (e.g. gifname = "nicegif.gif"), it will also make a gif out of the best individual's image for every generation.
There's a lot of parameters here to play around with, try out some crazy stuff!'

Inputs:

- image: The name of your target image (can be a png, a jpg, a jpeg,... I haven't tried any other formats but all raster-based images should work.)

OPTIONAL
- number_triangles: The amount of triangles the algorithm uses to try and recreate your image
- generations: The amount of generations in the evolutionary algorithm
- pop_size: The population size per generation
- elitism_freq: The fraction of your population that gets to be part of the elite. The best individuals of your generation will become part of the elite and get a free pass to the next generation.
- newblood_freq: The fraction of your population that gets replaced by new, random individuals every generation.
- mutation_freq: The chance for a triangle (= "a gene") of an individual to get mutated every generation
- gifname: If you want to make a gif out of the evolutionary proces, enter a gifname like "amazinggif.gif"
- fps: The FPS of your gif

Output:

- The population of the last generation, ordered by score.

OPTIONAL
- A gif consisting of the best individual of every generation. 
This is not returned, but immediately saved in the notebook folder as a gif if you have entered a gifname.

"""
function triangleevolution(image::String = "notebook/examplefigures/TotoroTester.jpeg"; number_triangles::Int = 25, generations::Int = 50, pop_size::Int = 70, elitism_freq::Number = 0.10, newblood_freq::Number =  0.03, mutation_freq::Number = 0.07, gifname = nothing, fps::Int = 2)
    
    @assert number_triangles >= 1 "You must have a positive amount of triangles"
    @assert generations >= 1 "You must have a positive amount of generations"
    @assert pop_size >= 1 "You must have a positive population size"
    @assert fps >= 1 "You must have a positive fps"
    @assert elitism_freq >= 0 && elitism_freq <= 1 && newblood_freq >= 0 && newblood_freq <= 1 && mutation_freq >= 0 && mutation_freq <= 1 "All frequencies should be within [0, 1]"
    

    makegif = !isnothing(gifname) # Only make the result into a gif if the user enters a name for it

    elite_size = Int(round(pop_size*elitism_freq)) # The elite of every generation (best individuals) will get a free pass to the next generation
    newblood_size = Int(round(pop_size*newblood_freq)) # A part of the population will be replaced with new, random individuals every generation.
    # This keeps our gene pool fresh and sparkly!

    if image[1:5] == "https" #file from internet: credits to Dan Getz from stackoverflow for this
        img = mktemp() do fn,f
            download(image, fn)
            load(fn)
        end
    else #local file
        img = load(image) 
    end

    img = RGB.(img) # png images are loaded as RGBA (with opacity which we dont use) so we convert those to RGB (jpgs load as RGB by default)

    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)
    childPopulation = Vector{Array}(undef, pop_size) # Preallocating the child population.

    if makegif
        anim = Plots.Animation()
    end

    population0 = generatepopulation(pop_size, number_triangles, img)
    sort!(population0, by = x -> x[3]) # sort population by score

    for i in 1:generations
        population = population0[1:elite_size] # First transfer the elite to the next generation

        for i in (elite_size+1):(pop_size-newblood_size) # Generate the next part of the population by means of A GRAND TOURNAMENT! MOSTLY THE STRONG SHALL WIN!
            winner = triangletournament(population0, pop_size)
            population = vcat(population, [winner])
        end

        population = vcat(population, generatepopulation(newblood_size, number_triangles, img)) # The last part of the population is made up of new people! Yay!

        # The winners gain the ultimate price! Children!
        couples = [shuffle(1:pop_size) shuffle(1:pop_size)] # Two list of all the people of the population in a random order make up our array of couples

        for i in 1:pop_size
            parent1 = population[couples[i, 1]]
            parent2 = population[couples[i, 2]] 
            childPopulation[i] = makechildpopulation(parent1, parent2, number_triangles)
        end

        # The children gain random mutations because of UV-radiation. Damn you Ozon hole!
        childPopulation = mutatepopulation(childPopulation, pop_size, mutation_freq, number_triangles, m, n, img, canvas)
        population0 = sort(childPopulation, by = x -> x[3]) # The children grow up and become the new population0. The cycle of life continues.

        print(i, " ", population0[1][3], "\n") # Print current generation and the score of the best individual.

        # And now to make the image of the currently best scoring individual into a frame of our gif (if we're making one)
        if makegif
            bestscore = population0[1][3]
            plot(population0[1][2], title = "Generation $i, score: $bestscore")
            Plots.frame(anim)
        end

    end

    # Combine frames of gif into an actual gif
    if makegif
        gif(anim, gifname, fps = fps)
    end

    return population0
end

end