
using GLMakie, NCDatasets, Dates

choice_variable=1
do_recording=false

##

fil_mp4="vishack2022_gf$(choice_variable)_v1.mp4"

if choice_variable==1
    fil="2t_167_hipq-tc1.sfc-rll.vishack-02x02.nc4"
    txt="variable = log10( |δ(T)| ) -- time = "
    cr=(-5.0,0.0)
elseif choice_variable==2
    fil="i10fg_228029_hipq-tc1.sfc-rll.vishack-02x02.nc4"
    txt="variable = i10fg -- time = "
    cr=(0.0,20.0)
else
    fil="xtprate_99999_hipq-tc1.sfc-rll.vishack-02x02.nc4"
    txt="variable = log10( xtprate ) -- time = "
    cr=(-7.0,-3.0)
end

##

sqgrad(x,i,j) = sqrt(0.25*( 
    (x[i,j]-x[i,j-1])^2+(x[i,j]-x[i,j+1])^2+
    (x[i,j]-x[i-1,j])^2+(x[i,j]-x[i+1,j])^2 ))

Χ(x) = x<10 ? "0$x" : "$x"
Χ(x::DateTime) = Χ(Dates.day(x))*","*Χ(Dates.hour(x))*","*Χ(Dates.minute(x))
    
##

ds=Dataset(fil)
s=(ds.dim["lon"],ds.dim["lat"])

"""
y=prep(100)
"""
function prep(t)
    if choice_variable==1
        x=ds["2t"][:,:,t]
        [log10(sqgrad(x,i,j)) for i in 2:s[1]-1, j in 2:s[2]-1]
    elseif choice_variable==2
        ds["i10fg"][:,:,t]
    else
        log10.(ds["xtprate"][:,:,t])
    end
end

"""
x=NaN*prep(1)
y=NaN*prep(1)
prep!(y,x,100)
"""
function prep!(y,x,t)
    if choice_variable==1
        x.=ds["2t"][:,:,t]
        y[2:siz[1]-1,2:siz[2]-1].=[log10(sqgrad(x,i,j)) for i in 2:siz[1]-1, j in 2:siz[2]-1]
    elseif choice_variable==2
        y.=ds["i10fg"][:,:,t]
    else
        y.=log10.(ds["xtprate"][:,:,t])
    end
end

##

function quickplot(y,cr;title="")
    f=Figure()
    ax=Axis(f[1,1],title=title)
    hm=heatmap!(ax,ds["lon"],ds["lat"],y,colorrange=cr)
    Colorbar(f[1,2], hm, height = Relative(0.65))
    f
end

##

t=Observable(1)
xx=@lift(prep($t))
tt=@lift(txt*Χ( ds["time"][$t] ))

f=quickplot(xx,cr,title=tt)

if do_recording
    record(f, fil_mp4, 1:912; framerate = 10) do i
        t[]=i
    end
end

##

#close(ds)

f
