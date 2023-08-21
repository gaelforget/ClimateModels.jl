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

    @test isa(MC1,PlutoConfig)

    n=notebooks.reroll(pathof(MC1),"main.jl")

    @test isfile(n)
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

