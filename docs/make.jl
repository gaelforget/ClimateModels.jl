using Documenter, ClimateModels, CairoMakie, Pkg
import PlutoSliderServer
Pkg.precompile()

lst=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","Hector.jl","FaIR.jl","MITgcm.jl","Speedy.jl","CMIP6.jl","IPCC.jl")

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
    #somehow with pycall, this fails at first, but second call works
    i=="FaIR.jl" ? PlutoSliderServer.export_notebook(fil_in) : nothing
    mv(fil_in[1:end-2]*"html",fil_out)
    cp(fil_in,fil_out[1:end-4]*"jl")
end

fil_in=joinpath(@__DIR__,"build","ClimateModelsJuliaCon2021.jl")
PlutoSliderServer.export_notebook(fil_in)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
