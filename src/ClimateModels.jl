module ClimateModels

using UUIDs, Pkg, Git

export AbstractModelConfig, ModelConfig
export clean, build, compile, setup, launch
export monitor, help, put!, take!, pause
#export train, compare, analyze
#export cmip

include("interface.jl")
#include("access.jl")

"""
   RandomWalker(x)

Random Walk in 2D over N=10000 steps. Used for examples.  
"""
function RandomWalker(x)
    N=10000
    m=zeros(N,2)
    [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:N]
    return m
end

end