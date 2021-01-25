module STMOZOO

# execute your source file and export the module you made
include("example.jl")

include("maximumflow.jl")
export MaximumFlow
include("polygon.jl")
export Example
export polygon
include("EulerianPath.jl")

export EulerianPath
# execute your source file and export the module you mad
include("local_greedydesc.jl")
export LocalSearch  
include("example.jl")
include("single_cell_nmf.jl")
export SingleCellNMF
include("gen_prog_align.jl")
export GenProgAlign

end # module
