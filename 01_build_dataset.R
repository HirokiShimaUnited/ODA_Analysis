#!/usr/bin/env Rscript
# scripts/01_build_dataset.R
# Reproducible build: merge CRS + WDI + Population/Income, create lags & z-scores
# Input (in project root):
#   - crs_disbursements.csv
#   - wdi_indicators.csv
#   - pop_income.csv
# Output:
#   - analysis/processed.csv

suppressPackageStartupMessages({
  libs <- c("readr","dplyr","tidyr","stringr","rlang")
  to_install <- setdiff(libs, rownames(installed.packages()))
  if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
  lapply(libs, library, character.only = TRUE)
})

# ---------- config ----------
DATA_DIR <- "."
OUT_DIR  <- "analysis"
OUT_CSV  <- file.path(OUT_DIR, "processed.csv")
if (!dir.exists(OUT_DIR)) dir.create(OUT_DIR, recursive = TRUE)

# ---------- helpers ----------
`%||%` <- function(x,y) if (is.null(x) || length(x)==0 || all(is.na(x))) y else x
pick_col <- function(df, candidates) {
  cn <- names(df)
  # exact first
  hit <- candidates[candidates %in% cn]
  if (length(hit)) return(hit[1])
  # case-insensitive
  low <- setNames(cn, tolower(cn))
  for (c in candidates) if (!is.na(low[[tolower(c)]])) return(low[[tolower(c)]])
  NA_character_
}

to_num <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
to_int <- function(x) suppressWarnings(as.integer(to_num(x)))

# ---------- read ----------
crs_path <- file.path(DATA_DIR, "crs_disbursements.csv")
wdi_path <- file.path(DATA_DIR, "wdi_indicators.csv")
pop_path <- file.path(DATA_DIR, "pop_income.csv")

stopifnot(file.exists(crs_path), file.exists(wdi_path), file.exists(pop_path))

crs  <- readr::read_csv(crs_path, show_col_types = FALSE)
wdi  <- readr::read_csv(wdi_path, show_col_types = FALSE)
meta <- readr::read_csv(pop_path, show_col_types = FALSE)

# ---------- CRS clean (OECD wide export tolerant) ----------
# common OECD headers (wide extracts)
crs_rec_code <- pick_col(crs, c("Recipient3","Recipient code","Recipient Code","Recipient ISO3 code","recipient_code","recipient"))
crs_rec_name <- pick_col(crs, c("RECIPIENT","Recipient","Recipient name","Recipient Name"))
crs_year     <- pick_col(crs, c("TIME_PERIOD","Time period","Year","year","TIME","time"))
crs_sector   <- pick_col(crs, c("Sector4","SECTOR","Sector","Purpose (name)","Purpose name"))
crs_value    <- pick_col(crs, c("OBS_VALUE","Observation value","Value","value"))

if (any(is.na(c(crs_rec_code, crs_rec_name, crs_year, crs_sector, crs_value)))) {
  stop("CRS columns not recognized. Saw: ", paste(names(crs), collapse=", "))
}

crs_clean <- crs %>%
  transmute(
    country_code = toupper(as.character(.data[[crs_rec_code]])),
    country_name = as.character(.data[[crs_rec_name]]),
    year         = to_int(.data[[crs_year]]),
    sector       = as.character(.data[[crs_sector]]),
    disbursements_constant_usd = to_num(.data[[crs_value]])
  ) %>%
  mutate(
    sector = dplyr::case_when(
      grepl("educ", sector, ignore.case = TRUE) ~ "Education",
      grepl("health", sector, ignore.case = TRUE) ~ "Health",
      TRUE ~ sector
    )
  ) %>%
  filter(sector %in% c("Education","Health")) %>%
  filter(!is.na(country_code), !is.na(year))

# aggregate to year-country-sector
crs_year <- crs_clean %>%
  group_by(country_code, country_name, year, sector) %>%
  summarize(oda_usd = sum(disbursements_constant_usd, na.rm = TRUE), .groups = "drop")

# ---------- WDI long -> wide (4 indicators) ----------
w_cc  <- pick_col(wdi, c("country_code","Country Code","Code"))
w_cn  <- pick_col(wdi, c("country_name","Country Name","Country"))
w_yr  <- pick_col(wdi, c("year","Year"))
w_ic  <- pick_col(wdi, c("indicator_code","Indicator Code","Series Code","Code.1"))
w_in  <- pick_col(wdi, c("indicator_name","Indicator Name","Series Name"))
w_val <- pick_col(wdi, c("value","Value"))

