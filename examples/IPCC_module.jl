module demo

## part 1 : downloading files

using Downloads, DataFrames, CSV, CFTime, Dates, Statistics, NetCDF
using Tar, CodecZlib

IPCC_SPM_path=joinpath(tempdir(),"IPCC_report_files")

function dowload_from_zenodo(storage_path)
	url="https://zenodo.org/record/5541768/files/IPCC-AR6-SPM-plus.tar.gz"
	tmp_file=Downloads.download(url)
	tmp_path=open(tmp_file) do io
		Tar.extract(CodecZlib.GzipDecompressorStream(io))
	end
    !isdir(storage_path) ? mkdir(storage_path) : nothing 
	tmp_mv(fil)=mv(joinpath(tmp_path,fil),joinpath(storage_path,fil),force=true)
	tmp_mv("README.md") 
	tmp_mv("spm") 
	tmp_mv("reference-regions") 
	readdir()
end

"""
    unzip(file,exdir="")

Unzip file content from `file` into the `exdir` folder. 
If `exdir` is not provided then unzip in the folder where `fil` is.

Source: https://discourse.julialang.org/t/how-to-extract-a-file-in-a-zip-archive-without-using-os-specific-tools/34585/5

```
using Downloads, ZipFile

url="https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/110m/cultural/ne_110m_admin_0_countries.zip"
fil=joinpath(tempdir(),"ne_110m_admin_0_countries.zip")

Downloads.download(url,fil)
unzip(fil)
```
"""
function unzip(file,exdir="")
	fileFullPath = isabspath(file) ?  file : joinpath(pwd(),file)
	basePath = dirname(fileFullPath)
	outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(),exdir)))
	isdir(outPath) ? "" : mkdir(outPath)
	zarchive = ZipFile.Reader(fileFullPath)
	for f in zarchive.files
		fullFilePath = joinpath(outPath,f.name)
		if (endswith(f.name,"/") || endswith(f.name,"\\"))
			mkdir(fullFilePath)
		else
			write(fullFilePath, read(f))
		end
	end
	close(zarchive)
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

## part 2 : plotting

using ClimateModels
using CairoMakie, Colors

function main(x::ModelConfig)
	##
	
	(dat_1b,meta_1b)=IPCC_fig1b_read()
	(dat, dat1, dat2)=IPCC_fig1a_read()

	(dat2a,dat2b,dat2c)=IPCC_fig2_read()
	df=IPCC_hexagons()
	clv, ttl, colors=IPCC_fig3_example(df)

	dat4a=IPCC_fig4a_read()
	dat4b=IPCC_fig4b_read()

	myfil="Panel_a2_Simulated_temperature_change_at_1C.nc"
	dat5=IPCC_fig5_read(myfil)

	##

	fig1a=demo.fig1a(dat,dat1,dat2)
	fig1b=demo.fig1b(dat_1b)
	fig2=demo.fig2(dat2a,dat2b,dat2c)
	fig_hexa=demo.hexagons(df,clv,ttl,colors)
	fig4a=demo.fig4a(dat4a)
	fig4b=demo.fig4b(dat4b)

	##

	p=joinpath(pathof(x),"figures")
	!isdir(p) ? mkdir(p) : nothing
	save(joinpath(p,"fig1a.png"),fig1a)
	save(joinpath(p,"fig1b.png"),fig1b)
	save(joinpath(p,"fig2.png"),fig2)
	save(joinpath(p,"fig_hexa.png"),fig_hexa)
	save(joinpath(p,"fig4a.png"),fig4a)
	save(joinpath(p,"fig4b.png"),fig4b)

	x.outputs[:fig1a]=fig1a
	x.outputs[:fig1b]=fig1b
	x.outputs[:fig2]=fig2
	x.outputs[:fig_hexa]=fig_hexa
	x.outputs[:fig4a]=fig4a
	x.outputs[:fig4b]=fig4b
	
	return "model run complete"
end

