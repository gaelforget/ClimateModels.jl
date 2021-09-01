# [Manual / User Guide](@id manual)

Here we document key functionalities offered in `ClimateModels.jl`

## Climate Model Interface

The climate model interface is based on a data structure (`ModelConfig`) and a series of methods like `setup`, `build`, and `launch`. The default assumption is that the model is either _1)_ a `Julia` package to be downloaded from a URL within `setup` using `Pkg.develop`, and run within `launch` using `Pkg.test` or _2)_ a `Julia` function to be called with a `ModelConfig` argument. 

A key point is that everything can be customized to e.g. `1)` use a custom workflow instead of `Pkg.test` or `2)` use popular models previously written in Fortran or C just as simply. The latter typically involves calling a `build` method to compile the model between `setup` and `launch`.

Leveraging the interface in real world application essentially means :

1. Define a concrete type `ModelConfig` (optional).
2. Customize interface methods to best suit your chosen model.

At first, one can skip the type definition (`#1` above) and may only want to customize `setup` and `launch` for `#2` (see examples 1, 2, and 3).

However, the idea is that for routine use of e.g. a popular model the customized interface elements would be provided via a dedicated package (e.g. [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl)). These customized interfaces would thus be maintained independently by developers and users most familiar with each model.

This approach is illustrated in the general circulation model example that uses the customized interface elements provided by [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) for [MITgcm](https://mitgcm.readthedocs.io/en/latest/).

```@docs
ModelConfig
```

```@docs
setup
build
compile
clean
launch
monitor
```

## Git Support

The `setup` method normally calls `git_log_init` to set up a temporary run folder with a `git` enabled subfolder called `log`. This allows for recording each workflow step, using functions listed here for example.

```@docs
git_log_init
git_log_msg
git_log_fil
git_log_prm
git_log_show
```

## Cloud Support

There are various ways that model output gets archived, distributed, and retrieved from the internet. In some cases downloading data can be the most convenient approach. In others it can be more advantageous to compute in the cloud and only download final results for plotting (e.g. `cmip`).

```@docs
cmip
```

## API Reference

```@index
```
