# ClimateModels.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/dev)
[![Build Status](https://travis-ci.org/gaelforget/ClimateModels.jl.svg?branch=master)](https://travis-ci.org/gaelforget/ClimateModels.jl)
[![Codecov](https://codecov.io/gh/gaelforget/ClimateModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaelforget/ClimateModels.jl)

[![DOI](https://zenodo.org/badge/260379066.svg)](https://zenodo.org/badge/latestdoi/260379066)

_Note: package in early development stage; breaking changes remain likely._

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using `git`, is included to allow for workflow documentation and reproducibility.

## Example Workflows That Run Models

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

## Remote Access To Model Output

The initial example accesses CMIP6 model output from cloud storage, via `AWS.jl` and `Zarr.jl`, to compute temperature maps and time series.
