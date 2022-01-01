### A Pluto.jl notebook ###
# v0.17.4

using Markdown
using InteractiveUtils

# ╔═╡ c6880c18-0125-41f5-856d-fc1427252c6d
using ClimateModels, CairoMakie, PlutoUI, Suppressor, Pkg

# ╔═╡ 1da1270e-10c9-11ec-0baa-9bc64b2254f6
md"""# Shallow Water Model (Julia)

Here we setup and run a two-dimensional shallow water model configuration from [ShallowWaters.jl](https://github.com/milankl/ShallowWaters.jl). 

We then plot its output, replayed from nectdf files, and generate an animation.

## Dry Run Model

In the cell below, we proceed with all defaults -- this mostly pre-installs `ShallowWaters.jl`. 

Later on, we design a more specific model configuration (see `SWM`), run it, and plot the results.
"""

# ╔═╡ 70fe39c4-ef1c-49e3-a7c1-5d84c2b36791
begin
	URL=PackageSpec(url="https://github.com/milankl/ShallowWaters.jl")
	MC0=ModelConfig(model=URL)
	setup(MC0)
	build(MC0)
	launch(MC0)
end

# ╔═╡ 5cd72770-2ab0-4ceb-846b-57970b99a39c
with_terminal() do
	show(MC0)
end	

# ╔═╡ be99297a-36de-4619-b28a-4a309e6bb9d2
md"""## Setup, Build, and Launch Model

- `ModelConfig` now gets a specific configuration, `SWM` defined below, and its parameters.
- `setup` calls `Pkg.develop` and sets up the `git` log subfolder.
- `build` defaults to `Pkg.build`.
- `launch` calls the `SWM` model and updates the `git` log accordingly.
"""

# ╔═╡ 65fe0050-7e6d-4ac0-b810-aa1af36a9426
md"""## Plot Results

Here we read tracer fields from the `netcdf` output file and animate their map. 

Note how the initial checkboard pattern gets distorted by the flow field.
"""

# ╔═╡ 68d0c28b-db12-44a7-9eff-6ae7d2d8d2b8
md"""## Animation"""

# ╔═╡ 597374ef-b13a-40b7-8252-c62d678f9ef0
md"""## Appendix : the SWM Function"""

# ╔═╡ 55d8ac89-1fc3-4935-bc5b-2b46123b0840
begin
	import ShallowWaters: run_model 

	parameters=Dict(:nx => 80, :ny => 40, :Lx => 1000e3, :nd=>100) #adjustable parameters
	
	function SWM(x)
	    pth=pwd()
	    cd(pathof(x))
	    (nx,ny)=(x.inputs[:nx],x.inputs[:ny])
	    (Lx,nd)=(x.inputs[:Lx],x.inputs[:nd])
	    L_ratio = nx / ny
	    @suppress run_model(;nx,Lx,L_ratio,Ndays=nd,output=true) #calling this may take several minutes (or more) depending on resolution
	    cd(pth)
	end
end

# ╔═╡ 5aca76a6-963f-4f28-b470-c6339b2c9931
begin
	MC=ModelConfig(model=URL,configuration=SWM,inputs=parameters)
	setup(MC)
	build(MC)
	launch(MC)
end

# ╔═╡ 7fad98c2-ae59-421d-9df0-f930da316ece
with_terminal() do
	println(" ModelConfig:\n")
	show(MC)

	println("\n With parameters:\n")
	show(MC.inputs)	
end	

# ╔═╡ eeebc291-6ddb-4ee1-9232-94e87d235771
begin
	MCdir=pathof(MC)
	ncfile = ClimateModels.NetCDF.open(joinpath(MCdir,"run0000","sst.nc"))
	sst = ncfile.vars["sst"][:,:,:]
	#img=contourf(sst[:,:,parameters[:nd]]',c = :grays, clims=(-1.,1.), frmt=:png)
	"Model output has been retrieved from file."
end

# ╔═╡ 97f9b817-97ea-46ed-92f7-35ea907e93b3
begin
	time = Node(parameters[:nd])
	sst_t = @lift( Float64.(sst[:,:,$time]) )

	set_theme!(theme_light())
	f=Figure(resolution = (600, 400))
	a = Axis(f[1, 1],xlabel="x",ylabel="y",title="tracer after $(time[]) days")		
	CairoMakie.contourf!(a,collect(1:parameters[:nx]),collect(1:parameters[:ny]),sst_t,
		colormap=:grays,colorrange=(-1.0,1.0))
		
	f
end

# ╔═╡ 3907f66e-6953-455f-b74a-7325ce6deda3
begin
		fil=joinpath(tempdir(),"sst.mp4")
		record(f,fil, 1:parameters[:nd]; framerate = 20) do t
	    	time[] = t
		end
end

# ╔═╡ 9edcdbce-5b90-42a5-b9d3-1a3483eb8876
	LocalResource(fil)

# ╔═╡ f216639c-676c-4ca3-bf37-17c42514820d
TableOfContents()

# ╔═╡ Cell order:
# ╟─1da1270e-10c9-11ec-0baa-9bc64b2254f6
# ╠═c6880c18-0125-41f5-856d-fc1427252c6d
# ╠═70fe39c4-ef1c-49e3-a7c1-5d84c2b36791
# ╟─5cd72770-2ab0-4ceb-846b-57970b99a39c
# ╟─be99297a-36de-4619-b28a-4a309e6bb9d2
# ╠═5aca76a6-963f-4f28-b470-c6339b2c9931
# ╟─7fad98c2-ae59-421d-9df0-f930da316ece
# ╟─65fe0050-7e6d-4ac0-b810-aa1af36a9426
# ╟─eeebc291-6ddb-4ee1-9232-94e87d235771
# ╟─97f9b817-97ea-46ed-92f7-35ea907e93b3
# ╟─3907f66e-6953-455f-b74a-7325ce6deda3
# ╟─68d0c28b-db12-44a7-9eff-6ae7d2d8d2b8
# ╟─9edcdbce-5b90-42a5-b9d3-1a3483eb8876
# ╟─597374ef-b13a-40b7-8252-c62d678f9ef0
# ╠═55d8ac89-1fc3-4935-bc5b-2b46123b0840
# ╟─f216639c-676c-4ca3-bf37-17c42514820d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
