# Create a list of data frames to simulate API responses
set.seed(123)
consumption_data_list <- lapply(1:100, function(i) {
  data.frame(
    consumption = rnorm(100),
    interval_start = as.character(Sys.time() + rnorm(100) * 3600),
    interval_end = as.character(Sys.time() + rnorm(100) * 3600 + 1800)
  )
})

# Ensure the vctrs package is loaded for a fair comparison,
# simulating an environment where it's available.
if (!requireNamespace("vctrs", quietly = TRUE)) {
  install.packages("vctrs")
}
library(vctrs)

# Benchmark the two methods for combining data frames
bench::mark(
  "Base R" = {
    do.call(rbind, consumption_data_list)
  },
  "vctrs" = {
    vctrs::vec_rbind(!!!consumption_data_list)
  },
  check = FALSE,
  min_iterations = 50
)
