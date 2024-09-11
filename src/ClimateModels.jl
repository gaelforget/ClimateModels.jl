module ClimateModels

using UUIDs, Suppressor, OrderedCollections
using Pkg, Git, TOML

function plot_examples end
function read_Zarr end
function write_CMIP6_mean end
function read_CMIP6_mean end
function read_IniFile end

include("interface.jl")
include("notebooks.jl")
include("toy_models.jl")
include("files.jl")
include("CMIP6.jl")
include("Hector.jl")
include("FaIR.jl")

import .notebooks: update
import .downloads: add_datadep
import .Hector: HectorConfig
import .FaIR: FaIRConfig

export AbstractModelConfig, ModelConfig, PlutoConfig, HectorConfig, FaIRConfig
export ModelRun, @ModelRun, PkgDevConfig, add_datadep, read_Zarr, read_IniFile
export clean, build, compile, setup, launch, update, notebooks
export put!, take!, pathof, readdir, log
#export git_log_init, git_log_msg, git_log_fil
#export git_log_prm, git_log_show
#export monitor, help, pause
#export train, compare, analyze
export RandomWalker, IPCC, CMIP6, Hector, FaIR

#export OrderedDict, UUID, uuid4, @suppress

conda(dev::String) = conda(:fair)
pyimport(dev::String) = pyimport(:fair)

__init__() = begin
    downloads.__init__datasets()
end

end
