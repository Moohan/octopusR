skip_if_offline(host = "api.octopus.energy")

# Helper to create a mock API response
create_mock_api_response <- function(count, results) {
  list(
    content = list(
      count = count,
      results = results
    )
  )
}

test_that("Can return electric consumption data sample", {
  # Mock get_api_key and get_meter_details to avoid needing environment vars
  with_mocked_bindings(
    get_api_key = function() "sk_test_dummy",
    get_meter_details = function(...) {
      list(
        mpan_mprn = "123",
        serial_number = "SN123"
      )
    },
    # Mock octopus_api to return dummy data
    octopus_api = function(...) {
      create_mock_api_response(
        count = 1,
        results = tibble::tibble(
          consumption = 1.5,
          interval_start = "2023-01-01T00:00:00Z",
          interval_end = "2023-01-01T00:30:00Z"
        )
      )
    },
    {
      expect_message(
        data <- get_consumption("electricity"),
        "Returning 100 rows only as a date range wasn't provided"
      )

      expect_s3_class(data, "tbl_df")
      expect_equal(nrow(data), 1)
      expect_named(data, c("consumption", "interval_start", "interval_end"))
    }
  )
})

test_that("errors properly with incorrect params", {
  expect_error(get_consumption(), "You must specify")
  expect_error(
    get_consumption("electricity", period_to = Sys.Date()),
    "To use period_to you must also provide the period_from"
  )
  expect_error(
    get_consumption("gas", direction = "import"),
    "direction parameter is only valid for electricity meters"
  )
})

test_that("Correctly handles multi-page parallel requests", {
  # This mock handles the two ways octopus_api is called in the multi-page
  # scenario
  mock_api_multi_page <- function(path, query, ..., perform = TRUE) {
    if (perform) {
      # The first call to get page count
      create_mock_api_response(
        count = 30,
        results = tibble::tibble(
          consumption = 1:10,
          interval_start = paste0("2023-01-01T00:", 0:9, ":00Z"),
          interval_end = paste0("2023-01-01T00:", 1:10, ":00Z")
        )
      )
    } else {
      # The calls to create request objects (perform = FALSE)
      # We just need to return something that can be passed to
      # req_perform_parallel
      httr2::request("https://api.octopus.energy/v1/test")
    }
  }

  # Mock req_perform_parallel to simulate responses for other pages
  mock_req_perform_parallel <- function(reqs, ...) {
    lapply(2:3, function(i) {
      # Create a real httr2_response object with JSON body
      resp_data <- list(
        results = data.frame(
          consumption = (1:10) + (i - 1) * 10,
          interval_start = paste0("2023-01-01T", i, ":", 0:9, ":00Z"),
          interval_end = paste0("2023-01-01T", i, ":", 1:10, ":00Z")
        )
      )

      # We need a way to create a mock response that httr2::resp_body_json
      # can read
      # A simple approach is to use a real response object if possible,
      # but mocking it as a list with the right class might also work depending
      # on how get_consumption is implemented.
      # Since get_consumption uses httr2::resp_body_json(r,
      # simplifyVector = TRUE),
      # we should return something it likes.
      structure(
        list(
          body = jsonlite::toJSON(resp_data, auto_unbox = TRUE),
          headers = list(`Content-Type` = "application/json"),
          status_code = 200
        ),
        class = "httr2_response"
      )
    })
  }

  with_mocked_bindings(
    get_api_key = function() "sk_test_dummy",
    get_meter_details = function(...) {
      list(mpan_mprn = "123", serial_number = "SN123")
    },
    octopus_api = mock_api_multi_page,
    `req_perform_parallel` = mock_req_perform_parallel,
    .package = "httr2",
    {
      # Call get_consumption with a small page size to trigger multiple pages
      data <- get_consumption(
        "electricity",
        period_from = "2023-01-01",
        page_size = 10
      )

      expect_equal(nrow(data), 30)
      expect_equal(data$consumption, 1:30)
    }
  )
})
