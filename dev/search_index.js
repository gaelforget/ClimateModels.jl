var documenterSearchIndex = {"docs":
[{"location":"functionalities/#manual","page":"Manual","title":"Manual / User Guide","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Here we document key functionalities offered in ClimateModels.jl","category":"page"},{"location":"functionalities/#Climate-Model-Interface","page":"Manual","title":"Climate Model Interface","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The climate model interface is based on a data structure (ModelConfig) and a series of methods like setup, build, and launch. The default assumption is that the model is either 1) a Julia package to be downloaded from a URL within setup using Pkg.develop, and run within launch using Pkg.test or 2) a Julia function to be called with a ModelConfig argument. ","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"A key point is that everything can be customized to e.g. 1) use a custom workflow instead of Pkg.test or 2) use popular models previously written in Fortran or C just as simply. The latter typically involves calling a build method to compile the model between setup and launch.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Leveraging the interface in real world application essentially means :","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"Define a concrete type ModelConfig (optional).\nCustomize interface methods to best suit your chosen model.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"At first, one can skip the type definition (#1 above) and may only want to customize setup and launch for #2 (see examples 1, 2, and 3).","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"However, the idea is that for routine use of e.g. a popular model the customized interface elements would be provided via a dedicated package (e.g. MITgcmTools.jl). These customized interfaces would thus be maintained independently by developers and users most familiar with each model.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"This approach is illustrated in the general circulation model example that uses the customized interface elements provided by MITgcmTools.jl for MITgcm.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"ModelConfig","category":"page"},{"location":"functionalities/#ClimateModels.ModelConfig","page":"Manual","title":"ClimateModels.ModelConfig","text":"struct ModelConfig <: AbstractModelConfig\n\nmodel :: Union{Function,String,Pkg.Types.PackageSpec} = \"anonymous\"\nconfiguration :: Union{Function,String} = \"anonymous\"\noptions :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\ninputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\noutputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\nstatus :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()\nchannel :: Channel{Any} = Channel{Any}(10) \nfolder :: String = tempdir()\nID :: UUID = UUIDs.uuid4()\n\n\n\n\n\n","category":"type"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"setup\nbuild\ncompile\nclean\nlaunch\nmonitor","category":"page"},{"location":"functionalities/#ClimateModels.setup","page":"Manual","title":"ClimateModels.setup","text":"setup(x)\n\nDefaults to default_ClimateModelSetup(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Suppressor, OrderedCollections\ninputs=OrderedDict(); inputs[\"NS\"]=1000;\ntmp=ModelConfig(model=ClimateModels.RandomWalker,inputs=inputs)\nsetup(tmp)\n\nbuild(tmp)\nlaunch(tmp)\ngit_log_fil(tmp,\"tracked_parameters.toml\",\"update tracked_parameters.toml (or skip)\")\n@suppress git_log_show(tmp)\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.build","page":"Manual","title":"ClimateModels.build","text":"build(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Pkg\ntmp0=PackageSpec(url=\"https://github.com/JuliaOcean/AirSeaFluxes.jl\")\ntmp=ModelConfig(model=tmp0,configuration=\"anonymous\")\nsetup(tmp)\nbuild(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.compile","page":"Manual","title":"ClimateModels.compile","text":"compile(x)\n\nDefaults to default_ClimateModelBuild(x). Can be expected to be  specialized for most concrete types of AbstractModelConfig\n\nusing ClimateModels, Pkg\ntmp0=PackageSpec(url=\"https://github.com/JuliaOcean/AirSeaFluxes.jl\")\ntmp=ModelConfig(model=tmp0)\nsetup(tmp)\ncompile(tmp)\n\nisa(tmp,AbstractModelConfig)\n\n# output\n\ntrue\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.clean","page":"Manual","title":"ClimateModels.clean","text":"clean(x :: AbstractModelConfig)\n\nCancel any remaining task (x.channel) and clean the run directory (via rm)\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nclean(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.launch","page":"Manual","title":"ClimateModels.launch","text":"launch(x)\n\nDefaults to default_ClimateModelLaunch(x) which consists in take!(x) for AbstractModelConfig. Can be expected to be specialized for most  concrete types of AbstractModelConfig\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nlaunch(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.monitor","page":"Manual","title":"ClimateModels.monitor","text":"monitor(x)\n\nShow x.status[end] by default.\n\ntmp=ModelConfig(model=ClimateModels.RandomWalker)\nsetup(tmp)\nmonitor(tmp)\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Git-Support","page":"Manual","title":"Git Support","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"The setup method normally calls git_log_init to set up a temporary run folder with a git enabled subfolder called log. This allows for recording each workflow step, using functions listed here for example.","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"git_log_init\ngit_log_msg\ngit_log_fil\ngit_log_prm\ngit_log_show","category":"page"},{"location":"functionalities/#ClimateModels.git_log_init","page":"Manual","title":"ClimateModels.git_log_init","text":"git_log_init(x :: AbstractModelConfig)\n\nCreate log subfolder, initialize git, and commit initial README.md\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.git_log_msg","page":"Manual","title":"ClimateModels.git_log_msg","text":"git_log_msg(x :: AbstractModelConfig,msg,commit_msg)\n\nAdd message msg to the log/README.md file and git commit.\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.git_log_fil","page":"Manual","title":"ClimateModels.git_log_fil","text":"git_log_fil(x :: AbstractModelConfig,fil,commit_msg)\n\nCommit changes to file log/fil with message commit_msg. If log/fil is  unknown to git (i.e. commit errors out) then try adding log/fil first. \n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.git_log_prm","page":"Manual","title":"ClimateModels.git_log_prm","text":"git_log_prm(x :: AbstractModelConfig,msg,commit_msg)\n\nAdd files found in tracked_parameters/ (if any) to git log.\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#ClimateModels.git_log_show","page":"Manual","title":"ClimateModels.git_log_show","text":"git_log_show(x :: AbstractModelConfig)\n\nShow git log.\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#Cloud-Support","page":"Manual","title":"Cloud Support","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"There are various ways that model output gets archived, distributed, and retrieved from the internet. In some cases downloading data can be the most convenient approach. In others it can be more advantageous to compute in the cloud and only download final results for plotting (e.g. cmip).","category":"page"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"cmip","category":"page"},{"location":"functionalities/#ClimateModels.cmip","page":"Manual","title":"ClimateModels.cmip","text":"cmip(institution_id,source_id,variable_id)\n\nAccess CMIP6 climate model archive (https://bit.ly/2WiWmoh) via AWS.jl and Zarr.jl and compute (1) time mean global map and (2) time evolving global mean.\n\nThis example was partly inspired by @rabernat 's https://bit.ly/2VRMgvl notebook\n\nusing ClimateModels\n(mm,gm,meta)=cmip()\nnm=meta[\"long_name\"]*\" in \"*meta[\"units\"]\n\nusing Plots\nheatmap(mm[\"lon\"], mm[\"lat\"], transpose(mm[\"m\"]),\n        title=nm*\" (time mean)\")\nplot(gm[\"t\"][1:12:end],gm[\"y\"][1:12:end],xlabel=\"time\",ylabel=nm,\n     title=meta[\"institution_id\"]*\" (global mean, month by month)\")\ndisplay.([plot!(gm[\"t\"][i:12:end],gm[\"y\"][i:12:end], leg = false) for i in 2:12])\n\n\n\n\n\n\n\n","category":"function"},{"location":"functionalities/#API-Reference","page":"Manual","title":"API Reference","text":"","category":"section"},{"location":"functionalities/","page":"Manual","title":"Manual","text":"","category":"page"},{"location":"examples/#examples","page":"Examples","title":"Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"The examples fall, broadly, into two categories.","category":"page"},{"location":"examples/#Workflows-That-Run-Models","page":"Examples","title":"Workflows That Run Models","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"basic behavior ➭ download / url\nrandom walk model (0D) ➭ download / url\nShallowWaters.jl model (2D) ➭ download / url\nHector global climate model ➭ download / url\nSPEEDY atmosphere model (3D) ➭ download / url\nMITgcm general circulation model ➭ download / url","category":"page"},{"location":"examples/#Workflows-That-Replay-Model-Outputs","page":"Examples","title":"Workflows That Replay Model Outputs","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"CMIP6 model output ➭ download / url","category":"page"},{"location":"examples/#examples-running","page":"Examples","title":"Running The Examples","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Any example found in the online documentation is most easily run using Pluto.jl. Just copy the corresponding download / url link (see above) and paste into the Pluto.jl interface.","category":"page"},{"location":"examples/","page":"Examples","title":"Examples","text":"The notebooks can also be run the command line (e.g., julia -e 'include(\"defaults.jl\"). In that case, unlike with Pluto.jl, user needs to Pkg.add packages separately.","category":"page"},{"location":"examples/#System-Requirements","page":"Examples","title":"System Requirements","text":"","category":"section"},{"location":"examples/","page":"Examples","title":"Examples","text":"Some models may only support linux based environments (i.e. linux and macos). Running examples which rely on a fortran compiler (gfortran) and / or netcdf libraries (libnetcdf-dev,libnetcdff-dev) will require user to e.g. install gfortran). All requirements should be preinstalled in this mybinder.org (a linux instance in the cloud) where one can just open a terminal window to try things out at the command line.","category":"page"},{"location":"#ClimateModels.jl","page":"Home","title":"ClimateModels.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using git, is included to allow for workflow documentation and reproducibility.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The JuliaCon 2021 Presentation provides a brief (8') overview and demo of the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Please refer to Examples and Manual  for more detail. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Note\nThis package is still in early development stage. Breaking changes remain likely.","category":"page"},{"location":"#Package-Features","page":"Home","title":"Package Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Climate Model Interface\nTracked Worklow Framework\nCloud + On-Premise File Support","category":"page"},{"location":"#main-contents","page":"Home","title":"Table Of Contents","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"functionalities.md\",\n    \"examples.md\",\n]\nDepth = 2","category":"page"},{"location":"#JuliaCon-2021-Presentation","page":"Home","title":"JuliaCon 2021 Presentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Presentation recording\nPresentation notebook (html)\nPresentation notebook (jl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Screen Shot 2021-08-31 at 2 25 04 PM)","category":"page"}]
}
