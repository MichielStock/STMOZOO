# STMO ZOO documentation

This is the documentation page for the STMO ZOO packages (edition 2020-2021). This is the place for the **documentation**
of your function. So explain the main functionality of your module and list the documentation of your funtions.

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
		
		if steps == 100
			break 
		end 
	
	end 
	
	return x, steps
	
end 
```
