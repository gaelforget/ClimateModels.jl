using Documenter, Literate, ClimateModels

pth=@__DIR__
EXAMPLE = joinpath(pth, "..", "examples", "MITgcm.jl")
OUTPUT = joinpath(pth, "src","generated")

Literate.markdown(EXAMPLE, OUTPUT, documenter = true)
Literate.notebook(EXAMPLE, OUTPUT, execute = true)
#Literate.notebook(EXAMPLE, OUTPUT, flavor = :pluto)

makedocs(;
    modules=[ClimateModels],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
        "generated/MITgcm.md",        
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
