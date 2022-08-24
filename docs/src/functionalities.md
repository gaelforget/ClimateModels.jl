# [User Manual](@id manual)

```@setup main
using ClimateModels
```

Here we document key functionalities offered in `ClimateModels.jl`

- Climate Model Interface
- Tracked Worklow Framework
- Cloud + On-Premise File Support

## Climate Model Interface

The interface ties the [`ModelConfig`](@ref) data structure with methods like [`setup`](@ref), [`build`](@ref), and [`launch`](@ref). In return, it provides standard methods to deal with inputs and outputs, as well as capabilities described below. 

The [`run`](@ref) method provides the capability to deploy models in streamlined fashion -- with just one code line, or just one click. It executes all three steps at once ([`setup`](@ref), [`build`](@ref), and [`launch`](@ref)). 
 
With the simplified [`ModelConfig`](@ref) constructor, we can then just write:

```@example main
f=ClimateModels.RandomWalker
run(ModelConfig(f))
```

The above example uses `ClimateModels.RandomWalker` as the model (function `f`). By design of our interface, it is **required** that `f` receives a `ModelConfig` as its sole input argument. 

!!! note
    In practice, this requirement is easily satisfied. Input parameters can be specified to `ModelConfig` via the `inputs` keyword argument, or via files instead.

Often it is most practical to break things down. Let's start with defining the model:

```@example main
MC=ModelConfig(model=f)
```

The `model`'s top level function gets called via [`launch`](@ref). In our example, `f` thus generates a file called `RandomWalker.csv`, which gets stored in the run folder. 

The `run` sequence is shown below. In practice, `setup` typically handles files and software, `build` may compile a chosen model configuration, and `launch` takes care of the main computation. 

```@example main
setup(MC)
build(MC)
launch(MC)
```

!!! note 
    Compilation during `build` is **not a requirement**. It can also be done within `launch` or beforehand.

Sometimes it is convenient to further break down the computational workflow into several tasks. These can be added to the `ModelConfig` via [`put!`](@ref) and then executed via `launch`, as demonstrated in [Additional Example](@ref).

The run folder name and its content can be viewed using [`pathof`](@ref) and [`readdir`](@ref), respectively.

```@example main
pathof(MC)
```

```@example main
readdir(MC)
```

The `log` subfolder was created earlier by [`setup`](@ref). The [`log`](@ref) function retrieves the workflow log. 

```@example main
log(MC)
```

This highlights that `Project.toml` and `Manifest.toml` for the environment being used have been archived. This happens during [`setup`](@ref) to document all dependencies and make the workflow reproducible.

### Customization

A key point is that everything can be customized to, e.g., use popular models previously written in Fortran or C just as simply. 

The simplest way to use the `ClimateModels.jl` interface is to specify `model` directly as a function, and use defaults for everything else, as illustrated in [random walk](../examples/RandomWalker.html). Alternatively, the `model` name can be provided as a `String` and the main `Function` as the `configuration`, as in [CMIP6](../examples/CMIP6.html).

Often, however, one may want to define custom `setup`, `build`, or `launch` methods. To this end, one can define a concrete type of `AbstractModelConfig` using [`ModelConfig`](@ref) as a blueprint. This is the recommended approach when other languanges like Fortran or Python are involved (e.g., [Hector](../examples/Hector.html), [FaIR](../examples/FaIR.html), [SPEEDY](../examples/Speedy.html), [MITgcm](../examples/MITgcm.html)). 

!!! note
    Defining a concrete type of `AbstractModelConfig` can also be practical with pure Julia model, e.g. to speed up [`launch`](@ref), generate ensembles, facilitate checkpointing, etc. That's the case in the [Oceananigans.jl](../examples/Oceananigans.html) example.

For popular models the customized interface elements can be provided via a dedicated package. This may allow them to be maintained independently by developers and users most familiar with each model. [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) does this for [MITgcm](https://mitgcm.readthedocs.io/en/latest/). It provides its own suite of examples that use the `ClimateModels.jl` interface.

### Additional Example

In this example, we illustrate how one can interact with model parameters and rerun models. After an initial model run of 100 steps, duration `NS` is extended to 200 time steps. The [`put!`](@ref) and [`launch`](@ref) sequence then reruns the model. 

The same method can be used to break down a workflow in several steps. Each call to `launch` sequentially takes the next task from the stack (i.e., `channel`). Once the task `channel` is empty then `launch` does nothing.

!!! note
    The call sequence is readily reflected in the workflow log, and the run dir now has two output files. The modified parameters are also automatically recorded in `tracked_parameters.toml` during [`launch`](@ref).

```@example main
MC=ModelConfig(f,(NS=100,filename="run01.csv"))
run(MC)

MC.inputs[:NS]=200
MC.inputs[:filename]="run02.csv"
put!(MC)
launch(MC)

log(MC)
```

```@example main
readdir(MC)
```

## Tracked Worklow Support

The [`setup`](@ref) method normally calls [`log`](@ref) to create a temporary run folder with a `git` enabled subfolder called `log`. This allows for recording each workflow step, which is normally done via the [`log`](@ref) functions listed below. 

Calling [`log`](@ref) on a [`ModelConfig`](@ref) without any other argument shows the workflow record. This feature is as illustrated several times in the above examples.

## Files and Cloud Support

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

## Data Structure

```@docs
ModelConfig
ModelConfig(::Function)
PkgDevConfig
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
notebooks.open
```

## Package Development Mode

In this alternative method, `model` is specified as a `PackageSpec`. This leads [`setup`](@ref) to install the chosen package using `Pkg.develop`. This can be useful for developing a package or using an unregistered package in the context of `ClimateModels.jl`. 

There are two common cases: 

- if `configuration` is left undefined then `launch` will run the package test suite using `Pkg.test` as in [this example](../examples/defaults.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/defaults.jl))
- if `configuration` is provided as a `Function` then `launch` will call it as illustrated in the [ShallowWaters.jl example](../examples/ShallowWaters.html) ([code link](https://raw.githubusercontent.com/gaelforget/ClimateModels.jl/master/examples/ShallowWaters.jl))

!!! note 
    As an exercise, can you turn [ShallowWaters.jl example](../examples/ShallowWaters.html) into a _normal user mode_ example?