"""
	hexagons(df,clv,ttl,colors)

```
df=IPCC_hexagons()
include("examples/IPCC.jl")
clv, ttl, colors=example_hexagons(df)
f=IPCC.hexagons(df,clv,ttl,colors)
save("f.png", f)
```
"""
function hexagons(df,clv,ttl,colors)

	cl=["⚫⚫⚫","⚫⚫","⚫","⚪"]

	set_theme!(theme_light())
	g = Figure()

	a = Axis(g[1, 1])

	h=25

	txt="Type of observed change \nin hot extremes"	
	t = text!(a, txt,
			position = Point2f(0,h*0.9),
			align = (:left, :baseline),
			justification = :left,
			color = :black,
			fontsize = 12)	
	
	poly!(hexa(1,h*0.8,0.5), color = :lightcoral, strokecolor = :black, strokewidth = 1)
	text!(a,"Increase (41)",position = Point2f(2,h*0.78),fontsize = 10)
	poly!(hexa(1,h*0.7,0.5), color = :lightblue, strokecolor = :black, strokewidth = 1)
	text!(a,"Decrease (0)",position = Point2f(2,h*0.68),fontsize = 10)
#	poly!(hexa(1,h*0.6,0.5), color = Pattern("/"), strokecolor = :black, strokewidth = 1)
	poly!(hexa(1,h*0.6,0.5), color = :yellow, strokecolor = :black, strokewidth = 1)
	text!(a,"Low agreement in the \n type of change (2)",position = Point2f(2,h*0.58),fontsize = 10)
	poly!(hexa(1,h*0.5,0.5), color = :lightgray, strokecolor = :black, strokewidth = 1)
	text!(a,"Limited data and/or \n literature (2)",position = Point2f(2,h*0.48),fontsize = 10)

	txt="Confidence in human \ncontribution to the \nobserved change"
	t = text!(a, txt,
			position = Point2f(0,h*0.3),
			align = (:left, :baseline),
			justification = :left,
			color = :black,
			fontsize = 12)	

	text!(a,cl[1]*" High",position = Point2f(1,h*0.24),fontsize = 10)
	text!(a,cl[2]*"  Medium",position = Point2f(1,h*0.20),fontsize = 10)
	text!(a,cl[3]*"    Low due to limited agreement",position = Point2f(1,h*0.16),fontsize = 10)
	text!(a,cl[4]*"    Low due to limited evidence",position = Point2f(1,h*0.12),fontsize = 10)

	hidespines!(a)
	hidedecorations!(a)
	xlims!(0,10)
	ylims!(0,h)

	a = Axis(g[1, 2],title=ttl)
	for i in 1:size(df,1)
		if iseven(df[i,:y])
			x0=cos(pi/6)*df[i,:x]
			y0=df[i,:y]*(1/2+sin(pi/6)/2)
			poly!(hexa(x0,y0,0.5), color = colors[i], strokecolor = :black, strokewidth = 1)
		else
			x0=cos(pi/6)*(df[i,:x]-0.5)
			y0=(0.5+sin(pi/6)/2)*df[i,:y]
			poly!(hexa(x0,y0,0.5), color = colors[i], strokecolor = :black, strokewidth = 1)
		end
			
		text!(
			df[i,:acronym],
			position = Point2f(x0,y0),
			align = (:center, :baseline),
			color = :black,
			fontsize = 10,
		)
		
		ll=["⚪?"]
		for l in 1:4
			sum(clv[l].==df[i,:acronym])>0 ? ll[1]=cl[l] : nothing
		end
		ll[1]=="⚪?" ? println("could not find confidence level for $(df[i,:acronym])") : nothing
		
		text!(
			ll[1],
			position = Point2f(x0,y0-0.2),
			align = (:center, :baseline),
			color = :black,
			fontsize = 10,
		)


	end

	text!(a,"Type of observed change since the 1950s",position = Point2f(0,-5),
		fontsize = 16,align = (:center, :baseline), justification = :center)
	
	hidespines!(a)
	hidedecorations!(a)
	xlims!(-7,8)
	ylims!(-6.0,4.0)
	
	colsize!(g.layout, 1, Relative(1/5))
	
	g
end

#position of the hexagon points if center is index x0,y0 and radius is r
function hexa(x0,y0,r)
	hx=Point2f[]
	for i=1:6
		push!(hx,Point2f(x0+r*cos(-.5pi+(i-1)*pi/3),y0+r*sin(-.5pi+(i-1)*pi/3)))
	end
	hx
end

##

