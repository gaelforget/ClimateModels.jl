# ClimateModels.jl

[![Dev](https://img.shields.io/badge/documentation-blue.svg)](https://gaelforget.github.io/ClimateModels.jl/dev)

`ClimateModels.jl` provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and analyzed in this framework. 

`ClimateModels.jl` supports standard model runs as well as workflows that replay model output from storage. The framework is compatible with the various computer languages and file formats commonly used in climate science. 

`ClimateModels.jl` uses _git_ to enable documentation and reproducibility of your workflows by default.

Notebooks listed below are also found in [the docs](https://gaelforget.github.io/ClimateModels.jl/dev/). 

<details>
 <summary> Examples that Run Models </summary>
<p>

- [random walk model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/RandomWalker.html)  (0D, Julia)
- [ShallowWaters.jl model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/ShallowWaters.html) (2D, Julia)
- [Oceananigans.jl model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Oceananigans.html) (3D, Julia)
- [Hector climate model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Hector.html) (global, C++)
- [FaIR climate model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/FaIR.html) (global, Python)
- [SPEEDY atmosphere model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/Speedy.html) (3D, Fortran90)
- [MITgcm general circulation model](https://gaelforget.github.io/ClimateModels.jl/dev/examples/MITgcm.html) (3D, Fortran)

</p>
</details>

<details>
 <summary> Examples that Replay Models </summary>
<p>

- [IPCC report 2021](https://gaelforget.github.io/ClimateModels.jl/dev/examples/IPCC.html) (NetCDF, CSV)
- [CMIP6 model output](https://gaelforget.github.io/ClimateModels.jl/dev/examples/CMIP6.html) (Zarr)
- [ECMWF IFS 1km](http://www.gaelforget.net/notebooks/IFS1km_notebook.html) (NetCDF)
- [ECCO version 4](https://gaelforget.github.io/OceanStateEstimation.jl/dev/examples/ECCO_standard_plots.html) (NetCDF)
- [Pathway Simulations](https://gaelforget.github.io/MITgcmTools.jl/dev/examples/HS94_particles.html) (binary, jld2)

</p>
</details>

<details>
 <summary> JuliaCon 2021 Presentation </summary>
<p>

- [Presentation recording](https://youtu.be/XR5hKCja0uw)
- [Presentation notebook (html)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.html)
- [Presentation notebook (notebook url)](https://gaelforget.github.io/ClimateModels.jl/dev/ClimateModelsJuliaCon2021.jl)

[![Screen Shot 2021-08-31 at 2 25 04 PM](https://user-images.githubusercontent.com/20276764/131556274-48f3df13-0608-4cd0-acf9-c3e29894a32c.png)](https://youtu.be/XR5hKCja0uw)

</p>
</details>
<br>

[![DOI](https://zenodo.org/badge/260379066.svg)](https://zenodo.org/badge/latestdoi/260379066)
[![Codecov](https://codecov.io/gh/gaelforget/ClimateModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/gaelforget/ClimateModels.jl)
[![CI](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/gaelforget/ClimateModels.jl/actions/workflows/ci.yml)
 [![cloud](https://img.shields.io/badge/cloud-binder-blue.svg)](https://gesis.mybinder.org/v2/gh/JuliaClimate/Notebooks/HEAD?urlpath=lab)
