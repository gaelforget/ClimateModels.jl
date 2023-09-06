# [User Manual](@id manual)

```@setup 1
using ClimateModels
```

```@setup 2
using ClimateModels
fun=ClimateModels.RandomWalker
MC=ModelConfig(fun)
```

```@setup 3
using ClimateModels
fil=joinpath(dirname(pathof(ClimateModels)),"..","examples","RandomWalker.jl")
tmp=joinpath(tempdir(),"notebook.jl")
cp(fil,tmp,force=true)
```

Here we document key functionalities offered in `ClimateModels.jl`

- Climate model interface
- Pluto notebook integration
- Tracked worklow framework
- File access and cloud support
- Plotting recipes and examples

## Climate Model Interface

The interface ties the [`ModelConfig`](@ref) data structure with methods like [`setup`](@ref), [`build`](@ref), and [`launch`](@ref). In return, it provides standard methods to deal with inputs and outputs, as well as capabilities described below. 

The [`ModelRun`](@ref) method provides the capability to deploy models in streamlined fashion -- with just one code line, or just one click. It executes all three steps at once ([`setup`](@ref), [`build`](@ref), and [`launch`](@ref)). 

For example, let's use [`RandomWalker`](@ref) as the model main function. 
 
```@example 1
fun=ClimateModels.RandomWalker
```
 
With the simplified [`ModelConfig`](@ref) constructor, we can then just write any of the following:

```@example 2
ModelRun(ModelConfig(model=fun))
run(ModelConfig(fun))
nothing # hide
```

Or via the `@ModelRun` macro:

```@example 1
@ModelRun ClimateModels.RandomWalker
nothing # hide
```

By design of our interface, **it is required** that function `fun` receives a `ModelConfig` as its sole input argument. 

In practice, **this requirement is easily satisfied**. Input parameters can be specified to `ModelConfig` via the `inputs` keyword argument, or via files instead. See [Parameters](@ref).

Often one may prefer to break things down though. Let's start with defining the model:

```@example 2
MC=ModelConfig(model=fun)
nothing # hide
```

The sequence of calls within `ModelRun` can then be expanded as shown below. In practice, `setup` typically handles files and software, `build` may compile a chosen model configuration, and `launch` takes care of the main computation. 

```@example 2
setup(MC)
build(MC)
launch(MC)
```

The `model`'s top level function gets called via [`launch`](@ref). In our example, it generates a CSV file found in the run folder as shown below. 

!!! note
    It is **not required** that compilation takes place during `build`. It can also be done beforehand or within `launch`.

Sometimes it is convenient to further break down the computational workflow into several tasks. These can be added to the `ModelConfig` via [`put!`](@ref) and then executed via `launch`, as demonstrated in [Parameters](@ref).

The run folder name and its content can be viewed using [`pathof`](@ref) and [`readdir`](@ref), respectively.

```@example 2
pathof(MC)
```

```@example 2
readdir(MC)
```

The `log` subfolder was created earlier by [`setup`](@ref). The [`log`](@ref) function can then retrieve the workflow log. 

```@example 2
log(MC)
```

This highlights that `Project.toml` and `Manifest.toml` for the environment being used have been archived. This happens during [`setup`](@ref) to document all dependencies and make the workflow reproducible.

### Customization

A key point is that everything can be customized to, e.g., use popular models previously written in Fortran or C just as simply. 

Here are simple ways to start usinf the `ClimateModels.jl` interface with your favorite `model`.

- specify `model` directly as a function, and use defaults for everything else, as illustrated in [random walk](../examples/RandomWalker.html)
- specify `model` name as a `String` and the main `Function` as the `configuration`, as in [CMIP6](../examples/CMIP6.html)
- put `model` in a Pluto notebook and ingest it via [`PlutoConfig`](@ref) as shown below

