# STMO ZOO documentation: Link between fractals and the Newton method

This is the documentation page for the STMO ZOO packages (edition 2021-2022). This is the place for the **documentation**
of two functions, Newtonsmethod and next_guess_zygote.

1. Newtonsmethod
This function will apply the Newton's method to the real point until the difference between two consecutive guesses smaller than ϵ. Some points won't converge, when 10000 steps are made the function stops running.

```@contents
function Newtonsmethod(f, x₀, ϵ = 0.00001)
	
	x = x₀
	steps = 0
	
	while true
		
		Δx = f(x)/f'(x)
		if 	abs(Δx) < ϵ
			break  
		end 	
		x -= Δx 
		steps = steps + 1
		
		if steps == 10000
			break 
		end 
	
	end 
	
	return x, steps
	
end 
```

2. next_guess_zygote
This function will apply the Newton's method to the real and the complex points the algorithm stops running after n steps. The default is n = 100.

```@contents
function next_guess_zygote(f, x₀, n = 100)
	
	@variables z
	fr(z) = real(f(z))
	
	x = x₀
	
	for i = 1:n
		df = gradient(fr, x)[1] |> conj
		x = x - f(x) / df
	end 
	
	return x
	
end 
```
