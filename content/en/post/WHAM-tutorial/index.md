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

# Data

New data inputs have been added. There are two main ways how WHAM can
read the input data: reading an ASAP3 data file or creating an R object
(list). The former option is not compatible with the new version of WHAM
presented in this tutorial, therefore, we focus on creating an R list
with the input data:

``` r
wham_data = list()
```

`wham_data` will contain the data used by WHAM. For example, the age
bins or years:

``` r
wham_data$ages = 1:21 # age bins
wham_data$years = 1970:2020 # years
```

To explore all the base inputs, see the [WHAM
website](https://timjmiller.github.io/wham/index.html).

The new inputs are:

-   `$lengths`: fish length bins
-   `$catch_pal`: Length compositions for fisheries. Array (number of
    fisheries $/times $ number of years $/times $ number of length
    bins).
-   `$catch_NeffL`: Input sample size for length compositions
    (fisheries). Matrix (number of years $/times $ number of fisheries).
-   `$use_catch_pal`: Use (1) or not use (0) length compositions
    (fisheries). Matrix (number of years $/times $ number of fisheries).
-   `$catch_caal`: Conditional length-at-age (CAAL) for fisheries. Array
    (number of fisheries $/times $ number of years $/times $ number of
    length bins $/times $ number of ages).
-   `$catch_caal_Neff`: Input sample size for CAAL (fisheries). Matrix
    (number of years $/times $ number of fisheries $/times $ number of
    length bins).
-   `$use_catch_caal`: Use (1) or not use (0) CAAL (fisheries). Matrix
    (number of years $/times $ number of fisheries).
-   `$index_pal`: Length compositions for indices. Array (number of
    indices $/times $ number of years $/times $ number of length bins).
-   `$index_NeffL`: Input sample size for length compositions (indices).
    Matrix (number of years $/times $ number of indices).
-   `$use_index_pal`: Use (1) or not use (0) length compositions
    (indices). Matrix (number of years $/times $ number of indices).
-   `$index_caal`: Conditional length-at-age (CAAL) for indices. Array
    (number of indices $/times $ number of years $/times $ number of
    length bins $/times $ number of ages).
-   `$index_caal_Neff`: Input sample size for CAAL (indices). Matrix
    (number of years $/times $ number of indices $/times $ number of
    length bins).
-   `$use_index_caal`: Use (1) or not use (0) CAAL (indices). Matrix
    (number of years $/times $ number of indices).

These data inputs are not mandatory (i.e. if length compositions for
indices are not available, `$index_pal`, `$index_NeffL`, and
`$use_index_pal` do not need to be created).

Finally, I want to point out that WHAM also requires to input the
weight-at-age information for all fisheries and indices ( `$waa` ). This
will be important to keep in mind in the following sections.

# Parameters

All parameters are specified in the `prepare_wham_input` function. I
also invite the readers to take a look at the help of that function
(`?prepare_wham_input`) to find more details about the new features
implemented here.

## Selectivity

``` r
prepare_wham_input(...,
                   selectivity = list(model, re, initial_pars, fix_pars, n_selblocks),
                   ...)
```

The base WHAM version has three selectivity-at-age models (`model`) (
[see
here](https://timjmiller.github.io/wham/articles/ex4_selectivity.html)
): `age-specific`, `logistic`, `double-logistic`, `decreasing-logistic`.

For this new WHAM version, the selectivity can be at age or at length.
Also, I replaced the `double-logistic` by the `double-normal`
parametrization (see Privitera-Johnson, Methot, and Punt (2022) ).
Therefore, the following options are available:

-   `age-specific`: selectivity by age (number of parameters is the
    number of ages)
-   `age-logistic`: increasing logistic at age (2 parameters)
-   `age-double-normal`: double normal at age (6 parameters)
-   `age-decreasing-logistic`: decreasing logistic at age (2 parameters)
-   `len-logistic`: increasing logistic at length (2 parameters)
-   `len-double-normal`: double normal at length (6 parameters)
-   `len-decreasing-logistic`: decreasing logistic at length (2
    parameters)

## Length-at-weight relationship

``` r
prepare_wham_input(...,
                   LW = list(re, init_vals, est_pars),
                   ...)
```

In case weight-at-age information is not provided as data input ( `$waa`
), the user can provide the parameters of the length-at-weight potential
relationship. The arguments are:

-   `LW$re`: random effects (RE) on LW parameters (2). Five options are
    available:
    -   `none`: no RE
    -   `iid_y`: RE vary by year (uncorrelated)
    -   `iid_c`: RE vary by cohort (uncorrelated)
    -   `ar1_y`: RE correlated by year
    -   `ar1_c`: RE correlated by cohort
-   `LW$init_vals`: LW parameters initial values (2).
-   `LW$est_pars`: Which LW parameter to estimate.

## Somatic growth

**Under development**

### References

Privitera-Johnson, Kristin M., Richard D. Methot, and André E. Punt.
2022. “Towards Best Practice for Specifying Selectivity in
Age-Structured Integrated Stock Assessments.” *Fisheries Research* 249:
106247. https://doi.org/<https://doi.org/10.1016/j.fishres.2022.106247>.

Stock, Brian C., and Timothy J. Miller. 2021. “The Woods Hole Assessment
Model (WHAM): A General State-Space Assessment Framework That
Incorporates Time- and Age-Varying Processes via Random Effects and
Links to Environmental Covariates.” *Fisheries Research* 240 (August):
105967. <https://doi.org/10.1016/j.fishres.2021.105967>.
