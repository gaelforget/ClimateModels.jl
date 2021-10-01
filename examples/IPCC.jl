### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# ╔═╡ bb74b13a-22ab-11ec-05f3-0fe6017780c2
begin
	import Pkg
	Pkg.activate()
	using CairoMakie, CSV, DataFrames, ClimateModels, PlutoUI
	
	p=dirname(pathof(ClimateModels))
	include(joinpath(p,"..","examples","Makie.jl"))
	md"""All set with packages and includes"""
end

# ╔═╡ bb40fcf2-3463-4e91-808d-4fc5b8326af8
md"""# Climate Change Report 2021

This notebook is a non-official rendering of data provided as part of the following report, published in 2021 by  the _Intergovernmental Panel on Climate Change_. 

For additional information about the plots, please refer to the report itself.

```
Climate Change 2021
The Physical Science Basis Summary for Policymakers

IPCC, 2021: Summary for Policymakers. In: Climate Change 2021: The Physical Science Basis. Contribution of Working Group I to the Sixth Assessment Report of the Intergovernmental Panel on Climate Change [Masson-Delmotte, V., P. Zhai, A. Pirani, S. L. Connors, C. Péan, S. Berger, N. Caud, Y. Chen, L. Goldfarb, M. I. Gomis, M. Huang, K. Leitzell, E. Lonnoy, J.B.R. Matthews, T. K. Maycock, T. Waterfield, O. Yelekçi, R. Yu and B. Zhou (eds.)]. Cambridge University Press. In Press.
```
"""

# ╔═╡ 5c60fbdf-096f-420b-b64a-84dd61e72e62
md"""## Temperature Change

This replicates **Fig 1 of the report** with _Hockey Stick Graph_ (Fig1a) and Human contribution graph (Fig1b).

"""

# ╔═╡ 75136e68-8811-443d-96a6-acfadbd40176
begin
(dat_1b,meta_1b)=ClimateModels.IPCC_fig1b_read();
	(dat, dat1, dat2)=ClimateModels.IPCC_fig1a_read();
	"Done reading data for fig 1"
end

# ╔═╡ 7e5894f9-66cf-468a-91f0-5a1bf4ba7875
IPCC.fig1a(dat,dat1,dat2)

# ╔═╡ e5af3b15-1916-420b-a42e-643a67ebcca6
IPCC.fig1b(dat_1b)

# ╔═╡ 62f1abf3-7342-4036-8b9d-cbca0f47d06e
md"""## Hexagon Plot

Let's start with the type of graphic shown in **Fig 3 of the report** where regions of the Earth are each represented as an hexagon and the hexagons appearance (e.g. their color) reflect summary statistics. 

The data structure shown below provides the basic configuration of the hexagon for plotting. The example plot, mimicing Fig 3 from the actual report, uses this information with data provided by `ClimateModels.example_hexagons`.
"""

# ╔═╡ 0d753dca-75d5-41f1-a39f-8514d90ff6e5
begin
	df=IPCC_hexagons()
	clv, ttl, colors=ClimateModels.IPCC_fig3_example(df)
	df
end

# ╔═╡ 3b6b635c-b725-4724-adfe-9bf7faf2df52
begin
	f=IPCC.hexagons(df,clv,ttl,colors)
	#save("f.png", f)
end

# ╔═╡ Cell order:
# ╟─bb40fcf2-3463-4e91-808d-4fc5b8326af8
# ╟─bb74b13a-22ab-11ec-05f3-0fe6017780c2
# ╟─5c60fbdf-096f-420b-b64a-84dd61e72e62
# ╟─75136e68-8811-443d-96a6-acfadbd40176
# ╟─7e5894f9-66cf-468a-91f0-5a1bf4ba7875
# ╟─e5af3b15-1916-420b-a42e-643a67ebcca6
# ╟─62f1abf3-7342-4036-8b9d-cbca0f47d06e
# ╟─3b6b635c-b725-4724-adfe-9bf7faf2df52
# ╟─0d753dca-75d5-41f1-a39f-8514d90ff6e5
