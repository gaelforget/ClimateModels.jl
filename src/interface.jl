
import Base: put!, take!

abstract type AbstractModelConfig end

"""
    struct ModelConfig <: AbstractModelConfig

```
model :: Union{Function,String,Pkg.Types.PackageSpec} = "anonymous"
configuration :: Union{Function,String} = "anonymous"
options :: Array{String,1} = Array{String,1}(undef, 0)
inputs :: Array{String,1} = Array{String,1}(undef, 0)
outputs :: Array{String,1} = Array{String,1}(undef, 0)
status :: Array{String,1} = Array{String,1}(undef, 0)
channel :: Channel{Any} = Channel{Any}(10) 
folder :: String = tempdir()
ID :: UUID = UUIDs.uuid4()
```
""" 
Base.@kwdef struct ModelConfig <: AbstractModelConfig
    model :: Union{Function,String,Pkg.Types.PackageSpec} = "anonymous"
    configuration :: Union{Function,String} = "anonymous"
    options :: Array{String,1} = Array{String,1}(undef, 0)
    inputs :: Array{String,1} = Array{String,1}(undef, 0)
    outputs :: Array{String,1} = Array{String,1}(undef, 0)
    status :: Array{String,1} = Array{String,1}(undef, 0)
    channel :: Channel{Any} = Channel{Any}(10) 
    folder :: String = tempdir()
    ID :: UUID = UUIDs.uuid4()
end


"""
    setup(x)

Defaults to `default_ClimateModelSetup2qa(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
```
"""
setup(x :: AbstractModelConfig) = default_ClimateModelSetup(x)

function default_ClimateModelSetup(x::AbstractModelConfig)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    pth=joinpath(x.folder,string(x.ID))
    !isdir(pth) ? mkdir(pth) : nothing    
    isa(x.model,Function) ? put!(x.channel,x.model) : nothing
    isa(x.configuration,Function) ? put!(x.channel,x.configuration) : nothing
    if isa(x.model,Pkg.Types.PackageSpec)
        url=x.model.repo.source
        git() do git
            run(`$git clone $url $pth`) #PackageSpec needs to be via web address for this to work
        end
        Pkg.activate(pth)
        Pkg.instantiate()
        Pkg.build()
        Pkg.activate()
        if x.configuration=="anonymous"
            put!(x.channel,run_the_tests)
        else
            put!(x.channel,x.configuration)
        end
    end
    return x
end

"""
    run_the_tests(x)

Default for launching model when it is a cloned julia package    
"""
function run_the_tests(x)
    pth=joinpath(x.folder,string(x.ID),"test")
    Pkg.activate(pth)
    Pkg.develop(path=joinpath(x.folder,string(x.ID)))
    include(joinpath(pth,"runtests.jl"))
    Pkg.activate()
end

"""
    build(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```
tmp=PackageSpec(url="https://github.com/JuliaClimate/MeshArrays.jl")
tmp=ModelConfig(model=tmp)
setup(tmp)
build(tmp)
```
"""
build(x :: AbstractModelConfig) = default_ClimateModelBuild(x)

"""
    compile(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```
tmp=PackageSpec(url="https://github.com/JuliaClimate/MeshArrays.jl")
tmp=ModelConfig(model=tmp)
setup(tmp)
compile(tmp)
```
"""
compile(x :: AbstractModelConfig) = default_ClimateModelBuild(x)

function default_ClimateModelBuild(x::AbstractModelConfig)
    isa(x.model,String) ? Pkg.build(x.model) : nothing
    isa(x.model,Pkg.Types.PackageSpec) ? build_the_pkg(x) : nothing
end

"""
   build_the_pkg(x)

Default for building/compiling model when it is a cloned julia package    
"""
function build_the_pkg(x)
    pth=joinpath(x.folder,string(x.ID))
    Pkg.activate(pth)
    Pkg.build()
    Pkg.activate()
end

"""
    launch(x)

Defaults to `default_ClimateModelLaunch(x)` which consists in `take!(x)`
for `AbstractModelConfig`. Can be expected to be specialized for most 
concrete types of `AbstractModelConfig`

```
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
launch(tmp)
```
"""
launch(x :: AbstractModelConfig) = default_ClimateModelLaunch(x)

function default_ClimateModelLaunch(x::AbstractModelConfig)
    !isempty(x.channel) ? take!(x) : "no task left in pipeline"
end

"""
    clean(config::MITgcm_config)

Cancel any remaining task (config.channel) and clean the run directory (via rm)

```
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
clean(tmp)
```
"""
function clean(x :: AbstractModelConfig)
    #cancel any remaining task
    while !isempty(x.channel)
        take!(x.channel)
    end
    #clean up run directory
    if isdir(joinpath(x.folder,string(x.ID)))
        rm(joinpath(x.folder,string(x.ID)),recursive=true)
    end
    #
    return "no task left in pipeline"
end

"""
    monitor(x)

Show `x.status[end]` by default.

```
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
monitor(tmp)
```
"""
function monitor(x :: AbstractModelConfig)
     try 
        x.status[end]
     catch e
        "no task left in pipeline"
     end
end

help(x :: AbstractModelConfig) = println("Please consider using relevant github issue trackers for questions")

"""
    show(io::IO, z::AbstractModelConfig)

```
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
show(tmp)
```
"""
function Base.show(io::IO, z::AbstractModelConfig)
    printstyled(io, "  model         = ",color=:normal)
    if isa(z.model,Pkg.Types.PackageSpec)
        printstyled(io, "$(z.model.repo.source)\n",color=:blue)
    else
        printstyled(io, "$(z.model)\n",color=:blue)
    end
    printstyled(io, "  configuration = ",color=:normal)
    printstyled(io, "$(z.configuration)\n",color=:blue)
    printstyled(io, "  status        = ",color=:normal)
    printstyled(io, "$(z.status)\n",color=:blue)
    printstyled(io, "  folder        = ",color=:normal)
    printstyled(io, "$(z.folder)\n",color=:blue)
    printstyled(io, "  ID            = ",color=:normal)
    printstyled(io, "$(z.ID)\n",color=:blue)
end

"""
    put!(x :: AbstractModelConfig,v)

Adds `v` to x.channel (i.e. `put!(x.channel,v)`)

```
tmp=ModelConfig()
put!(tmp,ClimateModels.RandomWalker)
```
"""
put!(x :: AbstractModelConfig,v) = put!(x.channel,v)
pause(x :: AbstractModelConfig) = put!(x.channel,"pausing now")

"""
    take!(x :: AbstractModelConfig)

Takes command `v` from x.channel (i.e. `take!(x.channel)`) and execute `v(x)` 
(if a Function) or return `v` (if not a Function, e.g. a String).

```
tmp=ModelConfig()
put!(tmp,ClimateModels.RandomWalker)
take!(tmp)
```
"""
function take!(x :: AbstractModelConfig)
    tmp=take!(x.channel)
    if isa(tmp,Function)
        tmp(x)
    else
        tmp
    end
    #do the git part here?
end

#train(x :: AbstractModelConfig,y) = missing
#compare(x :: AbstractModelConfig,y) = missing
#analyze(x :: AbstractModelConfig,y) = missing
