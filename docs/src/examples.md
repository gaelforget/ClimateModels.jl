# [Examples](@id examples)

The examples fall, broadly, into two categories.

#### Workflows That Run Models

- [basic behavior](defaults.html) (---> [notebook url](defaults.jl))
- [random walk model (0D)](RandomWalker.html) (---> [notebook url](RandomWalker.jl))
- [Hector global climate model](Hector.html) (---> [notebook url](Hector.jl))
- [ShallowWaters.jl model (2D)](ShallowWaters.html) (---> [notebook url](ShallowWaters.jl))
- [SPEEDY atmosphere model (3D)](Speedy.html) (---> [notebook url](Speedy.jl))
- [MITgcm general circulation model](MITgcm.html) (---> [notebook url](MITgcm.jl))

#### Workflows That Replay Model Outputs

- [CMIP6 model output](CMIP6.html) (---> [notebook url](CMIP6.jl))

## [Running The Examples](@id examples-running)

Any example found in the online documentation is most easily run using [Pluto.jl](https://github.com/fonsp/Pluto.jl). Just copy the corresponding notebook url (linked above) and paste into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto).

The notebooks can also be run the command line (e.g., `julia -e 'include("defaults.jl")`. In that case, unlike with `Pluto.jl`, user needs to `Pkg.add` packages separately.

## System Requirements

Some models may only support linux based environments (i.e. linux and macos). Running examples which rely on a fortran compiler (`gfortran`) and / or netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require user to e.g. [install gfortran](https://fortran-lang.org/learn/os_setup/install_gfortran)). All requirements should be preinstalled in [this mybinder.org](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab) (a linux instance in the cloud) where one can just open a terminal window to try things out at the command line.


