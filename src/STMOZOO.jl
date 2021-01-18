module STMOZOO
# execute your source file and export the module you mad
include("local_greedydesc.jl")
export LocalSearch  
include("example.jl")
include("single_cell_nmf.jl")
export Example, SingleCellNMF
include("gen_prog_align.jl")
export GenProgAlign

end # module
