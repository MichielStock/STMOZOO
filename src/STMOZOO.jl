module STMOZOO


# execute your source file and export the module you made
include("example.jl")
export Example

include("EulerianPath.jl")
export Eulerian_path

end # module
