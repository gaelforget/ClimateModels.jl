
module notebooks

using DataFrames, Downloads, UUIDs, OrderedCollections, Pkg
import Base: open
import ClimateModels: PlutoConfig, setup, git_log_fil, default_ClimateModelSetup

"""
    notebooks.list()

List downloadable notebooks based on the `JuliaClimate/Notebooks` webpage.     
"""
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

    #eliminate duplicates
    test0=zeros(size(notebooks,1))
    for j in 1:length(test0)-1
        tmp=[notebooks[i,:]==notebooks[j,:] for i in j+1:length(test0)]
        [test0[jj+j]=1 for jj in findall(tmp)]
    end
    notebooks=notebooks[findall(test0.==0),:]

    notebooks
end

"""
    notebooks.download(path,nbs)

Download notebooks/files listed in `nbs` to `path`.

If `nbs.file[i]` is found at `nbs.url[i]` then download it to `path`/`nbs.folder[i]`.  

If a second file is found at `nbs.url[i][1:end-3]*"_module.jl"` then we download it too.

```
using ClimateModels, UUIDs
path=joinpath(tempdir(),string(UUIDs.uuid4()))

nbs=notebooks.list()
notebooks.download(path,nbs)
```

or 

```
using DataFrames
url0="https://raw.githubusercontent.com/JuliaClimate/IndividualDisplacements.jl/master/examples/worldwide/"

nbs2=DataFrame( "folder" => ["IndividualDisplacements.jl","IndividualDisplacements.jl"], 
                "file" => ["ECCO_FlowFields.jl","OCCA_FlowFields.jl"], 
                "url" => [url0*"ECCO_FlowFields.jl",url0*"OCCA_FlowFields.jl"])
notebooks.download(path,nbs2)
```
"""
function download(path,nbs)
    !isdir(path) ? mkdir(path) : nothing
    for i in 1:size(nbs,1)
        tmp1=joinpath(path,nbs[i,:folder])
        !isdir(tmp1) ? mkdir(tmp1) : nothing
        tmp2=joinpath(tmp1,nbs[i,:file])
        try
            Downloads.download(nbs[i,:url],tmp2)
            try
                Downloads.download(nbs[i,:url][1:end-3]*"_module.jl",tmp2[1:end-3]*"_module.jl")
            catch
                nothing
            end
        catch e
            println("Skipping : ")
            println(tmp2)
        end
    end
end

"""
    open(;notebook_path="",notebook_url="",
          pluto_url="http://localhost:1234/",pluto_options="...")

Open notebook in web-browser via Pluto. 

**Important note:** this assumes that the Pluto server is already running, e.g. from `Pluto.run()`, at URL `pluto_url` (by default, "http://localhost:1234/", should work on a laptop or desktop).

Examples:

```
nbs=notebooks.list()
notebooks.open(notebook_url=nbs.url[1])

notebooks.open(notebook_path="examples/defaults.jl")
pluto_url="https://ade.ops.maap-project.org/serverpmohyfxe-ws-jupyter/server-3100/pluto/"
notebooks.open(notebook_path="examples/defaults.jl",pluto_url=pluto_url)
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
    unroll(PlutoFile::String; EnvPath="", ModuleFile="")

Split up Pluto notebook file (`PlutoFile`) into main program (_main.jl_), 
_Project.toml_, _Manifest.toml_, and _CellOrder.txt_.

- these files are saved to folder `p` (`EnvPath` or a temporary folder by default)
- `unroll` returns output path `p` and main program file name
- `unroll` optionally copies companion file `mf` to `p` (if file `mf` exists)
- default `mf` is `PlutoFile[1:end-3]*"_module.jl"` unless `ModuleFile` is specified
- the `reroll` function can be used to reassemble as a Pluto notebook 

For example:

```
using Pkg
p,f=notebooks.unroll("CMIP6.jl")
Pkg.activate(p)
Pkg.update()
n=notebooks.reroll(p,f)
```
"""
function unroll(PlutoFile::String; EnvPath="", ModuleFile="")

    isempty(EnvPath) ? p=joinpath(tempdir(),string(UUIDs.uuid4())) : p = EnvPath
    !isdir(p) ? mkdir(p) : nothing

    tmp1=readlines(PlutoFile)
    l0=findall(occursin.(Ref("# ╔═╡ 00000000-0000-0000-0000-000000000001"),tmp1))[1]
    l1=findall(occursin.(Ref("# ╔═╡ Cell order:"),tmp1))[1]-1

    open(joinpath(p,"main.jl"), "w") do io
        println.(Ref(io), tmp1[1:l0-1])
    end

    isempty(ModuleFile) ? mf=PlutoFile[1:end-3]*"_module.jl" : mf = ModuleFile
    tmp3=joinpath(string(p),basename(mf))
    isfile(mf) ? cp(mf,tmp3) : nothing

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

    open(joinpath(p,"CellOrder.txt"), "w") do io
        println.(io, tmp1[l1:end]);
    end

    return p,"main.jl"
