
using CSV, DataFrames

"""
RandomWalker(x::AbstractModelConfig)

Random Walk in 2D over `NS` steps (100 by default). The results are returned as an array 
and saved to a text file (`RandomWalker.csv` by default) inside the `run` folder 
(`pathof(x)` by default). 

Note: the `setup` method should be invoked to create the `run` folder beforehand.
"""
function RandomWalker(x::AbstractModelConfig)
 #model run
 haskey(x.inputs,"NS") ? NS=x.inputs["NS"] : NS=100
 haskey(x.inputs,:NS) ? NS=x.inputs[:NS] : nothing
 m=zeros(NS,2)
 [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:NS]

 #output to file
 haskey(x.inputs,"filename") ? fil0=x.inputs["filename"] : fil0="RandomWalker.csv"
 haskey(x.inputs,:filename) ? fil0=x.inputs[:filename] : nothing
 if isdir(pathof(x))
     df = DataFrame(x = m[:,1], y = m[:,2])
     fil=joinpath(pathof(x),fil0)
     CSV.write(fil, df)
 end

 return m
end