if (any(is.na(c(w_cc,w_cn,w_yr,w_ic,w_in,w_val)))) {
  stop("WDI columns not recognized. Saw: ", paste(names(wdi), collapse=", "))
}

keep_codes <- c("SE.ADT.LITR.ZS","SE.SEC.ENRR","SP.DYN.IMRT.IN","SP.DYN.LE00.IN")

wdi_wide <- wdi %>%
  transmute(
    country_code = toupper(as.character(.data[[w_cc]])),
    country_name = as.character(.data[[w_cn]]),
    year         = to_int(.data[[w_yr]]),
    indicator_code = gsub("[^A-Za-z0-9.]", "", as.character(.data[[w_ic]])),
    value        = to_num(.data[[w_val]])
  ) %>%
  filter(indicator_code %in% keep_codes) %>%
  distinct(country_code, country_name, year, indicator_code, .keep_all = TRUE) %>%
  tidyr::pivot_wider(names_from = indicator_code, values_from = value) %>%
  rename(
    literacy_rate     = `SE.ADT.LITR.ZS`,
    school_enrollment = `SE.SEC.ENRR`,
    infant_mortality  = `SP.DYN.IMRT.IN`,
    life_expectancy   = `SP.DYN.LE00.IN`
  )

# ---------- Population + Income ----------
p_cc <- pick_col(meta, c("country_code","Country Code","Code"))
p_cn <- pick_col(meta, c("country_name","Country Name","Economy","Country"))
p_yr <- pick_col(meta, c("year","Year"))
p_pop<- pick_col(meta, c("population","SP.POP.TOTL","Population"))
p_inc<- pick_col(meta, c("income_group","Income group","Income Group"))

if (any(is.na(c(p_cc,p_cn,p_yr,p_pop)))) {
  stop("POP/Income columns not recognized. Saw: ", paste(names(meta), collapse=", "))
}

meta_clean <- meta %>%
  transmute(
    country_code = toupper(as.character(.data[[p_cc]])),
    country_name = as.character(.data[[p_cn]]),
    year         = to_int(.data[[p_yr]]),
    population   = to_num(.data[[p_pop]]),
    income_group = if (!is.na(p_inc)) as.character(.data[[p_inc]]) else NA_character_
  )

# ---------- Merge all ----------
df <- crs_year %>%
  left_join(wdi_wide, by = c("country_code","country_name","year")) %>%
  left_join(meta_clean, by = c("country_code","country_name","year")) %>%
  relocate(country_name, country_code, year, sector)

# ---------- Lags (0–3 years) over outcomes ----------
lag_cols <- c("literacy_rate","school_enrollment","infant_mortality","life_expectancy")
make_lags <- function(dat, cols, kmax = 3) {
  dat <- dat %>% arrange(country_code, year)
  for (col in cols) {
    for (k in 1:kmax) {
      newnm <- paste0(col, "_lag", k)
      dat <- dat %>%
        group_by(country_code) %>%
        mutate(!!newnm := dplyr::lag(.data[[col]], n = k)) %>%
        ungroup()
    }
  }
  dat
}
df <- make_lags(df, lag_cols, 3)

# ---------- Peer z-scores (income_group × year), using non-lagged outcomes ----------
peer_z <- function(x) {
  x <- as.numeric(x)
  if (all(is.na(x)) || sum(!is.na(x)) < 3) return(rep(NA_real_, length(x)))
  m <- mean(x, na.rm = TRUE); s <- sd(x, na.rm = TRUE)
  if (is.na(s) || s == 0) return(rep(NA_real_, length(x)))
  (x - m)/s
}

for (col in lag_cols) {
  zcol <- paste0(col, "_z")
  df <- df %>%
    group_by(income_group, year) %>%
    mutate(!!zcol := peer_z(.data[[col]])) %>%
    ungroup()
}

# ---------- Mismatch flag (|z| >= 2 on any outcome) ----------
df <- df %>%
  mutate(
    mismatch_flag = dplyr::case_when(
      rowSums(cbind(
        abs(literacy_rate_z) >= 2,
        abs(school_enrollment_z) >= 2,
        abs(infant_mortality_z) >= 2,
        abs(life_expectancy_z) >= 2
      ), na.rm = TRUE) > 0 ~ "Notable",
      TRUE ~ "Normal"
    )
  )

# ---------- Write ----------
readr::write_csv(df, OUT_CSV)
message("Wrote: ", OUT_CSV, "  rows=", nrow(df), "  cols=", ncol(df))
