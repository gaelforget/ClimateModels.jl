
import Base: put!, take!

abstract type AbstractModelConfig end

"""
    struct ModelConfig <: AbstractModelConfig

```
model :: Union{Function,String,Pkg.Types.PackageSpec} = "anonymous"
configuration :: Union{Function,String} = "anonymous"
options :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
inputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
outputs :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
status :: OrderedDict{Any,Any} = OrderedDict{Any,Any}()
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
    setup(x)

Defaults to `default_ClimateModelSetup(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```jldoctest
using ClimateModels, Pkg
tmp=ModelConfig(model=ClimateModels.RandomWalker)
setup(tmp)

isa(tmp,AbstractModelConfig)

# output

true
```
"""
function setup(x :: AbstractModelConfig)
    @suppress begin
        default_ClimateModelSetup(x)
    end
end

function default_ClimateModelSetup(x::AbstractModelConfig)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    pth=joinpath(x.folder,string(x.ID))
    !isdir(pth) ? mkdir(pth) : nothing
    if isa(x.model,Pkg.Types.PackageSpec)
        url=x.model.repo.source
        run(`$(git()) clone $url $pth`); #PackageSpec needs to be via web address for this to work
        Pkg.activate(pth)
        Pkg.instantiate()
        Pkg.build()
        Pkg.activate()
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

    return x
end

"""
    git_log_init(x :: AbstractModelConfig)

Create `log` subfolder, initialize git, and commit initial README.md
"""
function git_log_init(x :: AbstractModelConfig)
    !isdir(joinpath(x.folder)) ? mkdir(joinpath(x.folder)) : nothing
    p=joinpath(x.folder,string(x.ID))
    !isdir(p) ? mkdir(p) : nothing
    p=joinpath(x.folder,string(x.ID),"log")
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

    @suppress run(`$(git()) init -b main`)
    run(`$(git()) add README.md`)
    try
        @suppress run(`$(git()) commit README.md -m "initial setup" --author="John Doe <john@doe.org>"`)        
    catch e
        println("skipping `git` (may need `config --global` to be define)")
    end

    cd(q)
end

"""
    run_the_tests(x)

Default for launching model when it is a cloned julia package

```jldoctest
using ClimateModels, Pkg
tmp0=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
tmp1=setup(ModelConfig(model=tmp0))
launch(tmp1)

clean(tmp1)=="no task left in pipeline"

# output

true
```    
"""
function run_the_tests(x)
    @suppress begin
        pth=joinpath(x.folder,string(x.ID),"test")
        Pkg.activate(pth)
        Pkg.develop(path=joinpath(x.folder,string(x.ID)))
        #include(joinpath(pth,"runtests.jl"))
        Pkg.activate()
    end
end

"""
    build(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```jldoctest
using ClimateModels, Pkg
tmp0=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
tmp=ModelConfig(model=tmp0,configuration="anonymous")
setup(tmp)
build(tmp)

isa(tmp,AbstractModelConfig)

# output

true
```
"""
build(x :: AbstractModelConfig) = default_ClimateModelBuild(x)

"""
    compile(x)

Defaults to `default_ClimateModelBuild(x)`. Can be expected to be 
specialized for most concrete types of `AbstractModelConfig`

```jldoctest
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
    @suppress begin
        isa(x.model,String) ? Pkg.build(x.model) : nothing
        isa(x.model,Pkg.Types.PackageSpec) ? build_the_pkg(x) : nothing
    end
end

"""
   build_the_pkg(x)

Default for building/compiling model when it is a cloned julia package    
"""
function build_the_pkg(x)
    pth=joinpath(x.folder,string(x.ID))
    @suppress begin
        Pkg.activate(pth)
        Pkg.build()
        Pkg.activate()
    end
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
    clean(x :: AbstractModelConfig)

Cancel any remaining task (x.channel) and clean the run directory (via rm)

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
    printstyled(io, "$(z.ID)\n",color=:blue)
    printstyled(io, "  model         = ",color=:normal)
    if isa(z.model,Pkg.Types.PackageSpec)
        printstyled(io, "$(z.model.repo.source)\n",color=:blue)
    else
        printstyled(io, "$(z.model)\n",color=:blue)
    end
    printstyled(io, "  configuration = ",color=:normal)
    printstyled(io, "$(z.configuration)\n",color=:blue)
#    printstyled(io, "  status        = ",color=:normal)
#    printstyled(io, "$(z.status)\n",color=:blue)    
    printstyled(io, "  folder        = ",color=:normal)
    printstyled(io, "$(z.folder)\n",color=:blue)
    logdir=joinpath(string(z.ID),"log")
    printstyled(io, "  log subfolder = ",color=:normal)
    printstyled(io, "$(logdir)\n",color=:blue)
    for i in z.channel.data
        printstyled(io, "  task(s)       = ",color=:normal)
        printstyled(io, "$(i)\n",color=:blue)
    end
end

"""
    put!(x :: AbstractModelConfig,v)

