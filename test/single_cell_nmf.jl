@testset "SingleCellNMF" begin
	using STMOZOO.SingleCellNMF, DataFrames, Distributions

	n_cells = 50
	n_rows_rna = 100
	n_rows_atac = 200
	
	rna_df = DataFrame(rand(n_rows_rna, n_cells))
	atac_df = DataFrame(rand(n_rows_atac, n_cells))
	
	rna_df[!, "gene_name"] = map(i -> "gene_$(i)", 1:n_rows_rna)
	atac_df[!, "locus_name"] = map(i -> "locus_$(i)", 1:n_rows_atac)

	all_non_negative(df) = all(all.(>(0), eachcol(df)))

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

			# Expect gene and loci names present in RNA and ATAC DataFrames
			@test_throws ArgumentError perform_nmf(rna_df_no_names, atac_df_no_names, k)
		end
		
		@testset "returned values" begin
			k = 5

			H, W_rna, W_atac, Z, R, obj_history = perform_nmf(rna_df, atac_df, k)

			# Dimensions match?
			@test size(H) == (k, n_cells) 
			# Columns = number of factors + feature name column
			@test size(W_rna) == (n_rows_rna, k + 1)
			@test size(W_atac) == (n_rows_atac, k + 1)
			@test size(Z) == (n_cells, n_cells)
			@test size(R) == (n_cells, n_cells)

			# Objective history recorded for all iterations?
			@test size(obj_history)[1] == 500
			
			# Feature names preserved?
			@test W_rna[!, "gene_name"] == rna_df[!, "gene_name"]
			@test W_atac[!, "locus_name"] == atac_df[!, "locus_name"]
			
			# Non-negativity constraints
			@test all_non_negative(W_rna[!,
				filter(x -> x != "gene_name", names(W_rna))]) 
			@test all_non_negative(W_atac[!,
				filter(x -> x != "locus_name", names(W_atac))]) 
			@test all_non_negative(H)
		end
	end
	
	@testset "reduce_dims_atac" begin
		Z = rand(n_cells, n_cells)
		R = rand(Bernoulli(), n_cells, n_cells)

		# Expect data reduced to two dimensions
		@test size(reduce_dims_atac(atac_df, Z, R)) == (2, n_cells)
		
		# Should also work without aggregation of cells
		@test size(reduce_dims_atac(atac_df)) == (2, n_cells)		
	end
end

