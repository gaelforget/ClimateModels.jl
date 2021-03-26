using ClimateModels, Pkg
using Test

#@testset "ClimateModels.jl" begin
#    (mm,gm,meta)=cmip()
#    @test isapprox(gm["y"][end],285.71875)
#end

tmp=ModelConfig()
show(tmp)
@test isa(tmp,AbstractModelConfig)

tmp=PackageSpec(url="https://github.com/JuliaClimate/IndividualDisplacements.jl")
tmp=ModelConfig(model=tmp)
setup(tmp)
@test !isempty(tmp.channel)

show(tmp)
monitor(tmp)
launch(tmp)
@test monitor(tmp)=="no task left in pipeline"

tmp=PackageSpec(url="https://github.com/milankl/ShallowWaters.jl")
tmp=ModelConfig(model=tmp)
setup(tmp)
@test clean(tmp)=="no task left in pipeline"

