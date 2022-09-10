module demo

using ClimateModels
using CairoMakie, Proj, Colors
using GeometryBasics
using GeoJSON
import GeoMakie
import GeoMakie.LineString

function main(x::ModelConfig)
	##
	
	(dat_1b,meta_1b)=ClimateModels.IPCC_fig1b_read()
	(dat, dat1, dat2)=ClimateModels.IPCC_fig1a_read()

	(dat2a,dat2b,dat2c)=ClimateModels.IPCC_fig2_read()
	df=IPCC_hexagons()
	clv, ttl, colors=ClimateModels.IPCC_fig3_example(df)

	dat4a=ClimateModels.IPCC_fig4a_read()
	dat4b=ClimateModels.IPCC_fig4b_read()

	#dat5=ClimateModels.IPCC_fig5_read(myfil)

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
	CairoMakie.save(joinpath(p,"fig1a.png"),fig1a)
	CairoMakie.save(joinpath(p,"fig1b.png"),fig1b)
	CairoMakie.save(joinpath(p,"fig2.png"),fig2)
	CairoMakie.save(joinpath(p,"fig_hexa.png"),fig_hexa)
	CairoMakie.save(joinpath(p,"fig4a.png"),fig4a)
	CairoMakie.save(joinpath(p,"fig4b.png"),fig4b)
	
	#CairoMakie.save(joinpath(p,"fig5.png"),fig5)

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
			textsize = 12)	
	
	poly!(hexa(1,h*0.8,0.5), color = :lightcoral, strokecolor = :black, strokewidth = 1)
	text!(a,"Increase (41)",position = Point2f(2,h*0.78),textsize = 10)
	poly!(hexa(1,h*0.7,0.5), color = :lightblue, strokecolor = :black, strokewidth = 1)
	text!(a,"Decrease (0)",position = Point2f(2,h*0.68),textsize = 10)
#	poly!(hexa(1,h*0.6,0.5), color = Pattern("/"), strokecolor = :black, strokewidth = 1)
	poly!(hexa(1,h*0.6,0.5), color = :yellow, strokecolor = :black, strokewidth = 1)
	text!(a,"Low agreement in the \n type of change (2)",position = Point2f(2,h*0.58),textsize = 10)
	poly!(hexa(1,h*0.5,0.5), color = :lightgray, strokecolor = :black, strokewidth = 1)
	text!(a,"Limited data and/or \n literature (2)",position = Point2f(2,h*0.48),textsize = 10)

	txt="Confidence in human \ncontribution to the \nobserved change"
	t = text!(a, txt,
			position = Point2f(0,h*0.3),
			align = (:left, :baseline),
			justification = :left,
			color = :black,
			textsize = 12)	

	text!(a,cl[1]*" High",position = Point2f(1,h*0.24),textsize = 10)
	text!(a,cl[2]*"  Medium",position = Point2f(1,h*0.20),textsize = 10)
	text!(a,cl[3]*"    Low due to limited agreement",position = Point2f(1,h*0.16),textsize = 10)
	text!(a,cl[4]*"    Low due to limited evidence",position = Point2f(1,h*0.12),textsize = 10)

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
			textsize = 10,
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
			textsize = 10,
		)


	end

	text!(a,"Type of observed change since the 1950s",position = Point2f(0,-5),
		textsize = 16,align = (:center, :baseline), justification = :center)
	
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
	fig1a = Figure(resolution = (900, 600))

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
	fig1b = Figure(resolution = (900, 600))
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
	f = Figure(resolution = (1200, 800))
	
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

	g = Figure(resolution = (900, 600))
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
	h = Figure(resolution = (900, 600))

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

## Functions needed for fig5 (coast lines contours vs date line choice)

function LineRegroup(tmp::Vector)
	coastlines_custom=LineString[]
	for ii in 1:length(tmp)
		push!(coastlines_custom,tmp[ii][:]...)
	end
	coastlines_custom
end

function LineSplit(tmp::Vector,lon0=-160.0)
	[LineSplit(a,lon0) for a in tmp]
end

function LineSplit(tmp::LineString,lon0=-160.0)
	lon0<0.0 ? lon1=lon0+180 : lon1=lon0-180 
	np=length(tmp)
	tmp2=fill(0,np)
	for p in 1:np
		tmp1=tmp[p]
		tmp2[p]=maximum( [(tmp1[1][1]<=lon1)+2*(tmp1[2][1]>=lon1) , (tmp1[2][1]<=lon1)+2*(tmp1[1][1]>=lon1)] )
	end
	if sum(tmp2.==3)==0
		[tmp]
	else
		jj=[0;findall(tmp2.==3)...;np+1]
		[LineString(tmp[jj[ii]+1:jj[ii+1]-1]) for ii in 1:length(jj)-1]
	end
	
#old method (simpler but insufficient)
#		tmp3a=LineString([tmp[ii][1] for ii in findall(tmp2.==1)])
#		tmp3b=LineString([tmp[ii][1] for ii in findall(tmp2.==2)])
#		[tmp3a,tmp3b]
end

"""
    demo_GeoMakie(lon0=-160.0)

Demonstrate use of `LineSplit` to cut coast line polygons at `lon0-180` and `lon0+180`.

The original cut at `-180` and `180` (from the GeoJSON specs it seems) is highlighted with Antarctica.
"""
function demo_GeoMakie(lon0=-160.0)
	f = Figure()
	ax = GeoMakie.GeoAxis(f[1,1]; dest = "+proj=longlat +datum=WGS84 +lon_0=$(lon0)",
		lonlims=GeoMakie.automatic)

	all_lines=LineSplit(GeoMakie.coastlines(),lon0)
	Antarctica=LineSplit(GeoMakie.coastlines()[99],lon0)

	[lines!(ax, l,color=:black) for l in all_lines]
	lines!(ax, Antarctica[1],color=:green)
	lines!(ax, Antarctica[2],color=:red)
	
	f
