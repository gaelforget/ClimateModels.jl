using Documenter, Literate, ClimateModels, Pkg

pth=@__DIR__
lst=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","MITgcm.jl","CMIP6.jl")
lstExecute=("defaults.jl","RandomWalker.jl","ShallowWaters.jl","CMIP6.jl")
for i in lst
    EXAMPLE = joinpath(pth, "..", "examples", i)
    OUTPUT = joinpath(pth, "src","generated")
    Pkg.activate(joinpath(pth,"..","docs"))
    Literate.markdown(EXAMPLE, OUTPUT, documenter = true)
    cd(pth)
    Pkg.activate(joinpath(pth,"..","docs"))
    prod(occursin.(i,lstExecute)) ? tmp=false : tmp=true
    Literate.notebook(EXAMPLE, OUTPUT, execute = tmp)
    cd(pth)
    #Literate.notebook(EXAMPLE, OUTPUT, flavor = :pluto)
end

makedocs(;
    modules=[ClimateModels],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "generated/defaults.md",        
        "generated/RandomWalker.md",        
        "generated/ShallowWaters.md",        
        "generated/MITgcm.md",        
        "generated/CMIP6.md",
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
