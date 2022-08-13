# [User Manual](@id manual)

```@setup main
using ClimateModels
```

Here we document key functionalities offered in `ClimateModels.jl`

- Climate Model Interface
- Tracked Worklow Framework
- Cloud + On-Premise File Support

## Climate Model Interface

The interface ties the [`ModelConfig`](@ref) data structure with methods like [`setup`](@ref), [`build`](@ref), and [`launch`](@ref). 

```@example main
f=ClimateModels.RandomWalker
MC=ModelConfig(model=f)
```

The typical sequence is shown below. Here `f` is a function that receives a `ModelConfig` as its only input argument. It gets called via [`launch`](@ref) and generates a file called `RandomWalker.csv`. 

```@example main
setup(MC)
build(MC)
launch(MC)
```

For convenience, [`run`](@ref) executes all three steps at once. Using the simplified [`ModelConfig`](@ref) constructor, we then just write:

```@example main
run(ModelConfig(f))
```

!!! note
    Once the initial model run has completed, it is always possible to add workflow steps via [`put!`](@ref) and [`launch`](@ref).

The run folder name and its content can be viewed using [`pathof`](@ref) and [`readdir`](@ref), respectively.

```@example main
pathof(MC)
```

```@example main
readdir(MC)
```

The [`show`](@ref) method for `ModelConfig` is demonstrated below.

```@example main
show(MC)
```

The `log` subfolder was created earlier by [`setup`](@ref). The [`log`](@ref) function retrieves the workflow log. 

```@example main
log(MC)
```

This highlights that `Project.toml` and `Manifest.toml` for the environment being used have been archived. This happens during [`setup`](@ref) to document all dependencies and make the workflow reproducible.

### Generalization

A key point is that everything can be customized to, e.g., use popular models previously written in Fortran or C just as simply. 

This typically involves defining a new concrete type of `AbstractModelConfig` and then providing customized `setup`, `build`,  and/or `launch` methods. 

To start, let's distinguish amongst [`ModelConfig`](@ref)s on the basis of their `model` variable type :

- _normal user mode_ is when `model` is a `String` or a `Function`.
- _package developer mode_ is when `model` is a `PackageSpec` (see below).

#### _Normal User Mode_

The simplest way to use the `ClimateModels.jl` interface is to specify `model` directly as a function, and use defaults for everything else, as illustrated in [random walk](../examples/RandomWalker.html). Alternatively, the `model` name can be provided as a `String` and the main `Function` as the `configuration`, as in [CMIP6](../examples/CMIP6.html).

Often, however, one may want to define custom `setup`, `build`, or `launch` methods. To this end, one can define a concrete type of `AbstractModelConfig` using [`ModelConfig`](@ref) as a blueprint. This is the recommended approach when other languanges like Fortran or Python are involved (e.g., [Hector](../examples/Hector.html), [FaIR](../examples/FaIR.html), [SPEEDY](../examples/Speedy.html), [MITgcm](../examples/MITgcm.html)). 

!!! note
    Defining a concrete type of `AbstractModelConfig` can also be practical with pure Julia model, e.g. to speed up [`launch`](@ref), generate ensembles, facilitate checkpointing, etc. That's the case in the [Oceananigans.jl](../examples/Oceananigans.html) example.

For popular models the customized interface elements can be provided via a dedicated package. This may allow them to be maintained independently by developers and users most familiar with each model. [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) does this for [MITgcm](https://mitgcm.readthedocs.io/en/latest/). It provides its own suite of examples that use the `ClimateModels.jl` interface.

#### _Package Developer Mode_

The defining feature of this approach is that the `PackageSpec`   specification of `model` makes [`setup`](@ref) install the chosen package using `Pkg.develop`. This allows for developing a package or using an unregistered package in the context of `ClimateModels.jl`. There are two cases: 

- if `configuration` is left undefined then `launch` will run the package test suite using `Pkg.test` as in [this example](../examples/defaults.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl))
- if `configuration` is provided as a `Function` then `launch` will call it as illustrated in the [ShallowWaters.jl example](../examples/ShallowWaters.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl))

!!! note 
    As an exercise, can you turn [ShallowWaters.jl example](../examples/ShallowWaters.html) into a _normal user mode_ example?

## Tracked Worklow Support

The `setup` method normally calls [`log`](@ref) to create a temporary run folder with a `git` enabled subfolder called `log`. This allows for recording each workflow step, using [`log`](@ref) functions listed below.

## Cloud And File Support

There are various ways that numerical model output gets archived, distributed, and retrieved from the internet. In some cases downloading data can be the most convenient approach. In others it can be more advantageous to compute in the cloud and only download final results for plotting. 

`ClimateModels.jl` comes equiped with packages that read popular file formats used in climate modeling and science. [Downloads.jl](https://github.com/JuliaLang/Downloads.jl), [CSV.jl](https://github.com/JuliaData/CSV.jl), [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl), [NetCDF.jl](https://github.com/JuliaGeo/NetCDF.jl), [Zarr.jl](https://github.com/meggart/Zarr.jl), and [TOML.jl](https://github.com/JuliaLang/TOML.jl) are thus readily available when you install `ClimateModels.jl`. For instance, one can read the CSV file generated before as

```@example main
fil=joinpath(pathof(MC),"RandomWalker.csv")
CSV=ClimateModels.CSV # hide
DataFrame=ClimateModels.DataFrame #hide
CSV.File(fil) |> DataFrame
summary(ans) # hide
```

For additional examples covering other file formats, please refer to the [IPCC report](../examples/IPCC.html) and [CMIP6 archive](../examples/CMIP6.html) notebooks and code links.

## API Reference

```@docs
ModelConfig
ModelConfig(::Function)
PkgDevConfig
```

```@docs
setup
build
launch
run
```

## Utilities

```@docs
show
log
pathof
readdir
clean
```

## notebooks

```@docs
notebooks.open
notebooks.execute
notebooks.unroll
```
