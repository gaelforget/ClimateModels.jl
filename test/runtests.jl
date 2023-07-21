using ClimateModels, Documenter, Test

@testset "JuliaClimate/Notebooks" begin
    nbs=notebooks.list()
    path=joinpath(tempdir(),"nbs")
    notebooks.download(path,nbs)
    @test isfile(joinpath(path,nbs.folder[1],nbs.file[1]))
end

@testset "defaults" begin
    tmp=ModelConfig()
    show(tmp)
    @test isa(tmp,AbstractModelConfig)

    p=dirname(pathof(ClimateModels))
    f = joinpath(p, "..","examples","defaults.jl")

    MC1=PlutoConfig(model=f)
    setup(MC1,IncludeManifest=false)
    build(MC1)
    launch(MC1)

    isa(MC1,PlutoConfig)

    p=joinpath(pathof(MC1),"run")
    n=notebooks.reroll(p,"main.jl")

    isfile(n)
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

