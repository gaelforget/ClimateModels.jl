# ClimateModels.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/dev)
[![Codecov](https://codecov.io/gh/gaelforget/ClimateModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaelforget/ClimateModels.jl)
[![CI](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml)

[![DOI](https://zenodo.org/badge/260379066.svg)](https://zenodo.org/badge/latestdoi/260379066)

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It supports workflows that run models as well as those that replay previous model output retrieved the cloud or local storage. File formats (incl. csv, netcdf, zarr) commonly used in climate science are supported. Version control support, using _git_, further allows for workflow documentation and reproducibility.

_Note: package in early development stage; breaking changes remain likely._

## Examples

The examples notebooks rendered as html are linked below. See [the docs](https://gaelforget.github.io/ClimateModels.jl/dev/) for detail. 

### Examples / Running Models

- [random walk model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html)  (0D, Julia)
- [ShallowWaters.jl model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) (2D, Julia)
- [Hector climate model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) (global, C++)
- [FaIR climate model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) (global, Python)
- [SPEEDY atmosphere model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) (3D, Fortran90)
- [MITgcm general circulation model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) (3D, Fortran)

### Examples / Replaying Outputs

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html)
- [IPCC report 2021](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html)

## JuliaCon 2021 Presentation Link

- [Presentation recording](https://youtu.be/XR5hKCja0uw)
- [Presentation notebook (html)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.html)
- [Presentation notebook (notebook url)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.jl)

[![Screen Shot 2021-08-31 at 2 25 04 PM](https://user-images.githubusercontent.com/20276764/131556274-48f3df13-0608-4cd0-acf9-c3e29894a32c.png)](https://youtu.be/XR5hKCja0uw)
