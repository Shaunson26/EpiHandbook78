#' IO + rio import() and export() example
#' 
#' rio uses data.table package to import data, and we would expect the class of
#' the imported object to be 'data.table'. There is a 'setclass' parameter in this
#' function, with the default to set class as a generic R data.frame
#' 
#' We use base R save()/load() for multiple objects

library(rio)

# 1) rio::import() and classes
# default is generic R data.frame
linelist <- rio::import('linelist_raw.csv')

class(linelist)

linelist

# tidyverse tibble
linelist <- rio::import('linelist_raw.csv', setclass = 'tibble')

class(linelist)

linelist

# data.table 
linelist <- rio::import('linelist_raw.csv', setclass = 'data.table')

class(linelist)

linelist

# 2) Export R data
rio::export(linelist, 'linelist_data.table.rds')

# imports as data.table
linelist <- rio::import('linelist_data.table.rds')

class(linelist)

linelist

# 3) save() and .Rdata
# Save multiple named objects
my_list <- list(a = 1, b = 2, c = 3)
my_vector <- c('cat', 'dog', 'fish')
my_model <- lm(mpg ~ wt, data = mtcars)

save(my_list, my_vector, my_model, file = 'my_objects.rdata')

# clear environment
rm(my_list, my_vector, my_model)

# loading back named objects
load('my_objects.rdata')


