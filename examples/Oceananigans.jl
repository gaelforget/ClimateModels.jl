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

# ╔═╡ cd09078c-61e1-11ec-1253-536acf09f901
begin
	using Pkg
	pth0=joinpath(tempdir(),"Oceananigans_dev01")
	Pkg.activate(pth0)

	using ClimateModels, JLD2, PlutoUI
end

# ╔═╡ 78559b4f-03c5-44f3-b48e-9f3986f13a3c
begin
	file_src=joinpath(dirname(pathof(ClimateModels)),"..","examples","Oceananigans_module.jl")
	include(file_src)
end

# ╔═╡ a5f3898b-5abe-4230-88a9-36c5c823b951
md"""# Non-Hydrostatic Model (Julia)

[Oceananigans.jl](https://clima.github.io/OceananigansDocumentation/stable/) is a fast and friendly fluid flow solver written in Julia that can simulate the incompressible Boussinesq equations, shallow water equations, or hydrostatic Boussinesq equations with a free surface. The model configuration used in this notebook is based off of their [ocean\_wind\_mixing\_and\_convection](https://clima.github.io/OceananigansDocumentation/stable/generated/ocean_wind_mixing_and_convection/) example.
"""

# ╔═╡ 42495d5e-2c2b-4260-85d5-2d7c5f53e70d
md"""## Select mode run duration

Nhours = $(@bind Nhours PlutoUI.Select([1,24,48,72],default=1)) hours

!!! note 
    Each change to `Nhours`  will reset the computation which may take several minutes to complete --  patience is good.
"""

# ╔═╡ 5ae22c8a-17d9-446e-b0cd-d4af7c9834c8
md"""## Main Computation"""

# ╔═╡ 193a8750-39bd-451f-8e22-4af1b25be22b
begin
	MC=demo.Oceananigans_config(configuration="ocean_wind_mixing_and_convection",inputs=Dict("Nh" => Nhours))
	✔1="Model Configuation Defined"
end

# ╔═╡ 65b71616-33bb-44fa-b40d-4fb13cf4ecee
MC

# ╔═╡ 2fd54b18-27e2-4e90-9d7d-a1057d393a78
begin
	✔1
	demo.setup(MC)
	demo.build(MC)
	✔2="Done with `setup` and `buid`"
end

# ╔═╡ 98d35bec-ba79-4e43-a79e-68714d88a1ff
begin
	✔2
	demo.launch(MC)
	✔3="Done with main computation"
end

# ╔═╡ be6b4de1-1e6d-42b0-ba3e-12a9fa2c140d
begin
	✔3
	#MC.inputs["Nh"]=72
	#simulation2=demo.build_simulation(MC.outputs["model"],MC.inputs["Nh"],pathof(MC))
	#demo.run!(simulation2, pickup=true)
end

# ╔═╡ 851a7116-a781-4f86-887f-99dcf0a21ea2
begin
	✔3
	nt=demo.nt_from_jld2(MC)

	PlutoUI.with_terminal() do
		println("*input / output:* \n\n")
		println("- time steps: \n")		
		println("nt=$nt \n")
		println("- run directory contents: \n")		
		println.(readdir(pathof(MC)))
		"Done scanning model output";
	end
end

# ╔═╡ bf064e23-c33f-4339-b2f1-290d8d0f1d87
md"""## Plot Model Snapshot

Select time step to plot. Here we show one `x-z` slice from the model output.

$(@bind tt PlutoUI.Select(1:10:nt, default=nt))
"""

# ╔═╡ 87a6ef53-5c0c-46d4-b4ca-9ab2b76cba74
demo.xz_plot(MC,tt)

# ╔═╡ 1b932395-501f-42ba-940c-9512bdace2b8
begin
	T,S,w,νₑ=demo.tz_slice(MC,nt=nt)
	md"""## Time-Depth Plots

	Here we compute the model mean (rhs plots) or root mean squared (lhs column) for each level and time step.
	"""
end

# ╔═╡ 09495b06-7850-48f6-8c1c-f64de540f4a2
tz_fig=demo.tz_plot(MC,T,S,w,νₑ) 
#save(joinpath(pathof(MC),"tz_4days.png"), tz_fig)

# ╔═╡ Cell order:
# ╟─a5f3898b-5abe-4230-88a9-36c5c823b951
# ╟─bf064e23-c33f-4339-b2f1-290d8d0f1d87
# ╟─87a6ef53-5c0c-46d4-b4ca-9ab2b76cba74
# ╟─1b932395-501f-42ba-940c-9512bdace2b8
# ╟─09495b06-7850-48f6-8c1c-f64de540f4a2
# ╟─42495d5e-2c2b-4260-85d5-2d7c5f53e70d
# ╟─5ae22c8a-17d9-446e-b0cd-d4af7c9834c8
# ╟─65b71616-33bb-44fa-b40d-4fb13cf4ecee
# ╟─193a8750-39bd-451f-8e22-4af1b25be22b
# ╟─2fd54b18-27e2-4e90-9d7d-a1057d393a78
# ╟─98d35bec-ba79-4e43-a79e-68714d88a1ff
# ╟─be6b4de1-1e6d-42b0-ba3e-12a9fa2c140d
# ╟─851a7116-a781-4f86-887f-99dcf0a21ea2
# ╠═cd09078c-61e1-11ec-1253-536acf09f901
# ╟─78559b4f-03c5-44f3-b48e-9f3986f13a3c
