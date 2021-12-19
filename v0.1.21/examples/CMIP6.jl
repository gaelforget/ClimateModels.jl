### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# ╔═╡ b8366940-20fb-4f29-ba9e-ae4e98d08217
begin
	using ClimateModels, CairoMakie, Dates, Statistics
	using TOML, CSV, DataFrames, NetCDF, PlutoUI
	"Done with loading packages"
end

# ╔═╡ 8b72289e-10d8-11ec-341d-cdf651104fc9
md"""# CMIP6 Models (Cloud Archive)

This example relies on model output that has already been computed and made available over the internet. 
It accesses model output via the `AWS.jl` and `Zarr.jl` packages as the starting point for further modeling / computation. 

Specifically, climate model output from CMIP6 is accessed from cloud storage to compute temperature time series and produce global maps.

## Workflow summary

- Access climate model output in cloud storage
- Choose model (`institution_id`, `source_id`, `variable_id`)
- Compute, save, and plot (_1._ global mean over time; _2._ time mean global map)
"""

# ╔═╡ bffa89ce-1c59-474d-bf59-43618719f35d
TableOfContents()

# ╔═╡ 56c67a30-24d4-45b2-8f8d-5506793d6f17
begin
	parameters=Dict("institution_id" => "IPSL", "source_id" => "IPSL-CM6A-LR", "variable_id" => "tas")

	md"""## Model Configuration

	Here we select that we want to access temperature (`tas`) from a model run by `IPSL` as part of [CMIP6](https://www.wcrp-climate.org/wgcm-cmip/wgcm-cmip6) (Coupled Model Intercomparison Project Phase 6).

	- `institution_id` = $(parameters["institution_id"])
	- `source_id` = $(parameters["source_id"])
	- `variable_id` = $(parameters["variable_id"])
	"""
end

# ╔═╡ 1c9e22a4-ee21-47d4-86bb-f32e37d28f1d
function GlobalAverage(x)

    #main computation = model run = access cloud storage + compute averages

    (mm,gm,meta)=cmip(x.inputs["institution_id"],x.inputs["source_id"],x.inputs["variable_id"])

    #save results to files

    fil=joinpath(x.folder,string(x.ID),"GlobalAverages.csv")
    df = DataFrame(time = gm["t"], tas = gm["y"])
    CSV.write(fil, df)

    fil=joinpath(x.folder,string(x.ID),"Details.toml")
    open(fil, "w") do io
        TOML.print(io, meta)
    end
    
    filename = joinpath(x.folder,string(x.ID),"MeanMaps.nc")
    varname  = x.inputs["variable_id"]
    (ni,nj)=size(mm["m"])
    nccreate(filename, "tas", "lon", collect(Float32.(mm["lon"][:])), "lat", collect(Float32.(mm["lat"][:])), atts=meta)
    ncwrite(Float32.(mm["m"]), filename, varname)
    
    return x
end

# ╔═╡ ed62bbe1-f95c-484b-92af-1410f452132f
md"""## Setup, Build, and Launch

!!! note
	This code cell may take most time, since `launch` is where data is accessed over the internet, and computation takes place.
"""

# ╔═╡ 4acda2ac-f583-4eb5-aaf1-dfbefefa992a
begin
	MC=ModelConfig(model="GlobalAverage",configuration=GlobalAverage,inputs=parameters)
	setup(MC)
	build(MC)
	launch(MC)
	"Done with setup, build, launch"
end

# ╔═╡ c7fe0d8d-b321-4497-b3d0-8a188f58e10d
readdir(joinpath(MC.folder,string(MC.ID)))

# ╔═╡ a32ad976-b431-4350-bc5b-e136dcf5fd2b
md"""## Read Output Files

The `GlobalAverage` function, called via `launch`, should now have generated the following output:

- Global averages in a `CSV` file
- Meta-data in a `TOML` file
- Maps + meta-data in a `NetCDF` file
"""

