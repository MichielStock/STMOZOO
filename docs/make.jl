using Documenter

using STMOZOO

makedocs(sitename="STMO ZOO",
    modules=[Example], # add your module
        )

deploydocs(
            repo = "github.com/michielstock/STMOZOO.jl.git",
        )