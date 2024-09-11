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

    update(PlutoConfig(model=f))

    MC1=PlutoConfig(model=f)
    setup(MC1,IncludeManifest=false)
    build(MC1)
    launch(MC1)

    @test isa(MC1,PlutoConfig)

    l=log(MC1)
    ll=split(l[1])[1]
    ClimateModels.git_log_show(MC1,ll)
    log(MC1,"final message to README",msg="all set")

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

    IPCC.IPCC_fig5_read(path=MC.inputs["path"])
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

    function read_CMIP6(MC)	
        fil=joinpath(pathof(MC),"output","MeanMaps.nc")
        lon = NetCDF.open(fil, "lon")
        lat = NetCDF.open(fil, "lat")
        tas = NetCDF.open(fil, "tas")
        
        fil=joinpath(pathof(MC),"output","Details.toml")
        meta=ClimateModels.TOML.parsefile(fil)
        
        fil=joinpath(pathof(MC),"output","GlobalAverages.csv")
        GlobalAverages=ClimateModels.CSV.read(fil,ClimateModels.DataFrame)
        GlobalAverages.year=CMIP6.Dates.year.(GlobalAverages.time)

        return lon,lat,tas,GlobalAverages,meta
    end
    
    lon,lat,tas,GlobalAverages,meta=read_CMIP6(MC)
    
    ClimateModels.plot_examples(:CMIP6_cycle,GlobalAverages,meta)
    ClimateModels.plot_examples(:CMIP6_series,GlobalAverages,meta)
    ClimateModels.plot_examples(:CMIP6_maps,lon,lat,tas,meta)
    
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