function fig1a(dat,dat1,dat2)
	set_theme!(theme_black())
	fig1a = Figure(size = (900, 600))

	##

	fig1a_ax1 = Axis(fig1a[1,1],xticksvisible=false,xticklabelsvisible=false,yticks=[0.2, 1.0])
	band!([0.0,1.0],fill(dat2.t5[1],2),fill(dat2.t95[1],2) ; color = (:greenyellow, 0.5))		

	ylims!(-0.5,2.0)
	hidespines!(fig1a_ax1,:t,:r,:b)

	##

	fig1a_ax2 = Axis(fig1a[1,2], title="Change in global surface temperature", ylabel="degree C")

	l1=lines!(dat.year,dat.temp; color = :dodgerblue)
	band!(dat.year, dat.t5, dat.t95; color = (:dodgerblue, 0.5))

	l2=lines!(dat1.year,dat1.temp; color = :red,linewidth=2.0)

	band!([1850.0,2000.0],fill(-0.5,2),fill(2.0,2) ; color = (:greenyellow, 0.25))

	ylims!(-0.5,2.0)
	axislegend(fig1a_ax2,[l1, l2],["reconstructed","observed"],position=:lt)

	##

	colsize!(fig1a.layout, 2, Relative(0.95))

	fig1a
end

##

function fig1b(dat_1b)
	set_theme!(theme_black())
	fig1b = Figure(size = (900, 600))
	fig1b_ax2 = Axis(fig1b[1,1], title="Change in global surface temperature", ylabel="degree C")

	f1b_l1=lines!(dat_1b.year,dat_1b.HNm; color = :violet)
	band!(dat_1b.year,dat_1b.HN5,dat_1b.HN95; color = (:violet, 0.5))

	f1b_l2=lines!(dat_1b.year,dat_1b.Nm; color = :dodgerblue)
	band!(dat_1b.year,dat_1b.N5,dat_1b.N95; color = (:dodgerblue, 0.5))

	f1b_l3=lines!(dat_1b.year,dat_1b.obs; color = :yellow, linewidth=2.0)
	axislegend(fig1b_ax2,[f1b_l1, f1b_l2, f1b_l3],["Human+Nature","Nature","observed"],position=:lt)

	fig1b
end

##

function fig2(dat,dat_b,dat_c)

	set_theme!(theme_black())
	f = Figure(size = (1200, 800))
	
	f_ax1 = Axis(f[1,1],xticksvisible=false,xticklabelsvisible=false,
		title="Observed warming \n 2010-2019 relative \n to 1850-1900 \n \n")	
	barplot!([dat[1,2]],color=:gray70)
	errorbars!([1.0], [dat[1,2]], [dat[1,2]-dat[2,2]], [dat[3,2]-dat[1,2]], color = :white, whiskerwidth = 20, linewidth=4.0)	
	xlims!(-0.5,2.5); ylims!(-1.0,2.0)

	ttl1a="Aggregated contributions to \n 2010-2019 warming relative to \n 1850-1900, assessed from \n attribution studies."
	xti1a=names(dat_b)[2:end]; n1a=length(xti1a); ye=:yellow; wh=:white;
	xpo1a=1:n1a; xco1a=[:orange,ye,ye,wh,wh]
	bco1a=[:darkorchid1,:darkorchid1,:deepskyblue,wh,wh]
	f_ax2 = Axis(f[1,2],title=ttl1a,xticks = (xpo1a,xti1a),xticklabelrotation=.25pi) #,xticklabelcolor=xco1a)	
	barplot!([dat_b[1,i] for i in 2:size(dat_b,2)],color=bco1a)
	ylims!(-1.0,2.0)
	
	xs=collect(2:size(dat_b,2)) .- 1.0
	ys=[dat_b[1,i] for i in 2:size(dat_b,2)]
	lowerrors=[dat_b[2,i]-dat_b[1,i] for i in 2:size(dat_b,2)]
	higherrors=[dat_b[2,i]-dat_b[1,i] for i in 2:size(dat_b,2)]
	errorbars!(xs, ys, lowerrors, higherrors, color = :white, whiskerwidth = 20, linewidth=4.0)
	
	ttl1a="Contributions to 2010-2019 \n warming relative to 1850-1900, \n assessed from radiative forcing studies \n "
	xti1a=dat_c[:,1]; n1a=length(xti1a);
	xpo1a=collect(1:n1a); xco1a=fill(wh,n1a)
	bco1a=fill(wh,n1a)
	bco1a[findall(dat_c[!,2].>0)].=:darkorchid1
	bco1a[findall(dat_c[!,2].<0)].=:deepskyblue
	f_ax3 = Axis(f[1,3],title=ttl1a,xticks=(xpo1a,xti1a),xticklabelcolor="white",xticklabelrotation=.25pi)	
	barplot!([dat_c[i,2] for i in 1:n1a], color=bco1a)
	ylims!(-1.0,2.0)

	xs=collect(1:size(dat_c,1))
	ys=[dat_c[i,2] for i in 1:size(dat_c,1)]
	lowerrors=[dat_c[i,2]-dat_c[i,3] for i in 1:size(dat_c,1)]
	higherrors=[dat_c[i,2]-dat_c[i,3] for i in 1:size(dat_c,1)]
	errorbars!(xs, ys, lowerrors, higherrors, color = :white, whiskerwidth = 20, linewidth=4.0)
	
	colsize!(f.layout, 1, Relative(0.1))
	colsize!(f.layout, 2, Relative(0.2))
	colsize!(f.layout, 3, Relative(0.7))
	
	f
