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

# ╔═╡ 3c88aa50-47ec-4a23-bdbd-da04ac05100a
begin
	using ClimateModels, CairoMakie, IniFile, Suppressor, PlutoUI

	uuid4=ClimateModels.uuid4
    OrderedDict=ClimateModels.OrderedDict
	Downloads=ClimateModels.Downloads
	git=ClimateModels.git
	DataFrame=ClimateModels.DataFrame

	md"""_Done with loading packages_"""
end

# ╔═╡ b5caddd5-4b34-4a28-af7d-aaea247bd2a5
md"""# Hector Global Climate (C++)

Here we setup, run and plot a simple global climate carbon-cycle model called [Hector](https://jgcri.github.io/hector/index.html). 

Hector reproduces the global historical trends of atmospheric [CO2], radiative forcing, and surface temperatures. It simulates all four Representative Concentration Pathways (RCPs) as shown below.

Documentation about Hector can be found [here](https://jgcri.github.io/hector/articles/manual/), [here](https://pyhector.readthedocs.io/en/latest/index.html), and [here](https://jgcri.github.io/hectorui/index.html).
"""

# ╔═╡ 8e2c86e7-f561-4157-af76-410f85897b46
md"""## The Four Scenarios"""

# ╔═╡ 37a9f083-d9ae-4506-b33c-2f9c6da5314e
md"""## Model Interface

Here we define a new concrete type called `Hector_config`. The rest of the `ClimateModels.jl` interface implementation for this new type is documented below (see `Model Interface details`). 
"""

# ╔═╡ b6fa0f44-97b7-47f7-90a2-7db80060418c
begin
	"""
	    struct Hector_config <: AbstractModelConfig
	
	Concrete type of `AbstractModelConfig` for `Hector` model.
	""" 
	Base.@kwdef struct Hector_config <: AbstractModelConfig
	    model :: String = "Hector"
	    configuration :: String = "hector_rcp45.ini"
	    options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	    channel :: Channel{Any} = Channel{Any}(10) 
	    folder :: String = tempdir()
	    ID :: UUID = uuid4()
	end
end

# ╔═╡ 95fcd1a0-60ad-465f-b5c0-35bb8ea044c2
md"""## Setup, Build, and Launch"""

# ╔═╡ 3e66a5bb-338c-49fb-b169-a6edb4c43949
begin
	
	function plot(x::Hector_config,varname="tgav")
	    varname !=="tgav" ? println("case not implemented yet") : nothing
	
	    pth=pathof(x)
	    log=readlines(joinpath(pth,"hector","logs","temperature.log"))
	
	    ii=findall([occursin("DEBUG:run:  tgav",i) for i in log])
	    nt=length(ii)
	    tgav=zeros(nt)
	    year=zeros(nt)
	
	    for i in 1:nt
	        tmp=split(log[ii[i]],"=")[2]
	        tgav[i]=parse(Float64,split(tmp,"degC")[1])
	        year[i]=parse(Float64,split(tmp,"in")[2])
	    end
	
		f=Figure(resolution = (900, 600))
		a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
		title="global atmospheric temperature anomaly")		
		lines!(year,tgav,label=x.configuration,linewidth=4)

	    f,a,year,tgav
	end
	
	md"""## Read Output And Plot"""
end

# ╔═╡ d033d4f3-409a-4b6e-bdc7-f881989b0653
md"""## Inspect Model Parameters"""

# ╔═╡ 68e4cf96-c335-4db1-b527-07043cacbc00
md"""## Appendices

### Workflow Log (Git)"""

# ╔═╡ 9ded98dd-d7ea-4edd-afe5-aa0dc9b41b2a
md"""### Model Interface Details"""

