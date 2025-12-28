
# install.packages("bench")
# install.packages("tibble")
# install.packages("vctrs")
# install.packages("data.table")

library(bench)
library(tibble)

# Simulate a list of 100 API responses, each with 100 rows
data_list <- replicate(100,
                       tibble(
                         consumption = runif(100),
                         interval_start = as.character(Sys.time() + runif(100) * 1e6),
                         interval_end = as.character(Sys.time() + runif(100) * 1e6 + 30 * 60)
                       ),
                       simplify = FALSE)

# Define the functions to benchmark
bind_rows_rbind <- function(list_of_dfs) {
  do.call(rbind, list_of_dfs)
}

bind_rows_vctrs <- function(list_of_dfs) {
  vctrs::vec_rbind(!!!list_of_dfs)
}

bind_rows_datatable <- function(list_of_dfs) {
  data.table::rbindlist(list_of_dfs)
}

# Run the benchmark
benchmark_results <- mark(
  rbind = bind_rows_rbind(data_list),
  vctrs = bind_rows_vctrs(data_list),
  datatable = bind_rows_datatable(data_list),
  check = FALSE
)

# Print the results
print(benchmark_results)
