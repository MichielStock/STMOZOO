using STMOZOO.polygon
using Colors, Plots


T1 = Triangle(3 + 2im, 3 + 4im, 5 + 1im, RGB(0, 0, 1))

p = plot(0:5, 0:5, label = false)
plot!([real(T1.p1), real(T1.p2), real(T1.p3), real(T1.p1)], [imag(T1.p1), imag(T1.p2), imag(T1.p3), imag(T1.p1)], label = false)

n = 300

for i in 1:n
    point = complex(rand()*5, rand()*5)
    check = point in T1
    if check == true
        col = :green
    else
        col = :red
    end
    scatter!([real(point)], [imag(point)], label = false, color = col)
end
display(p)