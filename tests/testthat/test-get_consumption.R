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

test_that("Can return electric consumption data sample", {
  mock_api <- function(...) {
    create_mock_api_response(
      count = 100,
      results = tibble::tibble(
        consumption = 1:100,
        interval_start = "a",
        interval_end = "b"
      )
    )
  }
  mockery::stub(get_consumption, "octopus_api", mock_api)

  expect_message(
    consumption_data <- get_consumption("electricity"),
    "Returning 100 rows"
  )

  expect_s3_class(consumption_data, "tbl_df")
  expect_named(
    consumption_data,
    c("consumption", "interval_start", "interval_end")
  )
  expect_equal(nrow(consumption_data), 100L)
})

test_that("Can return gas consumption data sample", {
  mock_api <- function(...) {
    create_mock_api_response(
      count = 100,
      results = tibble::tibble(
        consumption = 1:100,
        interval_start = "a",
        interval_end = "b"
      )
    )
  }
  mockery::stub(get_consumption, "octopus_api", mock_api)

  expect_message(
    consumption_data <- get_consumption("gas"),
    "Returning 100 rows"
  )

  expect_s3_class(consumption_data, "tbl_df")
  expect_named(
    consumption_data,
    c("consumption", "interval_start", "interval_end")
  )
  expect_equal(nrow(consumption_data), 100L)
})

test_that("errors properly with incorrect params", {
  expect_error(
    get_consumption(),
    "You must specify \"electricity\" or \"gas\" for `meter_type`"
  )
  expect_error(
    get_consumption("electricity", period_to = Sys.Date()),
    "To use `period_to` you must also provide the `period_from` parameter"
  )
})

test_that("Correctly handles multi-page parallel requests", {
  # This mock handles the two ways octopus_api is called in the multi-page scenario
  mock_api_multi_page <- function(path, query, ..., perform = TRUE) {
    if (perform) {
      # The first call to get page count
      create_mock_api_response(
        count = 30,
        results = tibble::tibble(
          consumption = 1:10,
          interval_start = "a",
          interval_end = "b"
        )
      )
    } else {
      # The subsequent calls to build the request list
      # Return a real request object so httr2::req_url_query works
      httr2::request("https://api.octopus.energy") |>
        httr2::req_url_query(!!!query)
    }
  }

  # This mock simulates the parallel execution
  mock_req_perform_parallel <- function(reqs, ...) {
    lapply(reqs, function(req) {
      # Extract page number from the request URL
      url <- httr2::url_parse(req$url)
      page_num <- as.integer(url$query$page)
      create_mock_httr2_response(
        results = tibble::tibble(
          consumption = (1:10) + ((page_num - 1) * 10),
          interval_start = "a",
          interval_end = "b"
        )
      )
    })
  }

  # Stub the two external functions
  mockery::stub(get_consumption, "octopus_api", mock_api_multi_page)
  mockery::stub(
    get_consumption,
    "httr2::req_perform_parallel",
    mock_req_perform_parallel
  )

  # Use a date range to trigger the multi-page logic
  consumption_data <- get_consumption(
    meter_type = "electricity",
    period_from = "2023-01-01",
    page_size = 10 # This needs to be smaller than the mocked count of 30
  )

  # Verify the result
  expect_equal(nrow(consumption_data), 30)
  expect_s3_class(consumption_data, "tbl_df")
  # Page 1 results are 1:10
  # Page 2 results are 11:20
  # Page 3 results are 21:30
  expect_equal(consumption_data$consumption, 1:30)
})
