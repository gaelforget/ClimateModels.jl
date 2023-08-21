
import Base: put!, take!, pathof, joinpath, readdir, log, run

abstract type AbstractModelConfig end

"""
    struct ModelConfig <: AbstractModelConfig

Generic data structure for a model configuration. This serves as :
    
- default concrete type for `AbstractModelConfig`
- keyword constructor for `AbstractModelConfig`

```
model :: Union{Function,String,Pkg.Types.PackageSpec} = "anonymous"
configuration :: Union{Function,String} = "anonymous"
inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
channel :: Channel{Any} = Channel{Any}(10) 
folder :: String = tempdir()
ID :: UUID = UUIDs.uuid4()
```
""" 
Base.@kwdef struct ModelConfig <: AbstractModelConfig
    model :: Union{Function,String,Pkg.Types.PackageSpec} = "anonymous"
    configuration :: Union{Function,String} = "anonymous"
    options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    channel :: Channel{Any} = Channel{Any}(10) 
    folder :: String = tempdir()
    ID :: UUID = UUIDs.uuid4()
end

"""
    struct PlutoConfig <: AbstractModelConfig

Generic data structure for a model configuration based on a Pluto notebook.
""" 
Base.@kwdef struct PlutoConfig <: AbstractModelConfig
    model :: String = "anonymous"
    configuration :: String = "anonymous"
    options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
    channel :: Channel{Any} = Channel{Any}(10) 
    folder :: String = tempdir()
    ID :: UUID = UUIDs.uuid4()
end

f(x)=Dict(pairs(x)) #convert NamedTuple to dict

"""
    @ModelRun(func)

Macro equivalent for `run(ModelConfig(model=func))`.
"""
macro ModelRun(func)
    return quote
       run(ModelConfig(model=$func))
    end
end

"""
    ModelConfig(func::Function,inputs::NamedTuple)

Simplified constructor for case when model is a Function.
"""
ModelConfig(func::Function) = ModelConfig(model=func)
ModelConfig(func::Function,inputs::NamedTuple) = ModelConfig(model=func,inputs=f(inputs))

"""
    PlutoConfig(func::Function,inputs::NamedTuple)

Simplified constructor for case when model is a Pluto notebook.

If a folder path is passed in `inputs.data` then it will get linked to the run folder.
"""
PlutoConfig(file::String) = PlutoConfig(model=file)
PlutoConfig(file::String,inputs::NamedTuple) = PlutoConfig(model=file,inputs=Dict(pairs(inputs)))

"""
    PkgDevConfig(url::String,func::Function,inputs::NamedTuple)

Simplified constructor for case when model is a url (PackageSpec).
"""
PkgDevConfig(url::String) = ModelConfig(model=PackageSpec(url=url))
PkgDevConfig(url::String,func::Function) = 
    ModelConfig(model=PackageSpec(url=url),configuration=func)
PkgDevConfig(url::String,func::Function,inputs::NamedTuple) = 
    ModelConfig(model=PackageSpec(url=url),configuration=func,inputs=f(inputs))

"""
    pathof(x::AbstractModelConfig)

Returns the run directory path for x ; i.e. `joinpath(x.folder,string(x.ID))`
"""
pathof(x::AbstractModelConfig) = joinpath(x.folder,string(x.ID))


"""
    pathof(x::AbstractModelConfig,subfolder::String)

Same as `pathof(joinpath(x,subfolder))` or `joinpath(pathof(x),subfolder)`
"""
pathof(x::AbstractModelConfig,subfolder...) = joinpath(x,subfolder...)


"""
    joinpath(x::AbstractModelConfig,y...)

Same as `joinpath(pathof(x),y...)`
"""
joinpath(x::AbstractModelConfig,y...) = joinpath(pathof(x),y...)

"""
    readdir(x::AbstractModelConfig)

Same as readdir(pathof(x)).
"""
readdir(x::AbstractModelConfig) = readdir(pathof(x))

"""
    readdir(x::AbstractModelConfig,subfolder::String)

Same as readdir(joinpath(pathof(x),subfolder)).
"""
readdir(x::AbstractModelConfig,subfolder::String) = readdir(joinpath(pathof(x),subfolder))

"""
    ModelRun(x :: AbstractModelConfig)

Shorthand for `x |> setup |> build |> launch`

Returns `AbstractModelConfig` as output.
"""
ModelRun(x :: AbstractModelConfig) = begin
    setup(x)
    build(x)
    launch(x)
    x
