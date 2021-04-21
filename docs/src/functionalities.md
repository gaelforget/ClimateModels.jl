# User Guide

Here we document key functionalities offered in `ClimateModels.jl`

## Climate Model Interface

The climate model interface is based on a data structure (`ModelConfig`) and a series of methods (incl., `setup` and `launch`). The defaults assume that the model is a `Julia` package to be downloaded from a URL (`setup`), and run via `Pkg.Test` (`launch`). But the key point is that everything can be customized to e.g. use popular models previously written in Fortran or C.

Leveraging the interface in real world application essentially means :

1. Define a concrete type `ModelConfig` (optional).
2. Customize interface methods to best suit your chosen model.

At first, one can skip the type definition (`#1` above) and may only want to customize `setup` and `launch` for `#2` (see 0D and 2D examples).

But for routine use of e.g. a popular model it is suggested that the customized interface elements be incorporated in a dedicated package maintained inpdependently by developers / users familiar with that model.

This approach is illustrated in the general circulation model example in these docs, which uses the customized interface elements provided by [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl) for [MITgcm](https://mitgcm.readthedocs.io/en/latest/) .

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

## API Reference

```@index
```

## Git Support

The `setup` method normally calls `git_log_init` to set up a temporary run folder with a `git` enabled subfolder called `log`. This allows for recording a workflow steps e.g. through the other functions listed here.

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

