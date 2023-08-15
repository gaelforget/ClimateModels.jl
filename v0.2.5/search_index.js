var documenterSearchIndex = {"docs":
[{"location":"functionalities/#manual","page":"Manual","title":"User Manual","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Here we document key functionalities offered in ClimateModels.jl","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Climate Model Interface\nTracked Worklow Framework\nCloud + On-Premise File Support","category":"page"},{"location":"functionalities/#Climate-Model-Interface","page":"Manual","title":"Climate Model Interface","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The climate model interface is based on the ModelConfig data structure and a series of methods like setup, build, and launch. The typical sequence is shown just below where f is a function that (1) receives a ModelConfig as its only input argument, and (2) gets called via launch. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"julia> using ClimateModels\njulia> f=ClimateModels.RandomWalker\njulia> MC=ModelConfig(model=f)\njulia> setup(MC)\njulia> build(MC)\njulia> launch(MC)","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The ModelConfig called MC is summarized using the show method which here reveals that f is just an alias for ClimateModels.RandomWalker. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"  ID            = 6e8444b3-220f-402e-9224-dbd11b513790\n  model         = RandomWalker\n  configuration = anonymous\n  run folder    = /tmp/6e8444b3-220f-402e-9224-dbd11b513790\n  log subfolder = /tmp/6e8444b3-220f-402e-9224-dbd11b513790/log\n  task(s)       = RandomWalker","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The run folder name can be accessed directly using pathof and its content inspected using readdir.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"2-element Vector{String}:\n \"RandomWalker.csv\"\n \"log\"","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Here launch(MC) has completed, RandomWalker.csv is a file that was generated by function f, and log is the log subfolder that was created by setup. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The workflow log is retrieved using the log function. log(MC) in this example would give:","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"5-element Vector{String}:\n \"9947f79 initial setup\"\n \"63e7e77 add Project.toml to log\"\n \"fa2a84e add Manifest.toml to log\"\n \"89359f5 task started [64e58e36-303a-4903-8ecd-2270f6583f0b]\"\n \"63e8857 (HEAD -> main) task ended [64e58e36-303a-4903-8ecd-2270f6583f0b]\"","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"This highlights that Project.toml and Manifest.toml for the environment being used have been archived. This happens during setup to document all dependencies and make the workflow reproducible.","category":"page"},{"location":"functionalities/#Generalization","page":"Manual","title":"Generalization","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"A key point is that everything can be customized to, e.g., use popular models previously written in Fortran or C just as simply. This typically involves defining a new concrete type of AbstractModelConfig and then providing customized build and/or setup methods as discussed below. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"To start, let's distinguish amongst ModelConfigs on the basis of their model variable type :","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"normal user mode is when model is a String or a Function\npackage developer mode is when model is a Pkg.Types.PackageSpec","category":"page"},{"location":"functionalities/#*Normal-User-Mode*","page":"Manual","title":"Normal User Mode","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The simplest way to use the ClimateModels.jl interface is to specify model directly as a function, and use defaults for everything else. This approach may be best suited to pure Julia models or as a first step. It is illustrated in random walk. In CMIP6 the model name is provided as a String and the main Function is specified as the configuration instead.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"note: Note\nOnce the initial launch call has completed, it is always possible to add workflow steps via put! and launch.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Often though, there are benefits to defining a custom setup and/or build method. One can then simply define a concrete type of AbstractModelConfig using ModelConfig as a blueprint. This is the recommended approach when another languange like Fortran, C++, or Python is involved. Thiis is illustrated with Hector, FaIR, SPEEDY, and MITgcm. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Defining a concrete type of AbstractModelConfig can also be practical with pure Julia model, e.g. to speed up launch, generate ensembles, facilitate checkpointing, etc. That's the case in the Oceananigans.jl example.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The idea in the longer term is that for popular models the customized interface elements would be provided via a dedicated package. They would thus be maintained independently by developers and users most familiar with each model. This approach is demonstrated in MITgcmTools.jl for MITgcm which provides its own suite of examples using the ClimateModels.jl interface.","category":"page"},{"location":"functionalities/#*Package-Developer-Mode*","page":"Manual","title":"Package Developer Mode","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The defining feature of this approach is that the PackageSpec   specification of model makes setup install the chosen package using Pkg.develop. This allows for developing a package or using an unregistered package in the context of ClimateModels.jl. There are two cases: ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"if configuration is left undefined then launch will run the package test suite using Pkg.test as in this example (code link, download link)\nif configuration is provided as a Function then launch will call it as illustrated in the ShallowWaters.jl example (code link, download link)","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"note: Note\nAs an exercise, can you turn ShallowWaters.jl example into a normal user mode example?","category":"page"},{"location":"functionalities/#Git-/-Log-Support","page":"Manual","title":"Git / Log Support","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The setup method normally calls log to create a temporary run folder with a git enabled subfolder called log. This allows for recording each workflow step, using log functions listed below.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"log","category":"page"},{"location":"functionalities/#Base.log","page":"Manual","title":"Base.log","text":"log(x :: AbstractModelConfig)\n\nShow the record of git commits that have taken place in the log folder.\n\n\n\n\n\nlog(x :: AbstractModelConfig, commit_msg :: String; \n             fil=\"\", msg=\"\", init=false, prm=false)\n\nKeyword arguments work like this \n\ninit==true : create log subfolder, initialize git, and commit initial README.md\nprm==true  : add files found in input or tracked_parameters/ (if any) to git log\n!isempty(fil) : commit changes to file log/$(fil) with message commit_msg.   If log/$(fil) is unknown to git (i.e. commit errors out) then try adding log/$(fil) first. \n\nand are mutually exclusive (i.e., use only one at a time).\n\nusing ClimateModels\n\nf=ClimateModels.RandomWalker\ntmp=ModelConfig(model=f,inputs=Dict(\"NS\"=>100))\n\nsetup(tmp)\nbuild(tmp)\nlaunch(tmp)\n\nmsg=\"update tracked_parameters.toml (or skip if up to date)\"\nlog(tmp,msg,fil=\"tracked_parameters.toml\")\nlog(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Cloud-/-File-Support","page":"Manual","title":"Cloud / File Support","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"There are various ways that numerical model output gets archived, distributed, and retrieved from the internet. In some cases downloading data can be the most convenient approach. In others it can be more advantageous to compute in the cloud and only download final results for plotting. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"ClimateModels.jl comes equiped with packages that read popular file formats used in climate modeling and science. Downloads.jl, CSV.jl, DataFrames.jl, NetCDF.jl, Zarr.jl, and TOML.jl are thus readily available when you install ClimateModels.jl. For instance, one can read the CSV file generated before as","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"julia> fil=joinpath(pathof(MC),\"RandomWalker.csv\")\njulia> ClimateModels.CSV.File(fil) |> ClimateModels.DataFrame","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"or, maybe preferably, as","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"julia> fil=joinpath(pathof(MC),\"RandomWalker.csv\")\njulia> CSV=ClimateModels.CSV\njulia> DataFrame=ClimateModels.DataFrame\njulia> CSV.File(fil) |> DataFrame","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"For additional examples covering other file formats, please refer to the IPCC report and CMIP6 archive notebooks and code links.","category":"page"},{"location":"functionalities/#API-Reference","page":"Manual","title":"API Reference","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"ModelConfig","category":"page"},{"location":"functionalities/#ClimateModels.ModelConfig","page":"Manual","title":"ClimateModels.ModelConfig","text":"struct ModelConfig <: AbstractModelConfig\n\nmodel :: Union{Function,String,Pkg.Types.PackageSpec} = \"anonymous\"\nconfiguration :: Union{Function,String} = \"anonymous\"\noptions :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\ninputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\noutputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\nstatus :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\nchannel :: Channel{Any} = Channel{Any}(10) \nfolder :: String = tempdir()\nID :: UUID = UUIDs.uuid4()\n\n\n\n\n\n","category":"type"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"setup\nbuild\nlaunch\nshow\npathof\nreaddir\nclean","category":"page"},{"location":"functionalities/#ClimateModels.setup","page":"Manual","title":"ClimateModels.setup","text":"setup(x)\n\nDefaults to default_ClimateModelSetup(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nf=ClimateModels.RandomWalker\ntmp=ModelConfig(model=f)\nsetup(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.build","page":"Manual","title":"ClimateModels.build","text":"build(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nbuild(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.launch","page":"Manual","title":"ClimateModels.launch","text":"launch(x)\n\nDefaults to default_ClimateModelLaunch(x) which consists in take!(x) for AbstractModelConfig. Can be expected to be specialized for most  concrete types of AbstractModelConfig\n\nf=ClimateModels.RandomWalker\ntmp=ModelConfig(model=f)\nsetup(tmp)\nbuild(tmp)\nlaunch(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Base.show","page":"Manual","title":"Base.show","text":"show(io::IO, z::AbstractModelConfig)\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nshow(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Base.pathof","page":"Manual","title":"Base.pathof","text":"pathof(x::AbstractModelConfig)\n\nReturns the run directory path for x ; i.e. joinpath(x.folder,string(x.ID))\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Base.Filesystem.readdir","page":"Manual","title":"Base.Filesystem.readdir","text":"readdir(x::AbstractModelConfig)\n\nSame as readdir(pathof(x)).\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.clean","page":"Manual","title":"ClimateModels.clean","text":"clean(x :: AbstractModelConfig)\n\nCancel any remaining task (x.channel) and rm the run directory (pathof(x))\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nclean(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"cmip\nnotebooks.open","category":"page"},{"location":"functionalities/#ClimateModels.cmip","page":"Manual","title":"ClimateModels.cmip","text":"cmip(institution_id,source_id,variable_id)\n\nAccess CMIP6 climate model archive via AWS.jl and Zarr.jl and compute (1) time mean global map and (2) time evolving global mean.\n\nThis example was partly inspired by this notebook.\n\nusing ClimateModels\n(mm,gm,meta)=cmip()\nnm=meta[\"long_name\"]*\" in \"*meta[\"units\"]\n\nusing Plots\nheatmap(mm[\"lon\"], mm[\"lat\"], transpose(mm[\"m\"]),\n        title=nm*\" (time mean)\")\nplot(gm[\"t\"][1:12:end],gm[\"y\"][1:12:end],xlabel=\"time\",ylabel=nm,\n     title=meta[\"institution_id\"]*\" (global mean, month by month)\")\ndisplay.([plot!(gm[\"t\"][i:12:end],gm[\"y\"][i:12:end], leg = false) for i in 2:12])\n\n\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.notebooks.open","page":"Manual","title":"ClimateModels.notebooks.open","text":"pluto_url=\"http://localhost:1234/\"\n#plut_url=\"https://notebooks.gesis.org/binder/jupyter/user/juliaclimate-notebooks-vx8glon1/pluto/\"\n#pluto_url=\"https://ade.ops.maap-project.org/serverpmohyfxe-ws-jupyter/server-3100/pluto/\"\nnbs=notebooks.list()\n\npath=joinpath(tempdir(),\"nbs\")\nnotebooks.download(path,nbs)\n\nii=1\nnotebook_url=nbs.url[ii]\n#notebook_path=joinpath(\"tutorials\",\"jl\",nbs.folder[ii],nbs.file[ii])\nnotebook_path=joinpath(path,nbs.folder[ii],nbs.file[ii])\n\nnotebooks.open(pluto_url,notebook_url=notebook_url)\n#notebooks.open(pluto_url,notebook_path)\n\n\n\n\n\n","category":"function"},{"location":"examples/#examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The random walk model example is a good place to start. It is also presented in greater detail in the Climate Model Interface section to further illustrate how things work.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"The examples generally fall into two categories : Workflows That Run Models and Workflows That Replay Models' output. The distinction is not strict though, as one model often depends for its input on another model's output. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"The Trying Out The Examples section is for users who'd like to run, modify, or experiment with the notebooks. The User Manual section on Climate Model Interface then outlines simple ways that models can be added to the framework. The examples presented here were built in this fashion.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"In the example list below, the core language of each model is indicated and the models are sorted, more or less, by increasing dimensionality / problem size. The example set, collectively, demonstrates that the Climate Model Interface is applicable to a wide range of models, computational languages, and problem sizes.","category":"page"},{"location":"examples/#Workflows-That-Run-Models","page":"Examples","title":"Workflows That Run Models","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"random walk model (Julia) ➭ code link, download link\nShallowWaters.jl model (Julia) ➭ code link, download link\nOceananigans.jl model (Julia) ➭ code link, download link\nHector global climate model (C++) ➭ code link, download link\nFaIR global climate model (Python) ➭ code link, download link\nSPEEDY atmosphere model (3D) (Fortran90) ➭ code link, download link\nMITgcm general circulation model (Fortran) ➭ code link, download link","category":"page"},{"location":"examples/#Workflows-That-Replay-Models","page":"Examples","title":"Workflows That Replay Models","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"CMIP6 model output ➭ code link, download link\nIPCC report 2021 ➭ code link, download link\nECMWF IFS 1km ➭ code link, download link","category":"page"},{"location":"examples/#Trying-Out-The-Examples","page":"Examples","title":"Trying Out The Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The examples are most easily run using Pluto.jl. To do it this way, one just needs to copy a code link provided above and paste this URL into the Pluto.jl interface.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"One can also run the notebooks (e.g., RandomWalker.jl) either (1) by calling julia RandomWalker.jl at the shell command line or (2) by calling include(\"RandomWalker.jl\") at the julia REPL prompt. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"If the shell CLI or the julia REPL is used, however, one needs to download the notebook file and potentially Pkg.add a few packages beforehand (Pluto.jl does this automatically).","category":"page"},{"location":"examples/#*System-Requirements*","page":"Examples","title":"System Requirements","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The pure Julia examples should immediately work on any laptop or cloud computing service. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (gfortran) and / or on Netcdf libraries (libnetcdf-dev,libnetcdff-dev) will require that you e.g. install gfortran. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"All requirements should be preinstalled in this cloud computer (see the JuliaClimate notebooks page for detail).","category":"page"},{"location":"examples/#Creating-Your-Own","page":"Examples","title":"Creating Your Own","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Please refer to the User Manual section, and Climate Model Interface in particular, for more on this.","category":"page"},{"location":"#ClimateModels.jl","page":"Home","title":"ClimateModels.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using git, is included to allow for workflow documentation and reproducibility.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The JuliaCon 2021 Presentation provides a brief (8') overview and demo of the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Please refer to Examples and User Manual  for more detail. ","category":"page"},{"location":"#main-contents","page":"Home","title":"Table Of Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"examples.md\",\n    \"functionalities.md\",\n]\nDepth = 2","category":"page"},{"location":"#JuliaCon-2021-Presentation","page":"Home","title":"JuliaCon 2021 Presentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Presentation recording\nPresentation notebook (html)\nPresentation notebook (jl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Screen Shot 2021-08-31 at 2 25 04 PM)","category":"page"}]
}