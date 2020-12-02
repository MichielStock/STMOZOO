@testset "SingleCellNMF" begin
	using STMOZOO.SingleCellNMF
	
	a = 10
	b = -3

	@testset "foo" begin
		result = foo(a, b)
		
		@test result == 7
	end
end

