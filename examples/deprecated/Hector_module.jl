module demo

using ClimateModels, IniFile, Suppressor, PlutoUI, Downloads

import ClimateModels: build	
import ClimateModels: setup

UUID=ClimateModels.UUID
uuid4=ClimateModels.uuid4
OrderedDict=ClimateModels.OrderedDict
git=ClimateModels.git
DataFrame=ClimateModels.DataFrame

"""
	struct Hector_config <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `Hector` model.
""" 
Base.@kwdef struct Hector_config <: AbstractModelConfig
	model :: String = "Hector"
	configuration :: String = "hector_ssp245.ini"
	inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	channel :: Channel{Any} = Channel{Any}(10) 
	folder :: String = tempdir()
	ID :: UUID = uuid4()
end

function build(x :: Hector_config; exe="")
	if isempty(exe)
		pth0=pwd()
		pth=pathof(x)

		url="https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.bz2"		
		fil=joinpath(pth,"boost_1_87_0.tar.bz2")
		Downloads.download(url,fil)
		@suppress run(`tar xvf $fil -C $pth`)

		println("  >> build : boost")

		pth_boost=joinpath(pth,"boost_1_87_0")
		ENV["BOOSTINC"] = pth_boost
		ENV["BOOSTLIB"] = joinpath(pth_boost,"stage","lib")

		cd(pth_boost)
		@suppress run(`./bootstrap.sh --with-libraries=filesystem`)
		@suppress run(`./b2`)
		@suppress run(`./bootstrap.sh --with-libraries=system`)
		@suppress run(`./b2`)

		println("  >> build : hector")

		pth_hector=joinpath(pth,"hector")
		cd(pth_hector)
		@suppress run(`make hector`)

		println("  >> build : complete")

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

    fi1=joinpath(pth,"hector","logs","temperature.log")
    fi2=joinpath(pth,"hector","logs",x.configuration[1:end-4]*"_temperature.log")
    @suppress cp(fi1,fi2,force=true)

    cd(pth0)
end

function setup(x :: Hector_config)
	!isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
	pth=pathof(x)
	!isdir(pth) ? mkdir(pth) : nothing

	url="https://github.com/gaelforget/hector"
    branch="fix_ini_trailing_comments"
	fil=joinpath(pth,"hector")
	@suppress !isfile(fil) ? run(`$(git()) clone -b $branch $url $fil`) : nothing
	
	!isdir(joinpath(pth,"log")) ? log(x,"initial setup",init=true) : nothing
	
	put!(x.channel,Hector_launch)
end

function calc_all_scenarios(MC)
	list=("hector_ssp119.ini","hector_ssp126.ini","hector_ssp245.ini",
        "hector_ssp370.ini","hector_ssp585.ini")
	store=fill(Hector_config(),length(list))
	for ii in 1:length(list)
		tmp=Hector_config(configuration=list[ii],folder=MC.folder,ID=MC.ID)
		put!(tmp,Hector_launch)
		launch(tmp)
		store[ii]=tmp
	end		
	return store,list
end

function read_nml(MC)
	pth=pathof(MC)
	fil=joinpath(pth,"hector/inst/input/",MC.configuration)
	read(Inifile(), fil)
end

end
