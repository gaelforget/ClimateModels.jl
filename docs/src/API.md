
# [API Reference](@id api)

## Data Structures

- `ModelConfig` is the main concrete type of `AbstractModelConfig`; used in the [examples](@ref examples).
- `PlutoConfig` let's us ingest any [Pluto.jl](https://github.com/fonsp/Pluto.jl/wiki) notebook easily via `ClimateModels`' [Notebooks Methods](@ref notebook_methods).

```@docs
ModelConfig
ModelConfig(::Function)
PlutoConfig
```

## General Methods

```@docs
setup(::ModelConfig)
build
launch
log
```

Also provided : [`pathof`](@ref), [`joinpath`](@ref), [`cd`](@ref), [`readdir`](@ref), [`show`](@ref), [`clean`](@ref), and [`@ModelRun`](@ref)

## [Notebook Methods](@id notebook_methods)

```@docs
setup(::PlutoConfig)
update(::PlutoConfig)
notebooks.open(::PlutoConfig)
```

!!! note
    `setup` and `update` use `unroll` and `reroll` internally to process notebooks.

## More

### Simplified API

```@docs
ModelRun
@ModelRun
```

### Utility Functions

```@docs
pathof
joinpath
cd
readdir
show
clean
```

### JuliaClimate/Notebooks

Convenience functions for notebooks documented in the `JuliaClimate/Notebooks` webpage.     

```@docs
notebooks.list
notebooks.download
```

### PkgDevConfig

In the package development mode, `model` is specified as a `PackageSpec`. 

```@docs
PkgDevConfig
```

This leads [`setup`](@ref) to install the chosen package using `Pkg.develop`. This can be useful for developing a package or using an unregistered package in the context of `ClimateModels.jl`. 

There are two common cases: 

- if `configuration` is left undefined then `launch` will run the package test suite using `Pkg.test` as in [this example](../examples/defaults.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl))
- if `configuration` is provided as a `Function` then `launch` will call it as illustrated in the [ShallowWaters.jl example](../examples/ShallowWaters.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl))

!!! note 
    As an exercise, can you turn [ShallowWaters.jl example](../examples/ShallowWaters.html) into a _normal user mode_ example?
