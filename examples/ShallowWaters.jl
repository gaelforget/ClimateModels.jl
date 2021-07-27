# # Shallow Water Model (Julia)
#
# Here we setup, run and plot a two-dimensional shallow water model configuration from [ShallowWaters.jl](https://github.com/milankl/ShallowWaters.jl)
#

using ClimateModels, Pkg, NetCDF, Suppressor

# ## Formulate Model
#

URL=PackageSpec(url="https://github.com/milankl/ShallowWaters.jl")

parameters=Dict(:nx => 100, :ny => 50, :Lx => 2000e3, :nd=>500) #adjustable parameters

function SWM(x)
    pth=pwd()
    cd(joinpath(x.folder,string(x.ID)))
    (nx,ny)=(x.inputs[:nx],x.inputs[:ny])
    (Lx,nd)=(x.inputs[:Lx],x.inputs[:nd])
    L_ratio = nx / ny
    @suppress run_model(;nx,Lx,L_ratio,Ndays=nd,output=true) #calling this may take several minutes (or more) depending on resolution
    cd(pth)
end

# ## Setup Model
#
# `ModelConfig` wraps up the model into a data structure, `MC`, which also includes e.g. the online location for the model repository, parameters, and a local folder path used later on.

MC=ModelConfig(model=URL,configuration=SWM,inputs=parameters)

# The `setup` function then calls `Pkg.develop` and sets up the `git` log subfolder.

setup(MC)

# ## Run Model
#
# The `SWM` model is run within the `launch` command which also updates the `git` log accordingly.

using ShallowWaters
launch(MC)

# ## Plot Results
#
# Here we read temperature from the `netcdf` output file and and map it for time `parameters[:nd]`

MCdir=joinpath(MC.folder,string(MC.ID))
ncfile = NetCDF.open(joinpath(MCdir,"run0000","sst.nc"))
sst = ncfile.vars["sst"][:,:,:]

# Alternatively, one can create an animated `gif` e.g. as shown here.
#
# ```
# anim = @animate for t ∈ 1:parameters[:nd]+1
#     contourf(sst[:,:,t+1]',c = :grays, clims=(-1.,1.))
# end
# gif(anim, joinpath(MCdir,"run0000","sst.gif"), fps = 40)
# ```