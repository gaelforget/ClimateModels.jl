# # General Circulation Model
#
# 	Here we setup, run and plot [MITgcm](https://mitgcm.readthedocs.io/en/latest/) interactively to generate something like this:
#
# ![fig1](https://user-images.githubusercontent.com/20276764/111042787-12377e00-840d-11eb-8ddb-64cc1cfd57fd.png)

using ClimateModels, MITgcmTools, MeshArrays, Plots

# ## Select Model Configuration
#
# Here we select one of the standard MITgcm configurations (or _verification experiments_) via the `MITgcmTools.jl` package.
#

exps=verification_experiments()	
myexp="global_with_exf"
tmp=[exps[i].configuration==myexp for i in 1:length(exps)]
iexp=findall(tmp)[1];

# To inspect model parameters use functions provided by `MITgcmTools.jl`

fil=joinpath(MITgcm_path,"verification",exps[iexp].configuration,"input","data")
nml=read(fil,MITgcm_namelist())

# ## Where Is `mitgcmuv` located?
#
# The model executable `mitcmuv` is normally found in the `build/` subfolder of the selected experiment.
# If `mitcmuv` is not found at this stage then it is assumed that the chosen model configuration has never been compiled -- such that we need to compile and run the model a first time. This might take a lot longer than a normal model run due to the one-time cost of compiling the model.
# Once `mitgcmuv` is found, then a `🏁` should appear just below.

filexe=joinpath(MITgcm_path,"verification",exps[iexp].configuration,"build","mitgcmuv")
!isfile(filexe) ? build(exps[iexp]) : nothing
filout=joinpath(exps[iexp].folder,"run","output.txt")
filstat=joinpath(exps[iexp].folder,"run","onestat.txt");

# ## Run Model
#
# The main model computation takes place here, and then we plot results

setup(exps[iexp])
launch(exps[iexp])

# Plot Monitor
#
# A _monitor_ here denotes a variable printed to standard model output (text file) at regular intervals.

run(pipeline(`grep dynstat_theta_mean $(filout)`,filstat))

tmp0 = read(filstat,String)
tmp0 = split(tmp0,"\n")
Tmean=[parse(Float64,split(tmp0[i],"=")[2]) for i in 1:length(tmp0)-1]
plot(Tmean)

# ## Access Model Output
#
# While the model runs or after it has finished, one can reread the model output for analysis

pth=joinpath(exps[iexp].folder,"run")
XC=read_mdsio(pth,"XC"); siz=size(XC)

mread(xx::Array,x::MeshArray) = read(xx,x)	
function mread(fil::String,x::MeshArray)
	d=dirname(fil)
	b=basename(fil)[1:end-5]
	read(read_mdsio(d,b),x)
end

γ=gcmgrid(pth,"PeriodicChannel",1,fill(siz,1), [siz[1] siz[2]], eltype(XC), mread, write)
Γ=GridLoad(γ)
T=read_mdsio(pth,"T.0000000020")
heatmap(T[:,:,1]')