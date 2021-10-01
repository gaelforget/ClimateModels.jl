using ClimateModels, Pkg, Documenter, Test, Suppressor

@testset "cmip" begin
    (mm,gm,meta)=cmip()
    @test isapprox(gm["y"][end],285.71875,atol=1)
end

@testset "ipcc" begin
	df=read_hexagons()
	clv, ttl, colors=ClimateModels.example_hexagons(df)
    @test isa(colors[1],Symbol)
end

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

