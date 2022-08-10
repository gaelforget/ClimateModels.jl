
using Zarr, AWS, Downloads, DataFrames, CSV, CFTime, Dates, Statistics, NetCDF

"""
    cmip(institution_id,source_id,variable_id)

Access CMIP6 climate model [archive](https://bit.ly/2WiWmoh) via
`AWS.jl` and `Zarr.jl` and compute (1) time mean global map and
(2) time evolving global mean.

This example was partly inspired by [this notebook](https://bit.ly/2VRMgvl).

```
using ClimateModels
(mm,gm,meta)=cmip()
nm=meta["long_name"]*" in "*meta["units"]

using Plots
heatmap(mm["lon"], mm["lat"], transpose(mm["m"]),
        title=nm*" (time mean)")
plot(gm["t"][1:12:end],gm["y"][1:12:end],xlabel="time",ylabel=nm,
     title=meta["institution_id"]*" (global mean, month by month)")
display.([plot!(gm["t"][i:12:end],gm["y"][i:12:end], leg = false) for i in 2:12])


```
"""
function cmip(institution_id="IPSL",source_id="IPSL-CM6A-LR",
    variable_id="tas")

    #choose model and variable
    S=[institution_id, source_id, variable_id]

    #get list of contents for cloud storage unit
    url="https://storage.googleapis.com/cmip6/cmip6-zarr-consolidated-stores.csv"
    ξ = CSV.read(Downloads.download(url),DataFrame)    

    # get model grid cell areas
    ii=findall( (ξ[!,:source_id].==S[2]).&(ξ[!,:variable_id].=="areacella") )
    μ=ξ[ii,:]
    cmip6,p = Zarr.storefromstring(μ.zstore[end])
    ζ = zopen(cmip6,path=p)
    Å = ζ["areacella"][:, :]

    # get model solution ensemble list
    i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
    (ξ[!,:variable_id].==S[3]).&(ξ[!,:experiment_id].=="historical").&
    (ξ[!,:institution_id].==S[1]) )
    μ=ξ[i,:]

    # access one model ensemble member
    cmip6,p = Zarr.storefromstring(μ.zstore[end])
    ζ = zopen(cmip6,path=p,fill_as_missing=true)
    
    meta=Dict("institution_id" => institution_id,"source_id" => source_id,
        "variable_id" => variable_id, "units" => ζ[S[3]].attrs["units"],
        "long_name" => ζ[S[3]].attrs["long_name"])

    # time mean global map
    m = convert(Array{Union{Missing, Float32},3},ζ[S[3]][:,:,:])
    m = dropdims(mean(m,dims=3),dims=3)

    mm=Dict("lon" => ζ["lon"], "lat" => ζ["lat"], "m" => m)

    # compute model grid cell areas
	function cellarea_calc(lon0,lat0)
		dlon=(lon0[2]-lon0[1])
		dlat=(lat0[2]-lat0[1])
		lat00=[lat0[1]-dlat/2, 0.5*(lat0[2:end]+lat0[1:end-1])...,lat0[end]+dlat/2]
		EarthArea=510072000*1e6
		cellarea(lat1,lat2,dlon)= (EarthArea / 4 / pi) * (pi/180)*abs(sind(lat1)-sind(lat2))*dlon
		[cellarea(lat00[i],lat00[i+1],dlon) for j in 1:length(lon0), i in 1:length(lat0)]
	end
	Å=cellarea_calc(ζ["lon"][:],ζ["lat"][:])

	# (alternative) read model grid cell areas from file
	function cellarea_read(ξ,areacellname="areacella")
	    ii=findall( (ξ[!,:source_id].==S[2]).&(ξ[!,:variable_id].==areacella) )
	    μ=ξ[ii,:]
	    cmip6,p = Zarr.storefromstring(μ.zstore[end])
	    ζζ = zopen(cmip6,path=p)
	    ζζ["areacella"][:, :]
	end
	#Å=cellarea_read(ξ,"areacella")

    # time evolving global mean
    t = ζ["time"]
    tt = timedecode(t[:], t.attrs["units"], t.attrs["calendar"])
    #note: next line "fixes" case when units are DateTimeNoLeap
	t = [DateTime(Dates.year(t),Dates.month(t),Dates.day(t)) for t in tt]

    y = ζ[S[3]][:,:,:]
    y=[sum(y[:, :, i].*Å) for i in 1:length(t)]./sum(Å)

    gm=Dict("t" => t, "y" => y)

    return mm,gm,meta
