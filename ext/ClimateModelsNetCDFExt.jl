module ClimateModelsNetCDFExt

    using NetCDF
    import ClimateModels: write_CMIP6_mean, ModelConfig

    function write_CMIP6_mean(x::ModelConfig,mm,meta)
        pth=joinpath(pathof(x),"output")
        filename = joinpath(pth,"MeanMaps.nc")
        varname  = x.inputs["variable_id"]
        (ni,nj)=size(mm["m"])
        nccreate(filename, "tas", 
            "lon", collect(Float32.(mm["lon"][:])), 
            "lat", collect(Float32.(mm["lat"][:])), atts=meta)
        ncwrite(Float32.(mm["m"]), filename, varname)
    end

end