# ╔═╡ 75a3d6cc-8754-4854-acec-93290575ff2e
begin	
	fil=joinpath(MC.folder,string(MC.ID),"MeanMaps.nc")
	lon = NetCDF.open(fil, "lon")
	lat = NetCDF.open(fil, "lat")
	tas = NetCDF.open(fil, "tas")
	
	#
	
	fil=joinpath(MC.folder,string(MC.ID),"Details.toml")
	meta=TOML.parsefile(fil)
	
	#
	
	fil=joinpath(MC.folder,string(MC.ID),"GlobalAverages.csv")
	GA=CSV.read(fil,DataFrame)
end

# ╔═╡ 4e71bf0e-1b37-42f1-8270-b2887b31ed86
md"""## Plot Results

1. Time Mean Seasonal Cycle
1. Month By Month Time Series
1. Time Mean Global Map
"""

# ╔═╡ da106acf-a691-41fb-b3dd-a17ead2ad159
	nm=meta["long_name"]*" in "*meta["units"]

# ╔═╡ 547d5173-3e9b-493a-b923-fd5fd57972b6
let	
	ny=Int(length(GA.time)/12)
	y=fill(0.0,(ny,12))
	[y[:,i].=GA.tas[i:12:end] for i in 1:12]
	
#	s=plot([0.5:1:11.5],vec(mean(y,dims=1)), xlabel="month",ylabel=nm,
#	leg = false, title=",frmt=:png)

	f=Figure(resolution = (900, 600))
	a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
	title=meta["institution_id"]*" (global mean, seasonal cycle)")		
	lines!(a,collect(0.5:1:11.5),vec(mean(y,dims=1)),xlabel="month",
	ylabel=nm,label=meta["institution_id"],linewidth=2)

	f
end

# ╔═╡ 62fd3c22-35d1-4422-97d9-438b6c8f9eaf
let
	f=Figure(resolution = (900, 600))
	a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
	title=meta["institution_id"]*" (global mean, Month By Month)")		
	tim=Dates.year.(GA.time[1:12:end])
	lines!(a,tim,GA.tas[1:12:end],xlabel="time",ylabel=nm,label="month 1",linewidth=2)
	[lines!(a,tim,GA.tas[i:12:end], label = "month $i") for i in 2:12]
	f
end

# ╔═╡ 0df7e3d5-dd12-4c92-92f3-114a1899f0a5
# #### 3. Time Mean Global Map
let
	f=Figure(resolution = (900, 600))
	a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",
	title=meta["institution_id"]*" (time mean)")		
	hm=CairoMakie.heatmap!(a,lon[:], lat[:], tas[:,:], title=nm*" (time mean)")
	Colorbar(f[1,2], hm, height = Relative(0.65))
	f
end

# ╔═╡ Cell order:
# ╟─8b72289e-10d8-11ec-341d-cdf651104fc9
# ╟─b8366940-20fb-4f29-ba9e-ae4e98d08217
# ╟─bffa89ce-1c59-474d-bf59-43618719f35d
# ╟─56c67a30-24d4-45b2-8f8d-5506793d6f17
# ╠═1c9e22a4-ee21-47d4-86bb-f32e37d28f1d
# ╟─c7fe0d8d-b321-4497-b3d0-8a188f58e10d
# ╟─ed62bbe1-f95c-484b-92af-1410f452132f
# ╠═4acda2ac-f583-4eb5-aaf1-dfbefefa992a
# ╟─a32ad976-b431-4350-bc5b-e136dcf5fd2b
# ╟─75a3d6cc-8754-4854-acec-93290575ff2e
# ╟─4e71bf0e-1b37-42f1-8270-b2887b31ed86
# ╟─da106acf-a691-41fb-b3dd-a17ead2ad159
# ╟─547d5173-3e9b-493a-b923-fd5fd57972b6
# ╟─62fd3c22-35d1-4422-97d9-438b6c8f9eaf
# ╟─0df7e3d5-dd12-4c92-92f3-114a1899f0a5