end

"""
	IPCC_hexagons()

Read hexagons used in IPPC AR6 report. DataFrame contains 
acronym, name, region, and the x, y coordinate (integers)
of each losange. There arrangement mimics the distribution
of continents as done in the report and interactive atlas.

```
df=IPCC_hexagons()
```
"""
function IPCC_hexagons()
	fil2=joinpath(IPCC_SPM_path,"reference-regions","hexagon_grid_locations.csv")
	DataFrame(CSV.File(fil2))
end

"""
	IPCC_fig3_example(df)

```
df=IPCC_hexagons()
clv, ttl, colors=IPCC_fig3_example(df)
```
"""
function IPCC_fig3_example(df)
	fil2=joinpath(IPCC_SPM_path,"reference-regions","hexagon_grid_locations.csv")
	df=DataFrame(CSV.File(fil2))

	#T=Union{Makie.LinePattern,Symbol}
	colors=Array{Symbol}(undef,size(df,1))

    #set colors to co where df.acronym.==acr
    function set_col!(df,acr,colors,co)
        k=findall(df.acronym.==acr)[1]
        colors[k]=co
    end

	colors.=:lightcoral
	set_col!(df,"CNA",colors,:yellow)
	set_col!(df,"ENA",colors,:yellow)
	set_col!(df,"SSA",colors,:lightgray)
	set_col!(df,"CAF",colors,:lightgray)

	ttl="a) Synthesis of assessment of observed change in hot extremes \n and confidence in human contribution to the observed changes \n in the world’s regions"

	confidencelevels=fill("⚪?",size(df,1)) 	
	cl=["⚫⚫⚫","⚫⚫","⚫","⚪"]
	clv=Array{Any}(undef,4)
	clv[1] = [ "NWN","NEN","NEU","WCE","EEU","WSB","ESB","RFE","MED","WCA","ECA","TIB","EAS",
				"SAS","SEA","NWS","SES","WSAF","ESAF","NAU","CAU","EAU","SAU"]
	clv[2] = [ "GIC","RAR","WNA","NCA","SCA","CAR","SAH","ARP","PAC","NWF","NSA",
				"WAF","NEAF","SAM","NES","SEAF","SWS"]
	clv[3] = [ "CNA","ENA","MDG","NZ"]
	clv[4] = [ "CAF","SSA"]

    return clv, ttl, colors

end

#(dat_1b,meta_1b)=ClimateModels.IPCC_fig1b_read()
function IPCC_fig1b_read()
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_01","v20210809")
    fil_1b=joinpath(pth_ipcc,"panel_b","gmst_changes_model_and_obs.csv")
    dat_1b=DataFrame(CSV.File(fil_1b; header=false, skipto=37, footerskip=1))
    rename!(dat_1b, Dict(:Column1 => :year, :Column2 => :HNm, :Column3 => :HN5, :Column4 => :HN95))
    rename!(dat_1b, Dict(:Column5 => :Nm, :Column6 => :N5, :Column7 => :N95, :Column8 => :obs))		

	header=readlines(fil_1b)[12:34]
	
	long_name=String[]
	units=String[]
	comment=String[]
	types=String[]

	for i in findall(occursin.("long_name",header))
			tmp2=split(header[i],",")
			push!(long_name,tmp2[3])
			push!(units,tmp2[4])
	end
	for i in findall(occursin.("comment",header))
			tmp2=split(header[i],",")
			push!(comment,tmp2[3])
	end
	for i in findall(occursin.("type",header))
			tmp2=split(header[i],",")
			push!(types,tmp2[3])
	end

    meta_1b=(long_name,units,comment,types)

    return dat_1b,meta_1b
end

