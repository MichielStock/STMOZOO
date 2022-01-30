module PlotUtils

export get_custom_rdbu_scale, get_plot_resolution, map_bool_to_color

function get_custom_rdbu_scale(opacity::Union{Float32, Float64})
	@assert opacity >= 0 || opacity <= 1 "Opacity must be in [0, 1]"
	return [
		[0, "rgba(255, 0, 0, $opacity)"],
		[0.45, "rgb(255, 200, 100, $opacity)"],
		[0.5, "rgba(255, 255, 255, $opacity)"],
		[0.55, "rgb(100, 200, 255, $opacity)"],
		[1, "rgba(0, 0, 255, $opacity)"]
	]
end

function get_plot_resolution(size)
	size = lowercase(size)
	@assert size in ["small", "medium", "large", "xlarge"] "Requested plot size '$size' is not supported."

	if size == "small"
		# 16:9 360p
		return 640, 360
	elseif size == "medium"
		# 16:9 480p
		return 854, 480
	elseif size == "large"
		# 16:9 720p
		return 1280, 720
	elseif size == "xlarge"
		# 16:9 1080p
		return 1920, 1080
	end
end

function map_bool_to_color(bool_vec::Union{BitVector, Vector{Bool}}, color_true::String, color_false::String)
	return map(el -> el == true ? color_true : color_false, bool_vec)
end

end