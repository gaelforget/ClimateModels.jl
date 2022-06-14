### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7057fdae-7b4a-42d4-8cd9-75999e72ecb7
begin
	using Pkg
	pth0=joinpath(tempdir(),"Speedy_dev01")
	Pkg.activate(pth0)

	using ClimateModels, PlutoUI
	file_src=joinpath(dirname(pathof(ClimateModels)),"..","examples","Speedy_module.jl")
	include(file_src)	

	"Done with loading packages"
end

# ╔═╡ a3f9fb60-d889-4320-a979-dddd87ff173f
md"""# SPEEDY Atmosphere (Fortran)

Here we setup, run and plot a fast atmospheric model called [speedy.f90](https://github.com/samhatfield/speedy.f90) (_Simplified Parameterizations, privitivE-Equation DYnamics_). Documentation about the model can be found [here](https://samhatfield.co.uk/speedy.f90/) and [here](https://www.ictp.it/research/esp/models/speedy.aspx).

As done with the other models, we define a new concrete type, `SPEEDY_config`, and the rest of the `ClimateModels.jl` interface implementation for this new type (`setup`, `build`, and `launch`) in this notebook.
"""

# ╔═╡ a63753bd-5b83-4324-8bf9-8b3532c6b3d4
md"""## Setup, Build, and Launch"""

# ╔═╡ 59211a03-6212-4f56-8d0a-66a0a805d9f0
begin
	MC=demo.SPEEDY_config()
	demo.setup(MC)
	"Done with setup"
end

# ╔═╡ a1f311f6-2dc2-46da-a48c-a5edc910b888
with_terminal() do
	show(MC)
end

# ╔═╡ c9f91552-b7d4-41c5-bfbd-13888bf290a2
md"""### Model Run Duration

####

How many simulated month? 

$(@bind nmonths NumberField(1:24))
"""

# ╔═╡ 7d7aea6b-a5de-4ad6-88fd-b05049f4f36a
demo.write_ini_file(MC,nmonths)

# ╔═╡ 91cd170b-7e8d-4abe-b000-46745e531c8f
begin
	exe=joinpath(homedir(),"speedy")
	exe_link=joinpath(pathof(MC),"bin","speedy")
	if isfile(exe)*!isfile(exe_link)
		pth=joinpath(pathof(MC),"bin")
		!isdir(pth) ? mkdir(pth) : nothing
		symlink(exe,exe_link)			
	elseif !isfile(exe_link)
		demo.build(MC)
	end
	"Done with build"
end

# ╔═╡ 7e9e1b6b-f0c8-4da1-820f-fb65214e7cd3
begin
	nmonths
	demo.launch(MC)
	tst="Done with launch"
end

# ╔═╡ c11fddfa-db75-48ba-a197-0be048ec60b3
begin
	#IDa="7c9a3f54-f972-4e0d-9514-4a3d4cb39492"
	IDa=string(MC.ID)
	
	𝑉=demo.DataFrame(name=String[],long_name=String[],unit=String[],ndims=Int[])
	push!(𝑉,("u","eastward_wind","m/s",3))
	push!(𝑉,("v","northward_wind","m/s",3))
	push!(𝑉,("t","air_temperature","K",3))
	push!(𝑉,("q","specific_humidity","1",3))
	push!(𝑉,("phi","geopotential_height","m",3))
	#two-dimensional variables:
	push!(𝑉,("ps","surface_air_pressure","Pa",2))
	push!(𝑉,("hfluxn","surface_heat_flux","W/m2",2))
	push!(𝑉,("evap","evaporation","g/(m^2 s)",2))

	md"""## Plot Model Output
	
	####

	Select Variable to Read and Plot:
	
	$(@bind myvar Select(𝑉.name))
	
	####
	
	List of Possible Output Variables : 
	"""
end

# ╔═╡ d46e35ad-da83-41c1-b802-6c52bbd58a32
with_terminal() do
	show(𝑉)
end

# ╔═╡ 6ff81750-6060-4f40-b3ce-fee20c9c1b1f
md"""### Animate Plots 

####

Click start to start browsing through model output. Or stop at anypoint to pause.

$(@bind ti Clock(1.0))"""

# ╔═╡ cda60695-fc07-42cb-b78c-9f3de34fb826
begin
	tst
	files=demo.list_files_output(MC)
	f_xy=demo.plot_output_xy(files,myvar,ti,8)
	f_zm=demo.plot_output_zm(files,myvar,ti)
	"Plots have been updated -- they are displayed below."
end

# ╔═╡ feead29a-c475-4b4b-93d2-8bf2adcc4a3e
#files
md"""Zonal mean:

$(f_zm)

Surface level:

$(f_xy)	
"""

# ╔═╡ 0787d4ae-4764-40b4-b607-acf3903210f4
begin
	#sea_surface_temperature.nc
	#86400/36/60=40 minutes time step
	#180/36=5days
	rundir=joinpath(pathof(MC),"rundir")
	
	msk=demo.get_msk(rundir)	
	
	md"""## Appendices
	
	- Plot Model Input
	- Model Parameters
	- Model Interface Details
	
	### Plot Model Input
	
	Here we display the SST input field that drives the Atmosphere model.
	
	Chosen month : $(@bind to NumberField(1:12))
	"""
end

# ╔═╡ 6ed201f2-f779-4f82-bc22-0c66ac0a4d74
demo.plot_input(MC,"sst",to)

# ╔═╡ 4ae7e302-10d5-11ec-0c5e-838d34e10c23
begin
	tst
	
    nml=demo.read_namelist(MC)
	nml[:params]
	nml[:date]

	md"""### Model Parameters
	"""
end

# ╔═╡ 4ad62ce6-606d-4784-adf6-b96319006082
with_terminal() do
	println("parameters groups : ")
	println(keys(nml))
	println("")
	println("nml[:params] has : ")
	println(nml[:params])
	println("")
	println("nml[:date] has :")
	println(nml[:date])
end

# ╔═╡ ee4443c0-5c12-4c6b-8c5b-1eca7cc62c37
TableOfContents()

# ╔═╡ Cell order:
# ╟─a3f9fb60-d889-4320-a979-dddd87ff173f
# ╟─7057fdae-7b4a-42d4-8cd9-75999e72ecb7
# ╟─a63753bd-5b83-4324-8bf9-8b3532c6b3d4
# ╟─59211a03-6212-4f56-8d0a-66a0a805d9f0
# ╟─a1f311f6-2dc2-46da-a48c-a5edc910b888
# ╟─c9f91552-b7d4-41c5-bfbd-13888bf290a2
# ╟─7d7aea6b-a5de-4ad6-88fd-b05049f4f36a
# ╟─91cd170b-7e8d-4abe-b000-46745e531c8f
# ╟─7e9e1b6b-f0c8-4da1-820f-fb65214e7cd3
# ╟─c11fddfa-db75-48ba-a197-0be048ec60b3
# ╟─d46e35ad-da83-41c1-b802-6c52bbd58a32
# ╟─cda60695-fc07-42cb-b78c-9f3de34fb826
# ╟─6ff81750-6060-4f40-b3ce-fee20c9c1b1f
# ╟─feead29a-c475-4b4b-93d2-8bf2adcc4a3e
# ╟─0787d4ae-4764-40b4-b607-acf3903210f4
# ╠═6ed201f2-f779-4f82-bc22-0c66ac0a4d74
# ╟─4ae7e302-10d5-11ec-0c5e-838d34e10c23
# ╟─4ad62ce6-606d-4784-adf6-b96319006082
# ╟─ee4443c0-5c12-4c6b-8c5b-1eca7cc62c37
