module ClimateModelsCondaExt

using Conda, ClimateModels

function ClimateModels.conda(flag=:fair)
    if flag==:fair
        Conda.pip_interop(true)
        Conda.pip("install", "fair==1.6.4")
    elseif flag==:seaduck
        Conda.pip("install","numpy")
        Conda.pip("install","xarray")
        Conda.pip("install","dask")
        Conda.pip_interop(true)
        Conda.pip("install","seaduck")
        Conda.pip("install","pooch")
        Conda.pip("install","zarr")
#        Conda.pip("install","matplotlib")
#        Conda.pip("install","cartopy")
    end
end

end
