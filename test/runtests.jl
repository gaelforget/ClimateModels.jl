using ClimateModels, Pkg, Documenter, Test

#@testset "ClimateModels.jl" begin
#    (mm,gm,meta)=cmip()
#    @test isapprox(gm["y"][end],285.71875)
#end

tmp=ModelConfig()
show(tmp)
@test isa(tmp,AbstractModelConfig)

tmp=PackageSpec(url="https://github.com/JuliaOcean/AirSeaFluxes.jl")
tmp=ModelConfig(model=tmp)
setup(tmp)
@test clean(tmp)=="no task left in pipeline"

@testset "doctests" begin
    doctest(ClimateModels; manual = false)
end

