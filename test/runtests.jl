using ClimateModels, Documenter, Test, PyCall, Conda, CairoMakie
import Zarr, NetCDF

ClimateModels.conda(:fair)
ClimateModels.pyimport(:fair)

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

@testset "files" begin
    IPCC_path=add_datadep("IPCC")
    fil=joinpath(IPCC_path,"README.md")
    @test isfile(fil)

    MC=ModelConfig(model=IPCC.main,inputs=Dict("path"=>IPCC_path))
    run(MC)
    @test isfile(joinpath(MC,"figures","fig1a.png"))
end

@testset "CMIP6" begin
    ξ=CMIP6.cmip6_stores_list()
	list_institution_id=unique(ξ.institution_id)
    institution_id="IPSL"
    list_source_id=unique(ξ[ξ.institution_id.==institution_id,:source_id])
    source_id=list_source_id[1]
	parameters=Dict("institution_id" => institution_id, "source_id" => source_id, "variable_id" => "tas")
    
    MC=ModelConfig(model="CMIP6_averages",configuration=CMIP6.main,inputs=parameters)
    run(MC)
    @test isfile(joinpath(MC,"output","MeanMaps.nc"))
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

