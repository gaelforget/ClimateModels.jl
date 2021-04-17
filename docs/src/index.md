# ClimateModels.jl

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

`ClimateModels.jl` is also aimed at cloud computing workflows that often start from previous model output available over the internet. Version control support is provided via `Git.jl` to facilitate documentation and reproducibility.

### Examples That Run Models

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

### Remote Access To Model Output


The initial example accesses CMIP6 model output from cloud storage, and computes time-mean maps + global-mean time series of temperature.

_Note: this package is still its early stage of development, such that breaking changes should be expected._


```@index
```

## Climate Model Interface

```@docs
ModelConfig
clean
setup
build
compile
launch
monitor
```

## Git Support

```@docs
init_git_log
git_log_msg
git_log_fil
git_log_prm
```

## Cloud Support

```@docs
cmip
```

