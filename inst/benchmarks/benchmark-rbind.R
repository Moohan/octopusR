# Benchmark to compare different methods of row-binding data frames
#
# This script is designed to measure the performance difference between
# do.call(rbind, ...), vctrs::vec_rbind(), and data.table::rbindlist().
#
# The `get_consumption` function in this package uses one of these methods
# to combine paginated API results, and this benchmark validates the choice
# of `vctrs::vec_rbind()` as a high-performance fallback when `data.table`
# is not installed.

# Ensure the `bench` package is installed
if (!requireNamespace("bench", quietly = TRUE)) {
  install.packages("bench")
}

library(bench)

# Create a list of data frames to simulate API results
set.seed(123)
list_of_dfs <- replicate(100, {
  data.frame(
    consumption = runif(1000, 0, 1),
    interval_start = as.character(Sys.time() + runif(1000, 0, 86400)),
    interval_end = as.character(Sys.time() + runif(1000, 86400, 172800))
  )
}, simplify = FALSE)

# Run the benchmark
benchmark_results <- bench::mark(
  "do.call(rbind)" = do.call(rbind, list_of_dfs),
  "vctrs::vec_rbind" = vctrs::vec_rbind(!!!list_of_dfs),
  "data.table::rbindlist" = data.table::rbindlist(list_of_dfs),
  check = FALSE,
  min_iterations = 50
)

# Print the results
print(benchmark_results)
