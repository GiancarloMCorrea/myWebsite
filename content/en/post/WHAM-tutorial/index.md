---
authors:
- admin
categories: []
date: "2022-07-25T00:00:00Z"
draft: false
featured: false
image:
  caption: 'Mean length-at-age variability.'
  focal_point: ""
lastMod: "2019-09-05T00:00:00Z"
projects: []
subtitle: Growth estimation
summary: Growth estimation
tags: []
title: Woods Hole Assessment Model
---

In this tutorial, I present the extended features that my colleagues,
Cole Monnahan and Jane Sullivan, and I have incorporated into the Woods
Hole Assessment Model (WHAM). The base features of this model has been
developed by Tim Miller and colleagues and are reported in Stock and
Miller (2021) and references therein. Also, several vignettes can be
found in the [WHAM
website](https://timjmiller.github.io/wham/index.html) explaining how to
run a model in WHAM. Before continuing exploring this tutorial, I highly
advise taking a look at that website.

First of all, the features described here are available in the
[**growth** branch](https://github.com/gmoroncorrea/wham/tree/growth)
forked from the [**master** branch of the WHAM GitHub
repository](https://github.com/timjmiller/wham/) and can be installed
using this line:

``` r
remotes::install_github(repo = 'gmoroncorrea/wham', ref='growth', INSTALL_opts = c("--no-docs", "--no-multiarch", "--no-demo"))
```

Then:

``` r
library(wham)
```

**Under development**

### References

Stock, Brian C., and Timothy J. Miller. 2021. “The Woods Hole Assessment
Model (WHAM): A General State-Space Assessment Framework That
Incorporates Time- and Age-Varying Processes via Random Effects and
Links to Environmental Covariates.” *Fisheries Research* 240 (August):
105967. <https://doi.org/10.1016/j.fishres.2021.105967>.



