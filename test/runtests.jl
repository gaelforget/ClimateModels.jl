using ClimateModels, Documenter, Test, PyCall, Conda, CairoMakie
import Zarr, NetCDF, IniFile, Oceananigans

@testset "Oceananigans" begin
    MC=OceananigansConfig(configuration="daily_cycle",inputs=Dict("Nh" => 1))
    run(MC)

    nt=ClimateModels.Oceananigans.nt_from_jld2(MC)
    XZ=ClimateModels.Oceananigans.xz_plot_prep(MC,nt)
    xz_fig=ClimateModels.plot_examples(:Oceananigans_xz,XZ...)

    T,S,w,νₑ=ClimateModels.Oceananigans.tz_slice(MC,nt=nt)
    xw, yw, zw, xT, yT, zT=ClimateModels.Oceananigans.read_grid(MC)
    tz_fig=ClimateModels.plot_examples(:Oceananigans_tz,xw, yw, zw, xT, yT, zT,T,S,w,νₑ)
    @test isa(tz_fig,Figure)
end

ClimateModels.conda(:fair)
ClimateModels.pyimport(:fair)

@testset "FaIR" begin
    MC=FaIRConfig()
    run(MC)
    scenarios,temperatures=FaIR.loop_over_scenarios()
    f=ClimateModels.plot_examples(:FaIR,scenarios,temperatures)
    @test isa(f,Figure)
end

@testset "Speedy" begin
    MC=SpeedyConfig()
    run(MC)

    nml=Speedy.read_namelist(MC)
    files=Speedy.list_files_output(MC)

#    myvar="sst"; ti=findall(occursin.("sea_surface_temperature.nc",files))[1]
    myvar="t"; ti=300
    tmp=Speedy.read_output(files,myvar,ti)
    f_xy=ClimateModels.plot_examples(:Speedy_xy,tmp,myvar,ti,8)
	f_zm=ClimateModels.plot_examples(:Speedy_zm,tmp,myvar,ti)

    rundir=joinpath(MC,"rundir")
    msk=Speedy.get_msk(rundir)
    myvar="sst"; to=1
    ncfile = NetCDF.open(joinpath(rundir,"sea_surface_temperature.nc"))
    f=ClimateModels.plot_examples(:Speedy_input,ncfile,myvar,to,msk)

    @test isa(f,Figure)
end

@testset "JuliaClimate/Notebooks" begin
    nbs=notebooks.list()
    path=joinpath(tempdir(),"nbs")
    notebooks.download(path,nbs)
    @test isfile(joinpath(path,nbs.folder[1],nbs.file[1]))
end

#@testset "defaults" begin
if false
    tmp=ModelConfig()
    show(tmp)
    @test isa(tmp,AbstractModelConfig)

    p=dirname(pathof(ClimateModels))
    f = joinpath(p, "..","examples","defaults.jl")

    update(PlutoConfig(model=f))
    MC0=PlutoConfig(f,(test=true,))

    inputs=Dict(:postprocessing=>"mv(pathof(MC),to_PlutoConfig)")
    MC1=PlutoConfig(model=f,inputs=inputs)
    run(MC1)

    @test isa(MC1,PlutoConfig)

    l=log(MC1)
    ll=split(l[1])[1]
    ClimateModels.git_log_show(MC1,ll)
    log(MC1,"final message to README",msg="all set")

    n=notebooks.reroll(pathof(MC1),"main.jl")
    @test isfile(n)
end

@testset "RandomWalker" begin
    f=ClimateModels.RandomWalker
    MC=ModelConfig(f)
    MC=run(ModelConfig(f,(NS=100,)))
    @test isfile(joinpath(MC,"RandomWalker.csv"))

    pathof(MC,"log")
    joinpath(MC,"log")
    readdir(MC)
    readdir(MC,"log")
    @test ispath(joinpath(MC,"log"))

    put!(MC)
end

@testset "PkgDevConfig" begin
    url="https://github.com/JuliaOcean/AirSeaFluxes.jl"
    PkgDevConfig(url)
    PkgDevConfig(url,x->x)
    x=PkgDevConfig(url,x->x,(y=true,))
    @test isa(x,ModelConfig)
end

@testset "IPCC" begin
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

@testset "Hector" begin
    MC=HectorConfig()
    if Sys.islinux()
        run(MC)
        ClimateModels.plot_examples(:Hector,MC)
        (store,list)=Hector.calc_all_scenarios(MC)
        f_all=ClimateModels.plot_examples(:Hector_scenarios,store,list)
    else
        setup(MC)
    end
    nml=read_IniFile(MC)
    @test isa(nml.sections,Dict)
end

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

