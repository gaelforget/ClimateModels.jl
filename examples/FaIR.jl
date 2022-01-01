### A Pluto.jl notebook ###
# v0.17.4

using Markdown
using InteractiveUtils

# ╔═╡ 0c76fe5c-23ed-11ec-2e29-738b856a0518
begin
	using Pkg, Conda, PyCall, CairoMakie, ClimateModels

	ENV["PYTHON"]=""
	Pkg.build("PyCall")

	uuid4=ClimateModels.uuid4
	OrderedDict=ClimateModels.OrderedDict
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

# ╔═╡ 46a28057-2710-430c-977f-4c868e08d434
function loop_over_scenarios()
	scenarios=[:rcp26,:rcp45,:rcp60,:rcp85]
	temperatures=[]
	
	fair=pyimport("fair")
	forward=pyimport("fair.forward")
	RCPs=pyimport("fair.RCPs")

	for i in scenarios
		emissions=RCPs[i].Emissions.emissions
		C,F,T = forward.fair_scm(emissions=emissions)
		push!(temperatures,T)
	end
	
	scenarios,temperatures
end

# ╔═╡ 1ecbf99d-b217-4154-a568-c208587dad4c
md"""### Model Interface Details"""

# ╔═╡ c44e10f7-8ba6-4e09-80bf-a34493431fc8
begin
	"""
	    struct FaIR_config <: AbstractModelConfig
	
	Concrete type of `AbstractModelConfig` for `FaIR` model.
	""" 
	Base.@kwdef struct FaIR_config <: AbstractModelConfig
	    model :: String = "FaIR"
	    configuration :: String = "rcp45"
	    options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    outputs :: OrderedDict{Any,Any} = OrderedDict(:C=>Float64[],:F=>Float64[],:T=>Float64[])
	    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    channel :: Channel{Any} = Channel{Any}(10) 
	    folder :: String = tempdir()
	    ID :: UUID = uuid4()
	end
end

# ╔═╡ e6910c7c-260b-4d06-bc3c-20c521d446e0
MC=FaIR_config()

# ╔═╡ 8c85f576-1e6c-471a-a0da-40be7e380899
begin
	import ClimateModels: setup
		
	function setup(x :: FaIR_config)
		!isdir(x.folder) ? mkdir(x.folder) : nothing
		!isdir(pathof(x)) ? mkdir(pathof(x)) : nothing

		Conda.pip_interop(true)
		Conda.pip("install", "fair")

		!isdir(joinpath(pathof(x),"log")) ? ClimateModels.log(x) : nothing
		put!(x.channel,FaIR_launch)
	end	
	
	function FaIR_launch(x::FaIR_config)
		pth0=pwd()
		cd(pathof(x))

		fair=pyimport("fair")
		forward=pyimport("fair.forward")
		RCPs=pyimport("fair.RCPs")

		emissions=RCPs.rcp85.Emissions.emissions
		C,F,T = forward.fair_scm(emissions=emissions)
		
		if isempty(x.outputs[:C])
			push!.(Ref(x.outputs[:C]),C[:])
			push!.(Ref(x.outputs[:F]),F[:])
			push!.(Ref(x.outputs[:T]),T[:])
		else
			x.outputs[:C]=C[:]
			x.outputs[:F]=F[:]
			x.outputs[:T]=T[:]
		end

		cd(pth0)
	end
end

# ╔═╡ ea7b87f1-acbb-4a4c-936a-218356d54c0b
begin
	setup(MC)
	build(MC)
	launch(MC)
	
	🏁 = MC.outputs
end

# ╔═╡ ef0138f0-e3db-455f-afd3-67ed1e73741b
begin
	🏁
	
	scenarios,temperatures=loop_over_scenarios()
	
	set_theme!(theme_light())

	f=Figure(resolution = (900, 600))
	
	a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
		title="global atmospheric temperature anomaly")		
	
	for i in 1:4
		lines!(temperatures[i],label="FaIR "*string(scenarios[i]),linewidth=4)
	end
	
	Legend(f[1, 2], a)
	
	f
end

# ╔═╡ Cell order:
# ╟─6860c8b4-3918-495c-9520-7ab80bf31a7e
# ╟─0c76fe5c-23ed-11ec-2e29-738b856a0518
# ╟─ab3428db-bab5-417a-ae71-f0bb3fd1334d
# ╟─ef0138f0-e3db-455f-afd3-67ed1e73741b
# ╟─46a28057-2710-430c-977f-4c868e08d434
# ╟─e6910c7c-260b-4d06-bc3c-20c521d446e0
# ╠═ea7b87f1-acbb-4a4c-936a-218356d54c0b
# ╟─1ecbf99d-b217-4154-a568-c208587dad4c
# ╠═8c85f576-1e6c-471a-a0da-40be7e380899
# ╠═c44e10f7-8ba6-4e09-80bf-a34493431fc8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
