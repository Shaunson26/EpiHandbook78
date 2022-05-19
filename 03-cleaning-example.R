#' Cleaning data
#' 
#' We follow various parts of Epi handbook Chapter 8

library(janitor)
library(dplyr)
library(tidyr)
library(epikit)

# rio uses readxl for input ...
# imports as a tibble data.frame
linelist_raw  <- readxl::read_excel('linelist_raw.xlsx')

# 1) Check columns imported correctly ----

# Is data imported as we expect? dates are dates, numbers are numbers (e.g. age)

# tibble printing help us ...
linelist_raw

# glimpse is another option for concise checking
# note: `date onset` <chr>, age <chr>
dplyr::glimpse(linelist_raw)

# examine age and `date onset` values
linelist_raw %>% 
  count(age)

linelist_raw %>% 
  count(age) %>% 
  print(n = Inf)

linelist_raw %>% 
  count(`date onset`) %>% 
  print(n = Inf)

# we will fix these later ...

# 2) Check data characteristics ----

# skim is useful for an overall view .. types, missingness, uniquness, etc

skimr::skim(linelist_raw)

# 3) Column names ----

# There can be quirks with column names in R - sometimes invisibly altered too
# Good to have consistent naming style too

# backticks needs to capture a name with space
linelist_raw$`infection date`

# The book uses janitor standardisation and rename() for date columns to start with 'date'
linelist <- 
  linelist_raw %>%
  janitor::clean_names() %>% 
  rename(date_infection       = infection_date,
         date_hospitalisation = hosp_date,
         date_outcome         = date_of_outcome)

# no need for back ticks
linelist$date_infection

# 4) Column selection ----

# select() can be used for selection or removal

# only need to remove columns
linelist <-
  linelist %>% 
  select(-c(row_num, merged_header, x28))

# 5) Deduplication ----

# 5a) Pure example ...
# Often have an ID and we may expect only 1
linelist %>% 
  count(case_id) %>% 
  arrange(desc(n))

linelist %>% 
  distinct(case_id)

# take FIRST observation of the distinct variable(s), keep other columns
# often sort by a date, and then use distinct on an ID (we did in COVID)
linelist %>% 
  arrange(date_onset) %>% 
  distinct(case_id, .keep_all = TRUE)

# 5b) Following the book
nrow(linelist) # 6611

linelist <- 
  linelist %>% 
  distinct() # which variables used?

nrow(linelist) # 6608

# 6) Derived column + transformations

# make use of mutate(), across() and tidyselect functions 

# we needed to change these
linelist$age[1:10]
linelist$date_onset[1:10]

linelist %>% 
  select(starts_with('date'))

# mutating columns + checking
linelist <- 
  linelist %>% 
  mutate(bmi = wt_kg / (ht_cm/100)^2,
         age = as.numeric(age),
         date_onset = as.Date(date_onset, format = '%Y-%m-%d'))

linelist %>% 
  select(bmi, age, date_onset)

linelist <- 
  linelist %>% 
  mutate(across(contains("date"), as.Date))

linelist %>% 
  select(starts_with('date'))

# 6) Recoding variables ----

# recode for explicit values
# tidyr::replace_na for NA to 'Missing'

linelist <-
  linelist %>% 
  mutate(hospital = recode(hospital,
                           # OLD = NEW
                           "Mitylira Hopital"  = "Military Hospital",
                           "Mitylira Hospital" = "Military Hospital",
                           "Military Hopital"  = "Military Hospital",
                           "Port Hopital"      = "Port Hospital",
                           "Central Hopital"   = "Central Hospital",
                           "other"             = "Other",
                           "St. Marks Maternity Hopital (SMMH)" = "St. Mark's Maternity Hospital (SMMH)"
  )) %>% 
  mutate(hospital = tidyr::replace_na(hospital, replace = "Missing")) 

# check!
linelist %>% 
  count(hospital)

# create age_years column (from age and age_unit)
linelist %>% 
  count(age, age_unit) %>% 
  print(n = 30)

linelist <-
  linelist %>% 
  mutate(age_years = case_when(
    age_unit == "years" ~ age,
    age_unit == "months" ~ age/12,
    is.na(age_unit) ~ age,
    TRUE ~ NA_real_))

linelist %>% 
  count(age, age_unit, age_years) %>% 
  print(n = 30)

# 7) Categories ----

# age categories very common in public health .. epikit has a good function

linelist <- 
  linelist %>% 
  mutate(
    age_cat_10 = age_categories(
      age_years, 
      lower = 0,
      upper = 100,
      by = 10),
    age_cat_5 = age_categories(
      age_years, 
      lower = 0,
      upper = 100,
      by = 5))

linelist %>% 
  count(age_cat_5, .drop = F) %>% 
  print(n = Inf)

linelist %>% 
  count(age_cat_10, .drop = F) %>% 
  print(n = Inf)

linelist %>% 
  count(age_cat_5, age_cat_10)

# 8) Filtering rows ----

# Following the books example

# keep rows with CASE_ID value
linelist <- 
  linelist %>%
  filter(
    # keep only rows where case_id is not missing
    !is.na(case_id),  
    
    # also filter to keep only the second outbreak
    date_onset > as.Date("2013-06-01") | (is.na(date_onset) & !hospital %in% c("Hospital A", "Hospital B")))

# 9) Rowwise calculations ----

# Often need to count across columns, e.g. of symptoms

# rowise()
linelist <-
  linelist %>%
  rowwise() %>%
  mutate(num_symptoms = sum(c(fever, chills, cough, aches, vomit) == "yes")) %>% 
  ungroup()

linelist %>% 
  select(fever, chills, cough, aches, vomit, num_symptoms)

# 10) output ----
rio::export(linelist, file = 'linelist_clean.rds')


