module demo

using Random, Printf, JLD2, Statistics, PlutoUI, Downloads

using ClimateModels	
import ClimateModels: build
OrderedDict=ClimateModels.OrderedDict
uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID

using Oceananigans
using Oceananigans.Units: minute, minutes, hour
using Oceananigans.OutputWriters.OffsetArrays

##

function setup_grid()
	Nz = 50          # number of points in the vertical direction
	Lz = 50          # (m) domain depth
	fz(k)=-Lz*(Nz+1-k)/Nz #fz.(1:Nz+1) gives the vertical grid for w points
	
	return RectilinearGrid(size = (32, 32, Nz), x = (0, 64), y = (0, 64), z = fz)
end

function setup_boundary_conditions(Qʰ,u₁₀,Ev)		
	dTdz = 0.1 # K m⁻¹, bottom boundary condition
	ρₒ = 1026 # kg m⁻³, average density at the surface of the world ocean
	cᴾ = 3991 # J K⁻¹ kg⁻¹, typical heat capacity for seawater
	Qᵀ(x, y, t) = Qʰ(t) / (ρₒ * cᴾ) # K m s⁻¹, surface _temperature_ flux
	T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵀ),
	                                bottom = GradientBoundaryCondition(dTdz))
	
	cᴰ = 2.5e-3 # dimensionless drag coefficient
	ρₐ = 1.225  # kg m⁻³, average density of air at sea-level
	Qᵘ(x, y, t) = - ρₐ / ρₒ * cᴰ * u₁₀(t) * abs(u₁₀(t)) # m² s⁻²
	u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))
	
	Qˢ(x, y, t, S) = - Ev(t) * S # [salinity unit] m s⁻¹
	evaporation_bc = FluxBoundaryCondition(Qˢ, field_dependencies=:S)
	S_bcs = FieldBoundaryConditions(top=evaporation_bc)

	return (u=u_bcs,T=T_bcs,S=S_bcs)
end

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

function build_model(grid,BC,IC)

	buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(thermal_expansion=2e-4, haline_contraction=8e-4))

	model = NonhydrostaticModel(
		advection = UpwindBiased(order=5),
		timestepper = :RungeKutta3,
		grid = grid,
		tracers = (:T, :S),
		coriolis = FPlane(f=1e-4),
		buoyancy = buoyancy,
		closure = AnisotropicMinimumDissipation(),
		boundary_conditions = (u=BC.u, T=BC.T, S=BC.S))

	# initial conditions (as functions of x,y,z)
	set!(model, u=IC.u, w=IC.u, T=IC.T, S=IC.S)

	return model
end

function build_simulation(model,Nh,rundir)
	simulation = Simulation(model, Δt=10.0, stop_time=Nh*60minutes)
	
	wizard = TimeStepWizard(cfl=1.0, max_change=1.1, max_Δt=20.0)
	simulation.callbacks[:wizard] = Callback(wizard, IterationInterval(10))
	
	progress_message(sim) = 
		@printf("Iteration: %04d, time: %s, Δt: %s, max(|w|) = %.1e ms⁻¹, wall time: %s\n",
		iteration(sim),prettytime(sim),prettytime(sim.Δt),
		maximum(abs, sim.model.velocities.w),prettytime(sim.run_wall_time))	
	simulation.callbacks[:progress] = Callback(progress_message, IterationInterval(1minute))
		
	eddy_viscosity = (; νₑ = model.diffusivity_fields.νₑ)	
	simulation.output_writers[:slices] =
	    JLD2OutputWriter(model, merge(model.velocities, model.tracers, eddy_viscosity),
							dir = rundir,
							filename = "daily_cycle.jld2",
	                        indices = (:,Int(model.grid.Ny/2),:),
	                         schedule = TimeInterval(1minute),
							 overwrite_existing = true)

	simulation.output_writers[:checkpointer] = 
		Checkpointer(model, schedule=TimeInterval(24hour), dir = rundir, prefix="model_checkpoint")
							
	##
	
	fil=simulation.output_writers[:slices].filepath

	xw, yw, zw = nodes(model.velocities.w)
	xT, yT, zT = nodes(model.tracers.T)
	coords=(xw, yw, zw, xT, yT, zT)

	fil_coords=joinpath(rundir,"coords.jld2")
	jldopen(fil_coords, "w") do file
	    mygroup = JLD2.Group(file, "coords")
	    mygroup["xw"] = xw
    	mygroup["yw"] = yw
    	mygroup["zw"] = zw
	    mygroup["xT"] = xT
    	mygroup["yT"] = yT
    	mygroup["zT"] = zT
	end

	return simulation
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
	(prettytime(t),w,T,S,νₑ,xw, yw, zw, xT, yT, zT)
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
#		Tall[:,tt]=view(OffsetArray(T, -2:53), 1:50)
#		Sall[:,tt]=view(OffsetArray(S, -2:53), 1:50)
#		wall[:,tt]=view(OffsetArray(w, -2:54), 1:51)
#		νₑall[:,tt]=view(OffsetArray(νₑ, -2:53), 1:50)
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
    Oceananigans_config()

Concrete type of `AbstractModelConfig` for `Oceananigans.jl`
"""
Base.@kwdef struct Oceananigans_config <: AbstractModelConfig
    model :: String = "Oceananigans"
    configuration :: String = "daily_cycle"
    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    channel :: Channel{Any} = Channel{Any}(10)
    folder :: String = tempdir()
    ID :: UUID = uuid4()
end

function build(x::Oceananigans_config)
	rundir=pathof(x)
	model=build_model(x.outputs["grid"],x.outputs["BC"],x.outputs["IC"])
	simulation=build_simulation(model,x.inputs["Nh"],rundir)

	x.outputs["model"]=model
	x.outputs["simulation"]=simulation
	
	return true
end

Oceananigans_launch(x::Oceananigans_config) = run!(x.outputs["simulation"], pickup=true)

function rerun(x::Oceananigans_config) 
	simulation=demo.build_simulation(x.outputs["model"],x.inputs["Nh"],pathof(x))
	x.outputs["simulation"]=simulation
	run!(simulation, pickup=true)
end

function setup(x::Oceananigans_config)

	if x.configuration=="daily_cycle"
		Qʰ(t) = 200.0 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # W m⁻², surface heat flux (>0 means ocean cooling)
		u₁₀(t) = 4.0 * (1.0-0.9*(mod(t,86400.0)>43200.0)) # m s⁻¹, wind speed 10 meters above ocean surface
		Ev(t) = 1e-7 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # m s⁻¹, evaporation rate
		Tᵢ(z) = 20 + 0.1 * z #initial temperature condition (function of z=-depth)

		grid=setup_grid()
		IC=setup_initial_conditions(Tᵢ)
		BC=setup_boundary_conditions(Qʰ,u₁₀,Ev)
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
