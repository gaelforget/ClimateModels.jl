
module notebooks

using DataFrames, Downloads, UUIDs
import Base: open

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

```
pluto_url="http://localhost:1234/"
#plut_url="https://notebooks.gesis.org/binder/jupyter/user/juliaclimate-notebooks-vx8glon1/pluto/"
#pluto_url="https://ade.ops.maap-project.org/serverpmohyfxe-ws-jupyter/server-3100/pluto/"
nbs=notebooks.list()

path=joinpath(tempdir(),"nbs")
notebooks.download(path,nbs)

ii=1
notebook_url=nbs.url[ii]
#notebook_path=joinpath("tutorials","jl",nbs.folder[ii],nbs.file[ii])
notebook_path=joinpath(path,nbs.folder[ii],nbs.file[ii])

notebooks.open(pluto_url,notebook_url=notebook_url)
#notebooks.open(pluto_url,notebook_path)
```
"""
function open(pluto_url="",notebook_path="";notebook_url="")
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
    extract_environment(PlutoFile::String; EnvPath="")

```
p=notebooks.extract_environment("CMIP6.jl")
Pkg.activate(p)
Pkg.instantiate()
include("CMIP6.jl")
```
"""
function extract_environment(PlutoFile::String; EnvPath="")

    isempty(EnvPath) ? p=joinpath(tempdir(),string(UUIDs.uuid4())) : p = EnvPath
    mkdir(p)

    tmp1=readlines(PlutoFile)
    l0=findall(occursin.(Ref("# ╔═╡ 00000000-0000-0000-0000-000000000001"),tmp1))[1]
    l1=findall(occursin.(Ref("# ╔═╡ Cell order:"),tmp1))[1]-1

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

    return p
end

end
