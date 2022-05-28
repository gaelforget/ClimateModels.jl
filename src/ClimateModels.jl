module ClimateModels

using UUIDs, Suppressor, OrderedCollections
using Pkg, Git, TOML
import Pkg.Artifacts

p=dirname(pathof(ClimateModels))
artifact_toml = joinpath(p, "../Artifacts.toml")
IPCC_SPM_hash = Artifacts.artifact_hash("IPCC_SPM", artifact_toml)
IPCC_SPM_path = Artifacts.artifact_path(IPCC_SPM_hash)

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export put!, take!
export pathof, readdir, log
#export git_log_init, git_log_msg, git_log_fil
#export git_log_prm, git_log_show
#export monitor, help, pause
#export train, compare, analyze
export cmip, notebooks

export IPCC_SPM_path, IPCC_hexagons #should be commented out?
export OrderedDict, UUID, uuid4, @suppress #should be commented out?

include("interface.jl")
include("access.jl")
include("notebooks.jl")
include("toy_models.jl")

end