# ╔═╡ e56ab54a-00d9-4381-bd65-0a10d25722c0
begin
	import ClimateModels: build
	
	
	function build(x :: Hector_config; exe="")
		if isempty(exe)
			pth0=pwd()
			pth=pathof(x)

			url="https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.bz2"
			fil=joinpath(pth,"boost_1_76_0.tar.bz2")
			Downloads.download(url,fil)
			@suppress run(`tar xvf $fil -C $pth`)
	
			pth_boost=joinpath(pth,"boost_1_76_0")
			ENV["BOOSTROOT"] = pth_boost
			ENV["BOOSTLIB"] = joinpath(pth_boost,"stage","lib")

			cd(pth_boost)
			@suppress run(`./bootstrap.sh --with-libraries=filesystem`)
			@suppress run(`./b2`)
			@suppress run(`./bootstrap.sh --with-libraries=system`)
			@suppress run(`./b2`)

			pth_hector=joinpath(pth,"hector")

			cd(pth_hector)
			@suppress run(`make hector`)

			cd(pth0)
		else
			exe_link=joinpath(pathof(x),"hector","src","hector")
			symlink(exe,exe_link)			
		end
	end
end

# ╔═╡ dea6dbde-895a-4c1b-bf33-73b70e940458
function Hector_launch(x::Hector_config)
    pth0=pwd()
    pth=pathof(x)
    cd(joinpath(pth,"hector"))
	
    msg=(" Parameter File = ```"*string(x.configuration)*" \n\n")
    ClimateModels.log(x,"Configuration File = $(x.configuration)",msg=msg)
	
    config=joinpath("inst","input",x.configuration)
    @suppress run(`./src/hector $config`)
    cd(pth0)
end

# ╔═╡ cd9ba04b-9851-4f69-b467-990b7b071d46
begin
	import ClimateModels: setup
	
	function setup(x :: Hector_config)
	    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
	    pth=pathof(x)
	    !isdir(pth) ? mkdir(pth) : nothing
	
	    url="https://github.com/JGCRI/hector"
	    fil=joinpath(pth,"hector")
	    @suppress run(`$(git()) clone $url $fil`)
		
	    !isdir(joinpath(pth,"log")) ? ClimateModels.log(x) : nothing
	    
	    put!(x.channel,Hector_launch)
	end
end

# ╔═╡ 448424ee-c2d0-4957-9763-4fa467f68992
begin
	H=Hector_config()
	setup(H)

	exe=joinpath(homedir(),"hector")
	if isfile(exe)
		build(H; exe=exe)
	else
		build(H)
		exe=joinpath(pathof(H),"hector","src","hector")
	end

	md"""The compiled Hector executable is at
	
	$(exe)
	"""
end

# ╔═╡ 7f7cb33a-e02a-4450-8d58-eadbb5f29297
begin
	MC=Hector_config()
	setup(MC)
	build(MC; exe=exe)
	launch(MC)
	"Done with setup, build, launch sequence."
end

# ╔═╡ 1bc9b369-1233-46e2-9cfc-8c0db286d352
begin
	function plot_all_scenarios(MC)
		list=("hector_rcp26.ini","hector_rcp45.ini","hector_rcp60.ini","hector_rcp85.ini")

		tmp=Hector_config(configuration=list[1],folder=MC.folder,ID=MC.ID)
		put!(tmp,Hector_launch)
		launch(tmp)
		
		f,a,year,tgav=plot(tmp,"tgav")

		for ii in 2:length(list)
			tmp=Hector_config(configuration=list[ii],folder=MC.folder,ID=MC.ID)
			put!(tmp,Hector_launch)
			launch(tmp)
			_,_,_,tgav=plot(tmp,"tgav");
			lines!(a,year,tgav,label=MC.configuration,linewidth=4)
		end
			
		Legend(f[1, 2], a)

		return f		
	end
	
	plot_all_scenarios(MC)
end

# ╔═╡ 5a731e2b-ff27-45fc-bc63-4988e484d7d2
PlutoUI.with_terminal() do
		show(MC)
end

# ╔═╡ 5c2381dc-55d6-4f4b-a1c0-a7a777283621
MC

