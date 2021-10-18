# [Examples](@id examples)

The examples fall, broadly, into two categories : _Workflows That Run Models_ and _Workflows That Replay Model Outputs_. The distinction is not strict though, as models often depend on other models output.

In the list below, the core language of each model is indicated, and models are more or less sorted by increasing dimensionality (_problem size_). It should be highlighted that the `ClimateModels.jl` interface is applicable to a wide range of models and computational languages.

#### Workflows That Run Models

- [basic behavior](defaults.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl), [download link](defaults.jl)
- [random walk model](RandomWalker.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/RandomWalker.jl), [download link](RandomWalker.jl)
- [ShallowWaters.jl model](ShallowWaters.html) (Julia) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl), [download link](ShallowWaters.jl)
- [Hector global climate model](Hector.html) (C++) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Hector.jl), [download link](Hector.jl)
- [FaIR global climate model](FaIR.html) (Python) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/FaIR.jl), [download link](FaIR.jl)
- [SPEEDY atmosphere model (3D)](Speedy.html) (Fortran90) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/Speedy.jl), [download link](Speedy.jl)
- [MITgcm general circulation model](MITgcm.html) (Fortran) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/MITgcm.jl), [download link](MITgcm.jl)

#### Workflows That Replay Model Outputs

- [CMIP6 model output](CMIP6.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/CMIP6.jl), [download link](CMIP6.jl)
- [IPCC report 2021](IPCC.html) ➭ [code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/IPCC.jl), [download link](IPCC.jl)

## [Running The Examples](@id examples-running)

Any example found in the online documentation is most easily run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Just copy the corresponding `download / url` link (see above) and paste into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto).

The notebooks can also be run the command line (e.g., `julia -e 'include("defaults.jl")`. In that case, unlike with `Pluto.jl`, user needs to `Pkg.add` packages separately.

## System Requirements

Some models may only support linux based environments (i.e. linux and macos). Running examples which rely on a fortran compiler (`gfortran`) and / or netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require user to e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran)). All requirements should be preinstalled in [this mybinder.org](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab) instance and [the JuliaClimate sandbox](https://juliaclimate.github.io/GlobalOceanNotebooks/).


