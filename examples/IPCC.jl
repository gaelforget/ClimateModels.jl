### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ bb74b13a-22ab-11ec-05f3-0fe6017780c2
begin
	using Pkg
	Pkg.activate()
	
	using ClimateModels, CSV, DataFrames, PlutoUI
	using CairoMakie, GeoMakie, GeoJSON, Proj4
	
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

# ╔═╡ c4a65a7a-dabb-430a-ab0d-36289ea925d3
TableOfContents()

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

# ╔═╡ 573483d2-1d56-4bdd-bb6e-efd95f133eb3
md"""## Warming Contributions

Replicate **Fig 2 of the report** : assessed contributions to observed warming in 2010–2019 relative to 1850–1900.
"""

# ╔═╡ 2e7d9b87-b6b5-4425-b048-bd836b3a1c8d
begin
	(dat2a,dat2b,dat2c)=ClimateModels.IPCC_fig2_read()
	"Done with reading data for Fig 2"
end

# ╔═╡ 2aac7dbf-1b88-4ae9-83ca-172f7f4948cf
IPCC.fig2(dat2a,dat2b,dat2c)

# ╔═╡ 62f1abf3-7342-4036-8b9d-cbca0f47d06e
md"""## Hexagon Graph

Let's start with the type of graphic shown in **Fig 3 of the report** where regions of the Earth are each represented as an hexagon and the hexagons appearance (e.g. their color) reflect summary statistics. 

The data structure shown below provides the basic configuration of the hexagon for plotting. The example plot, mimicing Fig 3 from the actual report, uses this information with data provided by `ClimateModels.example_hexagons`.
"""

# ╔═╡ 0d753dca-75d5-41f1-a39f-8514d90ff6e5
begin
	df=IPCC_hexagons()
	clv, ttl, colors=ClimateModels.IPCC_fig3_example(df)
	df[1:3,:]
end

# ╔═╡ 3b6b635c-b725-4724-adfe-9bf7faf2df52
IPCC.hexagons(df,clv,ttl,colors)

# ╔═╡ 0d251f5b-7814-4ed1-aaad-17191ff633d5
md"""## Future Emissions

Replicate **Fig 4 of the report** :  Future anthropogenic emissions of key drivers of climate change and warming contributions by groups of drivers for the five illustrative scenarios used in this report.
"""

# ╔═╡ 3a2cc088-837d-4353-987a-e1a4a17e3375
begin
	dat4a=ClimateModels.IPCC_fig4a_read()
	dat4b=ClimateModels.IPCC_fig4b_read()
	"Done with reading data for Fig 4"
end

# ╔═╡ 0e24318d-cff9-4751-9cb6-a81f2987c18d
IPCC.fig4a(dat4a)

# ╔═╡ 536fc0d9-4497-47bc-b233-877a2da67dae
IPCC.fig4b(dat4b)

# ╔═╡ 37132b35-883b-4532-97d8-81a9bc1ba8a6
md"""## Climate Change Maps

Replicate **Fig 5 of the report** : Changes in annual mean surface temperature, precipitation, and soil moisture.
"""

# ╔═╡ 23414dc7-3bb5-4233-bf77-5155c6f9d584
begin
	pth_ipcc=joinpath(IPCC_SPM_path,"spm","spm_05","v20210809")
	lst=readdir(pth_ipcc)
	lst_te=lst[findall(occursin.(Ref("temperature"),lst))]
	lst_pr=lst[findall(occursin.(Ref("precipitation"),lst))]
	lst_sm=lst[findall(occursin.(Ref("SM_tot"),lst))]
	lst=[lst_te[:];lst_pr[:];lst_sm[:]]

	md""" $(@bind myfil Select(lst)) """
end

# ╔═╡ b6a9cc84-a493-49af-a0a4-064a0db5f187
begin
	dat5=ClimateModels.IPCC_fig5_read(myfil)
	"Done with reading data for Fig 5"
end

# ╔═╡ 0c5f26cf-918f-416c-95d6-c54d6328a7b0
IPCC.fig5(dat5)

# ╔═╡ Cell order:
# ╟─bb40fcf2-3463-4e91-808d-4fc5b8326af8
# ╟─bb74b13a-22ab-11ec-05f3-0fe6017780c2
# ╟─c4a65a7a-dabb-430a-ab0d-36289ea925d3
# ╟─5c60fbdf-096f-420b-b64a-84dd61e72e62
# ╟─75136e68-8811-443d-96a6-acfadbd40176
# ╟─7e5894f9-66cf-468a-91f0-5a1bf4ba7875
# ╟─e5af3b15-1916-420b-a42e-643a67ebcca6
# ╟─573483d2-1d56-4bdd-bb6e-efd95f133eb3
# ╟─2e7d9b87-b6b5-4425-b048-bd836b3a1c8d
# ╟─2aac7dbf-1b88-4ae9-83ca-172f7f4948cf
# ╟─62f1abf3-7342-4036-8b9d-cbca0f47d06e
# ╟─3b6b635c-b725-4724-adfe-9bf7faf2df52
# ╟─0d753dca-75d5-41f1-a39f-8514d90ff6e5
# ╟─0d251f5b-7814-4ed1-aaad-17191ff633d5
# ╟─3a2cc088-837d-4353-987a-e1a4a17e3375
# ╟─0e24318d-cff9-4751-9cb6-a81f2987c18d
# ╟─536fc0d9-4497-47bc-b233-877a2da67dae
# ╟─37132b35-883b-4532-97d8-81a9bc1ba8a6
# ╟─23414dc7-3bb5-4233-bf77-5155c6f9d584
# ╟─b6a9cc84-a493-49af-a0a4-064a0db5f187
# ╟─0c5f26cf-918f-416c-95d6-c54d6328a7b0
