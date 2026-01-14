module ClimateModels

using UUIDs, Suppressor, OrderedCollections
using Pkg, Git, TOML, Printf, JLD2

function plot_examples end
function read_Zarr end
function write_CMIP6_mean end
function read_CMIP6_mean end
function read_IniFile end
function read_NetCDF end
function Oceananigans_setup_grid end
function Oceananigans_setup_BC end
function Oceananigans_build_model end
function Oceananigans_build_simulation end
function Oceananigans_launch end

include("interface.jl")
include("notebooks.jl")
include("toy_models.jl")
include("files.jl")
include("CMIP6.jl")
include("Hector.jl")
include("FaIR.jl")
include("Speedy.jl")
include("Oceananigans.jl")

import .notebooks: update
import .downloads: add_datadep
import .Hector: HectorConfig
import .FaIR: FaIRConfig
import .Speedy: SpeedyConfig
import .Oceananigans: OceananigansConfig

export AbstractModelConfig, ModelConfig, PlutoConfig
export HectorConfig, FaIRConfig, SpeedyConfig, OceananigansConfig
export ModelRun, @ModelRun, PkgDevConfig, add_datadep
export read_Zarr, read_IniFile, read_NetCDF
export clean, build, compile, setup, launch, update, notebooks
export put!, take!, pathof, readdir, log
export OrderedDict
#export git_log_init, git_log_msg, git_log_fil
#export git_log_prm, git_log_show
#export monitor, help, pause
#export train, compare, analyze

export RandomWalker, IPCC, CMIP6, Hector, FaIR, Speedy
#don't export Oceananigans module, which would conflict with Oceananigans.jl
#export Oceananigans 

#export OrderedDict, UUID, uuid4, @suppress

conda(dev::String) = conda(:fair)
pyimport(dev::String) = pyimport(:fair)

__init__() = begin
    downloads.__init__datasets()
end

end
