# [Examples](@id examples)

A good place to start is the [random walk model](RandomWalker.html) example, which is used in the [Climate Model Interface](@ref) documentation. The other examples, below, fall more or less into two categories : 

- [Workflows That Run Models](@ref run_model_examples)
- [Workflows That Replay Models](@ref replay_model_examples)

The main language and file format of the model examples vary. The notebook collection shows how [Climate Model Interface](@ref run_model_examples) is easily to a wide range of model types, programming languages, and problem sizes.

In [User Manual](@ref manual), the [Climate Model Interface](@ref) section outlines several simple ways that models can be added to the framework. The examples presented here were built in this fashion.

[Trying Out The Examples](@ref) is geared toward users who may want to experiment with models.    

```@docs
RandomWalker
```

## [Workflows That Run Models](@id run_model_examples)

- [Random Walk model](RandomWalker.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl)
- [ShallowWaters.jl model](ShallowWaters.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl)
- [Oceananigans.jl model](Oceananigans.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl)
- [Hector global climate model](Hector.html) (C++) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl)
- [FaIR global climate model](FaIR.html) (Python) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl)
- [SPEEDY atmosphere model](Speedy.html) (Fortran90) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl)
- [MITgcm general circulation model](MITgcm.html) (Fortran) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl)

## [Workflows That Replay Models](@id replay_model_examples)

- [IPCC report 2021](IPCC.html) (NetCDF, CSV) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)
- [CMIP6 model output](CMIP6.html) (Zarr) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)
- [ECMWF IFS 1km](http://www.gaelforget.net/notebooks/IFS1km_notebook.html) (NetCDF) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IFS1km.jl)
- [ECCO version 4](https://JuliaOcean.github.io/Climatology.jl/dev/examples/ECCO_standard_plots.html) (NetCDF) ➭ [code link](https://raw.githubusercontent.com/juliaocean/Climatology.jl/master/examples/ECCO/ECCO_standard_plots.jl)
- [Pathway Simulations](https://gaelforget.github.io/MITgcm.jl/dev/examples/HS94_particles.html) (binary, jld2) ➭ [code link](https://raw.githubusercontent.com/gaelforget/MITgcm.jl/master/examples/HS94_particles.jl)


## JuliaCon 2021 Presentation

- [notebook view (html)](ClimateModelsJuliaCon2021.html)
- [notebook source (jl)](https://github.com/gaelforget/ClimateModels.jl/blob/master/docs/src/ClimateModelsJuliaCon2021.jl)
- [video recording (mp4)](https://youtu.be/XR5hKCja0uw)

[![Screen Shot 2021-08-31 at 2 25 04 PM](https://user-images.githubusercontent.com/20276764/131556274-48f3df13-0608-4cd0-acf9-c3e29894a32c.png)](https://youtu.be/XR5hKCja0uw)

## Trying Out The Examples

The examples can be most easy to run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). The [JuliaClimate/Notebooks](https://juliaclimate.github.io/Notebooks) webpage links to free cloud resources and directions to run notebooks on your own computer.

Alternatively, you can create a `PlutoConfig` to extract dependencies from the notebook, and operate the notebook via the stanndard methods -- `setup`, `build`, and `launch`.

Or, You can run the notebooks directly from the command line interface (`CLI`) in a terminal window or in the Julia `REPL`. In this case, one may need to add packages beforehand (see `Pkg.add`). 

`include("RandomWalker.jl")`

### Creating Your Own

Please refer to the [User Manual](@ref manual) section, and [Climate Model Interface](@ref) in particular, for more on this. 

A good way to start can be by 1. converting a modeling workflow (setup, build, launch) into a Pluto notebook; 2. then using the [PlutoConfig](@ref) data structure.

### _System Requirements_

The pure Julia examples should immediately work on any laptop or cloud computing service. 

Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (`gfortran`) and / or on Netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require that you e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran). 

!!! tip
    All requirements should be preinstalled in the [JuliaClimate notebooks binder](https://gesis.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab) (see the [JuliaClimate notebooks page](https://juliaclimate.github.io/Notebooks/#directions) for detail and directions).


