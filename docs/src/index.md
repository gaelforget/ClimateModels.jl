# ClimateModels.jl

_Note: package in early development stage; breaking changes remain likely._

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using `git`, is included to allow for workflow documentation and reproducibility.

## Example Workflows That Run Models

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

## Remote Access To Model Output

The initial example accesses CMIP6 model output from cloud storage, via `AWS.jl` and `Zarr.jl`, to compute temperature maps and time series.

## API Reference

```@index
```

## Climate Model Interface

The climate model interface (`CMI`) is based on a data structure (`ModelConfig`) and various methods (e.g., `setup` and `launch`). The default assumes that the model is to be downloaded from a URL (`setup`), and that it's test suite should be run (`launch`). 

Leveraging the interface in real world application essentially means :

1. Define a concrete type `ModelConfig` (optional).
2. Customize the `CMI` functions to suit one's model as needed.

At first, one can skip the type definition (`#1` above) and may only want to customize `setup` and `launch` for `#2` (see first examples).

But for routine use of e.g. a popular model it is suggested that the custom `CMI` be incorporated in a dedicated package maintained inpdependently.

This approach is readily illustrated in the general circulation model example which uses the custom `CMI` provided by [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) for [MITgcm](https://mitgcm.readthedocs.io/en/latest/) .

```@docs
ModelConfig
```

```@docs
clean
setup
build
compile
launch
monitor
```

## Git Support

The `setup` method normally calls `init_git_log` to set up a temporary run folder with a `git` enabled subfolder called `log`. This allows for recording a workflow steps e.g. through the other functions listed here.

```@docs
init_git_log
git_log_msg
git_log_fil
git_log_prm
```

## Cloud Support

There are various ways that model output gets archived, distributed, and retrieved from the internet. In some cases downloading data can be the most convenient approach. In others it can be more advantageous to compute in the cloud and only download final results for plotting (e.g. `cmip`).

```@docs
cmip
```

