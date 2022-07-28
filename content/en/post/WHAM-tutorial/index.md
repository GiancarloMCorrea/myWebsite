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
    fisheries $$ number of years $$ number of length bins).
-   `$catch_NeffL`: Input sample size for length compositions
    (fisheries). Matrix (number of years $$ number of fisheries).
-   `$use_catch_pal`: Use (1) or not use (0) length compositions
    (fisheries). Matrix (number of years $$ number of fisheries).
-   `$catch_caal`: Conditional length-at-age (CAAL) for fisheries. Array
    (number of fisheries $$ number of years $$ number of length bins $$
    number of ages).
-   `$catch_caal_Neff`: Input sample size for CAAL (fisheries). Matrix
    (number of years $$ number of fisheries $$ number of length bins).
-   `$use_catch_caal`: Use (1) or not use (0) CAAL (fisheries). Matrix
    (number of years $$ number of fisheries).
-   `$index_pal`: Length compositions for indices. Array (number of
    indices $$ number of years $$ number of length bins).
-   `$index_NeffL`: Input sample size for length compositions (indices).
    Matrix (number of years $$ number of indices).
-   `$use_index_pal`: Use (1) or not use (0) length compositions
    (indices). Matrix (number of years $$ number of indices).
-   `$index_caal`: Conditional length-at-age (CAAL) for indices. Array
    (number of indices $$ number of years $$ number of length bins $$
    number of ages).
-   `$index_caal_Neff`: Input sample size for CAAL (indices). Matrix
    (number of years $$ number of indices $$ number of length bins).
-   `$use_index_caal`: Use (1) or not use (0) CAAL (indices). Matrix
    (number of years $$ number of indices).

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

There are two main ways to model mean length-at-age: using the von
Bertalanffy growth function or inputing a mean length-at-age.

### von Bertalanffy growth function

As parametrized by Schnute (1981). There are five parameters:

-   *k*: growth rate
-   *L*<sub>*i**n**f*</sub>: Asymptotic length
-   *L*<sub>1</sub>: length at age 1
-   *CV*<sub>1</sub>: coefficient of variation of lengths at age 1
-   *CV*<sub>*A*</sub>: coefficient of variation of lengths at age A
    (age plus group)

``` r
prepare_wham_input(...,
                   growth = list(model = 1, re, init_vals, est_pars),
                   ...)
```

The arguments are:

-   `growth$re`: random effects (RE) on growth parameters (5). Five
    options are available:
    -   `none`: no RE
    -   `iid_y`: RE vary by year (uncorrelated)
    -   `iid_c`: RE vary by cohort (uncorrelated)
    -   `ar1_y`: RE correlated by year
    -   `ar1_c`: RE correlated by cohort
-   `growth$init_vals`: growth parameters initial values (5).
-   `growth$est_pars`: Which growth parameter to estimate.

### Input mean length-at-age (LAA)

The number of parameters is equal to the number of ages. Also, the
*CV*<sub>1</sub> and *CV*<sub>*A*</sub> should be specified in
`growth`.

``` r
prepare_wham_input(...,
                   growth = list(model = 2, re, init_vals, est_pars),
                   LAA = list(LAA_vals, re, LAA_est),
                   ...)
```

The arguments are:

-   `LAA$LAA_vals`: LAA initial values (length equal to the number of
    ages).
-   `LAA$re`: random effects (RE) on LAA (1). Five options are
    available:
    -   `none`: no RE
    -   `iid`: RE vary by year and age (uncorrelated)
    -   `iid_a`: RE vary by age (uncorrelated)
    -   `ar1_a`: RE correlated by age
    -   `2dar1`: RE correlated by age and year
-   `LAA$LAA_est`: Which LAA to estimate.

# Analysis of results

The function `plot_wham_output` produces plots to summary the data
inputs, outputs, parameters, and others. This function was also expanded
in this new WHAM version.

## Input data

We can get a plot of the observed length compositions:

![](index_files/figure-markdown_github/catch_len_comp_fleet_1.png)

Or the input CAAL:

![](index_files/figure-markdown_github/CAAL_index_1_Year_26.png)

## Diagnostics

We can compare the observed vs predicted length compositions:

![](index_files/figure-markdown_github/Catch_len_comp_fleet_1_fit.png)

or bubble plots of CAAL residuals:

![](index_files/figure-markdown_github/Index_CAAL_resids_index_1_Year_26.png)

## Parameters

Some plots summarizing the variability in some parameters and biological
aspects are also available. For example, the variability of mean
length-at-age (when `growth$model = 2`):

![](index_files/figure-markdown_github/LAA_tile.png)

Or the variability of lengths-at-age (represented by the age-length
transition matrix):

![](index_files/figure-markdown_github/phi_mat_tile.png)

I suggest the user explores all the plots and tables produced by this
function.

# Examples

You can find several examples about how to use these new WHAM features
[here](https://giancarlomcorrea.netlify.app/labs/postdoc-uw/mytutorial_testing).
I will produce more examples in the future.

**This tutorial is under development and some features could be changed
in future versions**

### References

Privitera-Johnson, Kristin M., Richard D. Methot, and André E. Punt.
2022. “Towards Best Practice for Specifying Selectivity in
Age-Structured Integrated Stock Assessments.” *Fisheries Research* 249:
106247. https://doi.org/<https://doi.org/10.1016/j.fishres.2022.106247>.

Schnute, Jon. 1981. “A Versatile Growth Model with Statistically Stable
Parameters.” *Canadian Journal of Fisheries and Aquatic Sciences* 38
(9): 1128–40. <https://doi.org/10.1139/f81-153>.

Stock, Brian C., and Timothy J. Miller. 2021. “The Woods Hole Assessment
Model (WHAM): A General State-Space Assessment Framework That
Incorporates Time- and Age-Varying Processes via Random Effects and
Links to Environmental Covariates.” *Fisheries Research* 240 (August):
105967. <https://doi.org/10.1016/j.fishres.2021.105967>.
