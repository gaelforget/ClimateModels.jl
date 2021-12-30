

import MITgcmTools: read_namelist

function read_namelist(x:: SPEEDY_config)

    fil=joinpath(pathof(x),"rundir/namelist.nml")
    nml=readlines(fil)
    i=findall([nml[i][1]!=='!' for i in 1:length(nml)])
    nml=nml[i]

    i0=findall([nml[i][1]=='&' for i in 1:length(nml)])
    i1=findall([nml[i][1]=='/' for i in 1:length(nml)])

    tmp0=OrderedDict()
    for i in 1:length(i0)
        tmp1=Symbol(nml[i0[i]][2:end])
        tmp2=OrderedDict()
        for j in i0[i]+1:i1[i]-1
            tmp3=split(nml[j],'=')
            tmp2[tmp3[1]]=parse(Int,tmp3[2])
        end
        tmp0[tmp1]=tmp2
    end

    return tmp0
end


