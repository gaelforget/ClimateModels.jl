
"""
    run_one_notebook(fil::String)

```
fil="notebooks/ClimateModels.jl/CMIP6.jl"
MC=run_one_notebook(fil)
```

or

```
using ClimateModels

nbs=notebooks.list()
path0=joinpath(tempdir(),"notebooks")
#notebooks.download(path0,nbs)

nnbs=size(nbs,1)
MCs = Array{AbstractModelConfig}(undef, nnbs);
for ii in 1:nnbs
  fil=joinpath(path0,nbs[ii,:folder],nbs[ii,:file])
  MCs[ii]=run_one_notebook(fil)
  show(MCs[ii])
end
```
"""
function run_one_notebook(fil::String;IncludeManifest=true)
  reference_path=pwd()
  MC=ModelConfig(model=basename(fil))
  notebooks.setup(MC,fil,IncludeManifest=IncludeManifest)
  cd(joinpath(pathof(MC),"run"))
  include(joinpath(pathof(MC),"run","main.jl"))
  cd(reference_path)
  return MC
end

