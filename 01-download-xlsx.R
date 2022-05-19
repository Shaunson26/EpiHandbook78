#' Download Epi handbook data
#' 
#' Download linelist_raw.xlsx from github and export as csv

input_url <- 'https://github.com/appliedepi/epirhandbook_eng/raw/master/data/case_linelists/linelist_raw.xlsx'

library(readxl)
library(readr)

# mode = 'wb' to download binary file
download.file(input_url, destfile = basename(input_url), mode = 'wb')

linelist_raw  <- readxl::read_excel('linelist_raw.xlsx')

readr::write_csv(linelist_raw, 'linelist_raw.csv')
