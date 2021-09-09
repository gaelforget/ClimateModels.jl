# ClimateModels.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/dev)
[![CI](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml)
[![Codecov](https://codecov.io/gh/gaelforget/ClimateModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaelforget/ClimateModels.jl)

[![DOI](https://zenodo.org/badge/260379066.svg)](https://zenodo.org/badge/latestdoi/260379066)

_Note: package in early development stage; breaking changes remain likely._

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Common file formats are supported. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

## Examples

The examples notebooks rendered as html are linked below. 

Alternatively, to try an example using Julia :

- copy notebook url (also linked below)
- paste into the [Pluto.jl interface](https://github.com/fonsp/Pluto.jl/wiki/🔎-Basic-Commands-in-Pluto)

See [the docs](https://gaelforget.github.io/ClimateModels.jl/dev/) for detail. 

### Examples / Running Models

- [random walk model (0D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.jl))
- [Hector climate model (global)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.jl))
- [ShallowWaters.jl model (2D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.jl))
- [SPEEDY atmosphere model (3D)](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.jl))
- [MITgcm general circulation model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.jl))

### Examples / Replaying Outputs

- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) (---> [notebook url](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.jl))

## JuliaCon 2021 Presentation Link

- [Presentation recording](https://youtu.be/XR5hKCja0uw)
- [Presentation notebook (html)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.html)
- [Presentation notebook (notebook url)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.jl)

[![Screen Shot 2021-08-31 at 2 25 04 PM](https://user-images.githubusercontent.com/20276764/131556274-48f3df13-0608-4cd0-acf9-c3e29894a32c.png)](https://youtu.be/XR5hKCja0uw)
