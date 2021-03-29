# # Random Walker
#
# Here we setup, run and plot a two-dimensional random walker path.

using ClimateModels, Plots, CSV, DataFrames

# ## Formulate Model
#
# This simple model steps randomly, `N` times, on a `x,y` plane starting from `0,0`.

function RandomWalker(x::AbstractModelConfig)
    #model run
    N=10000
    m=zeros(N,2)
    [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:N]

    #output to file
    df = DataFrame(x = m[:,1], y = m[:,2])
    fil=joinpath(x.folder,string(x.ID),"RandomWalker.csv")
    CSV.write(fil, df)

    return m
end

# ## Setup And Run Model
#
# - `ModelConfig` defines the model into data structure `m`
# - `setup` prepares the model to run in a temporary folder
# - `launch` runs the `RandomWalker` model which writes results to file
#
# _Note: `RandomWalker` returns results also directly as an Array, but this is generally not an option for most, larger, models_

m=ModelConfig(model=RandomWalker)
setup(m)
xy=launch(m);

# ## Plot Results
#
# Afterwards, one often uses model output for further analysis. Here we just plot the random walker path from the output file.

fil=joinpath(m.folder,string(m.ID),"RandomWalker.csv")
output = CSV.File(fil) |> DataFrame
plot(output.x,output.y) #, fmt=:png)