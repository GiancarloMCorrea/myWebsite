---
authors:
- admin
categories: []
date: "2019-02-05T00:00:00Z"
draft: false
featured: false
image:
  caption: ""
  focal_point: ""
lastMod: "2019-09-05T00:00:00Z"
projects: []
subtitle: Age-length keys and Continuation Ratio Logits
summary: Age-length keys and Continuation Ratio Logits
tags: []
title: Age composition estimation
---

This is a tutorial to estimate age compositions from fishery-independent
sources (e.g. survey) using classic age-length keys and continuation
ratio logits (Berg et al., 2012). These two methods were evaluated in a
simulation experiment previously (Correa et al., 2020). I use simulated
data for this example:

    ## ## FSA v0.9.0. See citation('FSA') if used in publication.
    ## ## Run fishR() for related website and fishR('IFAR') for related book.

``` r
head(catch_data)
```

    ##   YEAR STATIONID    LON  LAT NUMBER_FISH
    ## 1 2007       108 -165.1 54.7          38
    ## 2 2007       230 -166.9 55.0          49
    ## 3 2007       236 -166.3 55.0          36
    ## 4 2007       241 -165.8 55.0          21
    ## 5 2007       248 -165.1 55.0          19
    ## 6 2007       310 -164.6 55.1          16

``` r
head(len_data)
```

    ##   YEAR STATIONID    LON  LAT LENGTH
    ## 1 2007       108 -165.1 54.7     17
    ## 2 2007       108 -165.1 54.7     23
    ## 3 2007       108 -165.1 54.7     24
    ## 4 2007       108 -165.1 54.7     26
    ## 5 2007       108 -165.1 54.7     28
    ## 6 2007       108 -165.1 54.7     35

``` r
head(age_data)
```

    ##   YEAR STATIONID    LON  LAT LENGTH AGE
    ## 1 2007       108 -165.1 54.7     17   1
    ## 2 2007       108 -165.1 54.7     23   1
    ## 3 2007       108 -165.1 54.7     61   4
    ## 4 2007       108 -165.1 54.7     61   4
    ## 5 2007       230 -166.9 55.0     53   3
    ## 6 2007       230 -166.9 55.0     60   4

`catch_data` is the catch data, `len_data` is the length subsample data
(each row represents a fish sampled), and the `age_data` is the age
subsample data (each row represents a fish sampled). The columns are:

-   `YEAR` is the sampling year
-   `STATIONID` is the station name or code where the sample was taken
-   `LON` and `LAT` are the longitude and latitude of the sampling
    station
-   `NUMBER_FISH` is the number of fish caught in the sampling station
-   `LENGTH` is the fish size
-   `AGE` is the fish age

For this example, only data from one year is considered.

Before going to the calculations, we should set the age plus group. In
this case, we set it to 8.

``` r
age_data$AGE = ifelse(test = age_data$AGE >= 8, yes = 8, no = age_data$AGE)
```

Using age-length key (ALK)
--------------------------

### ALK calculation

We use the functions in the R package `FSA`.

We construct the ALK using the information in the age subsample data.
First, calculate the frequency by length and age.

``` r
freq_len_age = xtabs(~LENGTH + AGE, data = age_data)
head(freq_len_age)
```

    ##       AGE
    ## LENGTH  1  2  3  4  5  6  7  8
    ##     10  1  0  0  0  0  0  0  0
    ##     11  4  0  0  0  0  0  0  0
    ##     12  3  0  0  0  0  0  0  0
    ##     13  1  0  0  0  0  0  0  0
    ##     14 10  0  0  0  0  0  0  0
    ##     15 16  1  0  0  0  0  0  0

Then, we calculate proportions (this is the ALK for this year):

``` r
ALK_year = prop.table(freq_len_age, margin=1)
head(ALK_year)
```

    ##       AGE
    ## LENGTH          1          2          3          4          5          6
    ##     10 1.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
    ##     11 1.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
    ##     12 1.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
    ##     13 1.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
    ##     14 1.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000
    ##     15 0.94117647 0.05882353 0.00000000 0.00000000 0.00000000 0.00000000
    ##       AGE
    ## LENGTH          7          8
    ##     10 0.00000000 0.00000000
    ##     11 0.00000000 0.00000000
    ##     12 0.00000000 0.00000000
    ##     13 0.00000000 0.00000000
    ##     14 0.00000000 0.00000000
    ##     15 0.00000000 0.00000000

We can plot the ALK:

``` r
alkPlot(key = ALK_year, type = "barplot")
```

![](index_files/figure-markdown_github/unnamed-chunk-5-1.png)