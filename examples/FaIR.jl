### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# ╔═╡ 0c76fe5c-23ed-11ec-2e29-738b856a0518
begin
	using Pkg
	pth0=joinpath(tempdir(),"FaIR_dev01")
	Pkg.activate(pth0)

	using ClimateModels

	file_src=joinpath(dirname(pathof(ClimateModels)),"..","examples","FaIR_module.jl")
	include(file_src)	
	
	"Done with packages"
end

# ╔═╡ 6860c8b4-3918-495c-9520-7ab80bf31a7e
md"""# FaIR climate-carbon-cycle model (Python)

Here we setup, run and plot a simple global climate carbon-cycle model called [FaIR](https://fair.readthedocs.io/en/latest/), for Finite Amplitude Impulse-Response simple climate-carbon-cycle model. 

#### References:
- Smith, C. J., Forster, P. M., Allen, M., Leach, N., Millar, R. J., Passerello, G. A., and Regayre, L. A.: FAIR v1.3: A simple emissions-based impulse response and carbon cycle model, Geosci. Model Dev., https://doi.org/10.5194/gmd-11-2273-2018, 2018.
- Millar, R. J., Nicholls, Z. R., Friedlingstein, P., and Allen, M. R.: A modified impulse-response representation of the global near-surface air temperature and atmospheric concentration response to carbon dioxide emissions, Atmos. Chem. Phys., 17, 7213-7228, https://doi.org/10.5194/acp-17-7213-2017, 2017.

!!! note
    In some circumstances (not fully undertsood but involving Conda.jl and PyCall.jl) it appears necessary to close and reopen this notebook in order for it to run as expected (the second time around).
"""

# ╔═╡ ab3428db-bab5-417a-ae71-f0bb3fd1334d
md"""### The Four Scenarios"""

# ╔═╡ e6910c7c-260b-4d06-bc3c-20c521d446e0
MC=demo.FaIR_config()

# ╔═╡ ea7b87f1-acbb-4a4c-936a-218356d54c0b
begin
	run(MC)
	🏁 = MC.outputs
end

# ╔═╡ ef0138f0-e3db-455f-afd3-67ed1e73741b
begin
	🏁
	scenarios,temperatures=demo.loop_over_scenarios()
	demo.plot(scenarios,temperatures)
end

# ╔═╡ Cell order:
# ╟─6860c8b4-3918-495c-9520-7ab80bf31a7e
# ╟─0c76fe5c-23ed-11ec-2e29-738b856a0518
# ╟─ab3428db-bab5-417a-ae71-f0bb3fd1334d
# ╟─ef0138f0-e3db-455f-afd3-67ed1e73741b
# ╟─e6910c7c-260b-4d06-bc3c-20c521d446e0
# ╟─ea7b87f1-acbb-4a4c-936a-218356d54c0b
