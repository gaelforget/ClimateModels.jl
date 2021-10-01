module ClimateModels

using UUIDs, Pkg, Git, Suppressor, OrderedCollections, TOML
import Pkg.Artifacts

p=dirname(pathof(ClimateModels))
artifact_toml = joinpath(p, "../Artifacts.toml")
IPCC_SPM_hash = Artifacts.artifact_hash("IPCC_SPM", artifact_toml)
IPCC_SPM_path = Artifacts.artifact_path(IPCC_SPM_hash)

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export monitor, help, put!, take!, pause
export git_log_init, git_log_msg, git_log_fil
export git_log_prm, git_log_show
#export train, compare, analyze
export cmip, IPCC_SPM_path, IPCC_hexagons

include("interface.jl")
include("access.jl")
include("toy_models.jl")

end
