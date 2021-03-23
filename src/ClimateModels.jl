module ClimateModels

using Zarr, AWSCore, DataFrames, CSV, CFTime, Dates, Statistics, UUIDs

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export pause, stop, monitor, clock, help
export train, compare, analyze

export cmip

abstract type AbstractModelConfig end

Base.@kwdef struct ModelConfig <: AbstractModelConfig
    model :: Union{Function,String} = "anonymous"
    configuration :: Union{Function,String} = "anonymous"
    options :: Array{String,1} = Array{String,1}(undef, 0)
    inputs :: Array{String,1} = Array{String,1}(undef, 0)
    outputs :: Array{String,1} = Array{String,1}(undef, 0)
    status :: Array{String,1} = Array{String,1}(undef, 0)
    channel :: Channel{Any} = Channel{Any}(10) 
    folder :: String = tempdir()
    ID :: UUID = UUIDs.uuid4()
end

"""
    default_ClimateModelSetup(x)

```
somemodel() = [x^2 for x in -10.:10.]
tmp=ModelConfig(model=somemodel)
setup(tmp)
launch(tmp)
```
""" 
function default_ClimateModelSetup(x::AbstractModelConfig)
    isa(x.model,Function) ? put!(x.channel,x.model) : nothing
    isa(x.configuration,Function) ? put!(x.channel,x.configuration) : nothing
end

function default_ClimateModelBuild(x)
    isa(x.model,String) ? Pkg.build(x.model) : nothing
end

default_ClimateModelRun(x) = take!(x.channel)()

clean(x :: AbstractModelConfig) = missing #use channel?
build(x :: AbstractModelConfig) = default_ClimateModelBuild(x)
compile(x :: AbstractModelConfig) = default_ClimateModelBuild(x)
setup(x :: AbstractModelConfig) = default_ClimateModelSetup(x)
launch(x :: AbstractModelConfig) = default_ClimateModelRun(x)

pause(x :: AbstractModelConfig) = missing #use channel?
stop(x :: AbstractModelConfig) = missing #use channel?
function monitor(x :: AbstractModelConfig)
     try 
        x.status[end]
     catch e
        missing
     end
end
clock(x :: AbstractModelConfig) = missing #use Base.Timer?
help(x :: AbstractModelConfig) = println("Please consider using relevant github issue trackers for questions")

function Base.show(io::IO, z::AbstractModelConfig)
    printstyled(io, "  model         = ",color=:normal)
    printstyled(io, "$(z.model)\n",color=:blue)
    printstyled(io, "  configuration = ",color=:normal)
    printstyled(io, "$(z.configuration)\n",color=:blue)
    printstyled(io, "  status        = ",color=:normal)
    printstyled(io, "$(z.status)\n",color=:blue)
    printstyled(io, "  folder        = ",color=:normal)
    printstyled(io, "$(z.folder)\n",color=:blue)
    printstyled(io, "  ID            = ",color=:normal)
    printstyled(io, "$(z.ID)\n",color=:blue)
end

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
