### A Pluto.jl notebook ###
# v0.19.8

using Markdown
using InteractiveUtils

# ╔═╡ deb4a3a8-b07a-4b99-8bad-005871858726
begin
	using Pkg; Pkg.activate()
    using ClimateModels, PlutoUI, CairoMakie
end

# ╔═╡ 080b34a0-c456-41f7-bb68-d1807b661d4a
md"""# Random Walk Model (Julia)

Here we setup, run and plot a two-dimensional random walker path. The model is a simple function, called `RandomWalker`, which outputs the result in a `csv` file. The model output is displayed afterwards using [Makie.jl](https://github.com/JuliaPlots/Makie.jl).
"""

# ╔═╡ d22d8933-08ff-4458-aefb-4f22a229199b
md"""## Formulate Model

The randowm walk model steps randomly, `NS` times, on a `x,y` plane starting from `0,0`. The `RandomWalker` function receives a `ModelConfig` as input, which itself contains input parameters like `NS`. The results are stored in a CSV file called `RandomWalker.csv`.
"""

# ╔═╡ ba4834ce-f72e-4c39-a18f-a75ce4c210fd
function RandomWalker(x::ModelConfig)
    #model run
    NS=x.inputs[:NS]
    m=zeros(NS,2)
    [m[i,j]=m[i-1,j]+rand((-1,1)) for j in 1:2, i in 2:NS]

    #output to file
    df = ClimateModels.DataFrame(x = m[:,1], y = m[:,2])
    fil=joinpath(pathof(x),"RandomWalker.csv")
    ClimateModels.CSV.write(fil, df)

    return "model run complete"
end

# ╔═╡ d718425f-fcd1-434c-b43b-ac5389c6f36b
md"""## Setup And Run Model

- `ModelConfig` defines the model into data structure `MC`
- `run(MC)` proceeds with the standard sequence:
  - `setup` prepares the model to run in a temporary folder
  - `build` which here does nothing but is useful for generality
  - `launch` executes `RandomWalker` which writes results to `RandomWalker.csv`
"""

# ╔═╡ 37ffb9b3-457d-4bb1-938c-7a40323e20f9
begin
	MC=ModelConfig(RandomWalker,(NS=100,))
	run(MC)
end

# ╔═╡ 4655ab8d-03bc-481a-9a33-f47710802ecf
with_terminal() do
	println("Contents of the run folder:\n\n")
	println.(readdir(pathof(MC)))
end

# ╔═╡ e0f12026-3e88-416e-af0b-a71f70520e6f
md"""## Exercise 

Change the duration parameter (`NS`) and update the following cells?"""

# ╔═╡ 8fc14ed2-3194-4263-b145-d356f9c6df3e
begin
	MC.inputs["NS"]=200
	put!(MC.channel,MC.model) #general method
	#setup(MC) #alernate method
	launch(MC)
	PlutoUI.with_terminal() do
		println("Answer is hidden here")
	end
end

# ╔═╡ 622146ce-eb73-4624-8394-6ce28a52ae89
md"""## Plot Results

After the fact, one often uses model output for further analysis. 

Here we plot the random walker path from the `csv` output file."""

# ╔═╡ fad59422-e329-44a3-bc39-bf8e1966c1b7
begin
	fil=joinpath(pathof(MC),"RandomWalker.csv")
	output = ClimateModels.CSV.File(fil) |> ClimateModels.DataFrame
	lines(output.x,output.y)
end

# ╔═╡ 3170d9a5-bd4a-4b57-b7ac-4c4223ccbfa7
md"""## Workflow Outline

Workflow steps are documented using `Git.jl`.

Here we show the git record for this workflow in timeline order.
"""

# ╔═╡ 070ae8e6-10b2-11ec-292c-55e5fd8138b4
with_terminal() do
	println.(log(MC))
end

# ╔═╡ 61a3b1cc-cd4e-42ce-af92-357c23cf11c0
TableOfContents()

# ╔═╡ Cell order:
# ╟─080b34a0-c456-41f7-bb68-d1807b661d4a
# ╟─deb4a3a8-b07a-4b99-8bad-005871858726
# ╟─d22d8933-08ff-4458-aefb-4f22a229199b
# ╠═ba4834ce-f72e-4c39-a18f-a75ce4c210fd
# ╟─d718425f-fcd1-434c-b43b-ac5389c6f36b
# ╠═37ffb9b3-457d-4bb1-938c-7a40323e20f9
# ╟─4655ab8d-03bc-481a-9a33-f47710802ecf
# ╟─e0f12026-3e88-416e-af0b-a71f70520e6f
# ╟─8fc14ed2-3194-4263-b145-d356f9c6df3e
# ╟─622146ce-eb73-4624-8394-6ce28a52ae89
# ╟─fad59422-e329-44a3-bc39-bf8e1966c1b7
# ╟─3170d9a5-bd4a-4b57-b7ac-4c4223ccbfa7
# ╟─070ae8e6-10b2-11ec-292c-55e5fd8138b4
# ╟─61a3b1cc-cd4e-42ce-af92-357c23cf11c0
