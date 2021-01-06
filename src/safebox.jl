"""
You know when you delete something only to find out you needed it 2 days later?
We don't do that here. Rather than deleting big chunks of code I store them in my safebox, just in case.
"""

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

# function alternatedrawimage(triangles::Array, canvas::Array)
#     m = length(canvas[:, 1]) # y-values
#     n = length(canvas[1, :]) # x-values
#     img = deepcopy(canvas)

#     for i in 1:m # y
#         for j in 1:n # x
#             for triangle in triangles
#                 if complex(j, i) in triangle
#                     img[i, j] = triangle.color
#                 end
#             end
#         end
#     end

#     return img
# end

# function colordiffsum(img1::Array, img2::Array, m::Int, n::Int)
#     colsum = 0
#     for i in 1:m
#         for j in 1:n
#             colsum += colordiff(img1[i, j], img2[i, j])
#         end
#     end
#     return colsum
# end


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

#         score = colordiffsum(polyimg, img)
#         population[i] = [triangles, polyimg, score]
#     end
#     return population
# end

"""
    horizontalgenetransfer(triangles1::Array, triangles2::Array, number_triangles::Int, HGT_rate::Number)

Alternative function for the makechildpopulation, in which HGT is simulated rather than good old having kids.
Current version of the algorithm is using makechildpopulation instead, this was implemented to test out how much the results would differ.
Not enough tests were done for a definitive conclusion.
"""
# function horizontalgenetransfer(triangles1::Array, triangles2::Array, number_triangles::Int, HGT_rate::Number)
#     triangles1_new = deepcopy(triangles1)
#     triangles2_new = deepcopy(triangles2)

#     for i in 1:number_triangles
#         if HGT_rate > rand()
#             triangles1_new[i] = triangles2[i]
#             triangles2_new[i] = triangles1[i]
#         end
#     end

#     return triangles1_new, triangles2_new

# end

"""
HGT part in triangleevolution
"""        
# childPopulation = population
# for i in 1:pop_size
#     if HGT_freq > rand()
#         partner1 = childPopulation[couples[i, 1]]
#         partner2 = childPopulation[couples[i, 2]]

#         childPopulation[couples[i, 1]][1], childPopulation[couples[i, 2]][1] = horizontalgenetransfer!(partner1[1], partner2[1], number_triangles, HGT_rate)
#     end
# end