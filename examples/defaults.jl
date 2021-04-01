# # Default Methods
#
# The defaults assume that the model is a `Julia` package downloaded 
# (via `git clone`) from online repository (its `url`). The cloned 
# package's `test/runtests.jl` is then used to _run the model_.

using ClimateModels, Pkg

url=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")

mo=ModelConfig(model=url)
setup(mo)
show(mo)
launch(mo)
monitor(mo)
clean(mo)
