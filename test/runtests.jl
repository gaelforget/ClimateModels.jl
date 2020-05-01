using ClimateModels
using Test

@testset "ClimateModels.jl" begin
    (mm,gm,meta)=cmip()
    @test isapprox(gm["y"][end],285.71875)
end