end

run(x :: AbstractModelConfig) = ModelRun(x)

"""
    setup(x::AbstractModelConfig)

Defaults to `default_ClimateModelSetup(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```
f=ClimateModels.RandomWalker
tmp=ModelConfig(model=f)
setup(tmp)
```
"""
setup(x :: AbstractModelConfig) = default_ClimateModelSetup(x)

function default_ClimateModelSetup(x::AbstractModelConfig)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    pth=pathof(x); !isdir(pth) ? mkdir(pth) : nothing

    if isa(x.model,Pkg.Types.PackageSpec)
        hasfield(Pkg.Types.PackageSpec,:url) ? url=x.model.url : url=x.model.repo.source
        @suppress Pkg.develop(url=url)
        if x.configuration=="anonymous"
            put!(x.channel,run_the_tests)
        else
            put!(x.channel,x.configuration)
        end
    elseif isa(x.model,Function)
        put!(x.channel,x.model)
    elseif isa(x.configuration,Function)
        put!(x.channel,x.configuration) 
    else
        nothing
    end

    !isdir(joinpath(pth,"log")) ? git_log_init(x) : nothing
    git_log_prm(x)

    fil_in=ClimateModels.Pkg.project().path
    fil_out=joinpath(pth,"log","Project.toml")
    if !isfile(fil_out)
        cp(fil_in,fil_out)
        git_log_fil(x,fil_out,"add Project.toml to log")
    end
    fil_in=joinpath(dirname(fil_in),"Manifest.toml")
    fil_out=joinpath(pth,"log","Manifest.toml")
    if !isfile(fil_out)
        cp(fil_in,fil_out)
        git_log_fil(x,fil_out,"add Manifest.toml to log")
    end

    return x
end

"""
    git_log_init(x :: AbstractModelConfig)

Create `log` subfolder, initialize git, and commit initial README.md
"""
function git_log_init(x :: AbstractModelConfig)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    p=pathof(x)
    !isdir(p) ? mkdir(p) : nothing
    p=joinpath(pathof(x),"log")
    !isdir(p) ? mkdir(p) : nothing

    f=joinpath(p,"README.md")
    q=pwd()
    cd(p)

    msg=("## Initial Setup\n\n",            
    "ID            = ```"*string(x.ID)*"```\n\n",
    "model         = ```"*string(x.model)*"```\n\n",
    "configuration = ```"*string(x.configuration)*"```\n\n")
    open(f, "w") do io
        write(io, msg...)
    end

    try 
        @suppress run(`$(git()) init -b main`)
    catch e
        @suppress run(`$(git()) init`)
    end
    run(`$(git()) add README.md`)
    try
        @suppress run(`$(git()) commit README.md -m "initial setup"`)        
    catch e
        run(`$(git()) config user.email "you@example.com"`)
        run(`$(git()) config user.name "Your Name"`)
        @suppress run(`$(git()) commit README.md -m "initial setup"`)
    end

    cd(q)
end

"""
    run_the_tests(x)

Default for launching model when it is a cloned julia package

```jldoctest; output = false
using ClimateModels, Pkg
tmp0=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
tmp1=ModelConfig(model=tmp0)
setup(tmp1)
build(tmp1)
launch(tmp1)

clean(tmp1)=="no task left in pipeline"

# output

true
```    
"""
function run_the_tests(x)
    hasfield(Pkg.Types.PackageSpec,:url) ? url=x.model.url : url=x.model.repo.source
    try
        @suppress Pkg.test(split(url,"/")[end][1:end-3])
    catch e
        txt=split(url,"/")[end][1:end-3]
        println("could not run Pkg.test($txt)")
    end
end

"""
    build(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```jldoctest; output = false
using ClimateModels
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)
build(tmp)

isa(tmp,AbstractModelConfig) # hide

# output

true
```
"""
build(x :: AbstractModelConfig) = default_ClimateModelBuild(x)

"""
    compile(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```jldoctest; output = false
using ClimateModels, Pkg
tmp0=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
tmp=ModelConfig(model=tmp0)
setup(tmp)
compile(tmp)

isa(tmp,AbstractModelConfig)

# output

true
```
"""
compile(x :: AbstractModelConfig) = default_ClimateModelBuild(x)

function default_ClimateModelBuild(x::AbstractModelConfig)
    isa(x.model,Pkg.Types.PackageSpec) ? build_the_pkg(x) : nothing
