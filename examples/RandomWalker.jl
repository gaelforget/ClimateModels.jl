# # Default Behavior (Julia Function)
#
# Here we setup, run and plot a two-dimensional random walker path.

using ClimateModels, Pkg, Plots, CSV, DataFrames

# ## Formulate Model
#
# This simple model steps randomly, `N` times, on a `x,y` plane starting from `0,0`.

function RandomWalker(x)
    #model run
    nSteps=x.inputs["nSteps"]
    m=zeros(nSteps,2)
    [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:nSteps]

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

MC=ModelConfig(model=RandomWalker,inputs=Dict("nSteps" => 1000))
setup(MC)
launch(MC)
MC

# ## Exercise 
#
# Change the duration parameter (nSteps) and update the following cells?

MC.inputs["nSteps"]=10000
setup(MC)
launch(MC)

# ## Plot Results
#
# Afterwards, one often uses model output for further analysis. Here we plot the random walker path from the `csv` output file.

fil=joinpath(MC.folder,string(MC.ID),"RandomWalker.csv")
output = CSV.File(fil) |> DataFrame
img=plot(output.x,output.y,frmt=:png,leg=:none)

# ## Workflow Outline
#
# Workflow steps are documented using `git`.
# Here we show the git record for this workflow (in timeline order).

git_log_show(MC)

# _See run folder for workflow output:_

show(MC)