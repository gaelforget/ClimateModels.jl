#see:
#?vishack2022.setup

module vishack2022

using GLMakie, NCDatasets, Dates

"""
For more information on what this relates to, see 

- event : https://events.ecmwf.int/event/305/
- repo : https://github.com/vismethack/challenges
- data set : https://doi.org/10.5281/zenodo.6633929
        - VisMetHack2022: Visualizing winds and surface variables from the ECMWF IFS 1-km nature run (1.0.2) [Data set]. Zenodo. 
        - Anantharaj, Valentine, Hatfield, Samuel, Vukovic, Milana, Polichtchouk, Inna, & Wedi, Nils. (2022). 

User Directions:

```
pa=vishack2022.setup()
ds=vishack2022.Dataset(pa.fil)

t=1
xx=vishack2022.prep(ds,pa,t)
tt=pa.txt*vishack2022.Χ( ds["time"][t] )
f=vishack2022.build_plot(ds,pa,xx,title=tt)

vishack2022.build_movie(ds,pa;times=1:100)
```
"""
function setup(;choice_variable=1,input_path="IFS1km_data",
    colormap=:none,colorrange=())
    if choice_variable==1
        name="f(2t)"
        fil=joinpath(input_path,"2t_167_hipq-tc1.sfc-rll.vishack-02x02.nc4")
        txt="variable = log10( |δ(T)| ) -- time = "
        cr=(-3.0,0.0)
        crmp=:delta
    elseif choice_variable==2
        name="f(i10fg)"
        fil=joinpath(input_path,"i10fg_228029_hipq-tc1.sfc-rll.vishack-02x02.nc4")
        txt="variable = i10fg -- time = "
        cr=(0.0,20.0)
        crmp=:thermal
    else
        name="f(xtprate)"
        fil=joinpath(input_path,"xtprate_99999_hipq-tc1.sfc-rll.vishack-02x02.nc4")
        txt="variable = log10( xtprate ) -- time = "
        cr=(-6.0,-4.0)
        crmp=:BuPu
    end
    fil_mp4=joinpath(tempdir(),"IFS1km_$(name).mp4")
    !isempty(colorrange) ? cr=colorrange : nothing
    colormap !== :none ? crmp=colormap : nothing

    ds=Dataset(fil)
    siz=(ds.dim["lon"],ds.dim["lat"])
    close(ds)

    variable=(ID=choice_variable,colorrange=cr,colormap=crmp,file=fil,txt=txt)
    
    (va=variable,size=siz,movie=fil_mp4)
end

sqgrad(x,i,j) = sqrt(0.25*( 
    (x[i,j]-x[i,j-1])^2+(x[i,j]-x[i,j+1])^2+
    (x[i,j]-x[i-1,j])^2+(x[i,j]-x[i+1,j])^2 ))

Χ(x) = x<10 ? "0$x" : "$x"
Χ(x::DateTime) = Χ(Dates.day(x))*","*Χ(Dates.hour(x))*","*Χ(Dates.minute(x))
    
function prep(ds,pa,t)
    if pa.va.ID==1
        x=ds["2t"][:,:,t]
        [log10(sqgrad(x,i,j)) for i in 2:pa.size[1]-1, j in 2:pa.size[2]-1]
    elseif pa.va.ID==2
        ds["i10fg"][:,:,t]
    else
        log10.(ds["xtprate"][:,:,t])
    end
end

function prep!(ds,pa,t,x,y)
    if pa.va.ID==1
        x.=ds["2t"][:,:,t]
        y[2:pa.size[1]-1,2:pa.size[2]-1].=
            [log10(sqgrad(x,i,j)) for i in 2:pa.size[1]-1, j in 2:pa.size[2]-1]
    elseif pa.va.ID==2
        y.=ds["i10fg"][:,:,t]
    else
        y.=log10.(ds["xtprate"][:,:,t])
    end
end

function build_plot(ds,pa,y;title="")
    f=Figure()
    ax=Axis(f[1,1],title=title)
    hm=heatmap!(ax,ds["lon"],ds["lat"],y,
    colorrange=pa.va.colorrange,colormap=pa.va.colormap)
    Colorbar(f[1,2], hm, height = Relative(0.65))
    f
end

function build_movie(ds,pa;times=1:912)
    t=Observable(1)
    xx=@lift(prep(ds,pa,$t))
    tt=@lift(pa.va.txt*Χ( ds["time"][$t] ))
    f=build_plot(ds,pa,xx,title=tt)
    record(f, pa.movie, times; framerate = 10) do i
        t[]=i
    end
end

end
