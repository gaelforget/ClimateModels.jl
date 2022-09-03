
# [API Reference](@id api)

## Data Structure

```@docs
ModelConfig
ModelConfig(::Function)
```

## Methods

```@docs
setup(::ModelConfig)
build
launch
run
log
```

## Utilities

```@docs
pathof
readdir
show
clean
```

## Notebooks

Here are convenience functions to use [Pluto.jl](https://github.com/fonsp/Pluto.jl/wiki) notebooks. 

```@docs
setup(::ModelConfig,::String)
notebooks.unroll
notebooks.list
notebooks.download
notebooks.open
```

## PkgDevConfig

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
