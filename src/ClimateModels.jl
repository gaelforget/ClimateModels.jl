module ClimateModels

using UUIDs, Pkg, GitCommand

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export monitor, help, put!, take!, pause
#export train, compare, analyze
#export cmip

include("interface.jl")
#include("access.jl")

end