# ╔═╡ a5336163-72e5-48b4-8156-224728ccd518
begin
	f,a,year,tgav=plot(MC,"tgav"); 
	Legend(f[1, 2], a)
	f
end

# ╔═╡ 3706903e-10b4-11ec-3eaf-8df6df1c23c3
begin	
	pth=pathof(MC)
	fil=joinpath(pth,"hector/inst/input/",MC.configuration)
	nml=read(Inifile(), fil)
	
	PlutoUI.with_terminal() do
		show(nml)
	end
end

# ╔═╡ 909a8669-9324-4982-bac7-9d7d112b5ab8
begin
	𝑷=DataFrame(group=String[],name=String[],default=Float64[],factors=StepRangeLen[],
		long_name=String[],unit=String[])
	push!(𝑷,("simpleNbox","beta",0.36,0.2:0.2:2,"CO2 fertilization factor","unitless"))
	push!(𝑷,("temperature","alpha",1,0.2:0.2:2,"Aerosol forcing scaling factor","unitless"))
	push!(𝑷,("temperature","diff",2.3,0.2:0.2:2,"Ocean heat diffusivity","cm2/s"))
	push!(𝑷,("temperature","S",4.0,0.2:0.2:2,"Equilibrium climate sensitivity","degC"))
	push!(𝑷,("simpleNbox","C0",588.071/2.13,0.2:0.2:2,"Preindustrial CO2 conc,","ppmv CO2"))
	#- atmos_c=588.071                 ; Pg C in CO2, from Murakami et al. (2010)
	#- ;C0=276                                 ; another way to specify, in ppmv
	#- 1 ppm by volume of atmosphere CO2 = 2.13 Gt C
	push!(𝑷,("simpleNbox","q10_rh",2.0,0.2:0.2:2,"Temp. sensitivity factor (Q10)","unitless"))
	push!(𝑷,("temperature","volscl",1,0.2:0.2:2,"Volcanic forcing scaling factor","unitless"))
	𝑉=[𝑷.default[i]*𝑷.factors[i] for i in 1:length(𝑷.default)]
	𝑷
	
	md"""## Modify Parameters & Rerun
	
	Let's consider the same sbuset of model parameters as done in [HectorUI](https://jgcri.github.io/hectorui/index.html). 
	
	Here, we start from $(MC.configuration) but with a `Equilibrium climate sensitivity` of 4 instead of 3.
	"""
end

# ╔═╡ cf70e31c-e95a-4768-b11b-0c25eba2a736
md"""

Parameter name | Value | unit
----|----|----
$(𝑷.long_name[1]) | $(@bind 𝑄_1 NumberField(𝑉[1]; default=𝑷.default[1]))  |  $(𝑷.unit[1])
$(𝑷.long_name[2]) | $(@bind 𝑄_2 NumberField(𝑉[2]; default=𝑷.default[2]))  |  $(𝑷.unit[2])
$(𝑷.long_name[3]) | $(@bind 𝑄_3 NumberField(𝑉[3]; default=𝑷.default[3]))  |  $(𝑷.unit[3])
$(𝑷.long_name[4]) | $(@bind 𝑄_4 NumberField(𝑉[4]; default=𝑷.default[4]))  |  $(𝑷.unit[4])
$(𝑷.long_name[5]) | $(@bind 𝑄_5 NumberField(𝑉[5]; default=𝑷.default[5]))  |  $(𝑷.unit[5])
$(𝑷.long_name[6]) | $(@bind 𝑄_6 NumberField(𝑉[6]; default=𝑷.default[6]))  |  $(𝑷.unit[6])
$(𝑷.long_name[7]) | $(@bind 𝑄_7 NumberField(𝑉[7]; default=𝑷.default[7]))  |  $(𝑷.unit[7])

$(@bind update_param PlutoUI.Button("Update & Rerun Model"))

"""

