
module Oceananigans

using Printf, Random, JLD2, Statistics, Downloads

using ClimateModels	
import ClimateModels: build, setup, AbstractModelConfig, Oceananigans_launch
import ClimateModels: Oceananigans_setup_grid, Oceananigans_setup_BC
import ClimateModels: Oceananigans_build_model, Oceananigans_build_simulation

OrderedDict=ClimateModels.OrderedDict
uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID

##

function setup_initial_conditions(Tᵢ)
	# Temperature initial condition:
	T(x, y, z) = Tᵢ(z)
	# Velocity initial condition:
	u(x, y, z) = randn()*1e-5
	# Salinity initial condition:
	S(x, y, z)=35.0
	
	return (T=T,S=S,u=u)
end

##

function read_grid(MC)
	fil_coords=joinpath(pathof(MC),"coords.jld2")
	file = jldopen(fil_coords)
	coords = load(fil_coords)
	xw = file["coords"]["xw"]
	yw = file["coords"]["yw"]
	zw = file["coords"]["zw"]
	xT = file["coords"]["xT"]
	yT = file["coords"]["yT"]
	zT = file["coords"]["zT"]
	close(file)
	return xw, yw, zw, xT, yT, zT
end

# ╔═╡ e3453716-b8db-449a-a3bb-c918af91878e
function xz_read(fil,t)
	# Open the file with our data
	file = jldopen(fil)
	
	# Extract a vector of iterations
	iterations = parse.(Int, keys(file["timeseries/t"]))	
	times = [file["timeseries/t/$iter"] for iter in iterations]	

	iter=iterations[t]
		
	t = file["timeseries/t/$iter"]
	w = file["timeseries/w/$iter"][:, 1, :]
	T = file["timeseries/T/$iter"][:, 1, :]
	S = file["timeseries/S/$iter"][:, 1, :]
	νₑ = file["timeseries/νₑ/$iter"][:, 1, :]

	close(file)

	return t,w,T,S,νₑ
end

function zt_read(fil,t)
	# Open the file with our data
	file = jldopen(fil)
	
	# Extract a vector of iterations
	iterations = parse.(Int, keys(file["timeseries/t"]))	
	times = [file["timeseries/t/$iter"] for iter in iterations]	

	iter=iterations[t]
		
	t = file["timeseries/t/$iter"]
	w = sqrt.(mean(file["timeseries/w/$iter"][:, :, :].^2, dims=(1,2)))[:]
	T = mean(file["timeseries/T/$iter"][:, :, :], dims=(1,2))[:]
	S = mean(file["timeseries/S/$iter"][:, :, :], dims=(1,2))[:]
	νₑ = sqrt.(mean(file["timeseries/νₑ/$iter"][:, :, :].^2, dims=(1,2)))[:]

	close(file)

	return t,w,T,S,νₑ
end

function xz_plot_prep(MC,i)
	fil=joinpath(pathof(MC),"daily_cycle.jld2")
	t,w,T,S,νₑ=xz_read(fil,i)
	xw, yw, zw, xT, yT, zT=read_grid(MC)
    tt="$(round(t/86400)) days"
    #tt=prettytime(t)
	(tt,w,T,S,νₑ,xw, yw, zw, xT, yT, zT)
end

function tz_slice(MC;nt=1,wli=missing,Tli=missing,Sli=missing,νli=missing)
	xw, yw, zw, xT, yT, zT=read_grid(MC)

	fil=joinpath(pathof(MC),"daily_cycle.jld2")
	Tall=Matrix{Float64}(undef,length(zT),nt)
	Sall=Matrix{Float64}(undef,length(zT),nt)
	wall=Matrix{Float64}(undef,length(zw),nt)
	νₑall=Matrix{Float64}(undef,length(zT),nt)
	for tt in 1:nt
		t,w,T,S,νₑ=zt_read(fil,tt)
		Tall[:,tt]=T
		Sall[:,tt]=S
		wall[:,tt]=w
		νₑall[:,tt]=νₑ
	end
	
	permutedims(Tall),permutedims(Sall),permutedims(wall),permutedims(νₑall)
end

function nt_from_jld2(MC)
	fil=joinpath(pathof(MC),"daily_cycle.jld2")
	file = jldopen(fil)
	iterations = parse.(Int, keys(file["timeseries/t"]))
	times = [file["timeseries/t/$iter"] for iter in iterations]
	close(file)
	nt=(length(times))

	return nt
end

##

"""
    OceananigansConfig()

Concrete type of `AbstractModelConfig` for `Oceananigans.jl`
"""
Base.@kwdef struct OceananigansConfig <: AbstractModelConfig
    model :: String = "Oceananigans"
    configuration :: String = "daily_cycle"
    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    channel :: Channel{Any} = Channel{Any}(10)
    folder :: String = tempdir()
    ID :: UUID = uuid4()
end

function build(x::OceananigansConfig)
	rundir=pathof(x)
	model=Oceananigans_build_model(x.outputs["grid"],x.outputs["BC"],x.outputs["IC"])
	simulation=Oceananigans_build_simulation(model,x.inputs["Nh"],rundir)

	x.outputs["model"]=model
	x.outputs["simulation"]=simulation
	
	return true
end

function rerun(x::OceananigansConfig) 
	simulation=demo.build_simulation(x.outputs["model"],x.inputs["Nh"],pathof(x))
	x.outputs["simulation"]=simulation
    Oceananigans_launch(x)
end

function setup(x::OceananigansConfig)

	if x.configuration=="daily_cycle"
		Qʰ(t) = 200.0 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # W m⁻², surface heat flux (>0 means ocean cooling)
		u₁₀(t) = 4.0 * (1.0-0.9*(mod(t,86400.0)>43200.0)) # m s⁻¹, wind speed 10 meters above ocean surface
		Ev(t) = 1e-7 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # m s⁻¹, evaporation rate
		Tᵢ(z) = 20 + 0.1 * z #initial temperature condition (function of z=-depth)

		grid=Oceananigans_setup_grid()
		IC=setup_initial_conditions(Tᵢ)
		BC=Oceananigans_setup_BC(Qʰ,u₁₀,Ev)
	else
		grid=missing
		IC=missing
		BC=missing
		error("unnknown model configuration")
	end

	!isdir(joinpath(pathof(x),"log")) ? log(x,"initial setup",init=true) : nothing
	put!(x.channel,Oceananigans_launch)

	x.outputs["grid"]=grid		
	x.outputs["IC"]=IC		
	x.outputs["BC"]=BC		

	if haskey(x.inputs,"checkpoint")
		checkpoint_file=joinpath(x,basename(x.inputs["checkpoint"]))
		if occursin("http",x.inputs["checkpoint"])
			Downloads.download(x.inputs["checkpoint"],checkpoint_file)
		else
			cp(x.inputs["checkpoint"],checkpoint_file)
		end
	end

	println("Oceananigans run directory is \n "*pathof(x))

	return true
end

##

end

