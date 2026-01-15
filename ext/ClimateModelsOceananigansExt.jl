
module ClimateModelsOceananigansExt

using Oceananigans, ClimateModels
import ClimateModels: JLD2, @printf, Oceananigans_launch
import ClimateModels: Oceananigans_setup_grid, Oceananigans_setup_BC
import ClimateModels: Oceananigans_build_model, Oceananigans_build_simulation

import Oceananigans.Units: minute, minutes, hour

Oceananigans_launch(x::OceananigansConfig) = run!(x.outputs["simulation"], pickup=true)

function Oceananigans_setup_grid(Nx=32, Ny=32, Nz=50, Lz=50)
	fz(k) = - Lz*(Nz+1-k)/Nz #fz.(1:Nz+1) gives the vertical grid for w points
	return RectilinearGrid(size = (Nx, Ny, Nz), x = (0, 2*Nx), y = (0, 2*Ny), z = fz)
end

function Oceananigans_setup_BC(Qʰ,u₁₀,Ev)		
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

##

function Oceananigans_build_model(grid, BC, IC, EOS=missing)

	if ismissing(EOS)
		buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(thermal_expansion=2e-4, haline_contraction=8e-4))
	else
		buoyancy = SeawaterBuoyancy(equation_of_state=EOS)
	end

	# Note: in version 0.104 grid is a positional argument
	model = NonhydrostaticModel(; grid, buoyancy,
	advection = WENO(order=9),
	tracers = (:T, :S),
	coriolis = FPlane(f=1e-4),
	boundary_conditions = (u=BC.u, T=BC.T, S=BC.S))
	
	# initial conditions (as functions of x,y,z)
	set!(model, u=IC.u, w=IC.u, T=IC.T, S=IC.S)

	return model
end

function Oceananigans_build_simulation(model; 
		nt_hours=24, nt_callback=20, dir=tempname())
		
	simulation = Simulation(model, Δt=10, stop_time=nt_hours*60minutes)
	conjure_time_step_wizard!(simulation, cfl=0.7)
	
	progress_message(sim) = 
		@printf("Iteration: %04d, time: %s, Δt: %s, max(|w|) = %.1e ms⁻¹, wall time: %s\n",
		iteration(sim),prettytime(sim),prettytime(sim.Δt),
		maximum(abs, sim.model.velocities.w),prettytime(sim.run_wall_time))	
	add_callback!(simulation, progress_message, IterationInterval(nt_callback))	

	if !isnothing(model.closure)
		eddy_viscosity = (; νₑ = model.closure_fields.νₑ)	
		output=merge(model.velocities, model.tracers, eddy_viscosity)
	else
		output=merge(model.velocities, model.tracers)
	end

	simulation.output_writers[:slices] =
	    JLD2Writer(model, output, dir = dir, 
			filename = "daily_cycle.jld2", indices = (:,Int(model.grid.Ny/2),:),
			schedule = TimeInterval(1minute), overwrite_existing = true)

	simulation.output_writers[:checkpointer] = 
		Checkpointer(model, schedule=TimeInterval(24hour), dir = dir, prefix="model_checkpoint")
							
	##
	
#	fil=simulation.output_writers[:slices].filepath

	xw, yw, zw = nodes(model.velocities.w)
	xT, yT, zT = nodes(model.tracers.T)
	coords=(xw, yw, zw, xT, yT, zT)

	fil_coords=joinpath(dir,"coords.jld2")
	JLD2.jldopen(fil_coords, "w") do file
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

end

