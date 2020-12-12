@testset "SingleCellNMF" begin
	using STMOZOO.SingleCellNMF, DataFrames

	n_cells = 100
	n_rows_rna = 500
	n_rows_atac = 1000
	
	rna_df = DataFrame(rand(n_rows_rna, n_cells))
	atac_df = DataFrame(rand(n_rows_atac, n_cells))
	
	rna_df[!, "gene_name"] = map(i -> "gene_$(i)", 1:n_rows_rna)
	atac_df[!, "locus_name"] = map(i -> "locus_$(i)", 1:n_rows_atac)

	@testset "perform_nmf" begin
		@testset "k validation" begin
			# number of factors should be positive
			k = -1
			@test_throws ArgumentError perform_nmf(rna_df, atac_df, k)  
		end

		@testset "DataFrame validation" begin
			k = 5
			rna_df_no_names = rna_df[!, filter(x -> x != "gene_name", names(rna_df))]
			atac_df_no_names = atac_df[!, filter(x -> x != "locus_name", names(atac_df))]

			@test_throws ArgumentError perform_nmf(rna_df_no_names, atac_df_no_names, k)
		end
		
		@testset "returned values" begin
			k = 5

			H, W_rna, W_atac, Z, R, obj_history = perform_nmf(rna_df, atac_df, k)

			@test size(H) == (k, n_cells) 
			@test size(W_rna) == (n_rows_rna, k)
			@test size(W_atac) == (n_rows_atac, k)
			@test size(Z) == (n_cells, n_cells)
			@test size(R) == (n_cells, n_cells)
			@test size(obj_history)[1] == 500
		end
	end
	
	@testset "reduce_dims_atac" begin
		Z = rand(n_cells, n_cells)
		R = rand(n_cells, n_cells)

		atac_reduced = reduce_dims_atac(atac_df, Z, R)
		
		@test size(atac_reduced) == (2, n_cells)
	end
end

