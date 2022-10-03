module ClimateModels

using UUIDs, Suppressor, OrderedCollections
using Pkg, Git, TOML

export AbstractModelConfig, ModelConfig, PkgDevConfig
export clean, build, compile, setup, launch, notebooks
export put!, take!
export pathof, readdir, log
#export git_log_init, git_log_msg, git_log_fil
#export git_log_prm, git_log_show
#export monitor, help, pause
#export train, compare, analyze

export OrderedDict, UUID, uuid4, @suppress #should be commented out?

include("interface.jl")
include("notebooks.jl")
include("toy_models.jl")

end
