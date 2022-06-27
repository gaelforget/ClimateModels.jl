---
title: 'ClimateModels : an interface to climate models and FAIR climate science framework'
tags:
  - Julia
  - climate
  - models
  - data
  - git
  - workflow
authors:
  - name: Gaël Forget
    orcid: 0000-0002-4234-056X
    affiliation: "1"
affiliations:
 - name: department of Earth, Atmospheric and Planetary Sciences, Massachusetts Institute of Technology, USA
   index: 1
date: 27 June 2022
bibliography: paper.bib
---

# Summary

This package provides a uniform interface to climate models of varying complexity and completeness. Models that range from low dimensional to whole Earth System models can be run and/or analyzed via this framework. 

It also supports e.g. cloud computing workflows that start from previous model output available over the internet. Version control, using _git_, is included to allow for workflow documentation and reproducibility.

The `JuliaCon 2021 Presentation` provides a brief (8') overview and demo of the package.

# Statement of need

`ClimateModels.jl` is ... 

# Mathematics

### from template

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$

You can also use plain \LaTeX for equations
\begin{equation}\label{eq:fourier}
\hat f(\omega) = \int_{-\infty}^{\infty} f(x) e^{i\omega x} dx
\end{equation}
and refer to \autoref{eq:fourier} from text.

# Citations

### from template

- detail : [rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
- the following citation commands can be used:
	- `@author:2001`  ->  "Author et al. (2001)"
	- `[@author:2001]` -> "(Author et al., 2001)"
	- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

### from me

- data : [@OCCAdataverse; @Forget2016dataverse]
- paper : [@Forget2021; gmd-8-3071-2015]
 
# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](https://github.com/JuliaClimate/IndividualDisplacements.jl/blob/master/docs/joss/simulated_atm_flow04.png?raw=true)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](https://user-images.githubusercontent.com/20276764/131556274-48f3df13-0608-4cd0-acf9-c3e29894a32c.png){ width=20% }

# Acknowledgements

We acknowledge contributions from the open source community.

# References
