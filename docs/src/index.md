# ClimateModels.jl

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models are ran and/or analyzed via a simple interface laid out hereafter. 

Three examples illustrate this framework which run models:

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

This package also means to support cloud computing workflows that commonly start from model output generated earlier, often by a third party, and available over internet. 

The initial example which retrieves model output from the cloud:

- compute time-mean maps and time-series of temperature in CMIP6 models

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

