using ClimateModels, Pkg, Documenter, Test, Suppressor

include("run_one_notebook.jl")

@testset "ipcc" begin
    (dat, dat1, dat2)=ClimateModels.IPCC_fig1a_read()
    (dat_1b,meta_1b)=ClimateModels.IPCC_fig1b_read()
    (dat2a,dat2b,dat2c)=ClimateModels.IPCC_fig2_read()

    df=IPCC_hexagons()
    clv, ttl, colors=ClimateModels.IPCC_fig3_example(df)

    dat4a=ClimateModels.IPCC_fig4a_read()
    dat4b=ClimateModels.IPCC_fig4b_read()
    dat5=ClimateModels.IPCC_fig5_read()
    
    @test isa(colors[1],Symbol)
end

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