Sometimes, one may also want to define custom `setup`, `build`, or `launch` methods. To do this, one can define a concrete type of `AbstractModelConfig` using [`ModelConfig`](@ref) as a blueprint. This is the recommended approach when other languanges like Fortran or Python are involved (e.g., [Hector](../examples/Hector.html, [FaIR](../examples/Speedy.html), [SPEEDY](../examples/Speedy.html), [MITgcm](../examples/MITgcm.html)). 

!!! note
    Defining a concrete type of `AbstractModelConfig` can also be practical with pure Julia model, e.g. to speed up [`launch`](@ref), generate ensembles, facilitate checkpointing, etc. That's the case in the [Oceananigans.jl](http://www.gaelforget.net/notebooks/Oceananigans.html) example.

For popular models the customized interface elements can be provided via a dedicated package. This may allow them to be maintained independently by developers and users most familiar with each model. [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) does this for [MITgcm](https://mitgcm.readthedocs.io/en/latest/). It provides its own suite of examples that use the `ClimateModels.jl` interface.

## Tracked Worklow Support

When creating a `ModelConfig`, it receives a unique identifier (`UUIDs.uuid4()`). By default, this identifier is used in the name of the run folder attached to the `ModelConfig`. 

The run folder normally gets created by [`setup`](@ref). During this phase, [`log`](@ref) is used to create a `git` enabled subfolder called `log`. This will allow us to record steps in our workflow -- again via [`log`](@ref). 

As shown in the [Parameters](@ref) example:

- Parameters specified via `inputs` are automatically recorded into `tracked_parameters.toml` during [`setup`](@ref).
- Modified parameters are automatically recorded in `tracked_parameters.toml` during [`launch`](@ref).
- [`log`](@ref) called on a [`ModelConfig`](@ref) with no other argument shows the workflow record.

### Parameters

In this example, we illustrate how one can interact with model parameters, rerun a model, and keep track of these workflow steps,

After an initial model run of 100 steps, duration `NS` is extended to 200 time steps. The [`put!`](@ref) and [`launch`](@ref) sequence then reruns the model. 

!!! note
    The same method can be used to break down a workflow in several steps. Each call to `launch` sequentially takes the next task from the stack (i.e., `channel`). Once the task `channel` is empty then `launch` does nothing.

```@example 1
fun=ClimateModels.RandomWalker # hide
mc=ModelConfig(fun,(NS=100,filename="run01.csv"))
run(mc)

mc.inputs[:NS]=200
mc.inputs[:filename]="run02.csv"
put!(mc)
launch(mc)

log(mc)
```

The call sequence is readily reflected in the workflow log, and the run folder now has two output files.

```@example 1
readdir(mc)
```

In more complex models, there generally is a large number of parameters that are often organized in a collection of text files. 

The `ClimateModels.jl` interface is easily customized to turn those into a `tracked_parameters.toml` file as demonstrated in the [Hector](../examples/Hector.html) and in the [MITgcm](../examples/MITgcm.html).

`ClimateModels.jl` thus readily enables interacting with parameters and tracking their values even with complex models as highlighted in the [JuliaCon 2021 Presentation](@ref).

## Pluto Notebook Integration

Any Pluto notebook is easily integrated to the `ClimateModels.jl` framework via [`PlutoConfig`](@ref). 

```@example 3
filename=joinpath(tempdir(),"notebook.jl")
PC=PlutoConfig(filename,(linked_model="MC",))
run(PC)
readdir(PC)
```

This functionality reformats the Pluto notebook via [`unroll`](@ref) and runs the notebook code in the notebook environment. All files get copied into `pathof(PC)` as before. This approach provides a simple way to run in batch mode model configurations documented in notebooks. 

If a notebook itself contains a `ModelConfig` called `MC` then the corresponding folder can be linked into the `PlutoConfig` folder at the end. This feature is controled by `linked_model` as ilustrated just above. 

Similarly a data input folder can be specified via the `data_folder` key. This will result in the specified folder getting linked into `pathof(PC)` before running the notebook.

The [`update`](@ref) method for a [`PlutoConfig`](@ref) adds a simple method for updating notebook dependencies. This is a routine maintanance operation, which is often followed by  rerunning the notebook to detect potential updating issues.

```@example 3
update(PlutoConfig(filename))
run(PlutoConfig(filename))
nothing # hide
```

## Files and Cloud Support

There are various ways that numerical model output gets archived, distributed, and retrieved. In some cases downloading data from the web can be most convenient. In others we would compute in the cloud and just download final results for plotting. 

`ClimateModels.jl` leverages standard Julia packages to read common file formats. [Downloads.jl](https://github.com/JuliaLang/Downloads.jl), [NetCDF.jl](https://github.com/JuliaGeo/NetCDF.jl), [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl), [CSV.jl](https://github.com/JuliaData/CSV.jl), and [TOML.jl](https://github.com/JuliaLang/TOML.jl) are direct dependencies of `ClimateModels.jl`. This makes it easy to read and write such files.

```@example 1
fil=joinpath(pathof(mc),"run02.csv")

CSV=ClimateModels.CSV
DataFrame=ClimateModels.DataFrame

CSV.File(fil) |> DataFrame
summary(ans) # hide
```

For examples with [NetCDF](https://github.com/JuliaGeo/NetCDF.jl) and [Zarr](https://github.com/meggart/Zarr.jl), please refer to [IPCC notebook](../examples/IPCC.html) (NetCDF) and [CMIP6 notebok](../examples/CMIP6.html) (Zarr).
