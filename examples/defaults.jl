# # Default Behavior : Package
#
# By default it is assumed that:
#
# - The model is a `Julia` package to be downloaded via `git clone` from the repository `URL`. 
# - The cloned package's `test/runtests.jl` is then used to _run the model_.
#
# But it should immediately be noted that anything in the `ClimateModels.jl` interface can be customized differently. 
#
# This will become clear in the other examples that largely differ in the specifics while using the same, uniform, interface.

using ClimateModels, Pkg

#

url=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
MC=ModelConfig(model=url)

#

setup(MC)
launch(MC)