end

"""
   build_the_pkg(x)

Default for building/compiling model when it is a cloned julia package    
"""
function build_the_pkg(x)
    @suppress Pkg.build()
end

"""
    launch(x)

Defaults to `default_ClimateModelLaunch(x)` which consists in `take!(x)`
for `AbstractModelConfig`. Can be expected to be specialized for most 
concrete types of `AbstractModelConfig`

```
f=ClimateModels.RandomWalker
tmp=ModelConfig(model=f)
setup(tmp)
build(tmp)
launch(tmp)
```
"""
launch(x :: AbstractModelConfig) = default_ClimateModelLaunch(x)

function default_ClimateModelLaunch(x::AbstractModelConfig)
    !isempty(x.channel) ? take!(x) : "no task left in pipeline"
end

"""
    clean(x :: AbstractModelConfig)

Cancel any remaining task (x.channel) and rm the run directory (pathof(x))

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
    isdir(pathof(x)) ? rm(pathof(x),recursive=true) : nothing
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
    k=keys(x.status)
    n=length(k)
    if n>0
        for i in k
            j=x.status[i]
            println(i*" = $j")
        end
    else
        println("no status information")
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
    printstyled(io, "  ID            = ",color=:normal)
    printstyled(io, "$(z.ID)\n",color=:slateblue1)
    printstyled(io, "  model         = ",color=:normal)
    if isa(z.model,Pkg.Types.PackageSpec)
        hasfield(Pkg.Types.PackageSpec,:url) ? url=z.model.url : url=z.model.repo.source
        printstyled(io, "$(url)\n",color=:slateblue1)
    else
        printstyled(io, "$(z.model)\n",color=:slateblue1)
    end
    printstyled(io, "  configuration = ",color=:normal)
    printstyled(io, "$(z.configuration)\n",color=:slateblue1)
#    printstyled(io, "  status        = ",color=:normal)
#    printstyled(io, "$(z.status)\n",color=:slateblue1)    
    printstyled(io, "  run folder    = ",color=:normal)
    rundir=pathof(z)
    printstyled(io, "$(rundir)\n",color=:slateblue1)
    logdir=joinpath(pathof(z),"log")
    printstyled(io, "  log subfolder = ",color=:normal)
    printstyled(io, "$(logdir)\n",color=:slateblue1)
    for i in z.channel.data
        printstyled(io, "  task(s)       = ",color=:normal)
        printstyled(io, "$(i)\n",color=:slateblue1)
    end
end

"""
    put!(x :: AbstractModelConfig,v)

Adds `v` to x.channel (i.e. `put!(x.channel,v)`)

```jldoctest; output = false
using ClimateModels, Suppressor
tmp=ModelConfig()
setup(tmp)
put!(tmp,ClimateModels.RandomWalker)
ClimateModels.pause(tmp)
@suppress ClimateModels.monitor(tmp)
@suppress ClimateModels.help(tmp)
launch(tmp)

isa(tmp,AbstractModelConfig)

# output

true
```
"""
put!(x :: AbstractModelConfig,v) = put!(x.channel,v)
put!(x :: AbstractModelConfig) = put!(x.channel,x.model)
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
    taskID=string(UUIDs.uuid4())

    msg=("## Task Started \n\n name = ```"*string(tmp)*
                    "```  \n\n ID = "*taskID*" \n\n")
    git_log_msg(x,msg,"task started ["*taskID*"]")

    if isa(tmp,Function)
        tmp(x)
    else
        tmp
    end

    #rewrite current parameters to git log (if changed)
    git_log_prm(x)

    msg=("## Task Ended   \n\n name = ```"*string(tmp)*
                    "```  \n\n ID = "*taskID*" \n\n")
    git_log_msg(x,msg,"task ended   ["*taskID*"]")
end

"""
    git_log_msg(x :: AbstractModelConfig,msg,commit_msg)

Add message `msg` to the `log/README.md` file and git commit.
"""
function git_log_msg(x :: AbstractModelConfig,msg,commit_msg)
    p=joinpath(pathof(x),"log")
    f=joinpath(p,"README.md")
    if isfile(f)
        q=pwd()
        cd(p)
        open(f, "a") do io
            write(io, msg...)
        end
        @suppress run(`$(git()) commit README.md -m "$commit_msg"`)            
        cd(q)
    end
end

"""
    git_log_fil(x :: AbstractModelConfig,fil,commit_msg)

