# Benchmark for different rbind methods
library(bench)

# Create a list of data frames to simulate API results
set.seed(123)
list_of_dfs <- lapply(1:1000, function(i) {
  data.frame(
    consumption = rnorm(100),
    interval_start = as.character(Sys.time() + i * 3600),
    interval_end = as.character(Sys.time() + (i + 1) * 3600)
  )
})

# Benchmark the two methods
bench_results <- bench::mark(
  "do.call" = do.call(rbind, list_of_dfs),
  "vctrs::vec_rbind" = vctrs::vec_rbind(!!!list_of_dfs),
  check = FALSE,
  min_iterations = 5
)

print(bench_results)
