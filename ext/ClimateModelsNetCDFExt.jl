module ClimateModelsNetCDFExt

    using NetCDF
    import ClimateModels: write_CMIP6_mean, read_CMIP6_mean, ModelConfig

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

    function read_CMIP6_mean(file,nam)
        lon = Float64.(NetCDF.open(file, "lon")[:])
        lat = Float64.(NetCDF.open(file, "lat")[:])
        var = Float64.(NetCDF.open(file, nam)[:,:,1])
        return lon,lat,var
    end

end
