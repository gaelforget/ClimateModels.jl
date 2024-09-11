
module downloads

using DataDeps, Dataverse, Glob

"""
    unpackDV(filepath)

Like DataDeps's `:unpack` but using `Dataverse.untargz` and remove the `.tar.gz` file.
"""    
function unpackDV(filepath; do_warn=false)
    tmp_path=Dataverse.untargz(filepath)
    tmp_path2=joinpath(tmp_path,basename(filepath)[1:end-7])
    tmp_path=(ispath(tmp_path2) ? tmp_path2 : tmp_path)
    if isdir(tmp_path)
        [mv(p,joinpath(dirname(filepath),basename(p))) for p in glob("*",tmp_path)]
        [println(joinpath(dirname(filepath),basename(p))) for p in glob("*",tmp_path)]
        rm(filepath)
    else
        rm(filepath)
        mv(tmp_path,joinpath(dirname(filepath),basename(tmp_path)))
    end
    do_warn ? println("done with unpackDV for "*filepath) : nothing
end

"""
    __init__datasets()

Register data dependency with DataDep.
"""
function __init__datasets()
    register(DataDep("IPCC","IPCC AR6 data",
        ["https://zenodo.org/record/5541768/files/IPCC-AR6-SPM-plus.tar.gz"],
        post_fetch_method=unpackDV))
end

"""
    add_datadep(nam::String)

Add data to the scratch space folder. Known options for `nam` include 
"release1", "release2", "release3", "release4", "release5", and "OCCA2HR1".

Under the hood this is the same as:

```
using Climatology
add_datadep("IPCC")
```
"""
function add_datadep(nam::String)
    withenv("DATADEPS_ALWAYS_ACCEPT"=>true) do
        if nam=="IPCC"
            datadep"IPCC"
        else
            println("unknown solution")
        end
    end
end

end

##

module IPCC

using DataFrames, CSV#, NetCDF
import ClimateModels: ModelConfig, plot_examples

#IPCC_SPM_path=downloads.add_datadep("IPCC")

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
function IPCC_hexagons(; path="")
	fil2=joinpath(path,"reference-regions","hexagon_grid_locations.csv")
	DataFrame(CSV.File(fil2))
end

"""
	IPCC_fig3_example(df)

```
df=IPCC_hexagons()
clv, ttl, colors=IPCC_fig3_example(df)
```
"""
function IPCC_fig3_example(df; path="")
	fil2=joinpath(path,"reference-regions","hexagon_grid_locations.csv")
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
function IPCC_fig1b_read(; path="")
    pth_ipcc=joinpath(path,"spm","spm_01","v20210809")
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
function IPCC_fig1a_read(; path="")
    pth_ipcc=joinpath(path,"spm","spm_01","v20210809")
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
function IPCC_fig2_read(; path="")
    pth_ipcc=joinpath(path,"spm","spm_02","v20210809")
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
function IPCC_fig4a_read(; path="")
    pth_ipcc=joinpath(path,"spm","spm_04","v20210809")

    C=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Carbon_dioxide_Gt_CO2_yr.csv")))
    M=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Methane_Mt_CO2_yr.csv")))
    N=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Nitrous_oxide_Mt_N2O_yr.csv")))	
    S=DataFrame(CSV.File(joinpath(pth_ipcc,"panel_a","Sulfur_dioxide_Mt_SO2_yr.csv")))
    
    (C=C,M=M,N=N,S=S)
end

#dat=IPCC_fig4b_read()
function IPCC_fig4b_read(; path="")
    pth_ipcc=joinpath(path,"spm","spm_04","v20210809")
    fil=joinpath(pth_ipcc,"panel_b","ts_warming_ranges_1850-1900_base_panel_b.csv")
    DataFrame(CSV.File(fil))
end

#dat=IPCC_fig5_read()
function IPCC_fig5_read(fil="Panel_a2_Simulated_temperature_change_at_1C.nc"; path="")

    nam=""
    occursin("temperature",fil) ? nam="tas" : nothing
    occursin("precipitation",fil) ? nam="pr" : nothing
    occursin("SM_tot",fil) ? nam="mrso" : nothing
    
    pth_ipcc=joinpath(path,"spm","spm_05","v20210809")
	lst=readdir(pth_ipcc)
	readme="Readme_for_figure_SPM5.txt"

    lon = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), "lon")[:])
    lat = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), "lat")[:])
    var = Float64.(NetCDF.open(joinpath(pth_ipcc,fil), nam)[:,:,1])

    tmp=(;lon,lat)
    lon=[tmp.lon[i] for i in 1:length(tmp.lon), j in 1:length(tmp.lat)]
    lat=[tmp.lat[j] for i in 1:length(tmp.lon), j in 1:length(tmp.lat)]

    lon0=0 #-160
    if nam=="tas"
        ttl="Annual mean temperature change (°C) relative to 1850-1900"
        meta=(colorrange=(0,6),cmap=:Reds_9,ttl=ttl,lon0=lon0)
        var=0.5*floor.(2*var,digits=0)
    elseif nam=="pr"
        ttl="Annual mean precipitation change (%) relative to 1850-1900"
        meta=(colorrange=(-40,40),cmap=:BrBG_10,ttl=ttl,lon0=lon0)
        var=5.0*floor.(0.2*var,digits=0)
    elseif nam=="mrso"
        ttl="Annual mean total column soil moisture change (standard deviation)"
        meta=(colorrange=(-1.5,1.5),cmap=:BrBG_10,ttl=ttl,lon0=lon0)
        var=0.25*floor.(4*var,digits=0)
    else
        error("unknown case")
    end

    (lon=lon,lat=lat,var=var,meta=meta)
end

function main(x::ModelConfig)
    path=x.inputs["path"]

	(dat_1b,meta_1b)=IPCC_fig1b_read(path=path)
	(dat, dat1, dat2)=IPCC_fig1a_read(path=path)

	(dat2a,dat2b,dat2c)=IPCC_fig2_read(path=path)
	df=IPCC_hexagons(path=path)
	clv, ttl, colors=IPCC_fig3_example(df,path=path)
    dat2d=(df, clv, ttl, colors)

	dat4a=IPCC_fig4a_read(path=path)
	dat4b=IPCC_fig4b_read(path=path)

#    return (dat,dat1,dat2,dat_1b,dat2a,dat2b,dat2c,dat2d,dat4a,dat4b)
    return plot_examples(:IPCC,x,dat,dat1,dat2,dat_1b,dat2a,dat2b,dat2c,dat2d,dat4a,dat4b)
end

end #module IPCC


