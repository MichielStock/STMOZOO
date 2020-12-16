using STMOZOO.polygon
using Colors

T1 = Triangle(3 + 2im, 3 + 4im, 5 + 1im, RGB(0, 0, 1))

p = plot(0:5, 0:5, label = false)
plot!([real(T1.p1), real(T1.p2), real(T1.p3), real(T1.p1)], [imag(T1.p1), imag(T1.p2), imag(T1.p3), imag(T1.p1)], label = false)
# testpoint = Vector{Complex}(undef, 8)
# testpoint[1] = 1 + 3im # not in T1
# testpoint[2] = 3 + 2im # in T1
# testpoint[3] = 4 + 1im # in T1
# testpoint[4] = 5 + 2im # not in T1
# testpoint[5] = 2 + 1.5im # on edge off T1 (= in)
# testpoint[6] = 4 + 5im # not
# testpoint[7] = 3.5 + 2.5im # yes
# testpoint[8] = 0.9 + 2im # no

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