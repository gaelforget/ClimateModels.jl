module ClimateModelsMakieExt

using ClimateModels, Makie
import ClimateModels: plot_examples, ModelConfig        

function plot_examples(ID=Symbol,stuff...)
        if ID==:IPCC
                main_plot_IPCC(stuff...)
        elseif ID==:CMIP6_cycle
                plot_seasonal_cycle(stuff...)
        elseif ID==:CMIP6_series
                plot_time_series(stuff...)
        elseif ID==:CMIP6_maps
                plot_mean_maps(stuff...)
	elseif ID==:FaIR  
		plot_FaIR(stuff...)
	elseif ID==:Oceananigans_xz
		xz_plot(stuff...)
	elseif ID==:Oceananigans_tz
		tz_plot(stuff...)
	elseif ID==:Speedy_input
		Speedy_plot_input(stuff...)
	elseif ID==:Speedy_zm
		Speedy_plot_output_zm(stuff...)
	elseif ID==:Hector
		plot_Hector(stuff...)
	elseif ID==:Hector_scenarios
		plot_all_scenarios(stuff...)
        else
            println("unknown plot ID")
        end
end

##

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

##


function main_plot_IPCC(x::ModelConfig,dat,dat1,dat2,dat_1b,dat2a,dat2b,dat2c,dat2d,dat4a,dat4b)
	fi1a=fig1a(dat,dat1,dat2)
	fi1b=fig1b(dat_1b)
	fi2=fig2(dat2a,dat2b,dat2c)
	fig_hexa=hexagons(dat2d...)
	fi4a=fig4a(dat4a)
	fi4b=fig4b(dat4b)

	p=joinpath(pathof(x),"figures")
	!isdir(p) ? mkdir(p) : nothing
	save(joinpath(p,"fig1a.png"),fi1a)
	save(joinpath(p,"fig1b.png"),fi1b)
	save(joinpath(p,"fig2.png"),fi2)
	save(joinpath(p,"fig_hexa.png"),fig_hexa)
	save(joinpath(p,"fig4a.png"),fi4a)
	save(joinpath(p,"fig4b.png"),fi4b)

	x.outputs[:fig1a]=fi1a
	x.outputs[:fig1b]=fi1b
	x.outputs[:fig2]=fi2
	x.outputs[:fig_hexa]=fig_hexa
	x.outputs[:fig4a]=fi4a
	x.outputs[:fig4b]=fi4b
	
	return "model run complete"
end

## CMIP6

function plot_seasonal_cycle(GA,meta)

nm=meta["long_name"]*" in "*meta["units"]
ny=Int(length(GA.time)/12)
y=fill(0.0,(ny,12))
[y[:,i].=GA.tas[i:12:end] for i in 1:12]

f=Figure(size = (900, 600))
a = Axis(f[1, 1],xlabel="year",ylabel=nm,
title=meta["institution_id"]*" (global mean, seasonal cycle)")		
lines!(a,collect(0.5:1:11.5),vec(sum(y,dims=1)/ny),label=meta["institution_id"],linewidth=2)

f
end

function plot_time_series(GA,meta)
nm=meta["long_name"]*" in "*meta["units"]

f=Figure(size = (900, 600))
a = Axis(f[1, 1],xlabel="year",ylabel=nm,
title=meta["institution_id"]*" (global mean, Month By Month)")		
tim=GA.year[1:12:end]
lines!(a,tim,GA.tas[1:12:end],label="month 1",linewidth=2)
[lines!(a,tim,GA.tas[i:12:end], label = "month $i") for i in 2:12]
f
end

function plot_mean_maps(lon,lat,tas,meta)
nm=meta["long_name"]*" in "*meta["units"]
f=Figure(size = (900, 600))
a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",
title=nm*" (time mean) "*meta["institution_id"])		
hm=heatmap!(a,lon[:], lat[:], tas[:,:])
Colorbar(f[1,2], hm, height = Relative(0.65))
f
end

##

function plot_FaIR(scenarios,temperatures)	
	set_theme!(theme_light())
	f=Figure(size = (900, 600))
	a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
		title="global atmospheric temperature anomaly")		
	for i in 1:4
		lines!(temperatures[i],label="FaIR "*string(scenarios[i]),linewidth=4)
	end
	Legend(f[1, 2], a)
	f
end

##

function xz_plot(t,w,T,S,νₑ,xw, yw, zw, xT, yT, zT)	
	wlims=(-2e-2,2e-2)
	Tlims=(18.5,20.0)
	Slims=(34.999,35.011)
	νlims=(0.0, 2e-3)

	w_title = "vertical velocity (m s⁻¹), t = "*t
	T_title = "temperature (ᵒC), t = "*t
	S_title = "salinity (g kg⁻¹), t = "*t
	ν_title = "eddy viscosity (m² s⁻¹), t = "*t

	f = Figure(size = (1000, 700))

	ga = f[1, 1] = GridLayout()
	gb = f[1, 2] = GridLayout()
	gc = f[2, 2] = GridLayout()
	gd = f[2, 1] = GridLayout()
	
	ax_w,hm_w=heatmap(ga[1, 1],xw[:], zw[:], w, colormap=:balance, colorrange=wlims)
	Colorbar(ga[1, 2], hm_w); ax_w.title = w_title
	ax_T,hm_T=heatmap(gb[1, 1],xT[:], zT[:], T, colormap=:darkrainbow, colorrange=Tlims)
	Colorbar(gb[1, 2], hm_T); ax_T.title = T_title
	ax_S,hm_S=heatmap(gc[1, 1],xT[:], zT[:], S, colormap=:haline, colorrange=Slims)
	Colorbar(gc[1, 2], hm_S); ax_S.title = S_title
	ax_ν,hm_ν=heatmap(gd[1, 1],xT[:], zT[:], νₑ, colormap=:thermal, colorrange=νlims)
	Colorbar(gd[1, 2], hm_ν); ax_ν.title = ν_title

	f
