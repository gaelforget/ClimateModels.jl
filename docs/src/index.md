# ClimateModels.jl

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models are 
ran and analyzed via a simple interface laid out hereafter. Three examples illustrate this framework as applied to:

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

_Note: this package is still its early stage of development, such that breaking changes should be expected._


```@index
```

## Climate Model Interface

```@docs
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
add_git_msg
```


