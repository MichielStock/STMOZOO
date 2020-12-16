# Michiel Stock
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module polygon

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using Images, Colors, Plots
import Base: in

export Triangle, drawtriangle, colordiffsum, sameSideOfLine

abstract type Shape end

struct Triangle <: Shape
    p1::ComplexF64 
    p2::ComplexF64
    p3::ComplexF64
    color::RGB
end

# function triangle2points(triangle::Triangle)
#     x1, y1 = real(triangle.p1), imag(triangle.p1)scatter!(20, 30)
#     x2, y2 = real(triangle.p2), imag(triangle.p2)
#     x3, y3 = real(triangle.p3), imag(triangle.p3)

#     return (x1, y1), (x2, y2), (x3, y3)
# end

function sameSideOfLine(point, trianglepoint, line)
    p1 = line[1]
    p2 = line[2]
    x1, y1 = real(p1), imag(p1)
    x2, y2 = real(p2), imag(p2)
    
    # making the lines equation from the given 2 points: y = ax + b
    if x1 != x2 #not a vertical line
        a = (y2 - y1)/(x2 - x1)
        # intercept from y = ax + b => b = y_1 - ax_1 
        b = y1 - a*x1

        # substract y-value from line at point's x-value from points y-value 
        linediff_point = imag(point) - (a*real(point) + b)
        linediff_trianglepoint = imag(trianglepoint) - (a*real(trianglepoint) + b)
        # if a point is above the line, this value will be positive, if it's beneath the line, the value will be negative
        # if both points are on the same side of the line, both values will have the same sign
        # if we multiply the values, a positive sign will indicate they're on the same side and a negative sign means they're on separate sides

        return linediff_point*linediff_trianglepoint > 0

    else #x1 == x2: A vertical line: a cannot be calculated (division by 0)
        #equation is now x = b
        b = x1
        linediff_point = real(point) - b
        linediff_trianglepoint = real(trianglepoint) - b
        # Difference between point's x-value and line's x-value
        # Same principle as above

        return linediff_point*linediff_trianglepoint > 0

    end
    

    
end

# using LinearAlgebra

# function sameside((p1, p2), p3, p)
#     x1, y1 = p1
#     x2, y2 = p2
#     n = [x1-x2, y2-y1] 
#     return (n ⋅ p3) * (n ⋅ p) > 0.0
# end


function in(point::Complex, triangle::Triangle)
    # Checks whether the point on a canvas is part of the triangle
    tpoints = (triangle.p1, triangle.p2, triangle.p3)
    checks = Vector{Bool}(undef, 3)

    for i in 1:3
        line = tpoints[1:3 .!= i] # e.g. points 2 and 3 if i = 1
        trianglepoint = tpoints[i] #e.g. point 1 if i = 1
        
        checks[i] = sameSideOfLine(point, trianglepoint, line)
    end

    return all(checks)
end

in((x, y), shape::Shape) = in(complex(x, y), shape)

function drawtriangle(triangle, img0)
    m = length(img0[:, 1]) # y-values
    n = length(img0[1, :]) # x-values
    img = deepcopy(img0)

    xmin = Int(min(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    xmin = max(xmin, 1) # In case xmin = 0
    xmax = Int(max(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    xmax = min(xmax, n) # In case xmax > canvas width
    ymin = Int(min(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymin = max(ymin, 1)
    ymax = Int(max(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymax = min(ymax, m)

    for i in ymin:ymax # y
        for j in xmin:xmax # x
            if complex(j, i) in triangle
                img[i, j] = triangle.color
            end
        end
    end

    return img
end

function drawImage(triangles, canvas)
    polyimg = canvas
    for triangle in triangles
        polyimg = drawtriangle(triangle, polyimg)
    end
    return polyimg
end

function colordiffsum(img1, img2, m, n)
    colsum = 0
    for i in 1:m
        for j in 1:n
            colsum += colordiff(img1[i, j], img2[i, j])
        end
    end
    return colsum
end

function generateTriangle(m, n)
    points = Int.(round.(rand(3)*n)) + Int.(round.(rand(3)*m))*im
    col = RGB(rand(), rand(), rand())
    return Triangle(points[1], points[2], points[3], col)
end

function generatePopulation(pop_size, number_triangles, img)

    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)

    population = Vector{Array}(undef, pop_size)

    for i in 1:pop_size
        triangles = [generateTriangle(m, n) for i in 1:number_triangles]
        polyimg = drawImage(triangles, canvas)

        score = colordiffsum(polyimg, img, m, n)
        population[i] = [triangles, polyimg, score]
    end
    return population
end

function triangleTournament(population0, pop_size)
    contestant1 = population0[Int(ceil(rand()*pop_size))] #Choose a random image from the population, using ceil because 0 is not a valid index
    contestant2 = population0[Int(ceil(rand()*pop_size))]
    if contestant1[3] >= contestant2[3]
        return contestant1
    else
        return contestant2
    end
end

function mutateTriangle(triangle, m, n)
    # Mutates a single triangle

    p1, p2, p3 = round.([triangle.p1, triangle.p2, triangle.p3] + (rand(3) .- 0.5)*(n/10) + (rand(3) .- 0.5)*(m/10)*im, RoundUp)
    # Position of all 3 points is changed, with the change in x and y value scaling with the width and height of the canvas respectively
    col = triangle.color + RGB((rand() - 0.5), (rand() - 0.5), (rand() - 0.5))
    col = parse(RGB{Float64}, string("#", hex(col))) # This looks a little weird but it just fixes any color with RGB values out of their bounds 
    # (by setting the value to the boundary it crossed) (the RGB type is hard to work with :( )
    return Triangle(p1, p2, p3, col)

end

function mutatePopulation(population, pop_size, mutation_freq, number_triangles, m, n, img, canvas)
    # Mutates an entire population of polygon images, by chance
    for i in 1:pop_size
        for j in 1:number_triangles
            if mutation_freq >= rand() # Mutation happens with a probability of the mtuation frequency
                population[i][1][j] = mutateTriangle(population[i][1][j], m, n)
            end
        end
        population[i][2] = drawImage(population[i][1], canvas) # Update mutated individual's image
        population[i][3] = colordiffsum(population[i][2], img, m, n) # Update mutated individual's score
    end

    return population
end

function triangleEvolution(image, number_triangles, generations)
    
    generations = 100
    number_triangles = 20
    pop_size = 20
    elitism_freq = 0.10 # best 10 percent of population always gets through to the next generation
    elite_size = Int(round(pop_size*elitism_freq))
    mutation_freq = 0.1
    image = "STMOZOO/src/figures/Bubberduck.jpg"

    img = load(image)
    m = length(img[:, 1])
    n = length(img[1, :])
    canvas = fill(RGB(1, 1, 1), m, n)

    population0 = generatePopulation(pop_size, number_triangles, img)
    sort!(population0, by = x -> x[3]) # sort population by score

    for i in 1:generations
        population = population0[1:elite_size] # First transfer the elite to the next generation

        for i in (elite_size+1):pop_size # Then generate the rest of the population by means of A GRAND TOURNAMENT! MOSTLY THE STRONG SHALL WIN!
            winner = triangleTournament(population0, pop_size)
            population = vcat(population, [winner])
        end

        population = mutatePopulation(population, pop_size, mutation_freq, number_triangles, m, n, img, canvas)
        population0 = sort(population, by = x -> x[3])
        print(i)
    end



end