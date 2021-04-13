
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
