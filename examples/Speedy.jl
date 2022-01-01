### A Pluto.jl notebook ###
# v0.17.4

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
	using ClimateModels, Pkg, CairoMakie, PlutoUI, Suppressor
	git=ClimateModels.git
	NetCDF=ClimateModels.NetCDF
	DataFrame=ClimateModels.DataFrame
	uuid4=ClimateModels.uuid4
	"Done with loading packages"
end

# ╔═╡ a3f9fb60-d889-4320-a979-dddd87ff173f
md"""# SPEEDY Atmosphere (Fortran)

Here we setup, run and plot a fast atmospheric model called [speedy.f90](https://github.com/samhatfield/speedy.f90) (_Simplified Parameterizations, privitivE-Equation DYnamics_). Documentation about the model can be found [here](https://samhatfield.co.uk/speedy.f90/) and [here](https://www.ictp.it/research/esp/models/speedy.aspx).

As done with the other models, we define a new concrete type, `SPEEDY_config`, and the rest of the `ClimateModels.jl` interface implementation for this new type (`setup`, `build`, and `launch`) in this notebook.
"""

# ╔═╡ a63753bd-5b83-4324-8bf9-8b3532c6b3d4
md"""## Setup, Build, and Launch"""

# ╔═╡ c9f91552-b7d4-41c5-bfbd-13888bf290a2
md"""### Model Run Duration

####

How many simulated month? 

$(@bind nmonths NumberField(1:24))
"""

# ╔═╡ 6ff81750-6060-4f40-b3ce-fee20c9c1b1f
md"""### Animate Plots 

####

Click start to start browsing through model output. Or stop at anypoint to pause.

$(@bind ti Clock(1.0))"""

# ╔═╡ 2bd3aba3-fbac-499b-9364-ec391b195f95
md"""### Model Interface Details"""

# ╔═╡ 22e7ecc9-a40e-47ea-8cda-2a6441ca8dbe
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
	ID :: UUID = uuid4()
end

# ╔═╡ 4dc8c2fa-269b-427e-aab1-5a541c91a011
begin
	import ClimateModels: build
	function build(x :: SPEEDY_config)
	    pth0=pwd()
	    pth=pathof(x)
	
	    cd(pth)
	    if Sys.isapple()
	        ENV["NETCDF"] = "/usr/local/Cellar/netcdf/4.8.0_1/" #may differ between computers
	    else
	        ENV["NETCDF"] = "/usr/" #may differ between computers
	    end
	    @suppress run(`bash build.sh`)
	    cd(pth0)
	end
end

# ╔═╡ a2582849-bea6-4447-94ba-06147266c67a
function SPEEDY_launch(x::SPEEDY_config)
    pth0=pwd()
    pth=pathof(x)
    cd(pth)
    @suppress run(`bash run.sh`)
    cd(pth0)
end

# ╔═╡ 24c0cf26-5a59-461f-817e-5b4c95d15e1d
begin
	import ClimateModels: setup
	function setup(x :: SPEEDY_config)
	    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
	    pth=pathof(x)
	    !isdir(pth) ? mkdir(pth) : nothing
	
	    url="https://github.com/gaelforget/speedy.f90"
	    @suppress run(`$(git()) clone -b more_diags $url $pth`)
	
	    !isdir(joinpath(pth,"log")) ? log(x) : nothing
	    
	    put!(x.channel,SPEEDY_launch)
	end
end

# ╔═╡ 59211a03-6212-4f56-8d0a-66a0a805d9f0
begin
	MC=SPEEDY_config()
	setup(MC)
	"Done with setup"
end

# ╔═╡ a1f311f6-2dc2-46da-a48c-a5edc910b888
with_terminal() do
	show(MC)
end

# ╔═╡ 7d7aea6b-a5de-4ad6-88fd-b05049f4f36a
begin
	(ny,nm)=divrem(nmonths+1,12)
	nm==0 ? (ny,nm)=(ny-1,12) : nothing
	(ny,nm)

	nml_ini="! nsteps_out = model variables are output every nsteps_out timesteps
! nstdia     = model diagnostics are printed every nstdia timesteps
&params
nsteps_out = 180
nstdia     = 180
/
! start_datetime = the start datetime of the model integration
! end_datetime   = the end datetime of the model integration
&date
start_datetime%year   = 1982
start_datetime%month  = 1
start_datetime%day    = 1
start_datetime%hour   = 0
start_datetime%minute = 0
end_datetime%year     = $(1982+ny)
end_datetime%month    = $(nm)
end_datetime%day      = 1
end_datetime%hour     = 0
end_datetime%minute   = 0
/
"
	
	write(joinpath(pathof(MC),"namelist.nml"),nml_ini)
	
	"Done with parameter file"
end

# ╔═╡ 91cd170b-7e8d-4abe-b000-46745e531c8f
begin
	exe=joinpath(homedir(),"speedy")
	exe_link=joinpath(pathof(MC),"bin","speedy")
	if isfile(exe)*!isfile(exe_link)
		pth=joinpath(pathof(MC),"bin")
		!isdir(pth) ? mkdir(pth) : nothing
		symlink(exe,exe_link)			
	elseif !isfile(exe_link)
		build(MC)
	end
	"Done with build"
end

# ╔═╡ 7e9e1b6b-f0c8-4da1-820f-fb65214e7cd3
begin
	nmonths
	launch(MC)
	tst="Done with launch"
