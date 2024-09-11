module ClimateModelsZarrExt

    using Zarr
    import ClimateModels: read_Zarr
    
    function read_Zarr(url; path=tempdir(),fill_as_missing=true)
        cmip6,p = Zarr.storefromstring(url)
        ζ = zopen(cmip6,path=p,fill_as_missing=true)
    end


    """
        benchmark_Zarr(url)

    Benchmark method suggested @ <https://juliaio.github.io/Zarr.jl/latest/operations/>

    ```
    url_day="gs://cmip6/CMIP6/CMIP/IPSL/IPSL-CM6A-LR/historical/r9i1p1f1/day/tas/gr/v20190614/"
    url_mon="gs://cmip6/CMIP6/CMIP/IPSL/IPSL-CM6A-LR/historical/r2i1p1f1/Amon/tas/gr/v20180803/"
    @time CMIP6.benchmark_Zarr(url_mon)
    ```
    """
    function benchmark_Zarr(url)
        g = zopen(url, consolidated=true)
        
        latweights = reshape(cosd.(g["lat"])[:],1,143,1);
        t_celsius = g["tas"].-273.15
        t_w = t_celsius .* latweights
        
        mean(t_w, dims = (1,2))./mean(latweights)
    end

end

