---
authors:
- admin
categories: []
date: "2023-11-11T00:00:00Z"
draft: false
featured: false
image:
  caption: 'Ocean Frontier Institute (Dalhousie University).'
  focal_point: ""
lastMod: "2023-11-11T00:00:00Z"
projects: []
subtitle: Workshop on assessment methods for stocks with little or no age data
summary: Short tutorial about the use of length data in the Woods Hole Assessment model (WHAM)
tags: []
title: Modeling time-varying growth WHAM
links:
- icon: file-powerpoint
  icon_pack: fas
  name: Presentation 1
  url: /labs/OFI_WK_2023/presentation-1.html
- icon: file-powerpoint
  icon_pack: fas
  name: Presentation 2
  url: /labs/OFI_WK_2023/presentation-2.html
- icon: file-excel
  icon_pack: fas
  name: Case 1
  url: /labs/OFI_WK_2023/examples/case1.xlsx
- icon: file-excel
  icon_pack: fas
  name: Case 2
  url: /labs/OFI_WK_2023/examples/case2.xlsx
- icon: file-excel
  icon_pack: fas
  name: Case 3
  url: /labs/OFI_WK_2023/examples/case3.xlsx
- icon: code
  icon_pack: fas
  name: Code 1
  url: /labs/OFI_WK_2023/examples/case1.R
- icon: code
  icon_pack: fas
  name: Code 2
  url: /labs/OFI_WK_2023/examples/case2.R
- icon: code
  icon_pack: fas
  name: Code 3
  url: /labs/OFI_WK_2023/examples/case3.R
- icon: code
  icon_pack: fas
  name: helper
  url: /labs/OFI_WK_2023/examples/helper.R
---

Here you can find the slides and examples that my colleague (Jane Sullivan, NOAA) and I made for the workshop 
**Assessment methods for stocks with little or no age data** organized by the *Ocean Frontier Institute* (Dalhousie University).

In our presentations, we provide a quick overview of the modeling of length information and time-varying growth in the WHAM model, how to implement a model from
scratch, and several examples. All required files for the examples can be downloaded on this site.

## Examples

We prepared three simple examples to show how to implement your model in WHAM. 

- **Case 1**: Only uses age compositions. Growth modeled using empirical weight-at-age or nonparametric WAA.
- **Case 2**: Uses marginal length compositions. Growth modeled using parametric LAA.
- **Case 3**: Uses marginal length compositions and conditional length-at-age data. Growth modeled using parametric LAA.

You can also find these cases [here](https://github.com/JaneSullivan-NOAA/ofi2023_growth) and more examples applied to fish stocks in Alaska [here](https://github.com/GiancarloMCorrea/AKWHAM). 