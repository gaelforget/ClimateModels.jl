# ClimateModels

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/dev)
[![Build Status](https://travis-ci.org/gaelforget/ClimateModels.jl.svg?branch=master)](https://travis-ci.org/gaelforget/ClimateModels.jl)
[![Codecov](https://codecov.io/gh/gaelforget/ClimateModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaelforget/ClimateModels.jl)

[![DOI](https://zenodo.org/badge/260379066.svg)](https://zenodo.org/badge/latestdoi/260379066)

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models are 
ran and analyzed via a simple interface laid out hereafter. Three examples illustrate this framework as applied to:

- one stochastic path (0D)
- a shallow water model (2D)
- the MIT general circulation model (3D, Ocean, Atmosphere, etc)

_Note: this package is still its early stage of development, such that breaking changes should be expected._

