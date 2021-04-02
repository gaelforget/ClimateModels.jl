using Documenter, Literate, ClimateModels

pth=@__DIR__
lst=("defaults.jl","RandomWalker.jl","ShallowWaters.jl")#,"MITgcm.jl")
for i in lst
    EXAMPLE = joinpath(pth, "..", "examples", i)
    OUTPUT = joinpath(pth, "src","generated")
    Literate.markdown(EXAMPLE, OUTPUT, documenter = true)
    Literate.notebook(EXAMPLE, OUTPUT, execute = false)
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
#        "generated/MITgcm.md",        
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
