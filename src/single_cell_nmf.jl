module SingleCellNMF

export perform_nmf 

function perform_nmf(rna_data::Array{Float64}, atac_data::Array{Float64}, k::Int64)
	if k <= 0
		throw(ArgumentError("k should be positive"))
	end
	
	n_rows_rna, n_cells = size(rna_data)
	n_rows_atac, n_cells = size(atac_data)

	H = zeros(k, n_cells)	
	W_rna = zeros(n_rows_rna, k)
	W_atac = zeros(n_rows_atac, k)

	return H, W_rna, W_atac
end
end
