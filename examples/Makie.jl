module IPCC

using CairoMakie

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

	g = Figure()

	a = Axis(g[1, 1])
	set_theme!(theme_light())

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
	set_theme!(theme_minimal())
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
		ll[1]!=="⚪?" ? println("could not find confidenve level for $(df[i,:acronym])") : nothing
		
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
	f_ax2 = Axis(f[1,2],title=ttl1a,xticks = (xpo1a,xti1a),xticklabelrotation=.25pi,xticklabelcolor=xco1a)	
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

	h = Figure(resolution = (900, 600))
	set_theme!(theme_light())

	xtla=["total (observed)","CO2","Non-CO2 GHGs","Aerosols, land use"]

	b = Axis(h[1, 1],xticks=(1:4,xtla), title=nam[1], textsize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[1],:deepskyblue,:deepskyblue3)

	b = Axis(h[1, 2],xticks=(1:4,xtla), title=nam[2], textsize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[2],:royalblue3,:midnightblue)

	b = Axis(h[1, 3],xticks=(1:4,xtla), title=nam[3], textsize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[3],:tan1,:tan3)

	b = Axis(h[1, 4],xticks=(1:4,xtla), title=nam[4], textsize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[4],:firebrick2,:firebrick3)

	b = Axis(h[1, 5],xticks=(1:4,xtla), title=nam[5], textsize=12, xticklabelrotation=.35pi)
	mybarplot!(dat_b,var[5],:brown3,:brown4)

	h
end

end
