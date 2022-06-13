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

# ╔═╡ fdeb2973-5ad8-485a-880c-4bdff1f172df
begin
	using Pkg; Pkg.activate()
	using GLMakie, NCDatasets, Dates, ClimateModels, PlutoUI
	file_src=joinpath(dirname(pathof(ClimateModels)),"..","examples","IFS1km_module.jl")
	include(file_src)
	"done with packages"
end

# ╔═╡ 0fcb36b5-d2df-4845-b867-942e5a6abc13
TableOfContents()

# ╔═╡ bd03e90c-ac05-4aa0-9cab-26e1c5da8979
md"""## Visualization"""

# ╔═╡ 7b8888eb-0cbb-47d0-a0c1-3b9cbadcec7d
md""" Time Step = $(@bind t0 Select(1:10:912)) 

Variable ID = $(@bind varID Select(1:3))
"""

# ╔═╡ 122799b1-ea85-45f8-9fda-970263b457f5
md"""## About

For more information on what this relates to, see 

- event info : <https://events.ecmwf.int/event/305/>
- github repo : <https://github.com/vismethack/challenges>
- data set : <https://doi.org/10.5281/zenodo.6633929>
  - `VisMetHack2022: Visualizing winds and surface variables from the ECMWF IFS 1-km nature run (1.0.2) [Data set].` Zenodo. `Anantharaj, Valentine, Hatfield, Samuel, Vukovic, Milana, Polichtchouk, Inna, & Wedi, Nils. (2022)`

## Directions

```
pa=vishack2022.setup()
ds=vishack2022.Dataset(pa.fil)

t=1
xx=vishack2022.prep(ds,pa,t)
tt=pa.txt*vishack2022.Χ( ds["time"][t] )
f=vishack2022.build_plot(ds,pa,xx,title=tt)

vishack2022.build_movie(ds,pa;times=1:100)
```
"""

# ╔═╡ 4f538e25-796a-49a4-96a5-5f37dc72a484
md"""## Julia Code"""

# ╔═╡ ee81aea9-810e-472e-a7a1-85a0325d00ad
begin	
#	pa=vishack2022.setup(choice_variable=varID,colormap=:delta,colorrange=(-3.0,0.0))
	pa=vishack2022.setup(choice_variable=varID)
	ds=vishack2022.Dataset(pa.va.file)
	"File opened"
	#pa
end

# ╔═╡ d7b15e06-88d8-4bec-98fe-31086c190388
ds

# ╔═╡ e38554a0-1843-4fb8-8ddb-7e7e858accec
begin
	t=t0
	xx=vishack2022.prep(ds,pa,t)
	tt=pa.va.txt*vishack2022.Χ( ds["time"][t] )
	"Plot presets"
end

# ╔═╡ 67139ed2-a67f-4d26-985b-8f321a2093f0
vishack2022.build_plot(ds,pa,xx,title=tt)

# ╔═╡ cad6bad0-9c79-4ba5-b5e4-94e027366fc8
#vishack2022.build_movie(ds,pa;times=1:100)

# ╔═╡ Cell order:
# ╟─0fcb36b5-d2df-4845-b867-942e5a6abc13
# ╟─bd03e90c-ac05-4aa0-9cab-26e1c5da8979
# ╟─7b8888eb-0cbb-47d0-a0c1-3b9cbadcec7d
# ╟─67139ed2-a67f-4d26-985b-8f321a2093f0
# ╟─d7b15e06-88d8-4bec-98fe-31086c190388
# ╟─122799b1-ea85-45f8-9fda-970263b457f5
# ╟─4f538e25-796a-49a4-96a5-5f37dc72a484
# ╟─fdeb2973-5ad8-485a-880c-4bdff1f172df
# ╠═ee81aea9-810e-472e-a7a1-85a0325d00ad
# ╟─e38554a0-1843-4fb8-8ddb-7e7e858accec
# ╠═cad6bad0-9c79-4ba5-b5e4-94e027366fc8