Commit changes to file `log/fil` with message `commit_msg`. If `log/fil` is 
unknown to git (i.e. commit errors out) then try adding `log/fil` first. 
"""
function git_log_fil(x :: AbstractModelConfig,fil,commit_msg)
    p=joinpath(pathof(x),"log")
    f=joinpath(p,fil)
    if isfile(f)
        q=pwd()
        cd(p)
        try
            @suppress run(`$(git()) commit $f -m "$commit_msg"`)            
        catch
            try
                run(`$(git()) add $f`)            
                @suppress run(`$(git()) commit $f -m "$commit_msg"`)
            catch
                @suppress println("no change to file -> skipping git commit")
            end
        end
        cd(q)
    end
end

"""
    git_log_prm(x :: AbstractModelConfig)

Add files found in `tracked_parameters/` (if any) to git log.
"""
function git_log_prm(x :: AbstractModelConfig)
    p=joinpath(pathof(x),"log")

    if !isempty(x.inputs)
        fil=joinpath(p,"tracked_parameters.toml")
        isfile(fil) ? txt="modify" : txt="initial"
        open(fil, "w") do io
            TOML.print(io, x.inputs)
        end
        q=pwd()
        cd(p)
        try
            run(`$(git()) add tracked_parameters.toml`)
            @suppress run(`$(git()) commit tracked_parameters.toml -m "$(txt) tracked_parameters.toml"`)
        catch e
            #should be skipped when no modification
        end
        cd(q)
    end

    if isdir(joinpath(p,"tracked_parameters"))
        q=pwd()
        cd(p)
        try
            commit_msg="add files in `tracked_parameters/` to git"
            tmp1=readdir("tracked_parameters")
            [run(`$(git()) add tracked_parameters/$i`) for i in tmp1]
            @suppress run(`$(git()) commit -m "$commit_msg"`)            
        catch e
            #not sure why this would fail
        end
    cd(q)
    end
end

"""
    git_log_show(x :: AbstractModelConfig)

Show the record of git commits that have taken place in the `log` folder.

```jldoctest; output = false
using ClimateModels
f=ClimateModels.RandomWalker
i=ClimateModels.OrderedDict(); i["NS"]=100
tmp=ModelConfig(model=f,inputs=i)
setup(tmp)
build(tmp)
launch(tmp)
ClimateModels.@suppress log(tmp)
isa(tmp,AbstractModelConfig)

# output

true
```
"""
function git_log_show(x :: AbstractModelConfig)
    p=joinpath(pathof(x),"log")
    q=pwd()
    cd(p)
    stdout=joinpath(pathof(x),"tmp.txt")
    @suppress run(pipeline(`$(git()) log --decorate --oneline --reverse`,stdout))
    cd(q)
    return readlines(stdout)
end

"""
    log(x :: AbstractModelConfig)

Show the record of git commits that have taken place in the `log` folder.
"""
log(x :: AbstractModelConfig) = git_log_show(x)

"""
    log(x :: AbstractModelConfig, commit_msg :: String; 
                 fil="", msg="", init=false, prm=false)

Keyword arguments work like this 

- `init==true` : create `log` subfolder, initialize git, and commit initial README.md
- `prm==true`  : add files found in `input` or `tracked_parameters/` (if any) to git log
- `!isempty(fil)` : commit changes to file `log/\$(fil)` with message `commit_msg`. 
   If `log/\$(fil)` is unknown to git (i.e. commit errors out) then try adding `log/\$(fil)` first. 

and are mutually exclusive (i.e., use only one at a time).

```
MC=run(ModelConfig(ClimateModels.RandomWalker,(NS=100,)))
MC.inputs[:NS]=200
msg="update tracked_parameters.toml (or skip if up to date)"
log(MC,msg,fil="tracked_parameters.toml",prm=true)
log(MC)
```
"""
function log(x :: AbstractModelConfig, commit_msg :: String; fil="", msg="", init=false, prm=false)
    init ? git_log_init(x) : nothing
    prm ? git_log_prm(x) : nothing
    !isempty(fil) ? git_log_fil(x :: AbstractModelConfig,fil,commit_msg) : nothing
    !isempty(msg) ? git_log_msg(x :: AbstractModelConfig,msg,commit_msg) : nothing
end

#train(x :: AbstractModelConfig,y) = missing
#compare(x :: AbstractModelConfig,y) = missing
#analyze(x :: AbstractModelConfig,y) = missing
