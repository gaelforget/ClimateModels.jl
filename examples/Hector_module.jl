module demo

using ClimateModels, CairoMakie, IniFile, Suppressor, PlutoUI

import ClimateModels: build	
import ClimateModels: setup

uuid4=ClimateModels.uuid4
OrderedDict=ClimateModels.OrderedDict
Downloads=ClimateModels.Downloads
git=ClimateModels.git
DataFrame=ClimateModels.DataFrame

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

function Hector_launch(x::Hector_config)
    pth0=pwd()
    pth=pathof(x)
    cd(joinpath(pth,"hector"))
	
    msg=(" Parameter File = ```"*string(x.configuration)*" \n\n")
    log(x,"Configuration File = $(x.configuration)",msg=msg)
	
    config=joinpath("inst","input",x.configuration)
    @suppress run(`./src/hector $config`)
    cd(pth0)
end

function setup(x :: Hector_config)
	!isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
	pth=pathof(x)
	!isdir(pth) ? mkdir(pth) : nothing

	url="https://github.com/JGCRI/hector"
	fil=joinpath(pth,"hector")
	@suppress run(`$(git()) clone $url $fil`)
	
	!isdir(joinpath(pth,"log")) ? log(x,"initial setup",init=true) : nothing
	
	put!(x.channel,Hector_launch)
end

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

end
