# # Shallow Water Model
#
# Here we setup, run and plot a two-dimensional shallow water model configuration from [ShallowWaters.jl](https://github.com/milankl/ShallowWaters.jl)
#

using ClimateModels, Pkg, Plots, NetCDF, Suppressor

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
# `ModelConfig` wraps up the model into a data structure, `MC`, which also includes e.g. the online location for the model repository.

MC=ModelConfig(model=URL,configuration=SWM,inputs=parameters)

# The `setup` function then clones the online repository to a temporary folder and sets up the `git` log subfolder.

setup(MC);

# The version of `ShallowWaters.jl` selected by `URL` should be used. The `Pkg.develop` command below should ensure that this is the case.
#
# _Note: if another version of the package was already installed, you may want to run `Pkg.free("ShallowWaters")` afterwards._

MCdir=joinpath(MC.folder,string(MC.ID))
@suppress Pkg.develop(path=MCdir)
using ShallowWaters

# ## Run Model
#
# The `SWM` model is run within the `launch` command which also updates the `git` log accordingly.

launch(MC);

# ## Plot Results
#
# Afterwards, one often replays model output for further analysis.
# Here we plot the random walker path from the `netcdf` output file.

ncfile = NetCDF.open(joinpath(MCdir,"run0000","sst.nc"))
sst = ncfile.vars["sst"][:,:,:]
img=contourf(sst[:,:,parameters[:nd]]',c = :grays, clims=(-1.,1.), frmt=:png)

# Or to create an animated `gif`
#
# ```
# anim = @animate for t ∈ 1:parameters[:nd]+1
#     contourf(sst[:,:,t+1]',c = :grays, clims=(-1.,1.))
# end
# gif(anim, joinpath(MCdir,"run0000","sst.gif"), fps = 40)
# ```