end

##

function fig4a(dat)
	nam=["SSP1-1.9","SSP1-2.6","SSP2-4.5","SSP3-7.0","SSP5-8.5"]
	var=["ssp119","ssp126","ssp245","ssp370","ssp585"]
	col=[:lightblue,:darkblue,:orange,:red,:darkred]

	g = Figure(size = (900, 600))
	a = Axis(g[1:3, 1],yticks=-20:20:140, title="Carbon dioxide (GtCO2/yr)")

	for i in 1:length(nam)
		lines!(dat.C.years,dat.C[!,var[i]],label=nam[i],color=col[i])
	end
	xlims!(2015,2100)

	Legend(g[2, 2], a)

	a = Axis(g[1, 3],yticks=0:200:800, title="Methane (MtCH4/yr)")
	for i in 1:length(nam)
		lines!(dat.M.years,dat.M[!,var[i]],label=nam[i],color=col[i])
	end
	xlims!(2015,2100); ylims!(0,800)

	a = Axis(g[2, 3],yticks=0:5:20, title="Nitrous oxide (MtN2O/yr)")
	for i in 1:length(nam)
		lines!(dat.N.years,dat.N[!,var[i]],label=nam[i],color=col[i])
	end
	xlims!(2015,2100); ylims!(0,20)

	a = Axis(g[3, 3],yticks=0:40:120, title="Sulfur dioxide (MtSO2/yr)")
	for i in 1:length(nam)
		lines!(dat.S.years,dat.S[!,var[i]],label=nam[i],color=col[i])
	end
	xlims!(2015,2100); ylims!(0,120)

	g
end

function mybarplot!(dat_b,nam="ssp126",col=:royalblue3,col2=:midnightblue)
	tmp1=dat_b[findall(dat_b.scenario.==nam),:]
	t=tmp1[findall(tmp1.forcing.=="total")[1],:]
	c=tmp1[findall(tmp1.forcing.=="co2")[1],:]
	n=tmp1[findall(tmp1.forcing.=="non_CO2_GHGs")[1],:]
	a=tmp1[findall(tmp1.forcing.=="Aersols_Landuse")[1],:]
	
	barplot!([t.p50,c.p50,n.p50,a.p50],color=col)

	o=dat_b[findall(dat_b.scenario.=="observations")[1],:]
	barplot!([o.p50],color=col2)
	
	errorbars!(collect(1.0:4.0),[t.p50,c.p50,n.p50,a.p50],
		[t.p50,c.p50,n.p50,a.p50].-[t.p05,c.p05,n.p05,a.p05],
		[t.p95,c.p95,n.p95,a.p95].-[t.p50,c.p50,n.p50,a.p50],
		color = :black, whiskerwidth = 20, linewidth=2.0)

	ylims!(-1.0,6.0)
end

function fig4b(dat_b)
	nam=["SSP1-1.9","SSP1-2.6","SSP2-4.5","SSP3-7.0","SSP5-8.5"]
	var=["ssp119","ssp126","ssp245","ssp370","ssp585"]

	set_theme!(theme_light())
	h = Figure(size = (900, 600))

	xtla=["total (observed)","CO2","Non-CO2 GHGs","Aerosols, land use"]

	b = Axis(h[1, 1],xticks=(1:4,xtla), title=nam[1], titlesize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[1],:deepskyblue,:deepskyblue3)

	b = Axis(h[1, 2],xticks=(1:4,xtla), title=nam[2], titlesize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[2],:royalblue3,:midnightblue)

	b = Axis(h[1, 3],xticks=(1:4,xtla), title=nam[3], titlesize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[3],:tan1,:tan3)

	b = Axis(h[1, 4],xticks=(1:4,xtla), title=nam[4], titlesize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[4],:firebrick2,:firebrick3)

	b = Axis(h[1, 5],xticks=(1:4,xtla), title=nam[5], titlesize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[5],:brown3,:brown4)

	h
end

end #module IPCC
