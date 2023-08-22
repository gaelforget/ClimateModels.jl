module demo

using Pkg, Conda, PyCall, CairoMakie, ClimateModels
import ClimateModels: setup

uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID
OrderedDict=ClimateModels.OrderedDict

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

"""
	struct FaIR_config <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `FaIR` model.
""" 
Base.@kwdef struct FaIR_config <: AbstractModelConfig
	model :: String = "FaIR"
	configuration :: String = "rcp45"
	inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	outputs :: OrderedDict{Any,Any} = OrderedDict(:C=>Float64[],:F=>Float64[],:T=>Float64[])
	status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	channel :: Channel{Any} = Channel{Any}(10) 
	folder :: String = tempdir()
	ID :: UUID = uuid4()
end
	
function setup(x :: FaIR_config)
	!isdir(x.folder) ? mkdir(x.folder) : nothing
	!isdir(pathof(x)) ? mkdir(pathof(x)) : nothing

	try
		fair=pyimport("fair")
	catch
		ENV["PYTHON"]=""
		Pkg.build("PyCall")

		Conda.pip_interop(true)
		Conda.pip("install", "fair==1.6.4")
	end

	!isdir(joinpath(pathof(x),"log")) ? log(x,"initial setup",init=true) : nothing
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

function plot(scenarios,temperatures)	
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

end
