# Michiel Stock
# Example of a source code file implementing a module.


# all your code is part of the module you are implementing
module polygon

# you have to import everything you need for your module to work
# if you use a new package, don't forget to add it in the package manager
using Images, Colors, Plots
import Base: in

export Triangle, drawtriangle, colordiffsum

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

function sameSideOfLine(point, trianglepoint, line1, line2)

end


function in(point::Complex, triangle::Triangle)
    # Checks whether the point on a canvas is part of the triangle
    tpoints = (triangle.p1, triangle.p2, triangle.p3)
    checks = Vector{Bool}(undef, 3)

    for i in 1:3
        curr_points = tpoints[1:3 .!= i] # e.g. points 1 and 2 if i = 3
        m = sum(curr_points)/2 # middle of side 1-2
        
        trianglevec = tpoints[i] - m # vector from middle of side 1-2 (m) to remaining point of triangle, point 3
        curr_point_vec = curr_points[2] - curr_points[1] # vector representing side 1-2 of triangle
        # We need the line perpendicular to this side of the triangle
        # Lets call the perpendicular vector vector 2 and the side of the triangle vector 1
        # => [x1 y1] * [x2 y2] = 0
        # <=> x1*x2 + y1*y2 = 0
        # <=> y2 = -x1*x2 / y1

        perp_vec = complex(real(trianglevec), -real(curr_point_vec) * real(trianglevec)/imag(curr_point_vec))
        # This vector will always point in to the triangle since it's based on trianglevec
        
        pointvec = point - m # vector from middle of side 1-2 to the point you're investigating
        checks[i] = real(perp_vec)*real(pointvec) + imag(perp_vec)*imag(pointvec) >= 0
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