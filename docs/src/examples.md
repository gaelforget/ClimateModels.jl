# [Examples](@id examples)

The [random walk model](RandomWalker.html) example is a good place to start. It is also presented in greater detail in the [Climate Model Interface](@ref) section to further illustrate how things work.

The examples generally fall into two categories : [Workflows That Run Models](@ref) and [Workflows That Replay Models](@ref)' output. The distinction is not strict though, as one model often depends for its input on another model's output, and so forth.

[Trying Out The Examples](@ref) is for users who'd like to run or experiment with the included models. In [User Manual](@ref manual), the [Climate Model Interface](@ref) section then outlines simple ways that models can be added to the framework. The examples presented here were built in this fashion.

In the list below, the core language or file format is indicated for each model. The models are sorted, more or less, by increasing dimensionality / _problem size_. 

The example set, taken collectively, demonstrates that the [Climate Model Interface](@ref) is applicable to a wide range of models, computational languages, and problem sizes.

## Workflows That Run Models

- [random walk model](RandomWalker.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl)
- [ShallowWaters.jl model](ShallowWaters.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl)
- [Oceananigans.jl model](Oceananigans.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl)
- [Hector global climate model](Hector.html) (C++) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl)
- [FaIR global climate model](FaIR.html) (Python) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl)
- [SPEEDY atmosphere model (3D)](Speedy.html) (Fortran90) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl)
- [MITgcm general circulation model](MITgcm.html) (Fortran) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl)

## Workflows That Replay Models

- [IPCC report 2021](IPCC.html) (NetCDF, CSV) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl)
- [CMIP6 model output](CMIP6.html) (Zarr) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl)
- [ECMWF IFS 1km](https://gaelforget.github.io/ClimateModels.jl/v0.2.6/examples/IFS1km_notebook.html) (NetCDF) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IFS1km_notebook.jl)

## Trying Out The Examples

The examples are often most easy to run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). See [these directions](https://juliaclimate.github.io/Notebooks/#directions) for how to do this in the cloud on your own computer.

You can also run the notebooks from the _shell command line_ / _terminal window_ (e.g., `julia -e 'include("RandomWalker.jl")'` or `julia RandomWalker.jl`). 

!!! tip
    If the shell CLI or the julia REPL is used, however, one may need to `Pkg.add` a few packages beforehand. In contrast, `Pluto.jl` does this automatically.

#### _System Requirements_

The pure Julia examples should immediately work on any laptop or cloud computing service. 

Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (`gfortran`) and / or on Netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require that you e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran). 

!!! tip
    All requirements should be preinstalled in the [JuliaClimate notebooks binder](https://gesis.mybinder.org/v2/gh/JuliaClimate/GlobalOceanNotebooks/HEAD?urlpath=lab) (see the [JuliaClimate notebooks page](https://juliaclimate.github.io/Notebooks/#directions) for detail and directions).

## Creating Your Own

Please refer to the [User Manual](@ref manual) section, and [Climate Model Interface](@ref) in particular, for more on this.

