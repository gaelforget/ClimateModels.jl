### A Pluto.jl notebook ###
# v0.17.4

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
	using Random, Printf, JLD2, PlutoUI
	import CairoMakie as Mkie

	using ClimateModels
	using Oceananigans
	using Oceananigans.Units: minute, minutes, hour
end

# ╔═╡ a5f3898b-5abe-4230-88a9-36c5c823b951
md"""# Non-Hydrostatic Model (Julia)

[Oceananigans.jl](https://clima.github.io/OceananigansDocumentation/stable/) is a fast and friendly fluid flow solver written in Julia that can simulate the incompressible Boussinesq equations, shallow water equations, or hydrostatic Boussinesq equations with a free surface. The model configuration used in this notebook is based off of their [ocean\_wind\_mixing\_and\_convection](https://clima.github.io/OceananigansDocumentation/stable/generated/ocean_wind_mixing_and_convection/) example.
"""

# ╔═╡ 42495d5e-2c2b-4260-85d5-2d7c5f53e70d
md"""## Select mode run duration

Nhours = $(@bind Nhours PlutoUI.NumberField(1:48,default=1)) hours

!!! note 
    Each change to `Nhours`  will reset the computation which may take several minutes to complete --  patience is good.
"""

# ╔═╡ bf064e23-c33f-4339-b2f1-290d8d0f1d87
md"""## Model Output

- run directory content
- x-z plots at chosen time
"""

# ╔═╡ d8388559-7cfb-4fbe-9b22-a01477c264da
md"""## Appendices"""

# ╔═╡ 3aaa0fb0-c629-4822-a75b-4d57de5b8908
function setup_grid()
	Nz = 50          # number of points in the vertical direction
	Lz = 50          # (m) domain depth
	fz(k)=-Lz*(Nz+1-k)/Nz #fz.(1:Nz+1) gives the vertical grid for w points
	
	return RectilinearGrid(size = (32, 32, Nz), x = (0, 64), y = (0, 64), z = fz)
end

# ╔═╡ 3dd9abc9-9787-4472-af13-bf3dace789c3
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

# ╔═╡ bf664d09-8934-47da-a908-0a11751fd15f
function setup_initial_conditions(Tᵢ)
	# Temperature initial condition:
	T(x, y, z) = Tᵢ(z)
	# Velocity initial condition:
	u(x, y, z) = randn()*1e-5
	# Salinity initial condition:
	S(x, y, z)=35.0
	
	return (T=T,S=S,u=u)
end

# ╔═╡ 783d93de-0f53-4b7d-b323-4037f3fb1fc6
function setup_model(grid,BC,IC)

	buoyancy = SeawaterBuoyancy(equation_of_state=LinearEquationOfState(α=2e-4, β=8e-4))

	model = NonhydrostaticModel(
		advection = UpwindBiasedFifthOrder(),
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

# ╔═╡ 39e686ce-13c3-481f-81f9-9f4e3e156282
function setup_simulation(model,Nh,rundir)
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
							   prefix = "ocean_wind_mixing_and_convection",
	                     field_slicer = FieldSlicer(j=Int(model.grid.Ny/2)),
	                         schedule = TimeInterval(1minute),
	                            force = true)

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

# ╔═╡ a4a8fd17-73e8-4b8d-a8a7-383e7c149d41
function ocean_wind_mixing_and_convection(x::ModelConfig)

	Qʰ(t) = 200.0 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # W m⁻², surface heat flux (>0 means ocean cooling)
	u₁₀(t) = 4.0 * (1.0-0.9*(mod(t,86400.0)>43200.0)) # m s⁻¹, wind speed 10 meters above ocean surface
	Ev(t) = 1e-7 * (1.0-2.0*(mod(t,86400.0)>43200.0)) # m s⁻¹, evaporation rate
	Tᵢ(z) = 20 + 0.1 * z #initial temperature condition (function of z=-depth)

	grid=setup_grid()
	IC=setup_initial_conditions(Tᵢ)
	BC=setup_boundary_conditions(Qʰ,u₁₀,Ev)
	model=setup_model(grid,BC,IC)

	rundir=pathof(x)
	simulation=setup_simulation(model,x.inputs["Nh"],rundir)

	run!(simulation)
	#run!(simulation, pickup=true)
	
	return "model run complete"
end

# ╔═╡ c9f1c233-f003-44dc-b8be-20b7a758d025
MC=ModelConfig(model=ocean_wind_mixing_and_convection,inputs=Dict("Nh" => Nhours))

# ╔═╡ 9f051fe8-3512-466b-b0d8-eae7ad0d03c4
begin
	setup(MC)
	build(MC)
	launch(MC)
end

# ╔═╡ 851a7116-a781-4f86-887f-99dcf0a21ea2
begin
	fil=joinpath(pathof(MC),"ocean_wind_mixing_and_convection.jld2")
	file = jldopen(fil)
	iterations = parse.(Int, keys(file["timeseries/t"]))
	times = [file["timeseries/t/$iter"] for iter in iterations]
	close(file)
	nt=(length(times))
	#t1 = searchsortedfirst(times, 10minutes)

	PlutoUI.with_terminal() do
		println("- time steps: \n")		
		println("nt=$nt \n")
		println("- rundir contents: \n")		
		println.(readdir(pathof(MC)))
	end
end