end

"""
    reroll(p,f; PlutoFile="notebook.jl")

The `reroll` function can be used to reassemble as a Pluto notebook that was previously `unroll`'ed.

See `unroll` documentation for an example.    
"""
function reroll(p,f; PlutoFile="notebook.jl")

    tmp1=readlines(joinpath(p,f))
    tmp2=readlines(joinpath(p,"Project.toml"))
    tmp3=readlines(joinpath(p,"Manifest.toml"))
    tmp4=readlines(joinpath(p,"CellOrder.txt"))

    open(joinpath(p,PlutoFile), "w") do io
        println.(io, tmp1)
        
        println(io, "")
        println(io, "# ╔═╡ 00000000-0000-0000-0000-000000000001")
        println(io, "PLUTO_PROJECT_TOML_CONTENTS = \"\"\"")        
        println.(io, tmp2)
        println(io, "\"\"\"")
        
        println(io, "")
        println(io, "# ╔═╡ 00000000-0000-0000-0000-000000000002")
        println(io, "PLUTO_MANIFEST_TOML_CONTENTS = \"\"\"")
        println.(io, tmp3)
        println(io, "\"\"\"")

        println.(io, tmp4)
    end

    return joinpath(p,PlutoFile)
end

"""
    setup(MC::PlutoConfig;IncludeManifest=true)

- call `default_ClimateModelSetup`
- call `unroll`
- add `notebook_launch` to tasks

```
MC1=PlutoConfig(model="examples/CMIP6.jl")
setup(MC1)
build(MC1)
launch(MC1)
```
"""
function setup(MC::PlutoConfig;IncludeManifest=true)
    default_ClimateModelSetup(MC)

    p=joinpath(pathof(MC),"run")
    unroll(MC.model,EnvPath=p)

    fil_in=joinpath(p,"Project.toml")
    fil_out=joinpath(pathof(MC),"log","Project.toml")
    rm(fil_out)
    cp(fil_in,fil_out)
    git_log_fil(MC,fil_out,"update Project.toml")

    if IncludeManifest
        fil_in=joinpath(p,"Manifest.toml")
        fil_out=joinpath(pathof(MC),"log","Manifest.toml")
        rm(fil_out)
        cp(fil_in,fil_out)
        git_log_fil(MC,fil_out,"update Manifest.toml")
    else
        rm(joinpath(p,"Manifest.toml"))
    end

    put!(MC,notebook_launch)
    
    return MC    
end

function notebook_launch(MC::PlutoConfig)
    try
        pth=pwd()
    catch e
        cd()
    end
    pth=pwd()
    cd(joinpath(pathof(MC),"run"))
    tmp=["STOP NORMAL END"]

    reference_project=Pkg.project().path
    Pkg.activate(".")
    Pkg.instantiate()

    try
        include("main.jl")
    catch e
        tmp[1]="model run may have failed"
    end

    Pkg.activate(reference_project)
    cd(pth)

    return tmp[1]
end

end
