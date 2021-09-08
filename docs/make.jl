using Documenter, Literate, ClimateModels, Pkg
import PlutoSliderServer, Plots

lst=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","Hector.jl","MITgcm.jl","Speedy.jl","CMIP6.jl")

makedocs(;
    modules=[ClimateModels],
    format=Documenter.HTML(),
    doctest=false,
    pages=[
        "Home" => "index.md",
        "Manual" => "functionalities.md",
        "Examples" => "examples.md",
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

for i in lst
    fil_in=joinpath(@__DIR__,"..", "examples",i)
    fil_out=joinpath(@__DIR__,"build", "examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    mv(fil_in[1:end-2]*"html",fil_out)
end

fil_in=joinpath(@__DIR__,"build","ClimateModelsJuliaCon2021.jl")
PlutoSliderServer.export_notebook(fil_in)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
