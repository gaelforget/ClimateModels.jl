# [Examples](@id examples)

The examples fall, broadly, into two categories : [Workflows That Run Models](@ref) and [Workflows That Replay Models](@ref)' output. The distinction is not strict though, as one model often depends on another model's output. The _random walk model_ example is presented in greater detail in the [Climate Model Interface](@ref) section to further illustrate how things work.

[Trying Out The Examples](@ref) provides directions for users who'd like to run, modify, or experiment with the notebooks. [Doing It Yourself](@ref) outlines simple ways that models can be added to the framework. The examples presented here were built in this fashion.

In the list below, the core language of each model is indicated and the models are sorted, more or less, by increasing dimensionality / _problem size_. The example set, collectively, demonstrates that the [Climate Model Interface](@ref) is applicable to a wide range of models, computational languages, and problem sizes.

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

The examples are most easily run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). To this end, one just needs to copy the corresponding `code link` (see above) and paste this URL into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto).

One can also run the notebooks, e.g. `RandomWalker.jl`, either (1) by calling `julia RandomWalker.jl` at the _shell command line_ or (2) by calling `include("RandomWalker.jl")` at the _julia REPL prompt_. 

If the shell CLI or the julia REPL is used, however, one needs to download the notebook file and potentially `Pkg.add` a few packages beforehand (`Pluto.jl` does thiss automatically).

### System Requirements

The pure julia examples should immediately work on any laptop or cloud computing service. 

Examples that involve Fortran, Python, or C++ should work in all linux based environments (i.e. linux and macos). However, for example those that rely on a Fortran compiler (`gfortran`) and / or on Netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran)). 

All requirements should be preinstalled in this [cloud computer](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab) (see [the JuliaClimate page](https://juliaclimate.github.io/GlobalOceanNotebooks/) for detail).

## Doing It Yourself

_tentative sketch:_

### 1. normal user mode

- the case of a function
- the full interface; create a concrete type
- parameters, log calls, trial and error, output files, etc

### 2. package developer mode

- the case of pkgSpec + function; package in development
- the case of pkgSpec alone [default behavior](defaults.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl), [download link](defaults.jl)
