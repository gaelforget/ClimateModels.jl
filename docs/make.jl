using Documenter, ClimateModels, CairoMakie, Pkg
import PlutoSliderServer, PyCall, Conda

Pkg.precompile()

ENV["PYTHON"]=""
Pkg.build("PyCall")
ClimateModels.conda(:fair)
ClimateModels.pyimport(:fair)

lst=("defaults.jl","Hector.jl","FaIR.jl","Oceananigans.jl","RandomWalker.jl",
     "ShallowWaters.jl","MITgcm.jl","Speedy.jl","CMIP6.jl","IPCC.jl")

do_run_notebooks=true

makedocs(;
    modules=[ClimateModels],
    format=Documenter.HTML(),
    doctest=false,
    pages=[
        "Home" => "index.md",
        "User Manual" => "functionalities.md",
        "Examples" => "examples.md",
        "API reference" => "API.md",
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    warnonly = [:cross_references,:missing_docs],
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
)

if do_run_notebooks

for i in lst
    fil_in=joinpath(@__DIR__,"..", "examples",i)
    fil_out=joinpath(@__DIR__,"build", "examples",i[1:end-2]*"html")
    PlutoSliderServer.export_notebook(fil_in)
    #somehow with pycall, this fails at first, but second call works
    i=="FaIR.jl" ? PlutoSliderServer.export_notebook(fil_in) : nothing
    mv(fil_in[1:end-2]*"html",fil_out)
    #cp(fil_in,fil_out[1:end-4]*"jl")
end

fil_in2=joinpath(@__DIR__,"build","ClimateModelsJuliaCon2021.jl")
fil_out2=joinpath(@__DIR__,"build", "examples","ClimateModelsJuliaCon2021.html")
PlutoSliderServer.export_notebook(fil_in2)
mv(fil_in2[1:end-2]*"html",fil_out2)

end #if do_run_notebooks

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
