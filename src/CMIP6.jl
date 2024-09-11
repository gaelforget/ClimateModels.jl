module CMIP6

    using ClimateModels, Statistics, Dates, CFTime
    using Downloads, CSV, DataFrames
    import ClimateModels: read_Zarr, write_CMIP6_mean

    """
        cmip6_stores_list()

    Download list from <https://storage.googleapis.com/cmip6/cmip6-zarr-consolidated-stores.csv>
    , read from file, and return as DataFrame.

    ```
    ξ=CMIP6.cmip6_stores_list()
    ii=findall( (ξ.institution_id.=="IPSL").&(ξ.table_id.=="Amon").&
                (ξ.variable_id.=="tas").&(ξ.experiment_id.=="historical") )
    tmp1=ξ[ii,:]
    ```
    """
	function cmip6_stores_list()
		url="https://storage.googleapis.com/cmip6/cmip6-zarr-consolidated-stores.csv"
		cmip6_zarr_consolidated_stores=Downloads.download(url)	
		ξ = CSV.read(cmip6_zarr_consolidated_stores,DataFrame)
	end

    function cmip_averages(ξ,institution_id="IPSL",source_id="IPSL-CM6A-LR",
        variable_id="tas",ensemble_member=1)

        ξ=cmip6_stores_list()

        # get model ensemble list
        i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
        (ξ[!,:variable_id].==variable_id).&(ξ[!,:experiment_id].=="historical").&
        (ξ[!,:institution_id].==institution_id) )
        μ=ξ[i,:]
    
        # access one model ensemble member
        url=μ.zstore[ensemble_member]
        ζ = read_Zarr(url)
                
        meta=Dict("institution_id" => institution_id,"source_id" => source_id,
            "variable_id" => variable_id, "units" => ζ[variable_id].attrs["units"],
            "long_name" => ζ[variable_id].attrs["long_name"])
    
        # time mean global map
        m = convert(Array{Union{Missing, Float32},3},ζ[variable_id][:,:,:])
        m = dropdims(mean(m,dims=3),dims=3)
    
        mm=Dict("lon" => ζ["lon"], "lat" => ζ["lat"], "m" => m)
    
        Å=cellarea_calc(ζ["lon"][:],ζ["lat"][:])
        #Å=cellarea_read(ξ,source_id,"areacella")
        #Å=cellarea_read(ξ,source_id,"areacellr")
    
        # time evolving global mean
        t = ζ["time"]
        tt = timedecode(t[:], t.attrs["units"], t.attrs["calendar"])
        t = [DateTime(Dates.year(t),Dates.month(t),Dates.day(t)) for t in tt]
    
        y = ζ[variable_id][:,:,:]
        y=[sum(y[:, :, i].*Å) for i in 1:length(t)]./sum(Å)
    
        gm=Dict("t" => t, "y" => y)
    
        return mm,gm,meta
    end
   
    # compute model grid cell areas
    function cellarea_calc(lon0,lat0)
        dlon=(lon0[2]-lon0[1])
        dlat=(lat0[2]-lat0[1])
        lat00=[lat0[1]-dlat/2, 0.5*(lat0[2:end]+lat0[1:end-1])...,lat0[end]+dlat/2]
        EarthArea=510072000*1e6
        cellarea(lat1,lat2,dlon)= (EarthArea / 4 / pi) * (pi/180)*abs(sind(lat1)-sind(lat2))*dlon
        [cellarea(lat00[i],lat00[i+1],dlon) for j in 1:length(lon0), i in 1:length(lat0)]
    end

    # (alternative) read model grid cell areas from file
    function cellarea_read(ξ,source_id,areacellname="areacella")
        ii=findall( (ξ[!,:source_id].==source_id).&(ξ[!,:variable_id].==areacellname) )
        μ=ξ[ii,:]
        cmip6,p = Zarr.storefromstring(μ.zstore[end])
        ζζ = zopen(cmip6,path=p)
        ζζ[areacellname][:, :]
    end
    
    ##

    function main(x)

        ξ=cmip6_stores_list()

        #1. main computation (or, model run) = access cloud storage + compute averages
    
        (mm,gm,meta)=cmip_averages(ξ,x.inputs["institution_id"],
            x.inputs["source_id"],x.inputs["variable_id"],1)
    
        #2. output results
    
        pth=joinpath(pathof(x),"output")
        !ispath(pth) ? mkdir(pth) : nothing
    
        #2.1 save results to file (CSV)
    
        fil=joinpath(pth,"GlobalAverages.csv")
        df = DataFrame(time = gm["t"], tas = gm["y"])
        CSV.write(fil, df)
        
        #2.2 save results to file (NetCDF)
        write_CMIP6_mean(x,mm,meta)
    
        #2.3 save parameters to file (TOML)
        
        fil=joinpath(pth,"Details.toml")
        open(fil, "w") do io
            ClimateModels.TOML.print(io, meta)
        end
        
        return x
    end    

end

