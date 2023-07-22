
# [API Reference](@id api)

## Data Structures

`ModelConfig` is the main concrete type of `AbstractModelConfig`.

```@docs
ModelConfig
ModelConfig(::Function)
```

`PlutoConfig` is also concrete type of `AbstractModelConfig`. It is provided to use [Pluto.jl](https://github.com/fonsp/Pluto.jl/wiki) notebooks via the interface (see [Notebooks Methods](@ref notebook_methods)).

```@docs
PlutoConfig
```

## Default Methods

```@docs
setup(::ModelConfig)
build
launch
log
```

## [Notebook Methods](@id notebook_methods)

The `setup` method for `PlutoConfig` uses `unroll` to pre-process notebook codes.

```@docs
setup(::PlutoConfig)
notebooks.update(::PlutoConfig)
notebooks.unroll
notebooks.reroll
notebooks.open(::PlutoConfig)
```

## Other Methods

### Simplified API

```@docs
@ModelRun
ModelRun
```

### Utility Functions

```@docs
pathof
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
