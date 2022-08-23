
module notebooks

using DataFrames, Downloads, UUIDs
import Base: open
import ClimateModels: AbstractModelConfig, setup, git_log_fil

function list()
    fil=Downloads.download("https://raw.githubusercontent.com/JuliaClimate/Notebooks/master/page/index.md")

    lines=readlines(fil);
    ii=findall( occursin.("[notebook url]",lines) )
    lines=lines[ii]

    sources=["gaelforget" "JuliaClimate" "JuliaOcean" "MarineEcosystemsJuliaCon2021.jl"]
    notebooks=DataFrame("folder" => [], "file" => [], "url" => [])

    for ii in lines
        tmp1=split(ii,"(")
        ii=findall( occursin.("[notebook url]",tmp1) )[1]
        tmp1=tmp1[ii+1]
        tmp1=split(tmp1,")")[1]

        tmp2=split(tmp1,"/")
        test=sum(tmp2[4].==sources)
        if test!==1
            println("Skipping : ")
            println(tmp1)
        end

        push!(notebooks, (tmp2[5], tmp2[end], string(tmp1) ))
    end

    notebooks
end

function download(path,notebooks)
    !isdir(path) ? mkdir(path) : nothing
    for i in 1:size(notebooks,1)
        tmp1=joinpath(path,notebooks[i,:folder])
        !isdir(tmp1) ? mkdir(tmp1) : nothing
        tmp2=joinpath(tmp1,notebooks[i,:file])
        try
            Downloads.download(notebooks[i,:url],tmp2)
        catch e
            println("Skipping : ")
            println(tmp2)
        end
    end
end

"""
    open(;notebook_path="",notebook_url="",
          pluto_url="http://localhost:1234/",pluto_options="...")

Open notebook in web-browser via Pluto. **Important note:** this assumes that the Pluto server is already running, e.g. from `Pluto.run()`, at URL `pluto_url` (by default, "http://localhost:1234/", should work on a laptop or desktop).

Simple examples:

```
notebooks.open(notebook_path="examples/defaults.jl")

nbs=notebooks.list()
notebooks.open(notebook_url=nbs.url[1])
```

More examples:

```
nbs=notebooks.list()
path=joinpath(tempdir(),"nbs")
notebooks.download(path,nbs)

pluto_url="https://ade.ops.maap-project.org/serverpmohyfxe-ws-jupyter/server-3100/pluto/"

ii=1
notebook_path=joinpath(path,nbs.folder[ii],nbs.file[ii])
notebooks.open(pluto_url=pluto_url,notebook_path=notebook_path)
```
"""
function open(;notebook_path="",notebook_url="",
    pluto_url="http://localhost:1234/",
    pluto_options="require_secret_for_open_links=false,require_secret_for_access=false")
    url0=split(pluto_url,"?")[1]
    length(url0)>0 && url0[end]=='/' ? url0=url0[1:end-1] : nothing

    if !isempty(notebook_url) && !isempty(url0)
        run(`open $(url0)/open\?url=$(notebook_url)`)
    elseif !isempty(notebook_path) && !isempty(url0)
        run(`open $(url0)/open\?path=$(notebook_path)`)
    else
        error("unknown pluto_url")
    end
end

"""
    unroll(PlutoFile::String; EnvPath="")

Extract main program, `Project.toml`, and `Manifest.toml` from Pluto notebook file `PlutoFile`. 
Save them in folder `EnvPath` (default = temporary folder).
Typical use case is shown below.

```
p,f=notebooks.unroll("CMIP6.jl")
cd(p)
Pkg.activate("./")
Pkg.instantiate()
include(f)
```
"""
function unroll(PlutoFile::String; EnvPath="")

    isempty(EnvPath) ? p=joinpath(tempdir(),string(UUIDs.uuid4())) : p = EnvPath
    !isdir(p) ? mkdir(p) : nothing

    tmp1=readlines(PlutoFile)
    l0=findall(occursin.(Ref("# ╔═╡ 00000000-0000-0000-0000-000000000001"),tmp1))[1]
    l1=findall(occursin.(Ref("# ╔═╡ Cell order:"),tmp1))[1]-1

    open(joinpath(p,"main.jl"), "w") do io
        println.(Ref(io), tmp1[1:l0-1])
    end

    tmp2=PlutoFile[1:end-3]*"_module.jl"
    tmp3=joinpath(string(p),basename(tmp2))
    isfile(tmp2) ? cp(tmp2,tmp3) : nothing

    open(joinpath(p,"tmp.jl"), "w") do io
        println.(Ref(io), tmp1[l0:l1])
    end
    include(joinpath(p,"tmp.jl"))

    open(joinpath(p,"Project.toml"), "w") do io
        print(io, PLUTO_PROJECT_TOML_CONTENTS);
    end

    open(joinpath(p,"Manifest.toml"), "w") do io
        print(io, PLUTO_MANIFEST_TOML_CONTENTS);
    end

    return p,"main.jl"
end

"""
    setup(MC::AbstractModelConfig,PlutoFile::String)

- Call default `setup` then
- Call `notebooks.unroll`
- Consolidate `main.jl` (activate, instantiate)

```
MC1=ModelConfig()
notebooks.setup(MC1,"examples/CMIP6.jl")

cd(joinpath(pathof(MC1),"run"))
include("main.jl")
```
"""
function setup(MC::AbstractModelConfig,PlutoFile::String)
    setup(MC)

    p=joinpath(pathof(MC),"run")
    notebooks.unroll(PlutoFile,EnvPath=p)

    fil_in=joinpath(p,"Project.toml")
    fil_out=joinpath(pathof(MC),"log","Project.toml")
    rm(fil_out)
    cp(fil_in,fil_out)
    git_log_fil(MC,fil_out,"update Project.toml")

    fil_in=joinpath(p,"Manifest.toml")
    fil_out=joinpath(pathof(MC),"log","Manifest.toml")
    rm(fil_out)
    cp(fil_in,fil_out)
    git_log_fil(MC,fil_out,"update Manifest.toml")

    mv(joinpath(p,"main.jl"),joinpath(p,"tmp1.jl"))
    tmp1=readlines(joinpath(p,"tmp1.jl"))

    tmp2=["using Pkg","reference_project=Pkg.project().path","Pkg.activate(\"./\")",
        "Pkg.instantiate()"," ",tmp1...," ","Pkg.activate(reference_project)"]

    open(joinpath(p,"main.jl"), "w") do io
        println.(Ref(io), tmp2)
    end
    
    return MC    
end

end
