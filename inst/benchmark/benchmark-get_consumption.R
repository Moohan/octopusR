# Benchmark for get_consumption() pagination
#
# This script measures the performance difference between two methods of updating
# the query parameters within the pagination loop of the `get_consumption` function.
#
# Method 1 (Original): Uses `append()` to add the "page" parameter to the query list.
#                       This creates a new list in each iteration.
# Method 2 (Optimized): Uses direct assignment (`query$page <- page`) to update the
#                       page number. This modifies the list in place.
#
# The benchmark mocks the `octopus_api` function to isolate the loop's performance
# from actual API calls.

# Mock the API response
mock_octopus_api_response <- function(page = 1) {
  list(
    content = list(
      count = 1000,
      next_page = if (page < 10) paste0("?page=", page + 1) else NULL,
      results = data.frame(
        consumption = runif(100),
        interval_start = Sys.time() + 1:100,
        interval_end = Sys.time() + 2:101
      )
    )
  )
}

# Original function using append()
get_consumption_original <- function() {
  query <- list(page_size = 100)
  page <- 1L
  resp <- mock_octopus_api_response(page)

  while (!is.null(resp$content$next_page)) {
    page <- page + 1L
    resp <- mock_octopus_api_response(page)
    # Inefficient part
    updated_query <- append(query, list(page = page))
  }
}

# Optimized function with direct assignment
get_consumption_optimized <- function() {
  query <- list(page_size = 100)
  page <- 1L
  resp <- mock_octopus_api_response(page)

  while (!is.null(resp$content$next_page)) {
    page <- page + 1L
    resp <- mock_octopus_api_response(page)
    # Efficient part
    query$page <- page
  }
}

# Run the benchmark
if (requireNamespace("bench", quietly = TRUE)) {
  bench::mark(
    original = get_consumption_original(),
    optimized = get_consumption_optimized(),
    check = FALSE,
    min_iterations = 100
  )
} else {
  message("Please install the 'bench' package to run this benchmark.")
}
