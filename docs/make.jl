using Documenter, OceanStateEstimation

makedocs(;
    modules=[OceanStateEstimation],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/gaelforget/OceanStateEstimation.jl/blob/{commit}{path}#L{line}",
    sitename="OceanStateEstimation.jl",
    authors="gaelforget <gforget@mit.edu>",
    assets=String[],
)

deploydocs(;
    repo="github.com/gaelforget/OceanStateEstimation.jl",
)
