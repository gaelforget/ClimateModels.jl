# # ShallowWaters.jl
#
# 	Here we setup, run and plot a two-dimensional shallow water model
#

function config(x)
    nx = 200
    ny = 100
    Lx = 2000e3
    L_ratio = nx/ny
    dx = Lx/nx

    pth=pwd()
    cd(joinpath(x.folder,string(tmp.ID)))
    RunModel(;nx,Lx,L_ratio,Ndays=100,output=true)    # may take 10min depending on resolution
    cd(pth)
end

## setup

using ClimateModels, Pkg
tmp=PackageSpec(url="https://github.com/milankl/ShallowWaters.jl")
tmp=ModelConfig(model=tmp,configuration=config)
setup(tmp)

## run

using ShallowWaters
launch(tmp)