#(dat, dat1, dat2)=IPCC_fig1a_read()
function IPCC_fig1a_read()
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_01","v20210809")
	files=readdir(joinpath(pth_ipcc,"panel_a"))

	input=joinpath(pth_ipcc,"panel_a",files[1])
	dat=DataFrame(CSV.File(input))
	rename!(dat, Dict(Symbol("5%") => :t5, Symbol("95%") => :t95))
	
	input=joinpath(pth_ipcc,"panel_a",files[2])
	dat1=sort(DataFrame(CSV.File(input)),:year)
	
	input=joinpath(pth_ipcc,"panel_a",files[3])
	dat2=DataFrame(CSV.File(input))
	rename!(dat2, Dict(Symbol("5%") => :t5, Symbol("95%") => :t95))

    dat, dat1, dat2
end

#(dat2a,dat2b,dat2c)=IPCC_fig2_read()
function IPCC_fig2_read()
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_02","v20210809")
    files=readdir(joinpath(pth_ipcc,"panel_a"))

	input=joinpath(pth_ipcc,"panel_a",files[1])
	dat=DataFrame(CSV.File(input))

    files_b=readdir(joinpath(pth_ipcc,"panel_b"))
	input_b=joinpath(pth_ipcc,"panel_b",files_b[1])
	dat_b=DataFrame(CSV.File(input_b))

    files_c=readdir(joinpath(pth_ipcc,"panel_c"))
	input_c=joinpath(pth_ipcc,"panel_c",files_c[1])
	dat_c=DataFrame(CSV.File(input_c))
	
	dat_c[6,1]="Volatile organic compounds and \n carbon monoxide (NMVOC + CO)"
	dat_c[4,1]="Halogenated gases (CFC + \n HCFC + HFC)"
	dat_c[11,1]="Land-use reflectance and \n irrigation (irrig+albedo)"

    return dat,dat_b,dat_c
end

#dat=IPCC_fig4_read()
function IPCC_fig4a_read()
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_04","v20210809")

    C=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Carbon_dioxide_Gt_CO2_yr.csv")))
    M=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Methane_Mt_CO2_yr.csv")))
    N=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Nitrous_oxide_Mt_N2O_yr.csv")))	
    S=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Sulfur_dioxide_Mt_SO2_yr.csv")))
    
    (C=C,M=M,N=N,S=S)
end

#dat=IPCC_fig4b_read()
function IPCC_fig4b_read()
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_04","v20210809")
    fil=joinpath(pth_ipcc,"panel_b","ts_warming_ranges_1850-1900_base_panel_b.csv")
    DataFrame(CSV.File(fil))
end

#dat=IPCC_fig5_read()
function IPCC_fig5_read(fil="Panel_a2_Simulated_temperature_change_at_1C.nc")

    nam=""
    occursin("temperature",fil) ? nam="tas" : nothing
    occursin("precipitation",fil) ? nam="pr" : nothing
    occursin("SM_tot",fil) ? nam="mrso" : nothing
    
    pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_05","v20210809")
	lst=readdir(pth_ipcc)
	readme="Readme_for_figure_SPM5.txt"

    lon = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), "lon")[:])
    lat = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), "lat")[:])
    var = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), nam)[:,:,1])

    tmp=(;lon,lat)
    lon=[tmp.lon[i] for i in 1:length(tmp.lon), j in 1:length(tmp.lat)]
    lat=[tmp.lat[j] for i in 1:length(tmp.lon), j in 1:length(tmp.lat)]

    if nam=="tas"
        ttl="Annual mean temperature change (°C) relative to 1850-1900"
        meta=(colorrange=(0,6),cmap=:Reds_9,ttl=ttl)
        var=0.5*floor.(2*var,digits=0)
    elseif nam=="pr"
        ttl="Annual mean precipitation change (%) relative to 1850-1900"
        meta=(colorrange=(-40,40),cmap=:BrBG_10,ttl=ttl)
        var=5.0*floor.(0.2*var,digits=0)
    elseif nam=="mrso"
        ttl="Annual mean total column soil moisture change (standard deviation)"
        meta=(colorrange=(-1.5,1.5),cmap=:BrBG_10,ttl=ttl)
        var=0.25*floor.(4*var,digits=0)
    else
        error("unknown case")
    end

    (lon=lon,lat=lat,var=var,meta=meta)
end