# ╔═╡ dc8acf44-adc4-42df-8587-fabc5ecbe800
md""" Select time step to plot.

$(@bind tt PlutoUI.Select(1:10:nt, default=nt))
"""

# ╔═╡ e3453716-b8db-449a-a3bb-c918af91878e
function get_record(fil,i)
	# Open the file with our data
	file = jldopen(fil)
	
	# Extract a vector of iterations
	iterations = parse.(Int, keys(file["timeseries/t"]))	
	times = [file["timeseries/t/$iter"] for iter in iterations]	

	iter=iterations[i]
		
	t = file["timeseries/t/$iter"]
	w = file["timeseries/w/$iter"][:, 1, :]
	T = file["timeseries/T/$iter"][:, 1, :]
	S = file["timeseries/S/$iter"][:, 1, :]
	νₑ = file["timeseries/νₑ/$iter"][:, 1, :]

	close(file)

	return t,w,T,S,νₑ
end

# ╔═╡ 3dc45b12-7854-465a-b119-8710335fc9c3
function get_grid(MC)
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

# ╔═╡ 54f33a1f-b3a1-4aec-a310-799dc6793347
function makie_plot(MC,i;wli=missing,Tli=missing,Sli=missing,νli=missing)
	fil=joinpath(pathof(MC),"ocean_wind_mixing_and_convection.jld2")
	t,w,T,S,νₑ=get_record(fil,i)
	xw, yw, zw, xT, yT, zT=get_grid(MC)
	
	!ismissing(wli) ? wlims=wli : wlims=(-3e-2,3e-2)
	!ismissing(Tli) ? Tlims=Tli : Tlims=(18.5,20.0)
	!ismissing(Sli) ? Slims=Sli : Slims=(34.999,35.011)
	!ismissing(νli) ? νlims=νli : νlims=(0.0, 5e-3)

	#kwargs = (linewidth=0, xlabel="x (m)", ylabel="z (m)", aspectratio=1)

	w_title = @sprintf("vertical velocity (m s⁻¹), t = %s", prettytime(t))
	T_title = @sprintf("temperature (ᵒC), t = %s", prettytime(t))
	S_title = @sprintf("salinity (g kg⁻¹), t = %s", prettytime(t))
	ν_title = @sprintf("eddy viscosity (m² s⁻¹), t = %s", prettytime(t))

	f = Mkie.Figure(resolution = (1000, 700))

	ga = f[1, 1] = Mkie.GridLayout()
	gb = f[1, 2] = Mkie.GridLayout()
	gc = f[2, 2] = Mkie.GridLayout()
	gd = f[2, 1] = Mkie.GridLayout()
	
	ax_w,hm_w=Mkie.heatmap(ga[1, 1],xw[:], zw[:], w, colormap=:balance, colorrange=wlims)
	Mkie.Colorbar(ga[1, 2], hm_w); ax_w.title = w_title
	ax_T,hm_T=Mkie.heatmap(gb[1, 1],xT[:], zT[:], T, colormap=:thermal, colorrange=Tlims)
	Mkie.Colorbar(gb[1, 2], hm_T); ax_T.title = T_title
	ax_S,hm_S=Mkie.heatmap(gc[1, 1],xT[:], zT[:], S, colormap=:haline, colorrange=Slims)
	Mkie.Colorbar(gc[1, 2], hm_S); ax_S.title = S_title
	ax_ν,hm_ν=Mkie.heatmap(gd[1, 1],xT[:], zT[:], νₑ, colormap=:thermal, colorrange=νlims)
	Mkie.Colorbar(gd[1, 2], hm_ν); ax_ν.title = ν_title

	f
end

# ╔═╡ 87a6ef53-5c0c-46d4-b4ca-9ab2b76cba74
makie_plot(MC,tt)

# ╔═╡ Cell order:
# ╟─a5f3898b-5abe-4230-88a9-36c5c823b951
# ╟─42495d5e-2c2b-4260-85d5-2d7c5f53e70d
# ╠═c9f1c233-f003-44dc-b8be-20b7a758d025
# ╠═9f051fe8-3512-466b-b0d8-eae7ad0d03c4
# ╟─bf064e23-c33f-4339-b2f1-290d8d0f1d87
# ╟─851a7116-a781-4f86-887f-99dcf0a21ea2
# ╟─dc8acf44-adc4-42df-8587-fabc5ecbe800
# ╟─87a6ef53-5c0c-46d4-b4ca-9ab2b76cba74
# ╟─d8388559-7cfb-4fbe-9b22-a01477c264da
# ╠═cd09078c-61e1-11ec-1253-536acf09f901
# ╠═a4a8fd17-73e8-4b8d-a8a7-383e7c149d41
# ╟─3aaa0fb0-c629-4822-a75b-4d57de5b8908
# ╟─3dd9abc9-9787-4472-af13-bf3dace789c3
# ╟─bf664d09-8934-47da-a908-0a11751fd15f
# ╟─783d93de-0f53-4b7d-b323-4037f3fb1fc6
# ╟─39e686ce-13c3-481f-81f9-9f4e3e156282
# ╟─e3453716-b8db-449a-a3bb-c918af91878e
# ╟─3dc45b12-7854-465a-b119-8710335fc9c3
# ╟─54f33a1f-b3a1-4aec-a310-799dc6793347
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