end

function tz_plot(xw, yw, zw, xT, yT, zT,T,S,w,νₑ)
	tt=collect(1:size(T,2))
	
	wlims=(0.0,1e-2)
	Tlims=(17.5,19.5)
	Slims=(34.98,35.02)
	νlims=(0.0, 1e-3)

	w_title = "vertical velocity (m s⁻¹)"
	T_title = "temperature (ᵒC)"
	S_title = "salinity (g kg⁻¹)"
	ν_title = "eddy viscosity (m² s⁻¹)"

	f = Figure(size = (1000, 700))

	ga = f[1, 1] = GridLayout()
	gb = f[1, 2] = GridLayout()
	gc = f[2, 2] = GridLayout()
	gd = f[2, 1] = GridLayout()

	cm=cgrad(:balance, 10)
	ax_w,hm_w=heatmap(ga[1, 1], tt[:], zw[:], w, colormap=cm, colorrange=wlims)
	Colorbar(ga[1, 2], hm_w); ax_w.title = w_title
	cm=cgrad(:darkrainbow, 10)
	ax_T,hm_T=heatmap(gb[1, 1], tt[:], zT[:], T, colormap=cm, colorrange=Tlims)
	Colorbar(gb[1, 2], hm_T); ax_T.title = T_title
	cm=cgrad(:haline, 10)
	ax_S,hm_S=heatmap(gc[1, 1], tt[:], zT[:], S, colormap=cm, colorrange=Slims)
	Colorbar(gc[1, 2], hm_S); ax_S.title = S_title
	cm=cgrad(:thermal, 10)
	ax_ν,hm_ν=heatmap(gd[1, 1], tt[:], zT[:], νₑ, colormap=cm, colorrange=νlims)
	Colorbar(gd[1, 2], hm_ν); ax_ν.title = ν_title

	f
end

##

function Speedy_plot_output_xy(tmp,varname="hfluxn",time=1,level=1)
	(lon,lat,lev,values,fil)=tmp		
	length(size(values))==4 ? tmp = values[:,:,level,1] : tmp = values[:,:,1]
	ttl = varname*" , at $(lev[level]) σ, $(basename(fil)[1:end-3])"

	set_theme!(theme_light())
	f=Figure(size = (900, 600))
	a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",title=ttl)		
	co = Makie.contourf!(a,lon,lat,tmp)
	Colorbar(f[1,2], co, height = Relative(0.65))

	f
end

function Speedy_plot_output_zm(tmp,varname="hfluxn",time=1)
	ttl = varname*" , zonal mean , $(basename(tmp.fil)[1:end-3])"
	set_theme!(theme_light())
	f=Figure(size = (900, 600))

	if length(size(tmp.values))==4 
		val=dropdims(sum(tmp.values[:,:,:,:],dims=1);dims=(1,4))/length(tmp.lon)
		a = Axis(f[1, 1],xlabel="-σ",ylabel="latitude (°N)",title=ttl)	
		co = Makie.contourf!(a,tmp.lat,reverse(-tmp.lev),reverse(val;dims=2))
		Colorbar(f[1,2], co, height = Relative(0.65))
	else
		val=dropdims(sum(tmp.values[:,:,:],dims=1);dims=(1,3))
		a = Axis(f[1, 1],"latitude (°N)",title=ttl)		
		Plots.plot!(a,tmp.lat,val)
	end

	f
end

function Speedy_plot_input(ncfile,varname="sst",time=1,msk=1)
	isnothing(time) ? t=1 : t=mod(time,Base.OneTo(12))
	lon = ncfile.vars["lon"][:]
	lat = reverse(ncfile.vars["lat"][:])
	tmp = reverse(ncfile.vars[varname][:,:,t],dims=2)
	tmp[findall(tmp.==9.96921f36)].=NaN
	
	set_theme!(theme_light())
	f=Figure(size = (900, 600))
	a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",title=varname*" (month $t)")		
	co = Makie.contourf!(a,lon,lat,(msk.*tmp), levels=273 .+collect(-32:4:32))
	Colorbar(f[1,2], co, height = Relative(0.65))
	
	f
end

##

#function plot(x::Hector_config,varname="tas")
function plot_Hector(x,varname="tas")
		varname !=="tas" ? println("case not implemented yet") : nothing

	pth=pathof(x)
	log=readlines(joinpath(pth,"hector","logs","temperature.log"))

	ii=findall([occursin("tas=",i) for i in log])
	nt=length(ii)
	tas=zeros(nt)
	year=zeros(nt)

	for i in 1:nt
		tmp=split(log[ii[i]],"=")[2]
		tas[i]=parse(Float64,split(tmp,"degC")[1])
		year[i]=parse(Float64,split(tmp,"in")[2])
	end

	f=Figure(size = (900, 600))
	a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
	title="global atmospheric temperature anomaly")		
	lines!(year,tas,label=x.configuration,linewidth=4)

	f,a,year,tas
end

function plot_all_scenarios(store,list)
	f,a,year,tas=plot_Hector(store[1],"tas")
	for ii in 2:length(list)
		_,_,_,tas=plot_Hector(store[ii],"tas")
		lines!(a,year,tas,label=list,linewidth=4)
	end
	#Legend(f[1, 2], a)
	return f		
end

end



