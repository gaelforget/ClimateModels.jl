
module downloads

using DataDeps, Dataverse, Glob

"""
    unpackDV(filepath)

Like DataDeps's `:unpack` but using `Dataverse.untargz` and remove the `.tar.gz` file.
"""    
function unpackDV(filepath; do_warn=false)
    tmp_path=Dataverse.untargz(filepath)
    tmp_path2=joinpath(tmp_path,basename(filepath)[1:end-7])
    tmp_path=(ispath(tmp_path2) ? tmp_path2 : tmp_path)
    if isdir(tmp_path)
        [mv(p,joinpath(dirname(filepath),basename(p))) for p in glob("*",tmp_path)]
        [println(joinpath(dirname(filepath),basename(p))) for p in glob("*",tmp_path)]
        rm(filepath)
    else
        rm(filepath)
        mv(tmp_path,joinpath(dirname(filepath),basename(tmp_path)))
    end
    do_warn ? println("done with unpackDV for "*filepath) : nothing
end

"""
    __init__datasets()

Register data dependency with DataDep.
"""
function __init__datasets()
    register(DataDep("IPCC","IPCC AR6 data",
        ["https://zenodo.org/record/5541768/files/IPCC-AR6-SPM-plus.tar.gz"],
        post_fetch_method=unpackDV))
end

"""
    add_datadep(nam::String)

Add data to the scratch space folder. Known options for `nam` include 
"release1", "release2", "release3", "release4", "release5", and "OCCA2HR1".

Under the hood this is the same as:

```
using Climatology
add_datadep("IPCC")
```
"""
function add_datadep(nam::String)
    withenv("DATADEPS_ALWAYS_ACCEPT"=>true) do
        if nam=="IPCC"
            datadep"IPCC"
        else
            println("unknown solution")
        end
    end
end

end