end

##

function get_land_geo()
	url = "https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/"
	#https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/countries.geojson
	land = Downloads.download(url * "countries.geojson", IOBuffer())
    land_geo = GeoJSON.read(seekstart(land))
	land_geo.features[1]
end

function fig5_legacy(dat,fil,proj=1)
	
	proj==1 ? dx=-Int(size(dat.lon,1)/2) : dx=-20
	lons = circshift(dat.lon[:,1],dx)
	lats = dat.lat[1,:]
	field = circshift(dat.var,(dx,0))

	if proj==2 
		source="+proj=longlat +datum=WGS84"
		dest="+proj=eqearth +lon_0=200.0 +lat_1=0.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80"
	elseif proj==1
		source="+proj=longlat +datum=WGS84"
		dest="+proj=wintri"
	elseif proj==3
		source="+proj=longlat +datum=WGS84"
		dest="+proj=longlat +datum=WGS84 +lon_0=200.0"
	end
	trans = Proj.Transformation(source,dest, always_xy=true) 

	lon=[i for i in lons, j in lats]
    lat=[j for i in lons, j in lats]

    tmp=trans.(lon[:],lat[:])
	x=[a[1] for a in tmp]
	y=[a[2] for a in tmp]
    x=reshape(x,size(lon))
    y=reshape(y,size(lon))

	f = Figure()
	ttl=dat.meta.ttl*" (at $(split(fil,"_")[end][1:end-3]))"
    ax = f[1, 1] = Axis(f, aspect = DataAspect(), title = ttl)

    surf = surface!(ax,x,y,0*x; color=field, 
	colorrange=dat.meta.colorrange, colormap=dat.meta.cmap,
        shading = false)

	ii=[i for i in -180:45:180, j in -78.5:1.0:78.5]';
    jj=[j for i in -180:45:180, j in -78.5:1.0:78.5]';
    xl=vcat([[ii[:,i]; NaN] for i in 1:size(ii,2)]...)
    yl=vcat([[jj[:,i]; NaN] for i in 1:size(ii,2)]...)
    tmp=trans.(xl[:],yl[:])
	xl=[a[1] for a in tmp]
	yl=[a[2] for a in tmp]
    proj<3 ? lines!(xl,yl, color = :black, linewidth = 0.5) : nothing

	if proj==2 
	    tmp=circshift(-179.5:1.0:179.5,(-200))
	elseif proj==1
	    tmp=(-179.5:1.0:179.5)
	elseif proj==3
	    tmp=circshift(-179.5:1.0:179.5,(-200))
	end
    ii=[i for i in tmp, j in -75:15:75];
    jj=[j for i in tmp, j in -75:15:75];
    xl=vcat([[ii[:,i]; NaN] for i in 1:size(ii,2)]...)
    yl=vcat([[jj[:,i]; NaN] for i in 1:size(ii,2)]...)
    tmp=trans.(xl[:],yl[:])
	xl=[a[1] for a in tmp]
	yl=[a[2] for a in tmp]
    proj<3 ? lines!(xl,yl, color = :black, linewidth = 0.5) : nothing

    hidespines!(ax)
    hidedecorations!.(ax)

	#coastplot = lines!(ax, GeoMakie.coastlines(); color = :black, overdraw = true)
	#translate!(coastplot, 0, 0, 99) # ensure they are on top of other plotted elements

	#add colorbar
	Colorbar(f[1,2], surf, height = Relative(0.5))

	f
end

function fig5(dat,fil,proj=1)
	
	proj==1 ? dx=-Int(size(dat.lon,1)/2) : dx=-20
	lons = circshift(dat.lon[:,1],dx)
	lats = dat.lat[1,:]
	field = circshift(dat.var,(dx,0))

	if proj==2 
		dest="+proj=eqearth +lon_0=200.0 +lat_1=0.0 +x_0=0.0 +y_0=0.0 +ellps=GRS80"
		lon0=-160.0
	elseif proj==1
		dest="+proj=wintri"
		lon0=0.0
	elseif proj==3
		dest="+proj=longlat +datum=WGS84 +lon_0=-160.0"
		lon0=-160.0
	end

	lon=[i for i in lons, j in lats]
    lat=[j for i in lons, j in lats]

	ttl=dat.meta.ttl*" (at $(split(fil,"_")[end][1:end-3]))"

	f = Figure()
	ax = GeoMakie.GeoAxis(f[1,1]; dest = dest, lonlims=GeoMakie.automatic, title = ttl)

	[tmp.attributes.attributes[:visible][]=false; for tmp in ax.blockscene.plots[10:10]]
	[tmp.attributes.attributes[:visible][]=false; for tmp in ax.blockscene.plots[15:15]]
	[tmp.attributes.attributes[:color][]=RGBA{Float32}(0.0,0.0,0.0,0.05); for tmp in ax.scene.plots[4:5]]

	surf = surface!(ax,lon,lat,0*lon; color=field, 
	colorrange=dat.meta.colorrange, colormap=dat.meta.cmap,
        shading = false)

	all_lines=demo.LineSplit(GeoMakie.coastlines(),lon0)
	[lines!(ax, l,color=:black,linewidth=1.0) for l in all_lines]
	
	Colorbar(f[1,2], surf, height = Relative(0.5))

	f
end

end #module IPCC