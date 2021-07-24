using Documenter, Literate, ClimateModels, Pkg

pth=@__DIR__
lst=("defaults.jl",)
lstExecute=("defaults.jl",)
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
    #Literate.notebook(EXAMPLE, OUTPUT, flavor = :pluto)
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
            "Listing" => [map(s -> "generated/$(s[1:end-2])md",lst)...],
            ],
    ],
    repo="https://github.com/gaelforget/ClimateModels.jl/blob/{commit}{path}#L{line}",
    sitename="ClimateModels.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/ClimateModels.jl",
)
