module PlotUtils

export get_custom_rdbu_scale, map_bool_to_color

function get_custom_rdbu_scale(opacity::Union{Float32, Float64})
	@assert opacity >= 0 || opacity <= 1 "Opacity must be in [0, 1]"
	white = "rgba(255, 255, 255, $opacity)"
	return [
		[0, "rgba(255, 0, 0, $opacity)"],
		[0.475, "rgb(255, 200, 100, $opacity)"],
		[0.5, white],
		[0.525, "rgb(100, 200, 255, $opacity)"],
		[1, "rgba(0, 0, 255, $opacity)"]
	]
end

function map_bool_to_color(bool_vec::Union{BitVector, Vector{Bool}}, color_true::String, color_false::String)
	return map(el -> el == true ? color_true : color_false, bool_vec)
end

end