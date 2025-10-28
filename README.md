**DONT USE**

# ODA Dashboard – Build Kit (Power BI + R)

This repository contains a reproducible **R build script** and usage notes for generating a merged dataset for your ODA dashboard.

## 🔧 What’s inside
- `01_build_dataset.R` — reads **CRS (OECD)**, **WDI (World Bank)**, and **Population/Income** CSVs, merges them, creates lags and peer z-scores, and writes `analysis/processed.csv` (Power BI–ready).

## 📂 Expected inputs (place in project root)
- `crs_disbursements.csv` — OECD CRS Disbursements (Education & Health, constant USD)
- `wdi_indicators.csv` — WDI indicators (literacy, enrollment, infant mortality, life expectancy)
- `pop_income.csv` — population + income group (World Bank country metadata)

## ▶️ How to run
```bash
Rscript 01_build_dataset.R

