module ClimateModels

using Zarr, AWSCore, DataFrames, CSV, CFTime, Dates, Statistics

export AbstractModelConfig, ModelConfig
export clean, build, compile, link, start
export pause, stop, monitor, clock, help
export train, compare, analyze

export cmip

abstract type AbstractModelConfig end

Base.@kwdef struct ModelConfig <: AbstractModelConfig
    model :: String = ""
    configuration :: String = ""
    options :: Array{String,1} = Array{String,1}(undef, 0)
    inputs :: Array{String,1} = Array{String,1}(undef, 0)
    outputs :: Array{String,1} = Array{String,1}(undef, 0)
    status :: Array{String,1} = Array{String,1}(undef, 0)
end

clean(x :: AbstractModelConfig) = missing
build(x :: AbstractModelConfig) = missing
compile(x :: AbstractModelConfig) = missing
link(x :: AbstractModelConfig) = missing
start(x :: AbstractModelConfig) = missing
pause(x :: AbstractModelConfig) = missing
stop(x :: AbstractModelConfig) = missing
function monitor(x :: AbstractModelConfig)
     try 
        x.status[end]
     catch e
        missing
     end
end
clock(x :: AbstractModelConfig) = missing
help(x :: AbstractModelConfig) = missing

train(x :: AbstractModelConfig,y) = missing
compare(x :: AbstractModelConfig,y) = missing
analyze(x :: AbstractModelConfig,y) = missing


"""
    cmip(institution_id,source_id,variable_id)

Access CMIP6 climate model archive (https://bit.ly/2WiWmoh) via
`AWSCore.jl` and `Zarr.jl` and compute (1) time mean global map and
(2) time evolving global mean.

This was partly inspired by @rabernat 's https://bit.ly/2VRMgvl notebook

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

    #initiate cloud connection
    ⅁ = AWSCore.aws_config(creds=nothing, region="",
    service_host="googleapis.com", service_name="storage")

    #get list of contents for cloud storage unit
    β = S3Store("cmip6","", aws=⅁, listversion=1)
    ξ = CSV.read(IOBuffer(β["cmip6-zarr-consolidated-stores.csv"]))

    # get model grid cell areas
    ii=findall( (ξ[!,:source_id].==S[2]).&(ξ[!,:variable_id].=="areacella") )
    μ=ξ[ii,:]
    i1=findfirst("cmip6",μ.zstore[end])[end]+2
    P = μ.zstore[end][i1:end]
    ζ = zopen(S3Store("cmip6", P, aws=⅁, listversion=1))
    Å = ζ["areacella"][:, :];

    # get model solution ensemble list
    i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
    (ξ[!,:variable_id].==S[3]).&(ξ[!,:experiment_id].=="historical").&
    (ξ[!,:institution_id].==S[1]) )
    μ=ξ[i,:]

    # access one model ensemble member
    i1=findfirst("cmip6",μ.zstore[end])[end]+2
    P = μ.zstore[end][i1:end]
    ζ = zopen(S3Store("cmip6", P, aws=⅁, listversion=1))

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

end # module
