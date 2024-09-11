
module Speedy

import ClimateModels
import ClimateModels: build, setup, AbstractModelConfig, read_NetCDF

using Suppressor
git=ClimateModels.git
DataFrame=ClimateModels.DataFrame
uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID
OrderedDict=ClimateModels.OrderedDict

"""
	struct SpeedyConfig <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `SPEEDY` model.
""" 
Base.@kwdef struct SpeedyConfig <: AbstractModelConfig
	model :: String = "speedy"
	configuration :: String = "default"
	inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	channel :: Channel{Any} = Channel{Any}(10) 
	folder :: String = tempdir()
	ID :: UUID = uuid4()
end

function build(x :: SpeedyConfig)
	pth0=pwd()
	pth=pathof(x)

	cd(pth)
	if Sys.isapple()
#		ENV["NETCDF"] = "/usr/local/"
        ENV["NETCDF"]="/opt/homebrew/"
	else
		ENV["NETCDF"] = "/usr/"
	end
	@suppress run(`bash build.sh`)
	cd(pth0)
end

function SPEEDY_launch(x::SpeedyConfig)
    pth0=pwd()
    pth=pathof(x)
    cd(pth)
    @suppress run(`bash run.sh`)
    cd(pth0)
end

function setup(x :: SpeedyConfig)
	!isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
	pth=pathof(x)
	!isdir(pth) ? mkdir(pth) : nothing

	url="https://github.com/gaelforget/speedy.f90"
	@suppress run(`$(git()) clone -b more_diags $url $pth`)

	!isdir(joinpath(pth,"log")) ? log(x,"initial setup",init=true) : nothing
	
	put!(x.channel,SPEEDY_launch)
end

function write_ini_file(MC,nmonths) 
	(ny,nm)=divrem(nmonths+1,12)
	nm==0 ? (ny,nm)=(ny-1,12) : nothing
	(ny,nm)

	nml_ini="! nsteps_out = model variables are output every nsteps_out timesteps
! nstdia     = model diagnostics are printed every nstdia timesteps
&params
nsteps_out = 180
nstdia     = 180
/
! start_datetime = the start datetime of the model integration
! end_datetime   = the end datetime of the model integration
&date
start_datetime%year   = 1982
start_datetime%month  = 1
start_datetime%day    = 1
start_datetime%hour   = 0
start_datetime%minute = 0
end_datetime%year     = $(1982+ny)
end_datetime%month    = $(nm)
end_datetime%day      = 1
end_datetime%hour     = 0
end_datetime%minute   = 0
/
"
	
	write(joinpath(pathof(MC),"namelist.nml"),nml_ini)
	
	"Done with parameter file"
end

function list_files_output(x::SpeedyConfig)
		pth=pathof(x)
		tmp=readdir(joinpath(pth,"rundir"))
		files=tmp[findall(occursin.(".nc",tmp))[2:end]]
		nt=length(files)
		[joinpath(pth,"rundir",t) for t in files]
end

function read_output(files,varname="t",time=1)
	nt=length(files)
	isnothing(time) ? t=1 : t=mod(time,Base.OneTo(nt))

	lon = read_NetCDF(files[t])["lon"][:]
	lat = read_NetCDF(files[t])["lat"][:]
	lev = read_NetCDF(files[t])["lev"][:]
	tmp = read_NetCDF(files[t])[varname]

	return (lon=lon,lat=lat,lev,values=tmp,fil=files[t])
end
	
function get_msk(rundir)
	file=joinpath(rundir,"surface.nc")
	lsm=read_NetCDF(file)["lsm"][:,:]
	msk=Float64.(reverse(lsm,dims=2))
	msk[findall(msk[:,:].==1.0)].=NaN
	msk[findall(msk[:,:].<1.0)].=1.0
	msk
end

function read_namelist(x:: SpeedyConfig)

	fil=joinpath(pathof(x),"rundir/namelist.nml")
	nml=readlines(fil)
	i=findall([nml[i][1]!=='!' for i in 1:length(nml)])
	nml=nml[i]

	i0=findall([nml[i][1]=='&' for i in 1:length(nml)])
	i1=findall([nml[i][1]=='/' for i in 1:length(nml)])

	tmp0=OrderedDict()
	for i in 1:length(i0)
		tmp1=Symbol(nml[i0[i]][2:end])
		tmp2=OrderedDict()
		for j in i0[i]+1:i1[i]-1
			tmp3=split(nml[j],'=')
			tmp2[tmp3[1]]=parse(Int,tmp3[2])
		end
		tmp0[tmp1]=tmp2
	end

	return tmp0
end    

end

