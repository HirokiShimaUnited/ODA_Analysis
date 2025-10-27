# Technical Details (ODA_Analysis)

This document provides technical details for reproducing the ODA_Analysis project.

## Requirements
- R version ≥ 4.3
- R packages: `tidyverse`, `broom`, `ggplot2`, `readr`, `dplyr`
- Optional: Quarto or RMarkdown for rendering

## Steps
```bash
Rscript code/00_setup.R
Rscript code/01_clean_merge.R
Rscript code/02_model_plots.R
quarto render reports/ODA_Analysis.qmd

Directory structure
data/
 ├─ raw/          # Source datasets (OECD DAC2A, WDI, etc.)
 └─ processed/    # Cleaned and merged data
code/
 ├─ 00_setup.R    # Package setup
 ├─ 01_clean_merge.R  # Data cleaning & merging
 └─ 02_model_plots.R  # Model & visualization
reports/
 ├─ ODA_Analysis.qmd  # Reproducible report
 └─ ODA_Analysis.pdf  # Knitted output

Notes

Data merged via Country + Year key.

ODA values adjusted to constant USD (OECD DAC2A).

Lag variables (1–3 years) used to assess delayed effects on literacy and life expectancy.

Figures exported to reports/figures/.