end

# ╔═╡ c11fddfa-db75-48ba-a197-0be048ec60b3
begin
	#IDa="7c9a3f54-f972-4e0d-9514-4a3d4cb39492"
	IDa=string(MC.ID)
	
	function plot_output_xy(files,varname="hfluxn",time=1,level=1)
		(lon,lat,lev,values,fil)=read_output(files,varname,time)		
		length(size(values))==4 ? tmp = values[:,:,level,1] : tmp = values[:,:,1]
		ttl = varname*" , at $(lev[level]) σ, $(basename(fil)[1:end-3])"

		set_theme!(theme_light())
		f=Figure(resolution = (900, 600))
		a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",title=ttl)		
		co = Makie.contourf!(a,lon,lat,tmp)
		Colorbar(f[1,2], co, height = Relative(0.65))

		f
	end
	
	function plot_output_zm(files,varname="hfluxn",time=1)
		tmp=read_output(files,varname,time)

		ttl = varname*" , zonal mean , $(basename(tmp.fil)[1:end-3])"
		set_theme!(theme_light())
		f=Figure(resolution = (900, 600))

		if length(size(tmp.values))==4 
			val=dropdims(sum(tmp.values,dims=1);dims=(1,4))/length(tmp.lon)
			a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",title=ttl)		
			co = Makie.contourf!(a,tmp.lat,reverse(-tmp.lev),reverse(val;dims=2),
				 frmt=:png,ylabel="-σ",xlabel="latitude (°N)")
			Colorbar(f[1,2], co, height = Relative(0.65))
		else
			val=dropdims(sum(tmp.values,dims=1);dims=(1,3))
			a = Axis(f[1, 1],"latitude (°N)",title=ttl)		
			Plots.plot!(a,tmp.lat,val)
		end

		f
	end
	
	function list_files_output(x::SPEEDY_config)
			pth=pathof(x)
			tmp=readdir(joinpath(pth,"rundir"))
			files=tmp[findall(occursin.("198",tmp))[2:end]]
			nt=length(files)
			[joinpath(pth,"rundir",t) for t in files]
	end
	
	function read_output(files,varname="t",time=1)
		nt=length(files)
		isnothing(time) ? t=1 : t=mod(time,Base.OneTo(nt))
		ncfile = NetCDF.open(files[t])
		
		lon = ncfile.vars["lon"][:]
		lat = ncfile.vars["lat"][:]
		lev = ncfile.vars["lev"][:]
		tmp = ncfile.vars[varname]
	
		return (lon=lon,lat=lat,lev,values=tmp,fil=files[t])
	end
	
	𝑉=DataFrame(name=String[],long_name=String[],unit=String[],ndims=Int[])
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

# ╔═╡ cda60695-fc07-42cb-b78c-9f3de34fb826
begin
	tst
	files=list_files_output(MC)
	f_xy=plot_output_xy(files,myvar,ti,8)
	f_zm=plot_output_zm(files,myvar,ti)
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
	
	function get_msk()
		ncfile = NetCDF.open(joinpath(rundir,"surface.nc"))
		lsm=ncfile.vars["lsm"]
		msk=Float64.(reverse(lsm,dims=2))
		msk[findall(msk[:,:].==1.0)].=NaN
		msk[findall(msk[:,:].<1.0)].=1.0
		msk
	end
	msk=get_msk()	
	
	function plot_input(x::SPEEDY_config,varname="sst",time=1)
		isnothing(time) ? t=1 : t=mod(time,Base.OneTo(12))
		ncfile = NetCDF.open(joinpath(rundir,"sea_surface_temperature.nc"))
		lon = ncfile.vars["lon"][:]
		lat = reverse(ncfile.vars["lat"][:])
		tmp = reverse(ncfile.vars[varname][:,:,t],dims=2)
		tmp[findall(tmp.==9.96921f36)].=NaN
		
		set_theme!(theme_light())
		f=Figure(resolution = (900, 600))
		a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",title=varname*" (month $t)")		
		co = Makie.contourf!(a,lon,lat,(msk.*tmp), levels=273 .+collect(-32:4:32),colorrange=(273-32,273+32))
		Colorbar(f[1,2], co, height = Relative(0.65))
		
		f
	end
	
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
plot_input(MC,"sst",to)

# ╔═╡ 4ae7e302-10d5-11ec-0c5e-838d34e10c23
begin
	tst
	
	import MITgcmTools: read_namelist
	pp=dirname(pathof(ClimateModels))
	include(joinpath(pp,"../examples/helper_functions.jl"))
	nml=read_namelist(MC)
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
# ╟─6ed201f2-f779-4f82-bc22-0c66ac0a4d74
# ╟─4ae7e302-10d5-11ec-0c5e-838d34e10c23
# ╟─4ad62ce6-606d-4784-adf6-b96319006082
# ╟─2bd3aba3-fbac-499b-9364-ec391b195f95
# ╠═22e7ecc9-a40e-47ea-8cda-2a6441ca8dbe
# ╠═24c0cf26-5a59-461f-817e-5b4c95d15e1d
# ╠═4dc8c2fa-269b-427e-aab1-5a541c91a011
# ╠═a2582849-bea6-4447-94ba-06147266c67a
# ╟─ee4443c0-5c12-4c6b-8c5b-1eca7cc62c37
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
