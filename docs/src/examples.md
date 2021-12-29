# [Examples](@id examples)

The examples fall, broadly, into two categories : [Workflows That Run Models](@ref) and [Workflows That Replay Models](@ref)' output. The distinction is not strict though, as one model often depend on another model's output.

In the examples below, the core language of each model is indicated, and models are more or less sorted by increasing dimensionality / _problem size_. As demonstrated, the `ClimateModels.jl` interface is applicable to a wide range of models, computational languages, and problem sizes.

[Trying Out The Examples](@ref) provides concrete directions for users who'd like to run, modify, or experiment with the notebooks. [Doing It Yourself](@ref) outlines several simple ways that models can be added to the framework. The various examples presented here were built in this fashion.

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

## [Trying Out The Examples](@id examples-running)

Any example found in the online documentation is most easily run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Just copy the corresponding `download / url` link (see above) and paste into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto).

The notebooks can also be run the command line (e.g., `julia RandomWalker.jl`. In that case, unlike with `Pluto.jl`, user needs to `Pkg.add` packages separately.

### System Requirements

Some models may only support linux based environments (i.e. linux and macos). Running examples which rely on a fortran compiler (`gfortran`) and / or netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require user to e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran)). All requirements should be preinstalled in [this mybinder.org](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab) instance and [the JuliaClimate sandbox](https://juliaclimate.github.io/GlobalOceanNotebooks/).

## Doing It Yourself

_tentative sketch:_

- the case of a function
- the full interface; create a concrete type
- the case of pkgSpec + function
- the case of pkgSpec alone [default behavior](defaults.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl), [download link](defaults.jl)
