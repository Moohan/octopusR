# Load necessary packages
library(bench)
library(mockery)
library(httr2)
library(tibble)

# Create a new environment to source the original function into
original_env <- new.env()
source("R/get_consumption.R", local = original_env)
original_get_consumption <- original_env$get_consumption

# Load the optimized version of the package
pkgload::load_all()

# Helper to create a mock API response object
create_mock_api_response <- function(count, results) {
  structure(
    list(content = list(count = count, results = results)),
    class = "octopus_api"
  )
}

# Helper to create a mock httr2 response object for parallel calls
create_mock_httr2_response <- function(results) {
  response_data <- list(results = results)
  httr2::response(
    status_code = 200,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(jsonlite::toJSON(response_data, auto_unbox = TRUE))
  )
}

# This mock handles the two ways octopus_api is called in the multi-page scenario
mock_api_multi_page <- function(path, query, ..., perform = TRUE) {
  if (perform) {
    # The first call to get page count
    create_mock_api_response(
      count = 30,
      results = tibble::tibble(consumption = 1:10, interval_start = "a", interval_end = "b")
    )
  } else {
    # The subsequent calls to build the request list
    httr2::request("http://localhost/") |>
      httr2::req_url_query(page = query$page)
  }
}

# This mock simulates the parallel execution
mock_req_perform_parallel <- function(reqs, ...) {
  lapply(reqs, function(req) {
    page_num <- as.integer(req$options$query$page)
    create_mock_httr2_response(
      results = tibble::tibble(consumption = (1:10) + ((page_num - 1) * 10), interval_start = "a", interval_end = "b")
    )
  })
}

# Stub the external functions for both original and optimized versions
mockery::stub(original_get_consumption, "get_meter_details", list(mpan_mprn = "123", serial_number = "456"))
mockery::stub(original_get_consumption, "octopus_api", mock_api_multi_page)
mockery::stub(original_get_consumption, "httr2::req_perform_parallel", mock_req_perform_parallel)

mockery::stub(get_consumption, "get_meter_details", list(mpan_mprn = "123", serial_number = "456"))
mockery::stub(get_consumption, "octopus_api", mock_api_multi_page)
mockery::stub(get_consumption, "httr2::req_perform_parallel", mock_req_perform_parallel)

# Run the benchmark
bench::mark(
  original = original_get_consumption(
    meter_type = "electricity",
    mpan_mprn = "123",
    serial_number = "456",
    api_key = "DUMMY_KEY",
    period_from = "2023-01-01",
    page_size = 10
  ),
  optimized = get_consumption(
    meter_type = "electricity",
    mpan_mprn = "123",
    serial_number = "456",
    api_key = "DUMMY_KEY",
    period_from = "2023-01-01",
    page_size = 10
  ),
  check = FALSE
)