# ╔═╡ 95301453-5c24-4884-9eab-098f8ce40c0f
begin
	#modify parameter values within nml
	𝑄=(𝑄_1,𝑄_2,𝑄_3,𝑄_4,𝑄_5,𝑄_6,𝑄_7)
	[nml.sections[𝑷.group[i]][𝑷.name[i]]=𝑄[i] for i in 1:length(𝑄)]
	[nml.sections[𝑷.group[i]][𝑷.name[i]] for i in 1:length(𝑄)]
	md"""Would rerun with parameters : $(𝑄)"""
end

# ╔═╡ 3711d123-0e16-486b-a4ba-c5ac6de93692
begin
	#rerun model with updated parameter file
	update_param
	
        pth1=pathof(MC)
	conf=joinpath(pth1,"log","custom_parameters.nml")
	open(conf, "w+") do io
		write(io, nml)
	end
	ClimateModels.log(MC,"update custom_parameters.nml (or skip)",fil="custom_parameters.nml")
	myconf=joinpath(pth1,"hector","inst","input","custom_parameters.nml")	
	cp(conf,myconf;force=true)
	
	myMC=Hector_config(configuration="custom_parameters.nml",folder=MC.folder,ID=MC.ID)
	put!(myMC,Hector_launch)
	launch(myMC)
	"rerun completed"
end

# ╔═╡ 76763a71-a8d3-472a-bb27-577a88ff637c
begin
	g,b,_,_=plot(myMC,"tgav")
	lines!(b,year,tgav,label=MC.configuration,lw=3)
	Legend(g[1, 2], b)
	g
end

# ╔═╡ 2c2ec4ba-e9ed-4695-a695-4549ee84e314
Dump(ClimateModels.log(MC))

# ╔═╡ acd184ff-dfce-496a-afa2-0cac1fc5fa98
TableOfContents()

# ╔═╡ Cell order:
# ╟─b5caddd5-4b34-4a28-af7d-aaea247bd2a5
# ╟─3c88aa50-47ec-4a23-bdbd-da04ac05100a
# ╟─8e2c86e7-f561-4157-af76-410f85897b46
# ╟─1bc9b369-1233-46e2-9cfc-8c0db286d352
# ╟─37a9f083-d9ae-4506-b33c-2f9c6da5314e
# ╠═b6fa0f44-97b7-47f7-90a2-7db80060418c
# ╟─448424ee-c2d0-4957-9763-4fa467f68992
# ╟─95fcd1a0-60ad-465f-b5c0-35bb8ea044c2
# ╠═7f7cb33a-e02a-4450-8d58-eadbb5f29297
# ╟─5a731e2b-ff27-45fc-bc63-4988e484d7d2
# ╟─5c2381dc-55d6-4f4b-a1c0-a7a777283621
# ╟─3e66a5bb-338c-49fb-b169-a6edb4c43949
# ╟─a5336163-72e5-48b4-8156-224728ccd518
# ╟─d033d4f3-409a-4b6e-bdc7-f881989b0653
# ╟─3706903e-10b4-11ec-3eaf-8df6df1c23c3
# ╟─909a8669-9324-4982-bac7-9d7d112b5ab8
# ╟─cf70e31c-e95a-4768-b11b-0c25eba2a736
# ╟─95301453-5c24-4884-9eab-098f8ce40c0f
# ╟─3711d123-0e16-486b-a4ba-c5ac6de93692
# ╟─76763a71-a8d3-472a-bb27-577a88ff637c
# ╟─68e4cf96-c335-4db1-b527-07043cacbc00
# ╟─2c2ec4ba-e9ed-4695-a695-4549ee84e314
# ╟─9ded98dd-d7ea-4edd-afe5-aa0dc9b41b2a
# ╠═cd9ba04b-9851-4f69-b467-990b7b071d46
# ╠═e56ab54a-00d9-4381-bd65-0a10d25722c0
# ╠═dea6dbde-895a-4c1b-bf33-73b70e940458
# ╟─acd184ff-dfce-496a-afa2-0cac1fc5fa98
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
