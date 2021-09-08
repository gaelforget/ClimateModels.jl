using Documenter, Literate, ClimateModels, Pkg
import PlutoSliderServer, Plots

pth=@__DIR__
lst=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","Hector.jl","MITgcm.jl","Speedy.jl","CMIP6.jl")
lstExecute=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","Hector.jl","MITgcm.jl","Speedy.jl","CMIP6.jl")
for i in lst
    EXAMPLE = joinpath(pth, "..", "examples", i)
    OUTPUT = joinpath(pth, "src","generated")
    Pkg.activate(joinpath(pth,"..","docs"))
    Literate.markdown(EXAMPLE, OUTPUT, documenter = true)
    cd(pth)
    Pkg.activate(joinpath(pth,"..","docs"))
    tmp=xor(occursin.(i,lstExecute)...)
    Literate.notebook(EXAMPLE, OUTPUT, execute = tmp)
    cd(pth)
end

makedocs(;
    modules=[ClimateModels],
    format=Documenter.HTML(),
    doctest=false,
    pages=[
        "Home" => "index.md",
        "Manual" => "functionalities.md",
        "Examples" => Any[
            "Guide " => "examples.md",
            "Notebooks" => [map(s -> "generated/$(s[1:end-2])md",lst)...],
            ],
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

fil_in=joinpath(@__DIR__,"build","ClimateModelsJuliaCon2021.jl")
PlutoSliderServer.export_notebook(fil_in)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
