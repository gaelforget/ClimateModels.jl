
using CairoMakie, CSV, DataFrames, ClimateModels

include("Makie.jl"); using Main.IPCC

##

"""
	read_hexagons()

```
include("examples/IPCC.jl")
df, clv, ttl, colors=read_hexagons()
f=IPCC.hexagons(df,clv,ttl,colors)
save("f.png", f)
```
"""
function read_hexagons()

    pth_ipcc=joinpath(IPCC_SPM_path,"spm")
	fil2=joinpath(IPCC_SPM_path,"reference-regions","hexagon_grid_locations.csv")
	df=DataFrame(CSV.File(fil2))

	T=Union{Makie.LinePattern,Symbol}
	colors=Array{T}(undef,size(df,1))

	colors.=:lightcoral
	IPCC.set_col!(df,"CNA",colors,:yellow)
	IPCC.set_col!(df,"ENA",colors,:yellow)
	IPCC.set_col!(df,"SSA",colors,:lightgray)
	IPCC.set_col!(df,"CAF",colors,:lightgray)

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

    return df, clv, ttl, colors

end

