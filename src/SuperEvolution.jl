module SuperEvolution

# Shauny Van Hoye
# Source code for the Super Evolution project (STMO)

# All the code is part of the module SuperEvolution
module SuperEvolution

# Importing all the packages needed for the module to work

using GraphPlot, Graphs, Plots

# Export all relevant functions 
export SuperFormula, PlotSuperFormula


"""
SuperFormula(a, b, m, n1, n2, n3, phi) 

SuperFormula is a generalization of the superellipse. The SuperFormula can be used to describe many complex shapes and curves found in nature.

Inputs:
    - a, b, m, n1, n2, n3: parameters that determine the shape of the figure
    - phi: the angle for which we want to evaluate the function

Outputs:
    - r: polar coordinates for the superformula figure
"""
function SuperFormula(a, b, m, n1, n2, n3, phi)
	
  
	raux = abs(1 / a .* abs(cos(m * phi / 4))) .^ n2 + abs(1 / b .* abs(sin(m * phi / 4))) .^ n3
  
	r = abs(raux) .^ (- 1 / n1)
  
	return r

end




"""
PlotSuperFormula(a, b, m, n1, n2, n3, phi)

SuperFormula is a generalization of the superellipse. The SuperFormula can be used to describe many complex shapes and curves found in nature.
PlotSuperFormula makes a plot of the shape obtained by the SuperFormula.

Inputs:
    - a, b, m, n1, n2, n3: parameters that determine the shape of the figure
    - phi: the angle for which we want to evaluate the function

Outputs:
    - plot of the superformula figure

"""
function PlotSuperFormula(a, b, m, n1, n2, n3, phi)

	rnew = fill(0.0, length(phi))
	x = fill(0.0, length(phi))
	y = fill(0.0, length(phi))
	
	for (num, i) in enumerate(phi)
		
		rnew[num] =  round(SuperFormula(a, b, m, n1, n2, n3, i), digits=8)

		x[num] = rnew[num] .* cos(i)
  
		y[num] = rnew[num] .* sin(i)

	end
	
	return plot(x, y, axis = nothing, label= nothing, border=:none)

end


end

end # module
