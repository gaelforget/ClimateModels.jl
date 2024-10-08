
module FaIR

import ClimateModels
import ClimateModels: setup, AbstractModelConfig

uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID
OrderedDict=ClimateModels.OrderedDict

function loop_over_scenarios()
	scenarios=[:rcp26,:rcp45,:rcp60,:rcp85]
	temperatures=[]
	
	(fair,forward,RCPs)=ClimateModels.pyimport(:fair)

	for i in scenarios
		emissions=RCPs[i].Emissions.emissions
		C,F,T = forward.fair_scm(emissions=emissions)
		push!(temperatures,T)
	end
	
	scenarios,temperatures
end

"""
	struct FaIRConfig <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `FaIR` model.
""" 
Base.@kwdef struct FaIRConfig <: AbstractModelConfig
	model :: String = "FaIR"
	configuration :: String = "rcp45"
	inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	outputs :: OrderedDict{Any,Any} = OrderedDict(:C=>Float64[],:F=>Float64[],:T=>Float64[])
	status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	channel :: Channel{Any} = Channel{Any}(10) 
	folder :: String = tempdir()
	ID :: UUID = uuid4()
end
	
function setup(x :: FaIRConfig)
	!isdir(x.folder) ? mkdir(x.folder) : nothing
	!isdir(pathof(x)) ? mkdir(pathof(x)) : nothing
	try
		ClimateModels.pyimport(:fair)
	catch
		ClimateModels.conda(:fair)
	end
	!isdir(joinpath(pathof(x),"log")) ? log(x,"initial setup",init=true) : nothing
	put!(x.channel,FaIR_launch)
end	

function FaIR_launch(x::FaIRConfig)
	pth0=pwd()
	cd(pathof(x))

	(fair,forward,RCPs)=ClimateModels.pyimport(:fair)

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
