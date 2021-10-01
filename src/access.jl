
using Zarr, AWS, Downloads, DataFrames, CSV, CFTime, Dates, Statistics

"""
    cmip(institution_id,source_id,variable_id)

Access CMIP6 climate model archive (https://bit.ly/2WiWmoh) via
`AWS.jl` and `Zarr.jl` and compute (1) time mean global map and
(2) time evolving global mean.

This example was partly inspired by @rabernat 's https://bit.ly/2VRMgvl notebook

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
    ζ = zopen(μ.zstore[end], consolidated=true)
    Å = ζ["areacella"][:, :];

    # get model solution ensemble list
    i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
    (ξ[!,:variable_id].==S[3]).&(ξ[!,:experiment_id].=="historical").&
    (ξ[!,:institution_id].==S[1]) )
    μ=ξ[i,:]

    # access one model ensemble member
    ζ = zopen(μ.zstore[end], consolidated=true)

    meta=Dict("institution_id" => institution_id,"source_id" => source_id,
        "variable_id" => variable_id, "units" => ζ[S[3]].attrs["units"],
        "long_name" => ζ[S[3]].attrs["long_name"])

    # time mean global map
    m = convert(Array{Union{Missing, Float32},3},ζ[S[3]][:,:,:])
    m = dropdims(mean(m,dims=3),dims=3)

    mm=Dict("lon" => ζ["lon"], "lat" => ζ["lat"], "m" => m)

    # time evolving global mean
    t = ζ["time"]
    t = timedecode(t[:], t.attrs["units"], t.attrs["calendar"])

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
