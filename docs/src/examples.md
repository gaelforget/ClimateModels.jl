# [Examples](@id examples)

The [random walk model](RandomWalker.html) example is a good place to start. It is also presented in greater detail in the [Climate Model Interface](@ref) section to further illustrate how things work.

The examples generally fall into two categories : [Workflows That Run Models](@ref) and [Workflows That Replay Models](@ref)' output. The distinction is not strict though, as one model often depends for its input on another model's output. 

The [Trying Out The Examples](@ref) section is for users who'd like to run, modify, or experiment with the notebooks. The [Doing It Yourself](@ref) section then outlines simple ways that models can be added to the framework. The examples presented here were built in this fashion.

In the example list below, the core language of each model is indicated and the models are sorted, more or less, by increasing dimensionality / _problem size_. The example set, collectively, demonstrates that the [Climate Model Interface](@ref) is applicable to a wide range of models, computational languages, and problem sizes.

## Workflows That Run Models

- [random walk model](RandomWalker.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl), [download link](RandomWalker.jl)
- [ShallowWaters.jl model](ShallowWaters.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl), [download link](ShallowWaters.jl)
- [Oceananigans.jl model](Oceananigans.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Oceananigans.jl), [download link](Oceananigans.jl)
- [Hector global climate model](Hector.html) (C++) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl), [download link](Hector.jl)
- [FaIR global climate model](FaIR.html) (Python) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl), [download link](FaIR.jl)
- [SPEEDY atmosphere model (3D)](Speedy.html) (Fortran90) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl), [download link](Speedy.jl)
- [MITgcm general circulation model](MITgcm.html) (Fortran) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl), [download link](MITgcm.jl)

## Workflows That Replay Models

- [CMIP6 model output](CMIP6.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl), [download link](CMIP6.jl)
- [IPCC report 2021](IPCC.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl), [download link](IPCC.jl)

## Trying Out The Examples

The examples are most easily run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). To do it this way, one just needs to copy a `code link` provided above and paste this URL into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto).

One can also run the notebooks (e.g., `RandomWalker.jl`) either (1) by calling `julia RandomWalker.jl` at the _shell command line_ or (2) by calling `include("RandomWalker.jl")` at the _julia REPL prompt_. 

If the shell CLI or the julia REPL is used, however, one needs to download the notebook file and potentially `Pkg.add` a few packages beforehand (`Pluto.jl` does this automatically).

### System Requirements

The pure julia examples should immediately work on any laptop or cloud computing service. 

Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e., Linux and macOS). However, those that rely on a Fortran compiler (`gfortran`) and / or on Netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require that you e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran). 

All requirements should be preinstalled in this [cloud computer](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab) (see the [JuliaClimate notebooks page](https://juliaclimate.github.io/GlobalOceanNotebooks/) for detail).

## Doing It Yourself

One can separate out use cases based on the type of `model` variable specified in defining a [`ModelConfig`](@ref) :

- _normal user mode_ is when `model` is a `String` or a `Function`
- _package developer mode_ is when `model` is a `Pkg.Types.PackageSpec`

Most users likely will use only the former and not the latter.

### 1. normal user mode

- the case of a function
- the full interface; create a concrete type
- parameters, log calls, trial and error, output files, etc

### 2. package developer mode

The defining feature of this approach is that the `PackageSpec`   specification of `model` makes [`setup`](@ref) install the chosen package using `Pkg.develop`. This allows for developing a package or using an unregistered package in the context of `ClimateModels.jl`. There are two cases: 

- if `configuration` is left undefined then `launch` will run the package test suite using `Pkg.test` as in [this example](defaults.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl), [download link](defaults.jl))
- if `configuration` is provided as a `Function` then `launch` will call it as illustrated in the [ShallowWaters.jl model](ShallowWaters.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl), [download link](ShallowWaters.jl))
 
