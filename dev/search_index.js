var documenterSearchIndex = {"docs":
[{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"EditURL = \"https://github.com/gaelforget/ClimateModels.jl/blob/master/examples/ShallowWaters.jl\"","category":"page"},{"location":"generated/ShallowWaters/#Shallow-Water-Model","page":"Shallow Water Model","title":"Shallow Water Model","text":"","category":"section"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"Here we setup, run and plot a two-dimensional shallow water model using ShallowWaters.jl","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"using ClimateModels, Pkg, Plots, NetCDF, Suppressor","category":"page"},{"location":"generated/ShallowWaters/#Formulate-Model","page":"Shallow Water Model","title":"Formulate Model","text":"","category":"section"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"function SWM(x)\n    pth=pwd()\n    cd(joinpath(x.folder,string(x.ID)))\n    L_ratio = P.nx / P.ny\n    @suppress run_model(;P.nx,P.Lx,L_ratio,Ndays=P.nd,output=true) #note: this may take 10min depending on resolution\n    cd(pth)\nend\n\nP=(nx = 100, ny = 50, Lx = 2000e3, nd=200) #adjustable parameters","category":"page"},{"location":"generated/ShallowWaters/#Setup-Model","page":"Shallow Water Model","title":"Setup Model","text":"","category":"section"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"ModelConfig defines the model into data structure sw, which includes the online location for the model repository.","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"pk=PackageSpec(url=\"https://github.com/milankl/ShallowWaters.jl\")\nsw=ModelConfig(model=pk,configuration=SWM);\nnothing #hide","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"The setup function then clones the online repository to a temporary folder.","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"setup(sw)","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"To ensure that the chosen package version is being used (just in case another version of the package was already installed) one can do this:","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"pk=joinpath(sw.folder,string(sw.ID))\n@suppress Pkg.develop(path=pk)","category":"page"},{"location":"generated/ShallowWaters/#Run-Model","page":"Shallow Water Model","title":"Run Model","text":"","category":"section"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"Within the launch command is where the model run (e.g. SWM) takes place.","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"using ShallowWaters\n\nlaunch(sw);\n\n#Pkg.free(\"ShallowWaters\")","category":"page"},{"location":"generated/ShallowWaters/#Plot-Results","page":"Shallow Water Model","title":"Plot Results","text":"","category":"section"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"Afterwards, one often replays model output for further analysis. Here we plot the random walker path from the netcdf output file.","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"ncfile = NetCDF.open(joinpath(pk,\"run0000\",\"sst.nc\"))\nsst = ncfile.vars[\"sst\"][:,:,:]\ncontourf(sst[:,:,end]',c = :grays, clims=(-1.,1.))","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"Or to create an animated gif","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"anim = @animate for t ∈ 1:P.nd+1\n   contourf(sst[:,:,t+1]',c = :grays, clims=(-1.,1.))\nend\ngif(anim, \"sst.gif\", fps = 40)","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"","category":"page"},{"location":"generated/ShallowWaters/","page":"Shallow Water Model","title":"Shallow Water Model","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"EditURL = \"https://github.com/gaelforget/ClimateModels.jl/blob/master/examples/MITgcm.jl\"","category":"page"},{"location":"generated/MITgcm/#General-Circulation-Model","page":"General Circulation Model","title":"General Circulation Model","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"Here we setup and run MITgcm. This general circulation model can simulate the Ocean (as done here), Atmosphere (plot below), and other components of the climate system accross a wide range of scales and configurations.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"using ClimateModels, MITgcmTools, MeshArrays, Plots, Suppressor","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"(Image: fig1)","category":"page"},{"location":"generated/MITgcm/#Setup-Model","page":"General Circulation Model","title":"Setup Model","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"The most standard MITgcm configurations (verification experiments) are all available via the MITgcmTools.jl package.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"exps=verification_experiments()\nmyexp=\"global_with_exf\"\ntmp=[exps[i].configuration==myexp for i in 1:length(exps)]\niexp=findall(tmp)[1];\nnothing #hide","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"User can inspect model parameters (e.g. in data) via functions also provided by MITgcmTools.jl (e.g. MITgcm_namelist)","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"fil=joinpath(MITgcm_path,\"verification\",exps[iexp].configuration,\"input\",\"data\")\nnml=read(fil,MITgcm_namelist())","category":"page"},{"location":"generated/MITgcm/#Where-Is-mitgcmuv-located?","page":"General Circulation Model","title":"Where Is mitgcmuv located?","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"The model executable mitcmuv is normally found in the build/ subfolder of the selected experiment. If mitcmuv is not found at this stage then it is assumed that the chosen model configuration has never been compiled. Thus we need to compile and run the model a first time via the build function. This might take a lot longer than a normal model run due to the one-time cost of compiling the model.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"filexe=joinpath(MITgcm_path,\"verification\",exps[iexp].configuration,\"build\",\"mitgcmuv\")\n!isfile(filexe) ? build(exps[iexp]) : nothing\npp=joinpath(exps[iexp].folder,string(exps[iexp].ID),\"run\")\nfilout=joinpath(pp,\"output.txt\")\nfilstat=joinpath(pp,\"onestat.txt\");\nnothing #hide","category":"page"},{"location":"generated/MITgcm/#Run-Model","page":"General Circulation Model","title":"Run Model","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"The main model computation takes place here.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"@suppress setup(exps[iexp])\n\n@suppress launch(exps[iexp])","category":"page"},{"location":"generated/MITgcm/#Plot-Monitor","page":"General Circulation Model","title":"Plot Monitor","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"Often, monitor denotes a statement / counter printed to standard model output (text file) at regular intervals. In the example below, we use global mean temperature which is reported every time step as dynstat_theta_mean.","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"run(pipeline(`grep dynstat_theta_mean $(filout)`,filstat))\n\ntmp0 = read(filstat,String)\ntmp0 = split(tmp0,\"\\n\")\nTmean=[parse(Float64,split(tmp0[i],\"=\")[2]) for i in 1:length(tmp0)-1]\nplot(Tmean)","category":"page"},{"location":"generated/MITgcm/#Plot-Results","page":"General Circulation Model","title":"Plot Results","text":"","category":"section"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"While such models run, they typically output snapshots and/or time-averages of state variables in e.g. binary or netcdf format. Aftewards, e.g. once the model run has completed, one often wants to reread this output for further analysis. Here, for example, we reread and plot a temperature field saved at the last time step (T.0000000020).","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"XC=read_mdsio(pp,\"XC\"); siz=size(XC)\n\nmread(xx::Array,x::MeshArray) = read(xx,x)\nfunction mread(fil::String,x::MeshArray)\n\td=dirname(fil)\n\tb=basename(fil)[1:end-5]\n\tread(read_mdsio(d,b),x)\nend\n\nγ=gcmgrid(pp,\"PeriodicChannel\",1,fill(siz,1), [siz[1] siz[2]], eltype(XC), mread, write)\nΓ=GridLoad(γ)\nT=read_mdsio(pp,\"T.0000000020\")\nheatmap(T[:,:,1]')","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"","category":"page"},{"location":"generated/MITgcm/","page":"General Circulation Model","title":"General Circulation Model","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"EditURL = \"https://github.com/gaelforget/ClimateModels.jl/blob/master/examples/RandomWalker.jl\"","category":"page"},{"location":"generated/RandomWalker/#Random-Walker","page":"Random Walker","title":"Random Walker","text":"","category":"section"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"Here we setup, run and plot a two-dimensional random walker path.","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"using ClimateModels, Plots, CSV, DataFrames","category":"page"},{"location":"generated/RandomWalker/#Formulate-Model","page":"Random Walker","title":"Formulate Model","text":"","category":"section"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"This simple model steps randomly, N times, on a x,y plane starting from 0,0.","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"function RandomWalker(x)\n    #model run\n    N=10000\n    m=zeros(N,2)\n    [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:N]\n\n    #output to file\n    df = DataFrame(x = m[:,1], y = m[:,2])\n    fil=joinpath(x.folder,string(x.ID),\"RandomWalker.csv\")\n    CSV.write(fil, df)\n\n    return m\nend","category":"page"},{"location":"generated/RandomWalker/#Setup-And-Run-Model","page":"Random Walker","title":"Setup And Run Model","text":"","category":"section"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"ModelConfig defines the model into data structure m\nsetup prepares the model to run in a temporary folder\nlaunch runs the RandomWalker model which writes results to file","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"Note: RandomWalker returns results also directly as an Array, but this is generally not an option for most, larger, models","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"m=ModelConfig(model=RandomWalker)\nsetup(m)\nxy=launch(m);\nnothing #hide","category":"page"},{"location":"generated/RandomWalker/#Plot-Results","page":"Random Walker","title":"Plot Results","text":"","category":"section"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"Afterwards, one often uses model output for further analysis. Here we plot the random walker path from the csv output file.","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"fil=joinpath(m.folder,string(m.ID),\"RandomWalker.csv\")\noutput = CSV.File(fil) |> DataFrame\nplot(output.x,output.y) #, fmt=:png)","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"","category":"page"},{"location":"generated/RandomWalker/","page":"Random Walker","title":"Random Walker","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/defaults/","page":"Default Methods","title":"Default Methods","text":"EditURL = \"https://github.com/gaelforget/ClimateModels.jl/blob/master/examples/defaults.jl\"","category":"page"},{"location":"generated/defaults/#Default-Methods","page":"Default Methods","title":"Default Methods","text":"","category":"section"},{"location":"generated/defaults/","page":"Default Methods","title":"Default Methods","text":"The defaults assume that the model is a Julia package downloaded (via git clone) from online repository (its url). The cloned package's test/runtests.jl is then used to run the model.","category":"page"},{"location":"generated/defaults/","page":"Default Methods","title":"Default Methods","text":"using ClimateModels, Pkg\n\nurl=PackageSpec(url=\"https://github.com/JuliaOcean/AirSeaFluxes.jl\")\n\nmo=ModelConfig(model=url)\nsetup(mo)\npause(mo)\nshow(mo)\nlaunch(mo)\nmonitor(mo)\nclean(mo)","category":"page"},{"location":"generated/defaults/","page":"Default Methods","title":"Default Methods","text":"","category":"page"},{"location":"generated/defaults/","page":"Default Methods","title":"Default Methods","text":"This page was generated using Literate.jl.","category":"page"},{"location":"#ClimateModels.jl","page":"Home","title":"ClimateModels.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models are  ran and analyzed via a simple interface laid out hereafter. Three examples illustrate this framework as applied to:","category":"page"},{"location":"","page":"Home","title":"Home","text":"one stochastic path (0D)\na shallow water model (2D)\nthe MIT general circulation model (3D, Ocean, Atmosphere, etc)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Note: this package is still its early stage of development, such that breaking changes should be expected.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Climate-Model-Interface","page":"Home","title":"Climate Model Interface","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"ModelConfig\nclean\nsetup\nbuild\ncompile\nlaunch\nmonitor","category":"page"},{"location":"#ClimateModels.ModelConfig","page":"Home","title":"ClimateModels.ModelConfig","text":"struct ModelConfig <: AbstractModelConfig\n\nmodel :: Union{Function,String,Pkg.Types.PackageSpec} = \"anonymous\"\nconfiguration :: Union{Function,String} = \"anonymous\"\noptions :: Array{String,1} = Array{String,1}(undef, 0)\ninputs :: Array{String,1} = Array{String,1}(undef, 0)\noutputs :: Array{String,1} = Array{String,1}(undef, 0)\nstatus :: Array{String,1} = Array{String,1}(undef, 0)\nchannel :: Channel{Any} = Channel{Any}(10) \nfolder :: String = tempdir()\nID :: UUID = UUIDs.uuid4()\n\n\n\n\n\n","category":"type"},{"location":"#ClimateModels.clean","page":"Home","title":"ClimateModels.clean","text":"clean(x :: AbstractModelConfig)\n\nCancel any remaining task (x.channel) and clean the run directory (via rm)\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nclean(tmp)\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.setup","page":"Home","title":"ClimateModels.setup","text":"setup(x)\n\nDefaults to default_ClimateModelSetup(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Pkg\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.build","page":"Home","title":"ClimateModels.build","text":"build(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Pkg\ntmp0=PackageSpec(url=\"https://github.com/JuliaOcean/AirSeaFluxes.jl\")\ntmp=ModelConfig(model=tmp0,configuration=\"anonymous\",options=Array{String,1}(undef, 0))\nsetup(tmp)\nbuild(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.compile","page":"Home","title":"ClimateModels.compile","text":"compile(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Pkg\ntmp0=PackageSpec(url=\"https://github.com/JuliaOcean/AirSeaFluxes.jl\")\ntmp=ModelConfig(model=tmp0)\nsetup(tmp)\ncompile(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.launch","page":"Home","title":"ClimateModels.launch","text":"launch(x)\n\nDefaults to default_ClimateModelLaunch(x) which consists in take!(x) for AbstractModelConfig. Can be expected to be specialized for most  concrete types of AbstractModelConfig\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nlaunch(tmp)\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.monitor","page":"Home","title":"ClimateModels.monitor","text":"monitor(x)\n\nShow x.status[end] by default.\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nmonitor(tmp)\n\n\n\n\n\n","category":"function"},{"location":"#Git-Support","page":"Home","title":"Git Support","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"init_git_log\nadd_git_msg","category":"page"},{"location":"#ClimateModels.init_git_log","page":"Home","title":"ClimateModels.init_git_log","text":"init_git_log(x :: AbstractModelConfig)\n\nCreate log subfolder, initialize git, and commit initial README.md\n\n\n\n\n\n","category":"function"},{"location":"#ClimateModels.add_git_msg","page":"Home","title":"ClimateModels.add_git_msg","text":"add_git_msg(x :: AbstractModelConfig,msg,commit_msg)\n\nAdd message msg to the log/README.md file and git commit.\n\n\n\n\n\n","category":"function"}]
}
