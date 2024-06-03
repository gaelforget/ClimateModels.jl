module demo

    using ClimateModels, Statistics, Dates, CFTime
    using Downloads, CSV, DataFrames, Zarr

    """
        cmip6_stores_list()

    Download list from <https://storage.googleapis.com/cmip6/cmip6-zarr-consolidated-stores.csv>
    , read from file, and return as DataFrame.

    ```
    ξ=demo.cmip6_stores_list()
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

    """
        benchmark_Zarr(url)

    Benchmark method suggested @ <https://juliaio.github.io/Zarr.jl/latest/operations/>

    ```
    url_day="gs://cmip6/CMIP6/CMIP/IPSL/IPSL-CM6A-LR/historical/r9i1p1f1/day/tas/gr/v20190614/"
    url_mon="gs://cmip6/CMIP6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Amon/tas/gr/v20180803/"
    @time demo.benchmark_Zarr(url_mon)
    ```
    """
    function benchmark_Zarr(url)
        g = zopen(url, consolidated=true)
        
        latweights = reshape(cosd.(g["lat"])[:],1,143,1);
        t_celsius = g["tas"].-273.15
        t_w = t_celsius .* latweights
        
        mean(t_w, dims = (1,2))./mean(latweights)
    end

    function cmip_averages(ξ,institution_id="IPSL",source_id="IPSL-CM6A-LR",
        variable_id="tas",ensemble_member=1)

        # get model ensemble list
        i=findall( (ξ[!,:activity_id].=="CMIP").&(ξ[!,:table_id].=="Amon").&
        (ξ[!,:variable_id].==variable_id).&(ξ[!,:experiment_id].=="historical").&
        (ξ[!,:institution_id].==institution_id) )
        μ=ξ[i,:]
    
        # access one model ensemble member
        cmip6,p = Zarr.storefromstring(μ.zstore[ensemble_member])
        ζ = zopen(cmip6,path=p,fill_as_missing=true)
        
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

end
