
#https://www.ictp.it/research/esp/models/speedy.aspx
#https://samhatfield.co.uk/speedy.f90/
#https://github.com/samhatfield/speedy.f90

using ClimateModels, Pkg, Plots, NetCDF, Suppressor, OrderedCollections, Git, UUIDs

import ClimateModels: build, setup, launch

"""
    struct ModelConfig <: AbstractModelConfig

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
    
    put!(x.channel,SPEEDY_launch)
end

function build(x :: SPEEDY_config)
    pth0=pwd()
    pth=joinpath(x.folder,string(x.ID))

    cd(pth)
    ENV["NETCDF"] = "/usr/local/Cellar/netcdf/4.7.3_2/" #may differ between computers
    @suppress run(`bash build.sh`)
    cd(pth0)
end

##

function SPEEDY_launch(x::SPEEDY_config)
    pth0=pwd()
    pth=joinpath(x.folder,string(x.ID))
    cd(pth)
    @suppress run(`bash run.sh`)
    cd(pth0)
end

##

MC=SPEEDY_config()
setup(MC)
build(MC)
launch(MC)

##

function plot(x::SPEEDY_config,varname="hfluxn")
    pth=joinpath(MC.folder,string(MC.ID))
    ncfile = NetCDF.open(joinpath(pth,"rundir","198201072200.nc"))
    tmp = ncfile.vars[varname][:,:,1,1]
    contourf(tmp', frmt=:png,title=varname)
end

