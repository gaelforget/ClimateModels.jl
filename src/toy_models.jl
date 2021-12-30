
"""
RandomWalker(x::AbstractModelConfig)

Random Walk in 2D over `NS` steps (100 by default). Returns the results to as an array and 
saves them to a `.csv` file (_RandomWalker.csv_ by default) inside the run directory 
(`pathof(x)` by default), if `setup` method has been invoked to create it.
"""
function RandomWalker(x::AbstractModelConfig)
 #model run
 haskey(x.inputs,"NS") ? NS=x.inputs["NS"] : NS=100
 m=zeros(NS,2)
 [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:NS]

 #output to file
 haskey(x.inputs,"filename") ? fil=x.inputs["filename"] : fil="RandomWalker.csv"
 if isdir(pathof(x))
     df = DataFrame(x = m[:,1], y = m[:,2])
     fil=joinpath(pathof(x),"RandomWalker.csv")
     CSV.write(fil, df)
 end

 return m
end
