---
authors:
- admin
categories: []
date: "2024-07-23T00:00:00Z"
draft: false
featured: false
image:
  caption: 'Zotero.'
  focal_point: ""
lastMod: "2024-07-23T00:00:00Z"
projects: []
subtitle: Working with Quarto and Zotero
summary: Short tutorial about management citations in Quarto using Zotero
tags: []
title: Working with Quarto and Zotero
---

This is a short tutorial to work with Zotero from RStudio to manage your citations in your Quarto document. Assuming you already have your bibliography uploaded in Zotero, you then need to follow these steps:

## Create citation keys in Zotero

These keys are used as an identifier, so RStudio can find all the information of your bibliography item (e.g., article, book). To create automatically citations keys for all your items in your Zotero, you can use [Better Bibtex for Zotero](https://retorque.re/zotero-better-bibtex/). You can install it following [these instructions](https://retorque.re/zotero-better-bibtex/installation/index.html). Once installed, you could see that every item in your Zotero library will have a *Citation key*, which should look something like `kearneyCoupledPelagicBenthic2020`.

## Install the `rbbt` R package

This package is quite useful to efficiently insert citations in your Quarto document (i.e., RStudio) from Zotero. The original `rbbt` package can be found [here](https://github.com/paleolimbot/rbbt), but it has a bug. So I recommend installing it from this [Github repository](https://github.com/wmoldham/rbbt). Restart RStudio just in case. 

## Create a BIB file

Create a empty bibtex file (e.g., `references.bib`), where the references cited in the Quarto document will be saved as Bibtex code automatically. Also specify in the YAML of your `.qmd` file that the references will be called from this Bibtex file:

```{r, eval=FALSE}
---
bibliography: references.bib
---
```

## Insert your citations in Quarto

Insert your citations keys (e.g., `@kearneyCoupledPelagicBenthic2020`) in your Quarto document when needed. One (inefficient) way of doing this is to look the desired bibliography item up in your Zotero library, copy the citation key, and paste it in your Quarto document. 

However, the `rbbt` package allows us to use the Zotero popup window to look for bibliography items directly from RStudio. To use it, you need to go to `Tools > Modify Keyboard Shortcuts...` and create a shortcut for `Insert Zotero Citation`. I use `Ctrl+Shift+T`, but feel free to use whatever you want. Then, when using this shortcut from your Quarto document, the Zotero popup window will show up so you can look up for references directly from it, and the citation keys of those references will be inserted in your Quarto file. 

## Update the Bibtex file

This is done automatically by inserting this R code chunk at the beginning of your Quarto file (`.qmd`):

```{r, eval=FALSE}
require(rbbt)
require(this.path)
qmd_file = this.path() # this identifies the qmd file name
keys = rbbt::bbt_detect_citations(qmd_file)
bbt_ignore = keys[grepl("fig-|tbl-|eq-|sec-|suppfig-", keys)] # ignore these patterns as citations
rbbt::bbt_update_bib(path_rmd = qmd_file, ignore = bbt_ignore, overwrite = T, translator = "bibtex")
```

This chunk automatically detects all the citation keys (e.g., `@kearneyCoupledPelagicBenthic2020`) used in the current Quarto document, find it in your Zotero library, and add it to the `references.bib` file so can be read by RStudio. That means that the `references.bib` file is automatically updated every time you render your Quarto document.

> :warning: **Important**
>
> When specifying labels for figures, tables, equations, sections, and supplementary figures, you should always start with the `fig-`, `tbl-`, `eq-`, `sec-`, and `suppfig-` prefixes, respectively. So the `bbt_update_bib` function will not interpret these labels as citation keys (see last step above).

Let me know if you have any questions or suggestions. Happy coding!