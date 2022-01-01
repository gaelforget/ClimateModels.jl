### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ 1fe310bb-7d3a-425a-b51d-f327d67fdc64
begin
	using ClimateModels, MITgcmTools, MeshArrays, CairoMakie, Suppressor, PlutoUI
	!isdir(MITgcmTools.MITgcm_path) ? MITgcmTools.MITgcm_download() : nothing
	"Done with loading packages"
end

# ╔═╡ 5eae2953-dba7-446e-ba33-811dd0eccc24
md"""# General Circulation Model (Fortran)

Here we setup and run [MITgcm](https://mitgcm.readthedocs.io/en/latest/). This  
general circulation model can simulate the Ocean (as done here), Atmosphere 
(plot below), and other components of the climate system accross a wide range 
of scales and configurations.

![fig1](https://user-images.githubusercontent.com/20276764/111042787-12377e00-840d-11eb-8ddb-64cc1cfd57fd.png)
"""

# ╔═╡ f8dd47e3-0ecf-4e8f-952b-52a8bf6cc50d
md"""## Setup Model

The most standard MITgcm configurations (_verification experiments_) are all readily available via `MITgcmTools.jl`'s `MITgcm_config` function.

The `setup` function links input files to the `run/` subfolder. The model executable `mitcmuv` is normally found in the `build/` subfolder of the selected experiment and will get linked to `run/`.

!!! note 
	If `mitcmuv` is not found at this stage then it is assumed that the chosen model configuration still needs to be compiled (once, via the `build` function). This might take a lot longer than a normal model run due to the one-time cost of compiling the model.
"""

# ╔═╡ 4ba0bd91-0e66-48cd-bbfd-eebbc5dbf1e5
begin
	MC=MITgcm_config(configuration="tutorial_global_oce_biogeo")
	setup(MC)
	with_terminal() do
		println("Configuration:")
		println("")
		show(MC)
		println("")
		println("With paramater groups:")
		println("")
		show(keys(MC.inputs))
	end
end

# ╔═╡ b4f7f94d-02bb-4687-9dee-7fd8e0c1ec3c
if isa(MITgcm_path,Array) #MITgcmTools > v0.1.22
	build(MC,"--allow-skip")
	"Done with build"
else
	build(MC)
	"Done with build"
end

# ╔═╡ 7fd4e01a-dc95-4595-8349-05ae648149b6
md"""## Run Model

The main model computation takes place via the `launch` function. 

Once done, the next cell will display the model standard text file called `output.txt`"""

# ╔═╡ 2e210b6a-49ea-4b5f-bc2a-f65ed771cd04
begin
	launch(MC)
	"Done with launch"
end

# ╔═╡ 90b6da62-4250-4d2f-b908-2f75eb56c9bf
begin
	# MITgcm will output files in the `run/` folder incl. the standard `output.txt` file.
	rundir=joinpath(MC.folder,string(MC.ID),"run")
	fileout=joinpath(rundir,"output.txt")
	readlines(fileout)
end

# ╔═╡ 803dc24a-553b-4893-bb51-f679e3d0f256
readdir(rundir)

# ╔═╡ 144d0b05-a5b6-4c3f-ae41-a027158c5134
begin
	filstat=joinpath(rundir,"onestat.txt")
	run(pipeline(`grep dynstat_theta_mean $(fileout)`,filstat))

	tmp0 = read(filstat,String)
	tmp0 = split(tmp0,"\n")
	Tmean=[parse(Float64,split(tmp0[i],"=")[2]) for i in 1:length(tmp0)-1]
	#p=plot(Tmean,frmt=:png,label="mean temperature",xlabel="time record",ylabel="degC")
	
	f=Figure(resolution = (900, 600))
	a = Axis(f[1, 1],xlabel="time record",ylabel="degree C",title="mean temperature")
	lines!(a,Tmean,linewidth=3)
	md"""## Plot Model State Monitor

	Often, the term _monitor_ in climate modeling denotes a statement / counter printed to standard model output (text file) at regular intervals to monitor the model's integration through time. In the example below, we use global mean temperature which is reported every time step as `dynstat_theta_mean` in the MITgcm `output.txt` file.
	
	$(f)"""
end


# ╔═╡ d5a48f21-91eb-4904-88e7-61a5ba3b6071
begin
	XC=read_mdsio(rundir,"XC")	
	YC=read_mdsio(rundir,"YC")
	T=read_mdsio(rundir,"T.0005184004")
	T[findall(T.==0.0)].=NaN
	
	g=Figure(resolution = (900, 600))
	b = Axis(g[1, 1],xlabel="longitude",ylabel="latitude",title="temperature snapshot")
		
	hm=CairoMakie.heatmap!(b,XC[:,1],YC[1,:],T[:,:,1])
	Colorbar(g[1,2], hm, height = Relative(0.65))
	md"""## Plot Model Snapshot

	As models run through time, they typically output snapshots and/or time-averages of state variables in `binary` or `netcdf` format for example. Afterwards, or even while the model runs, one can reread this output. Here, for example, we plot the temperature map after 20 time steps (`T.0000000020`) this way by using the convenient [MITgcmTools.jl](https://gaelforget.github.io/MITgcmTools.jl/dev/) package to read MITgcm files.
	
	$(g)
	"""
end

# ╔═╡ f5736582-10ce-11ec-3ad9-d1cbab1ac39b
md"""## Workflow Outline

_ClimateModels.jl_ additionally supports workflow documentation using `git`. Here we summarize this workflow's record.
"""

# ╔═╡ a786625a-057a-4fcb-9ee1-6defe375357e
with_terminal() do
	println.(ClimateModels.log(MC))
end

# ╔═╡ 5fc9c087-7136-423f-9f38-193746c3e79f
TableOfContents()

# ╔═╡ Cell order:
# ╟─5eae2953-dba7-446e-ba33-811dd0eccc24
# ╟─1fe310bb-7d3a-425a-b51d-f327d67fdc64
# ╟─f8dd47e3-0ecf-4e8f-952b-52a8bf6cc50d
# ╟─4ba0bd91-0e66-48cd-bbfd-eebbc5dbf1e5
# ╟─b4f7f94d-02bb-4687-9dee-7fd8e0c1ec3c
# ╟─7fd4e01a-dc95-4595-8349-05ae648149b6
# ╟─2e210b6a-49ea-4b5f-bc2a-f65ed771cd04
# ╟─90b6da62-4250-4d2f-b908-2f75eb56c9bf
# ╟─803dc24a-553b-4893-bb51-f679e3d0f256
# ╟─144d0b05-a5b6-4c3f-ae41-a027158c5134
# ╟─d5a48f21-91eb-4904-88e7-61a5ba3b6071
# ╟─f5736582-10ce-11ec-3ad9-d1cbab1ac39b
# ╟─a786625a-057a-4fcb-9ee1-6defe375357e
# ╟─5fc9c087-7136-423f-9f38-193746c3e79f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
