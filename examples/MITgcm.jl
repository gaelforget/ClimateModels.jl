# # General Circulation Model (Fortran)
#
# Here we setup and run [MITgcm](https://mitgcm.readthedocs.io/en/latest/). This  
# general circulation model can simulate the Ocean (as done here), Atmosphere 
# (plot below), and other components of the climate system accross a wide range 
# of scales and configurations.

using ClimateModels, MITgcmTools, MeshArrays, Plots, Suppressor

# ![fig1](https://user-images.githubusercontent.com/20276764/111042787-12377e00-840d-11eb-8ddb-64cc1cfd57fd.png)
	
# ## Setup Model
#
# The most standard MITgcm configurations (_verification experiments_) are all readily available via `MITgcmTools.jl`'s `MITgcm_config` function.
#

MC=MITgcm_config(configuration="global_with_exf")

# The `setup` function links input files to the `run/` folder (see below).

setup(MC)

# Model parameters can then be accessed via `MC.inputs`.

MC.inputs

# ## Build `mitgcmuv`
#
# The model executable `mitcmuv` is normally found in the `build/` subfolder of the selected experiment.
# If `mitcmuv` is not found at this stage then it is assumed that the chosen model configuration still needs to be compiled (once, via the `build` function).
# This might take a lot longer than a normal model run due to the one-time cost of compiling the model.

if isa(MITgcm_path,Array) #MITgcmTools > v0.1.22
	build(MC,"--allow-skip")
else
	build(MC)
end

# ## Run Model
#
# The main model computation takes place via the `launch` function. 

launch(MC)

# MITgcm will output files in the `run/` folder incl. the standard `output.txt` file.

rundir=joinpath(MC.folder,string(MC.ID),"run")
fileout=joinpath(rundir,"output.txt")
readlines(fileout)

# ## Model Monitor
# 
# Often, the term _monitor_ in climate modeling denotes a statement / counter printed to standard model output (text file) at regular intervals to monitor the model's integration through time. In the example below, we use global mean temperature which is reported every time step as `dynstat_theta_mean` in the MITgcm `output.txt` file.

filstat=joinpath(rundir,"onestat.txt")
run(pipeline(`grep dynstat_theta_mean $(fileout)`,filstat))

tmp0 = read(filstat,String)
tmp0 = split(tmp0,"\n")
Tmean=[parse(Float64,split(tmp0[i],"=")[2]) for i in 1:length(tmp0)-1]
p=plot(Tmean,frmt=:png)

# ## Plot Results
#
# As models run through time, they typically output snapshots and/or time-averages of state variables in `binary` or `netcdf` format for example. Afterwards, or even while the model runs, one can reread this output. Here, for example, we plot the temperature map after 20 time steps (`T.0000000020`) this way by using the convenient [MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) and [MeshArrays.jl](https://juliaclimate.github.io/MeshArrays.jl/dev/) packages which simplify the handling of files and data.

XC=read_mdsio(rundir,"XC"); siz=size(XC)

mread(xx::Array,x::MeshArray) = read(xx,x)	
function mread(fil::String,x::MeshArray)
	d=dirname(fil)
	b=basename(fil)[1:end-5]
	read(read_mdsio(d,b),x)
end

γ=gcmgrid(rundir,"PeriodicChannel",1,fill(siz,1), [siz[1] siz[2]], eltype(XC), mread, write)
Γ=GridLoad(γ)
T=read_mdsio(rundir,"T.0000000020")
h=heatmap(T[:,:,1]',frmt=:png)

# ## Workflow Outline
# 
# _ClimateModels.jl_ additionally supports workflow documentation using `git`. Here we summarize this workflow's record.

git_log_show(MC)

# _See run folder for workflow output:_

show(MC)