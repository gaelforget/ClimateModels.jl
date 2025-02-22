module demo

using ClimateModels, NetCDF
import ClimateModels: build
import ClimateModels: setup

using CairoMakie, PlutoUI, Suppressor
git=ClimateModels.git
DataFrame=ClimateModels.DataFrame
uuid4=ClimateModels.uuid4
UUID=ClimateModels.UUID
OrderedDict=ClimateModels.OrderedDict

"""
	struct SPEEDY_config <: AbstractModelConfig

Concrete type of `AbstractModelConfig` for `SPEEDY` model.
""" 
Base.@kwdef struct SPEEDY_config <: AbstractModelConfig
	model :: String = "speedy"
	configuration :: String = "default"
	inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
	channel :: Channel{Any} = Channel{Any}(10) 
	folder :: String = tempdir()
	ID :: UUID = uuid4()
end

function build(x :: SPEEDY_config)
	pth0=pwd()
	pth=pathof(x)

	cd(pth)

	NETCDF = @static if Sys.islinux()
		"/usr/"
	elseif Sys.isapple()&&(Sys.ARCH==:x86_64)
		"/usr/local/"
	elseif Sys.isapple() #&&(Sys.ARCH==:AArch64)
		"/opt/homebrew/"
	else
		error("unsupported system")
	end

	withenv("NETCDF"=>NETCDF) do
		try
			@suppress run(`bash build.sh`)
		catch
			@warn "compilation has failed"
		end
	end

	cd(pth0)
end

function SPEEDY_launch(x::SPEEDY_config)
    pth0=pwd()
    pth=pathof(x)
    cd(pth)
    @suppress run(`bash run.sh`)
    cd(pth0)
end

function setup(x :: SPEEDY_config)
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

function list_files_output(x::SPEEDY_config)
		pth=pathof(x)
		tmp=readdir(joinpath(pth,"rundir"))
		files=tmp[findall(occursin.(".nc",tmp))[2:end]]
		nt=length(files)
		[joinpath(pth,"rundir",t) for t in files]
end

function read_output(files,varname="t",time=1)
	nt=length(files)
	isnothing(time) ? t=1 : t=mod(time,Base.OneTo(nt))
	ncfile = NetCDF.open(files[t])
	
	lon = ncfile.vars["lon"][:]
	lat = ncfile.vars["lat"][:]
	lev = ncfile.vars["lev"][:]
	tmp = ncfile.vars[varname]

	return (lon=lon,lat=lat,lev,values=tmp,fil=files[t])
end
	
function get_msk(rundir)
	ncfile = NetCDF.open(joinpath(rundir,"surface.nc"))
	lsm=ncfile.vars["lsm"][:,:]
	msk=Float64.(reverse(lsm,dims=2))
	msk[findall(msk[:,:].==1.0)].=NaN
	msk[findall(msk[:,:].<1.0)].=1.0
	msk
end

function read_namelist(x:: SPEEDY_config)

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
