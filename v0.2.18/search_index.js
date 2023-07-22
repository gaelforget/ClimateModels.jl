var documenterSearchIndex = {"docs":
[{"location":"functionalities/#manual","page":"User Manual","title":"User Manual","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"using ClimateModels","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Here we document key functionalities offered in ClimateModels.jl","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Climate Model Interface\nTracked Worklow Framework\nCloud + On-Premise File Support","category":"page"},{"location":"functionalities/#Climate-Model-Interface","page":"User Manual","title":"Climate Model Interface","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The interface ties the ModelConfig data structure with methods like setup, build, and launch. In return, it provides standard methods to deal with inputs and outputs, as well as capabilities described below. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The ModelRun method provides the capability to deploy models in streamlined fashion – with just one code line, or just one click. It executes all three steps at once (setup, build, and launch). ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"With the simplified ModelConfig constructor, we can then just write:","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"f=ClimateModels.RandomWalker\nModelRun(ModelConfig(f))\nnothing #hide","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"or using the @ModelRun to abbreviate further:","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"@ModelRun ClimateModels.RandomWalker","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The above example uses RandomWalker as the model's top level function / wrapper function. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"By design of our interface, it is required that this function receives a ModelConfig as its sole input argument. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"note: Note\nIn practice, this requirement is easily satisfied. Input parameters can be specified to ModelConfig via the inputs keyword argument, or via files instead. See Parameters.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Often one may prefer to break things down though. Let's start with defining the model:","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"MC=ModelConfig(model=ClimateModels.RandomWalker)\nnothing #hide","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The sequence of calls within ModelRun can then be expanded as shown below. In practice, setup typically handles files and software, build may compile a chosen model configuration, and launch takes care of the main computation. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"setup(MC)\nbuild(MC)\nlaunch(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The model's top level function gets called via launch. In our example, it generates a CSV file found in the run folder as shown below. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"note: Note\nIt is not required that compilation takes place during build. It can also be done beforehand or within launch.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Sometimes it is convenient to further break down the computational workflow into several tasks. These can be added to the ModelConfig via put! and then executed via launch, as demonstrated in Parameters.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The run folder name and its content can be viewed using pathof and readdir, respectively.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"pathof(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"readdir(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The log subfolder was created earlier by setup. The log function retrieves the workflow log. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"log(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"This highlights that Project.toml and Manifest.toml for the environment being used have been archived. This happens during setup to document all dependencies and make the workflow reproducible.","category":"page"},{"location":"functionalities/#Customization","page":"User Manual","title":"Customization","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"A key point is that everything can be customized to, e.g., use popular models previously written in Fortran or C just as simply. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The simplest way to use the ClimateModels.jl interface is to specify model directly as a function, and use defaults for everything else, as illustrated in random walk. Alternatively, the model name can be provided as a String and the main Function as the configuration, as in CMIP6.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Often, however, one may want to define custom setup, build, or launch methods. To this end, one can define a concrete type of AbstractModelConfig using ModelConfig as a blueprint. This is the recommended approach when other languanges like Fortran or Python are involved (e.g., Hector, FaIR, SPEEDY, MITgcm). ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"note: Note\nDefining a concrete type of AbstractModelConfig can also be practical with pure Julia model, e.g. to speed up launch, generate ensembles, facilitate checkpointing, etc. That's the case in the Oceananigans.jl example.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"For popular models the customized interface elements can be provided via a dedicated package. This may allow them to be maintained independently by developers and users most familiar with each model. MITgcmTools.jl does this for MITgcm. It provides its own suite of examples that use the ClimateModels.jl interface.","category":"page"},{"location":"functionalities/#Parameters","page":"User Manual","title":"Parameters","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"In this example, we illustrate how one can interact with model parameters and rerun a model. After an initial model run of 100 steps, duration NS is extended to 200 time steps. The put! and launch sequence then reruns the model. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"note: Note\nThe same method can be used to break down a workflow in several steps. Each call to launch sequentially takes the next task from the stack (i.e., channel). Once the task channel is empty then launch does nothing.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"MC=ModelConfig(f,(NS=100,filename=\"run01.csv\"))\nrun(MC)\n\nMC.inputs[:NS]=200\nMC.inputs[:filename]=\"run02.csv\"\nput!(MC)\nlaunch(MC)\n\nlog(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The call sequence is readily reflected in the workflow log (see Tracked Worklow Support), and the run folder now has two output files.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"readdir(MC)","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"In more complex models, there generally is a large number of parameters that are often organized in a collection of text files. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The ClimateModels.jl interface can easily be customized to turn these parameter sets into a tracked_parameters.toml file as illustrated in our Hector example and in the MITgcmTools.jl examples.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"ClimateModels.jl thus readily enables interacting with parameters and tracking their values even with complex models as highlighted in the JuliaCon 2021 Presentation.","category":"page"},{"location":"functionalities/#Tracked-Worklow-Support","page":"User Manual","title":"Tracked Worklow Support","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"When creating a ModelConfig, it receives a unique identifier (UUIDs.uuid4()). By default, this identifier is used in the name of the run folder attached to the ModelConfig. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"The run folder normally gets created by setup. During this phase, log is used to create a git enabled subfolder called log. This will allow us to record steps in our workflow – again via log. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"As shown in the Parameters example:","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"Parameters specified via inputs are automatically recorded into tracked_parameters.toml during setup.\nModified parameters are automatically recorded in tracked_parameters.toml during launch.\nlog called on a ModelConfig with no other argument shows the workflow record.","category":"page"},{"location":"functionalities/#Files-and-Cloud-Support","page":"User Manual","title":"Files and Cloud Support","text":"","category":"section"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"There are various ways that numerical model output gets archived, distributed, and retrieved. In some cases downloading data from the web can be most convenient. In others we would compute in the cloud and just download final results for plotting. ","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"ClimateModels.jl leverages standard Julia packages to read common file formats. Downloads.jl, NetCDF.jl, DataFrames.jl, CSV.jl, and TOML.jl are direct dependencies of ClimateModels.jl.","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"fil=joinpath(pathof(MC),\"run02.csv\")\nCSV=ClimateModels.CSV # hide\nDataFrame=ClimateModels.DataFrame #hide\nCSV.File(fil) |> DataFrame\nsummary(ans) # hide","category":"page"},{"location":"functionalities/","page":"User Manual","title":"User Manual","text":"For examples with NetCDF and Zarr, please refer to IPCC notebook (NetCDF) and CMIP6 notebok (Zarr).","category":"page"},{"location":"examples/#examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"A good place to start is the random walk model example. It is also presented in greater detail in the Climate Model Interface section to further illustrate how things work.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"RandomWalker","category":"page"},{"location":"examples/#ClimateModels.RandomWalker","page":"Examples","title":"ClimateModels.RandomWalker","text":"RandomWalker(x::AbstractModelConfig)\n\nRandom Walk in 2D over NS steps (100 by default). The results are returned as an array  and saved to a text file (RandomWalker.csv by default) inside the run folder  (pathof(x) by default). \n\nNote: the setup method should be invoked to create the run folder beforehand.\n\n\n\n\n\n","category":"function"},{"location":"examples/","page":"Examples","title":"Examples","text":"The examples may fall into two categories : ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Workflows That Run Models\nWorkflows That Replay Models","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"note: Note\nOne model may get input from another model's output.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Examples are listed below. For each model, the core language or file format is indicated. Models are sorted by increasing problem size. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"The notebook collection illustrates that the Climate Model Interface is applicable to a wide range of model types, programming languages, and problem sizes.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"In User Manual, the Climate Model Interface section outlines several simple ways that models can be added to the framework. The examples presented here were built in this fashion.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Trying Out The Examples is geared toward users who may want to run or experiment with models.    ","category":"page"},{"location":"examples/#run_model_examples","page":"Examples","title":"Workflows That Run Models","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Random Walk model (Julia) ➭ code link\nShallowWaters.jl model (Julia) ➭ code link\nOceananigans.jl model (Julia) ➭ code link\nHector global climate model (C++) ➭ code link\nFaIR global climate model (Python) ➭ code link\nSPEEDY atmosphere model (Fortran90) ➭ code link\nMITgcm general circulation model (Fortran) ➭ code link","category":"page"},{"location":"examples/#replay_model_examples","page":"Examples","title":"Workflows That Replay Models","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"IPCC report 2021 (NetCDF, CSV) ➭ code link\nCMIP6 model output (Zarr) ➭ code link\nECMWF IFS 1km (NetCDF) ➭ code link\nECCO version 4 (NetCDF) ➭ code link\nPathway Simulations (binary, jld2) ➭ code link","category":"page"},{"location":"examples/#Trying-or-Creating-Examples","page":"Examples","title":"Trying or Creating Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The examples can be most easy to run using Pluto.jl. See these directions for how to do this in the cloud on your own computer.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Alternatively, you can create a PlutoConfig to extract dependencies from the notebook, and operate the notebook via the stanndard methods – setup, build, and launch.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Or, You can run the notebooks directly from the command line interface (CLI) in a terminal window or in the Julia REPL. In this case, one may need to add packages beforehand (see Pkg.add). ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"include(\"RandomWalker.jl\")","category":"page"},{"location":"examples/#Creating-Your-Own","page":"Examples","title":"Creating Your Own","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Please refer to the User Manual section, and Climate Model Interface in particular, for more on this. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"tip: Tip\nA good way to start can be by 1. converting a modeling workflow (setup, build, launch) into a Pluto notebook; 2. then using the notebooks setup method.","category":"page"},{"location":"examples/#*System-Requirements*","page":"Examples","title":"System Requirements","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The pure Julia examples should immediately work on any laptop or cloud computing service. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (gfortran) and / or on Netcdf libraries (libnetcdf-dev,libnetcdff-dev) will require that you e.g. install gfortran. ","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"tip: Tip\nAll requirements should be preinstalled in the JuliaClimate notebooks binder (see the JuliaClimate notebooks page for detail and directions).","category":"page"},{"location":"#ClimateModels.jl","page":"Home","title":"ClimateModels.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using git, is included to allow for workflow documentation and reproducibility.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The JuliaCon 2021 Presentation provides a brief (8') overview and demo of the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Please refer to User Manual, Examples, and API Reference  for more detail. ","category":"page"},{"location":"#main-contents","page":"Home","title":"Table Of Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"functionalities.md\",\n    \"examples.md\",\n    \"API.md\",\n]\nDepth = 2","category":"page"},{"location":"","page":"Home","title":"Home","text":"JuliaCon 2021 Presentation\nvideo recording (mp4)\nnotebook view (html)\nnotebook source (jl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Screen Shot 2021-08-31 at 2 25 04 PM)","category":"page"},{"location":"API/#api","page":"API reference","title":"API Reference","text":"","category":"section"},{"location":"API/#Data-Structures","page":"API reference","title":"Data Structures","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"ModelConfig is the main concrete type of AbstractModelConfig.","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"ModelConfig\nModelConfig(::Function)","category":"page"},{"location":"API/#ClimateModels.ModelConfig","page":"API reference","title":"ClimateModels.ModelConfig","text":"struct ModelConfig <: AbstractModelConfig\n\nGeneric data structure for a model configuration. This serves as :\n\ndefault concrete type for AbstractModelConfig\nkeyword constructor for AbstractModelConfig\n\nmodel :: Union{Function,String,Pkg.Types.PackageSpec} = \"anonymous\"\nconfiguration :: Union{Function,String} = \"anonymous\"\ninputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\noutputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\nchannel :: Channel{Any} = Channel{Any}(10) \nfolder :: String = tempdir()\nID :: UUID = UUIDs.uuid4()\n\n\n\n\n\n","category":"type"},{"location":"API/#ClimateModels.ModelConfig-Tuple{Function}","page":"API reference","title":"ClimateModels.ModelConfig","text":"ModelConfig(func::Function,inputs::NamedTuple)\n\nSimplified constructor for case when model is a Function.\n\n\n\n\n\n","category":"method"},{"location":"API/","page":"API reference","title":"API reference","text":"PlutoConfig is also concrete type of AbstractModelConfig. It is provided to use Pluto.jl notebooks via the interface (see Notebooks Methods).","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"PlutoConfig","category":"page"},{"location":"API/#ClimateModels.PlutoConfig","page":"API reference","title":"ClimateModels.PlutoConfig","text":"struct PlutoConfig <: AbstractModelConfig\n\nGeneric data structure for a model configuration based on a Pluto notebook.\n\n\n\n\n\n","category":"type"},{"location":"API/#General-Methods","page":"API reference","title":"General Methods","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"setup(::ModelConfig)\nbuild\nlaunch\nlog","category":"page"},{"location":"API/#ClimateModels.setup-Tuple{ModelConfig}","page":"API reference","title":"ClimateModels.setup","text":"setup(x::AbstractModelConfig)\n\nDefaults to default_ClimateModelSetup(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nf=ClimateModels.RandomWalker\ntmp=ModelConfig(model=f)\nsetup(tmp)\n\n\n\n\n\n","category":"method"},{"location":"API/#ClimateModels.build","page":"API reference","title":"ClimateModels.build","text":"build(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nbuild(tmp)\n\nisa(tmp,AbstractModelConfig) # hide\n\n\n\n\n\n","category":"function"},{"location":"API/#ClimateModels.launch","page":"API reference","title":"ClimateModels.launch","text":"launch(x)\n\nDefaults to default_ClimateModelLaunch(x) which consists in take!(x) for AbstractModelConfig. Can be expected to be specialized for most  concrete types of AbstractModelConfig\n\nf=ClimateModels.RandomWalker\ntmp=ModelConfig(model=f)\nsetup(tmp)\nbuild(tmp)\nlaunch(tmp)\n\n\n\n\n\n","category":"function"},{"location":"API/#Base.log","page":"API reference","title":"Base.log","text":"log(x :: AbstractModelConfig)\n\nShow the record of git commits that have taken place in the log folder.\n\n\n\n\n\nlog(x :: AbstractModelConfig, commit_msg :: String; \n             fil=\"\", msg=\"\", init=false, prm=false)\n\nKeyword arguments work like this \n\ninit==true : create log subfolder, initialize git, and commit initial README.md\nprm==true  : add files found in input or tracked_parameters/ (if any) to git log\n!isempty(fil) : commit changes to file log/$(fil) with message commit_msg.   If log/$(fil) is unknown to git (i.e. commit errors out) then try adding log/$(fil) first. \n\nand are mutually exclusive (i.e., use only one at a time).\n\nMC=run(ModelConfig(ClimateModels.RandomWalker,(NS=100,)))\nMC.inputs[:NS]=200\nmsg=\"update tracked_parameters.toml (or skip if up to date)\"\nlog(MC,msg,fil=\"tracked_parameters.toml\",prm=true)\nlog(MC)\n\n\n\n\n\n","category":"function"},{"location":"API/","page":"API reference","title":"API reference","text":"Also provided : pathof, readdir, show, clean, and @ModelRun","category":"page"},{"location":"API/#notebook_methods","page":"API reference","title":"Notebook Methods","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"The setup method for PlutoConfig uses unroll to pre-process notebook codes.","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"setup(::PlutoConfig)\nnotebooks.update(::PlutoConfig)\nnotebooks.open(::PlutoConfig)\nnotebooks.unroll\nnotebooks.reroll","category":"page"},{"location":"API/#ClimateModels.setup-Tuple{PlutoConfig}","page":"API reference","title":"ClimateModels.setup","text":"setup(MC::PlutoConfig)\n\ncall default_ClimateModelSetup\ncall unroll\nadd notebook_launch to tasks\n\nMC1=PlutoConfig(model=\"examples/defaults.jl\")\nsetup(MC1)\nbuild(MC1)\nlaunch(MC1)\n\n\n\n\n\n","category":"method"},{"location":"API/#ClimateModels.notebooks.update-Tuple{PlutoConfig}","page":"API reference","title":"ClimateModels.notebooks.update","text":"update(MC::PlutoConfig)\n\nUpdate notebook dependencies (via unroll & reroll) and replace initial notebook file.\n\nupdate(PlutoConfig(model=\"examples/defaults.jl\"))\nrun(PlutoConfig(model=\"examples/defaults.jl\"))\n\n\n\n\n\n","category":"method"},{"location":"API/#Base.open-Tuple{PlutoConfig}","page":"API reference","title":"Base.open","text":"open(MC::PlutoConfig))\n\nOpen notebook in web-browser via Pluto. \n\nImportant note: this assumes that the Pluto server is already running, e.g. from Pluto.run(), at URL pluto_url (by default, \"http://localhost:1234/\", should work on a laptop or desktop).\n\nnotebooks.open(PlutoConfig(model=\"examples/defaults.jl\"))\n\n\n\n\n\n","category":"method"},{"location":"API/#ClimateModels.notebooks.unroll","page":"API reference","title":"ClimateModels.notebooks.unroll","text":"unroll(PlutoFile::String; EnvPath=\"\", ModuleFile=\"\")\n\nSplit up Pluto notebook file (PlutoFile) into main program (main.jl),  Project.toml, Manifest.toml, and CellOrder.txt.\n\nthese files are saved to folder p (EnvPath or a temporary folder by default)\nunroll returns output path p and main program file name\nunroll optionally copies companion file mf to p (if file mf exists)\ndefault mf is PlutoFile[1:end-3]*\"_module.jl\" unless ModuleFile is specified\nthe reroll function can be used to reassemble as a Pluto notebook \n\nUse case example: updating notebook dependencies\n\nusing Pkg\np,f=notebooks.unroll(\"CMIP6.jl\")\nPkg.activate(p)\nPkg.update()\nn=notebooks.reroll(p,f)\n\n\n\n\n\n","category":"function"},{"location":"API/#ClimateModels.notebooks.reroll","page":"API reference","title":"ClimateModels.notebooks.reroll","text":"reroll(p,f; PlutoFile=\"notebook.jl\")\n\nThe reroll function can be used to reassemble as a Pluto notebook that was previously unroll'ed.\n\nSee unroll documentation for a use case example.\n\n\n\n\n\n","category":"function"},{"location":"API/#More","page":"API reference","title":"More","text":"","category":"section"},{"location":"API/#Simplified-API","page":"API reference","title":"Simplified API","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"@ModelRun\nModelRun","category":"page"},{"location":"API/#ClimateModels.@ModelRun","page":"API reference","title":"ClimateModels.@ModelRun","text":"@ModelRun(func)\n\nMacro equivalent for run(ModelConfig(model=func)).\n\n\n\n\n\n@ModelRun(func::AbstractModelConfig)\n\nMacro equivalent for run(ModelConfig(model=func)).\n\n\n\n\n\n","category":"macro"},{"location":"API/#ClimateModels.ModelRun","page":"API reference","title":"ClimateModels.ModelRun","text":"ModelRun(x :: AbstractModelConfig)\n\nShorthand for x |> setup |> build |> launch\n\nReturns AbstractModelConfig as output.\n\n\n\n\n\n","category":"function"},{"location":"API/#Utility-Functions","page":"API reference","title":"Utility Functions","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"pathof\nreaddir\nshow\nclean","category":"page"},{"location":"API/#Base.pathof","page":"API reference","title":"Base.pathof","text":"pathof(x::AbstractModelConfig)\n\nReturns the run directory path for x ; i.e. joinpath(x.folder,string(x.ID))\n\n\n\n\n\npathof(x::AbstractModelConfig,subfolder::String)\n\nSame as pathof(joinpath(x,subfolder)).\n\n\n\n\n\n","category":"function"},{"location":"API/#Base.Filesystem.readdir","page":"API reference","title":"Base.Filesystem.readdir","text":"readdir(x::AbstractModelConfig)\n\nSame as readdir(pathof(x)).\n\n\n\n\n\nreaddir(x::AbstractModelConfig,subfolder::String)\n\nSame as readdir(joinpath(pathof(x),subfolder)).\n\n\n\n\n\n","category":"function"},{"location":"API/#Base.show","page":"API reference","title":"Base.show","text":"show(io::IO, z::AbstractModelConfig)\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nshow(tmp)\n\n\n\n\n\n","category":"function"},{"location":"API/#ClimateModels.clean","page":"API reference","title":"ClimateModels.clean","text":"clean(x :: AbstractModelConfig)\n\nCancel any remaining task (x.channel) and rm the run directory (pathof(x))\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nclean(tmp)\n\n\n\n\n\n","category":"function"},{"location":"API/#JuliaClimate/Notebooks","page":"API reference","title":"JuliaClimate/Notebooks","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"Convenience functions for notebooks documented in the JuliaClimate/Notebooks webpage.     ","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"notebooks.list\nnotebooks.download","category":"page"},{"location":"API/#ClimateModels.notebooks.list","page":"API reference","title":"ClimateModels.notebooks.list","text":"notebooks.list()\n\nList downloadable notebooks based on the JuliaClimate/Notebooks webpage.\n\nReturns a DataFrame with columns folder, file, and url. \n\n\n\n\n\n","category":"function"},{"location":"API/#ClimateModels.notebooks.download","page":"API reference","title":"ClimateModels.notebooks.download","text":"notebooks.download(path,nbs)\n\nDownload notebooks/files listed in nbs to path.\n\nIf nbs.file[i] is found at nbs.url[i] then download it to path/nbs.folder[i].  \nIf a second file is found at nbs.url[i][1:end-3]*\"_module.jl\" then we download it too.\n\nnbs=notebooks.list()\nnotebooks.download(tempdir(),nbs)\n\n\n\n\n\n","category":"function"},{"location":"API/#PkgDevConfig","page":"API reference","title":"PkgDevConfig","text":"","category":"section"},{"location":"API/","page":"API reference","title":"API reference","text":"In the package development mode, model is specified as a PackageSpec. ","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"PkgDevConfig","category":"page"},{"location":"API/#ClimateModels.PkgDevConfig","page":"API reference","title":"ClimateModels.PkgDevConfig","text":"PkgDevConfig(url::String,func::Function,inputs::NamedTuple)\n\nSimplified constructor for case when model is a url (PackageSpec).\n\n\n\n\n\n","category":"function"},{"location":"API/","page":"API reference","title":"API reference","text":"This leads setup to install the chosen package using Pkg.develop. This can be useful for developing a package or using an unregistered package in the context of ClimateModels.jl. ","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"There are two common cases: ","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"if configuration is left undefined then launch will run the package test suite using Pkg.test as in this example (code link)\nif configuration is provided as a Function then launch will call it as illustrated in the ShallowWaters.jl example (code link)","category":"page"},{"location":"API/","page":"API reference","title":"API reference","text":"note: Note\nAs an exercise, can you turn ShallowWaters.jl example into a normal user mode example?","category":"page"}]
}
