@testset "SingleCellNMF" begin
	using STMOZOO.SingleCellNMF
	
	@testset "arguments validation" begin
		@test_throws ArgumentError perform_nmf(zeros(1, 1), zeros(1, 1,), -1)  
	end
	
	@testset "returned values" begin
		n_cells = 100
		n_rows_rna = 500
		n_rows_atac = 1000
		rna_data = zeros(n_rows_rna, n_cells)
		atac_data = zeros(n_rows_atac, n_cells)
		k = 5

		H, W_rna, W_atac = perform_nmf(rna_data, atac_data, k)

		@test size(H) == (k, n_cells) 
		@test size(W_rna) == (n_rows_rna, k)
		@test size(W_atac) == (n_rows_atac, k)
	end
end

