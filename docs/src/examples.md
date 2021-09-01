# [Example Guide](@id examples)

The next sections are examples which broadly fall into two categories.

### Workflows That Run Models

- [random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/generated/RandomWalker/)
- [Hector global climate model](https://gaelforget.github.io/ClimateModels.jl/dev/generated/Hector/)
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/generated/ShallowWaters/)
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/generated/Speedy/)
- [MITgcm general circulation model](https://gaelforget.github.io/ClimateModels.jl/dev/generated/MITgcm/)

### Workflows Using Remote Files

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/generated/CMIP6/)

## [Running The Examples](@id examples-running)

An example found in the online documentation can be run as follows:

```
git clone https://github.com/gaelforget/ClimateModels.jl
cd ClimateModels.jl

julia --project=docs/ 'using Pkg; Pkg.instantiate()'
julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd()))'

julia --project=docs/ -e 'include("examples/defaults.jl")'
```

The example file name (`defaults.jl` here) can readily be replaced with another one from `examples/` to run a different example. However, running examples which rely on a fortran compiler (`gfortran`) and / or netcdf libraries (`libnetcdf-dev`,`libnetcdff-dev`) will require that those have been pre-installed. It should also be noted that some models may only support linux based environments (i.e. linux and macos).

All requirements are preinstalled in the following <https://mybinder.org> cloud instance, where one can just open a terminal window and run the above commands. All examples have been run in this fashion.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gaelforget/ClimateModels.jl/HEAD?urlpath=lab)

## [Outline Of The Examples](@id examples-outline)

```@contents
Pages = [
    "generated/defaults.md",
    "generated/RandomWalker.md",
    "generated/Hector.md",
    "generated/ShallowWaters.md",
    "generated/MITgcm.md",
    "generated/Speedy.md",
    "generated/CMIP6.md",
]
Depth = 2
```
