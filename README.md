# ODA_Analysis

Independent analysis of Official Development Assistance (ODA) effectiveness, 2000–2023.  
Uses OECD DAC2A and World Bank WDI data to explore how education and health investments influence literacy, life expectancy, and infant mortality, highlighting cross-sector connectivity in human development.  
Includes R scripts, RMarkdown, and a PDF report with fully reproducible analysis.

---

## About the Data
This project investigates Official Development Assistance (ODA) and key human development indicators across selected developing countries from 2000 to 2023.  
The purpose is to assess how education and health sector aid interact to shape literacy, life expectancy, and infant mortality outcomes.

### Data Sources
1. **OECD DAC2A – Creditor Reporting System (CRS):**  
   Aggregate ODA disbursements by donor and recipient in constant USD.  
2. **World Bank WDI – World Development Indicators:**  
   Literacy, Life Expectancy, Infant Mortality, and School Enrollment.  
3. **World Bank Population Data:**  
   Used to compute ODA per capita and demographic growth factors.

### Data Processing
- Data merged and cleaned in **Power Query** and **R**.  
- Indicators normalized by year and income group.  
- Lag variables (1–3 years) applied to capture delayed effects of ODA on literacy and life expectancy.  
- Averages, growth rates, and mismatch indicators computed using **DAX** and **tidyverse**.  

### Dashboard & Analytical Goals
- Evaluate ODA allocation efficiency by **sector** and **income group**.  
- Assess long-term human development improvements.  
- Identify mismatches between ODA inflows and outcome trends.  
- Support data-driven, integrated ODA decision making through the **Education–Health Nexus** framework.

---

## Data Sources (Summary)
- **OECD DAC2A:** Aid (ODA) disbursements to countries and regions (2000–2023)  
- **World Bank WDI:** Literacy rate, life expectancy, infant mortality, school enrollment  

---

## Files Included
- `data/` – Cleaned dataset used in the analysis  
- `scripts/` – R scripts for data processing and visualization  
- `report.Rmd` – RMarkdown source file  
- `report.pdf` – Final report (knitted output)

---

## Reproducibility
All analysis steps can be replicated using **R 4.3+** and the **tidyverse** package suite.  
Data sources are publicly available and referenced for transparency.  
Results are fully reproducible using the included RMarkdown and scripts.

---

## Author
**Hiroki Shima**  
Independent Researcher | Human Capital & Development Analytics  
[GitHub: HirokiShimaUnited](https://github.com/HirokiShimaUnited)

---

## Citation
If you use this repository or data for academic or policy work, please cite as:  
Hiroki Shima (2025). *ODA_Analysis: Independent evaluation of Official Development Assistance effectiveness (2000–2023).* GitHub repository: [https://github.com/HirokiShimaUnited/ODA_Analysis](https://github.com/HirokiShimaUnited/ODA_Analysis)
