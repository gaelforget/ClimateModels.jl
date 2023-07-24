# [Examples](@id examples)

A good place to start is the [random walk model](RandomWalker.html) example. It is also presented in greater detail in the [Climate Model Interface](@ref) section to further illustrate how things work.

```@docs
RandomWalker
```

The examples may fall into two categories : 

- [Workflows That Run Models](@ref run_model_examples)
- [Workflows That Replay Models](@ref replay_model_examples)

!!! note
    One model may get input from another model's output.

Examples are listed below. For each model, the core language or file format is indicated. Models are sorted by increasing problem size. 

The notebook collection illustrates that the [Climate Model Interface](@ref run_model_examples) is applicable to a wide range of model types, programming languages, and problem sizes.

In [User Manual](@ref manual), the [Climate Model Interface](@ref) section outlines several simple ways that models can be added to the framework. The examples presented here were built in this fashion.

[Trying Out The Examples](@ref) is geared toward users who may want to run or experiment with models.    

## [Workflows That Run Models](@id run_model_examples)

- [Random Walk model](RandomWalker.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl)
- [ShallowWaters.jl model](ShallowWaters.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl)
- [Oceananigans.jl model](http://www.gaelforget.net/notebooks/Oceananigans.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl)
- [Hector global climate model](http://www.gaelforget.net/notebooks/Hector.html) (C++) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl)
- [FaIR global climate model](http://www.gaelforget.net/notebooks/FaIR.html) (Python) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl)
- [SPEEDY atmosphere model](Speedy.html) (Fortran90) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl)
- [MITgcm general circulation model](MITgcm.html) (Fortran) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl)

## [Workflows That Replay Models](@id replay_model_examples)

- [IPCC report 2021](IPCC.html) (NetCDF, CSV) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)
- [CMIP6 model output](CMIP6.html) (Zarr) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)
- [ECMWF IFS 1km](http://www.gaelforget.net/notebooks/IFS1km_notebook.html) (NetCDF) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IFS1km.jl)
- [ECCO version 4](https://JuliaOcean.github.io/OceanStateEstimation.jl/dev/examples/ECCO_standard_plots.html) (NetCDF) ➭ [code link](https://raw.githubusercontent.com/gaelforget/OceanStateEstimation.jl/master/examples/ECCO/ECCO_standard_plots.jl)
- [Pathway Simulations](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) (binary, jld2) ➭ [code link](https://raw.githubusercontent.com/gaelforget/MITgcmTools.jl/master/examples/HS94_particles.jl)

## Trying or Creating Examples

The examples can be most easy to run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). See [these directions](https://juliaclimate.github.io/Notebooks/#directions) for how to do this in the cloud on your own computer.

Alternatively, you can create a `PlutoConfig` to extract dependencies from the notebook, and operate the notebook via the stanndard methods -- `setup`, `build`, and `launch`.

Or, You can run the notebooks directly from the command line interface (`CLI`) in a terminal window or in the Julia `REPL`. In this case, one may need to add packages beforehand (see `Pkg.add`). 

`include("RandomWalker.jl")`

### Creating Your Own

Please refer to the [User Manual](@ref manual) section, and [Climate Model Interface](@ref) in particular, for more on this. 

!!! tip
    A good way to start can be by 1. converting a modeling workflow (setup, build, launch) into a Pluto notebook; 2. then using the [notebooks setup](@ref notebook_methods) method.

### _System Requirements_

The pure Julia examples should immediately work on any laptop or cloud computing service. 

Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (`gfortran`) and / or on Netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require that you e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran). 

!!! tip
    All requirements should be preinstalled in the [JuliaClimate notebooks binder](https://gesis.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab) (see the [JuliaClimate notebooks page](https://juliaclimate.github.io/Notebooks/#directions) for detail and directions).