Adds `v` to x.channel (i.e. `put!(x.channel,v)`)

```jldoctest
using ClimateModels, Pkg, Suppressor
tmp=ModelConfig()
setup(tmp)
put!(tmp,ClimateModels.RandomWalker)
pause(tmp)
@suppress monitor(tmp)
@suppress help(tmp)
launch(tmp)

isa(tmp,AbstractModelConfig)

# output

true
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
    p=joinpath(x.folder,string(x.ID),"log")
    f=joinpath(p,"README.md")
    if isfile(f)
        q=pwd()
        cd(p)
        open(f, "a") do io
            write(io, msg...)
        end
        try
            @suppress run(`$(git()) commit README.md -m "$commit_msg" --author="John Doe <john@doe.org>"`)            
        catch e
            println("skipping `git` (due to error?)")
        end
        cd(q)
    end
end

"""
    git_log_fil(x :: AbstractModelConfig,fil,commit_msg)

Commit changes to file `log/fil` with message `commit_msg`. If `log/fil` is 
unknown to git (i.e. commit errors out) then try adding `log/fil` first. 
"""
function git_log_fil(x :: AbstractModelConfig,fil,commit_msg)
    p=joinpath(x.folder,string(x.ID),"log")
    f=joinpath(p,fil)
    if isfile(f)
        q=pwd()
        cd(p)
        try
            @suppress run(`$(git()) commit $f -m "$commit_msg" --author="John Doe <john@doe.org>"`)            
        catch
            try
                @suppress run(`$(git()) add $f`)            
                @suppress run(`$(git()) commit $f -m "$commit_msg" --author="John Doe <john@doe.org>"`)            
            catch
                println("skipping `git`  (due to error?)")
            end
        end
        cd(q)
    end
end

"""
    git_log_prm(x :: AbstractModelConfig,msg,commit_msg)

Add files found in `tracked_parameters/` (if any) to git log.
"""
function git_log_prm(x :: AbstractModelConfig)
    p=joinpath(x.folder,string(x.ID),"log")

    if !isempty(x.inputs)
        fil=joinpath(p,"tracked_parameters.toml")
        isfile(fil) ? txt="modify" : txt="initial"
        open(fil, "w") do io
            TOML.print(io, x.inputs)
        end
        q=pwd()
        cd(p)
        try
            @suppress run(`$(git()) add tracked_parameters.toml`)
            @suppress run(`$(git()) commit tracked_parameters.toml -m "$(txt) tracked_parameters.toml" --author="John Doe <john@doe.org>"`)
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
            @suppress [run(`$(git()) add tracked_parameters/$i`) for i in tmp1]
            @suppress run(`$(git()) commit -m "$commit_msg" --author="John Doe <john@doe.org>"`)            
        catch e
            println("skipping `git`  (due to error?)")
        end
        cd(q)
    end
end

"""
    git_log_show(x :: AbstractModelConfig)

Show git log.
"""
function git_log_show(x :: AbstractModelConfig)
    p=joinpath(x.folder,string(x.ID),"log")
    q=pwd()
    cd(p)
    stdout=joinpath(x.folder,string(x.ID),"tmp.txt")
    try        
        @suppress run(pipeline(`$(git()) log --decorate --oneline --reverse`,stdout))
    catch e
        println("skipping `git`  (due to error?)")
    end
    cd(q)
    return readlines(stdout)
end

#train(x :: AbstractModelConfig,y) = missing
#compare(x :: AbstractModelConfig,y) = missing
#analyze(x :: AbstractModelConfig,y) = missing
