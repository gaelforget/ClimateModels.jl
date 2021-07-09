module ClimateModels

using UUIDs, Pkg, Git, Suppressor, OrderedCollections, TOML

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export monitor, help, put!, take!, pause
export git_log_init, git_log_msg, git_log_fil
export git_log_prm, git_log_show
#export train, compare, analyze
export cmip

include("interface.jl")
include("access.jl")
include("toy_models.jl")

end
