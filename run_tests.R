
# Source all R files to load package functions
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
for (file in r_files) {
  source(file)
}

library(testthat)
test_file("tests/testthat/test-get_consumption.R")
