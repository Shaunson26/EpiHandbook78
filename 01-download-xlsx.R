#' Download Epi handbook data
#' 
#' Download linelist_raw.xlsx from github and export as csv

library(readxl)
library(readr)

input_url <- 'https://github.com/appliedepi/epirhandbook_eng/raw/master/data/case_linelists/linelist_raw.xlsx'

# mode = 'wb' to download binary file
download.file(input_url, destfile = basename(input_url), mode = 'wb')

linelist_raw  <- readxl::read_excel('linelist_raw.xlsx')

linelist_raw

# write_csv for IO example in next script
readr::write_csv(linelist_raw, 'linelist_raw.csv')
