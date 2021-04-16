# # Retrieve CMIP6 model output
#
# - Access Climate Model Output Using `AWS.jl` and `Zarr.jl`
# - Choose institution_id, source_id, variable_id
# - Compute and plot (1) time mean global map and (2) time evolving global mean

using ClimateModels, Plots, DisplayAs, Statistics

# ## Access Model Ouput
#
# Here we select that we want to access temperate `tas` from a model by `IPSL`.

(mm,gm,meta)=cmip("IPSL","IPSL-CM6A-LR","tas")

# ## Plot Results
#
# Afterwards, one often uses model output for further analysis. Here we 
# compute and plot (1) time mean global map and (2) time evolving global mean.

nm=meta["long_name"]*" in "*meta["units"]
m=heatmap(mm["lon"], mm["lat"], transpose(mm["m"]), title=nm*" (time mean)")

# ### Time Mean Seasonal Cycle

t=gm["t"]; y=gm["y"]
ylab=meta["long_name"]*" in "*meta["units"]
ny=Int(length(t)/12)
a_y=fill(0.0,(ny,12))
[a_y[:,i].=y[i:12:end] for i in 1:12]

s=plot([0.5:1:11.5],vec(mean(a_y,dims=1)), xlabel="month",ylabel=ylab, 
leg = false, title=meta["institution_id"]*" (global mean, seasonal cycle)")

DisplayAs.PNG(s)

# ### Month By Month Time Series

p=plot(gm["t"][1:12:end],gm["y"][1:12:end],xlabel="time",ylabel=nm,
title=meta["institution_id"]*" (global mean, Month By Month)")
[plot!(gm["t"][i:12:end],gm["y"][i:12:end], leg = false) for i in 2:12];
    
DisplayAs.PNG(p)


