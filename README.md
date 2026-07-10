# TFM

Code developed for the Master's Thesis (TFM) *Evaluating Wind-Induced Uncertainty in Fire Weather Index Estimates Using High-Resolution Observational and Reanalysis Data*, completed as part of the Master's in Data Science.

## Overview

This project examines how the choice of near-surface wind dataset — ERA5-Land, CIDE, or HARMONIE-AROME — affects fire danger estimates from the Canadian Fire Weather Index (FWI) system, and assesses how well these estimates align with observed wildfire activity over the Iberian Peninsula.

## Repository structure

| File | Description | Rendered output |
|---|---|---|
| `fwi.R` | Compute FWI, FFMC, ISI and BUI with every dataset | — |
| `load_data.R` | Loads and prepares the wind, FWI, ISI, and BUI data used across the analysis | — |
| `data_sources.Rmd` | Wind climatologies and temporal comparisons across the three datasets | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/data_sources.html) |
| `ISI_BUI.Rmd` | Joint distribution of ISI and BUI | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/ISI_BUI.html) |
| `fire-weather_typing.Rmd` | Temporal clustering of daily fire-weather regimes (BUI–ISI space) | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/fire-weather_typing.html) |
| `fire-weather_regions.Rmd` | Spatial clustering into fire-weather zones | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/fire-weather_regions.html) |
| `temporal_persistence.Rmd` | Fire danger persistence and extreme event duration | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/temporal_persistence.html) |
| `comparison.Rmd` | Comparison plots across the three wind datasets | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/comparison.html) |
| `fire.Rmd` | Observed fire activity | [View](https://htmlpreview.github.io/?https://github.com/izarourru/TFM/blob/main/html/fire.html) |
