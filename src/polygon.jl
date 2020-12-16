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

function drawtriangle(triangle, img)
    m = length(img[:, 1]) # y-values
    n = length(img[1, :]) # x-values

    for i in 1:m # y
        for j in 1:n # x
            if complex(j, i) in triangle
                img[j, i] = triangle.color
            end
        end
    end

    return img
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



end