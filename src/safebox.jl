"""
An absolute unit of a function. Should probably have been split into multiple smaller functions, but it functions so well as it is.
This function uses some tricks to prevent going over every single pixel in the rectangle encapsulating your triangle.
Rather than checking every pixel in a line, it searches for the left-most and right-most points of the triangle on a certain height, and then fills in all points between these 2 as "part of the triangle".
By calculating the slopes of the sides of the triangle, it calculates where these points should be.
However, a pixelated line can vary by 1, and the slope will change when you reach a vertex of the triangle, which is why you have to
a) keep checking whether the point you expect to be part of the triangle based on the slope actually is
b) keep calculating the slope
By using these tricks, the function is about 30 times faster than olddrawtriangle.
"""
function drawtriangle(triangle, img0)
    m = length(img0[:, 1]) # y-values
    n = length(img0[1, :]) # x-values
    img = deepcopy(img0)
    ymindanger = false

    xmin = Int(min(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    if xmin < 1 # A point of the triangle is outside of the canvas
        ymindanger = true
        xmin = 1 
    end

    xmax = Int(max(real(triangle.p1), real(triangle.p2), real(triangle.p3)))
    if xmax > n # Again, point is out of the canvas
        ymindanger = true
        xmax = n 
    end

    ymin = Int(min(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymin = max(ymin, 1) # This poses no danger to starting at ymin and not actually finding your triangle
    ymax = Int(max(imag(triangle.p1), imag(triangle.p2), imag(triangle.p3)))
    ymax = min(ymax, m) # Idem

    if ymindanger
        searching4triangle = true

        while searching4triangle # We're going to raise ymin until a point of the triangle was found on the ymin line

            j = xmin # Start at left side of line and go right
            while j <= xmax # Loop breaks if you find point in triangle or you reach end of line without finding anything
                if complex(j, ymin) in triangle # Left point of triangle found
                    searching4triangle = false
                    ymin -= 1 # We're at the correct ymin right now, but ymin += 1 is coming so we raise it by 1 here to cancel it out
                end
                j += 1 # x-value + 1 => We're going to the right looking for our noble triangle
            end
            ymin += 1
        end
    end

    j_left = xmin
    j_right = xmax
    left_points = Vector{Int}(undef, 2)
    right_points = Vector{Int}(undef, 2)
    counter = 1

    for i in ymin:(ymin+1) # We need the first 2 points of both sides of the triangle for their slopes

        j = xmin # Start at left side of line and go right
        while j <= xmax # Loop breaks if you find point in triangle or you reach end of line without finding anything
            if complex(j, i) in triangle # Left point of triangle found
                j_left = j
                left_points[counter] = j
                j = xmax # Get out of loop
            end
            j += 1 # x-value + 1 => We're going to the right looking for our noble triangle
        end

        j = xmax # Now we look for the right point, starting from the right-most point of the line and going left
        while j >= xmin
            if complex(j, i) in triangle
                j_right = j
                right_points[counter] = j
                j = xmin # Out of the loop
                img[i, j_left:j_right] .= triangle.color # Draw the line between the 2 points you found
                # We do this in the if statement because we don't want to draw a line if no point of the triangle was found on this line
            end
            j -= 1
        end

        counter += 1
    end

    leftslope = left_points[2] - left_points[1]
    lastleft = left_points[2]
    print(leftslope, "\n")

    rightslope = right_points[2] - right_points[1]
    lastright = right_points[2]
    print(rightslope, "\n")
    
    for i in (ymin+2):ymax # The rest of the triangle can be done making use of the slopes

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