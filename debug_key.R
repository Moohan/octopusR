
library(octopusR)
print(paste("API KEY:", get_api_key()))
print(paste("IS TESTING:", octopusR:::is_testing()))
print(paste("TESTTHAT ENV:", Sys.getenv("TESTTHAT")))
