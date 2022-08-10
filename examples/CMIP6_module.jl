module demo

    using ClimateModels, CairoMakie, Statistics, Dates
    using Downloads, CSV, DataFrames, Zarr, CFTime, NetCDF

	function cmip6_stores_list()
		url="https://storage.googleapis.com/cmip6/cmip6-zarr-consolidated-stores.csv"
		cmip6_zarr_consolidated_stores=Downloads.download(url)	
		ξ = CSV.read(cmip6_zarr_consolidated_stores,DataFrame)
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

    function plot_seasonal_cycle(GA,meta)

        nm=meta["long_name"]*" in "*meta["units"]
        ny=Int(length(GA.time)/12)
        y=fill(0.0,(ny,12))
        [y[:,i].=GA.tas[i:12:end] for i in 1:12]
        
    #	s=plot([0.5:1:11.5],vec(mean(y,dims=1)), xlabel="month",ylabel=nm,
    #	leg = false, title=",frmt=:png)
    
        f=Figure(resolution = (900, 600))
        a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
        title=meta["institution_id"]*" (global mean, seasonal cycle)")		
        lines!(a,collect(0.5:1:11.5),vec(mean(y,dims=1)),xlabel="month",
        ylabel=nm,label=meta["institution_id"],linewidth=2)
    
        f
    end

    function plot_time_series(GA,meta)
        nm=meta["long_name"]*" in "*meta["units"]

        f=Figure(resolution = (900, 600))
        a = Axis(f[1, 1],xlabel="year",ylabel="degree C",
        title=meta["institution_id"]*" (global mean, Month By Month)")		
        tim=Dates.year.(GA.time[1:12:end])
        lines!(a,tim,GA.tas[1:12:end],xlabel="time",ylabel=nm,label="month 1",linewidth=2)
        [lines!(a,tim,GA.tas[i:12:end], label = "month $i") for i in 2:12]
        f
    end

    function plot_mean_maps(lon,lat,tas,meta)
        nm=meta["long_name"]*" in "*meta["units"]

        f=Figure(resolution = (900, 600))
        a = Axis(f[1, 1],xlabel="longitude",ylabel="latitude",
        title=meta["institution_id"]*" (time mean)")		
        hm=CairoMakie.heatmap!(a,lon[:], lat[:], tas[:,:], title=nm*" (time mean)")
        Colorbar(f[1,2], hm, height = Relative(0.65))
        f
    end

end