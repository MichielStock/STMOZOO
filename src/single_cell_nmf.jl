module SingleCellNMF

using Distributions

export perform_nmf 

function perform_nmf(X_rna::Array{Float64}, X_atac::Array{Float64}, k::Int64,
			dropout_prob = 0.25, n_iter = 500.0, alpha = 1.0, lambda = 100000.0,
			gamma = 1.0)
	if k <= 0
		throw(ArgumentError("k should be positive"))
	end
	
	n_rows_rna, n_cells = size(X_rna)
	n_rows_atac, n_cells = size(X_atac)

	H = rand(Uniform(), k, n_cells)	
	Z = rand(Uniform(), n_cells, n_cells)
	R = rand(Bernoulli(dropout_prob), n_cells, n_cells)

	W_rna = rand(Uniform(), n_rows_rna, k)
	W_atac = rand(Uniform(), n_rows_atac, k)
	
	for i = 1:n_iter
		# Normalize H
		H = H ./ sum(H, dims = 2)
		W_rna = update_W_rna(W_rna, X_rna, H)  
		w_atac = update_W_atac(W_atac, X_atac, H, Z, R)
		H = update_H(W_rna, W_atac, X_rna, X_atac, H, Z, R, alpha, lambda, gamma)
	end

	return H, W_rna, W_atac
end

function update_W_rna(W_rna::Array{Float64}, X_rna::Array{Float64}, H::Array{Float64})
	return W_rna .* (X_rna * H') ./ (W_rna * H * H')
end

function update_W_atac(W_atac::Array{Float64}, X_atac::Array{Float64}, H::Array{Float64},
			Z::Array{Float64}, R::Array{Bool})
	return W_atac .* (X_atac * (Z .* R) * H') ./ (W_atac * H * H') 
end

function update_H(W_rna::Array{Float64}, W_atac::Array{Float64}, X_rna::Array{Float64},
			X_atac::Array{Float64}, H::Array{Float64}, Z::Array{Float64},
			R::Array{Bool}, alpha::Float64, lambda::Float64, gamma::Float64)
	numerator = alpha * W_rna' * X_rna + W_atac' * X_atac * (Z .* R)
			+ lambda * H * (Z + Z')
	k = size(H)[1]
	denominator = (alpha * W_rna' * W_rna + W_atac' * W_atac + 2 * lambda * H * H'
			+ gamma * zeros(k, k)) * H

	return H .* numerator ./ denominator	
end
end
