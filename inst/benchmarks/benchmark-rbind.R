# Benchmark for different rbind methods

# Create a list of data frames to simulate API responses
set.seed(123)
list_of_dfs <- replicate(100, {
  data.frame(
    consumption = runif(48, 0, 1),
    interval_start = seq.POSIXt(as.POSIXct("2023-01-01"), by = "30 min", length.out = 48),
    interval_end = seq.POSIXt(as.POSIXct("2023-01-01") + 1800, by = "30 min", length.out = 48)
  )
}, simplify = FALSE)

# Run the benchmark
bench::mark(
  "do.call rbind" = {
    do.call(rbind, list_of_dfs)
  },
  "vctrs::vec_rbind" = {
    vctrs::vec_rbind(!!!list_of_dfs)
  },
  check = FALSE,
  min_iterations = 50
)
