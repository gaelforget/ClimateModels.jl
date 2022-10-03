using ClimateModels, Documenter, Test

include("run_one_notebook.jl")

@testset "notebooks" begin
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
    MC1=run_one_notebook(f,IncludeManifest=false)
    isa(MC1,AbstractModelConfig)
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

