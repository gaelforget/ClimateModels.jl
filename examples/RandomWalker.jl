# # RandomWalker.jl
#
# 	Here we setup, run and plot a two-dimensional random Walk
#

using ClimateModels, GR
MC=ModelConfig(model=ClimateModels.RandomWalker)
setup(MC)
out=launch(MC)
plot(out[:,1],out[:,2])