# benchmark.R
library(bench)

# Create a list of 100 small data frames, simulating API pages
list_of_dfs <- replicate(100, data.frame(x = rnorm(100), y = sample(letters, 100, replace = TRUE)), simplify = FALSE)

# Benchmark the two methods
bm <- bench::mark(
  "do.call(rbind, ...)" = do.call(rbind, list_of_dfs),
  "vctrs::vec_rbind()"  = vctrs::vec_rbind(!!!list_of_dfs),
  check = FALSE,
  min_iterations = 50
)

print(bm[, c("expression", "min", "median", "itr/sec", "n_gc")])
