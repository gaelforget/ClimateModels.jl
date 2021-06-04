
# # Intermediate Complexity Atmosphere
#
# Here we setup, run and plot a fast atmopsheric model called [speedy.f90](https://github.com/samhatfield/speedy.f90)
# which stands for _Simplified Parameterizations, privitivE-Equation DYnamics_. Documentation can be found
# [here](https://samhatfield.co.uk/speedy.f90/) and [here](https://www.ictp.it/research/esp/models/speedy.aspx).
#

using ClimateModels, Pkg, Plots, NetCDF
using Suppressor, OrderedCollections, Git, UUIDs

import ClimateModels: build, setup, launch

# ## Define Model Interface

"""
    struct SPEEDY_config <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `SPEEDY` model.
""" 
Base.@kwdef struct SPEEDY_config <: AbstractModelConfig
    model :: String = "speedy"
    configuration :: String = "default"
    options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    channel :: Channel{Any} = Channel{Any}(10) 
    folder :: String = tempdir()
    ID :: UUID = UUIDs.uuid4()
end

function setup(x :: SPEEDY_config)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    pth=joinpath(x.folder,string(x.ID))
    !isdir(pth) ? mkdir(pth) : nothing

    url="https://github.com/gaelforget/speedy.f90"
    @suppress run(`$(git()) clone -b more_diags $url $pth`)

    !isdir(joinpath(pth,"log")) ? git_log_init(x) : nothing
    
    put!(x.channel,launch)
end

function build(x :: SPEEDY_config)
    pth0=pwd()
    pth=joinpath(x.folder,string(x.ID))

    cd(pth)
    #ENV["NETCDF"] = "/usr/local/Cellar/netcdf/4.7.3_2/" #may differ between computers
    ENV["NETCDF"] = "/usr/" #may differ between computers
    @suppress run(`bash build.sh`)
    cd(pth0)
end

function launch(x::SPEEDY_config)
    pth0=pwd()
    pth=joinpath(x.folder,string(x.ID))
    cd(pth)
    @suppress run(`bash run.sh`)
    cd(pth0)
end

# ## Setup, Build, And Launch

MC=SPEEDY_config()
setup(MC)
build(MC)
launch(MC)

# ## Read Model Output And Plot

function plot(x::SPEEDY_config,varname="hfluxn")
    pth=joinpath(MC.folder,string(MC.ID))
    ncfile = NetCDF.open(joinpath(pth,"rundir","198201072200.nc"))
    tmp = ncfile.vars[varname][:,:,1,1]
    contourf(tmp', frmt=:png,title=varname)
end

plot(MC,"hfluxn")

# ## Model Parameters

import MITgcmTools: read_namelist
p=dirname(pathof(ClimateModels))
include(joinpath(p,"../examples/helper_functions.jl"))

nml=read_namelist(MC)
nml[:params]

# ## Time Steps, etc

nml[:date]

