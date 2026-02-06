skip_if_offline(host = "api.octopus.energy")

test_that("combine_consumption handles missing data gracefully", {
  # Test with no import or export data available
  expect_error(
    combine_consumption(),
    "No import or export consumption data could be retrieved"
  )
})

# Mock function for testing combine_consumption without API calls
mock_consumption_data <- function(consumption_values, intervals = NULL) {
  if (is.null(intervals)) {
    intervals <- seq.POSIXt(
      from = as.POSIXct("2023-01-01 00:00:00", tz = "UTC"),
      by = "30 min",
      length.out = length(consumption_values)
    )
  }

  tibble::tibble(
    consumption = consumption_values,
    interval_start = intervals,
    interval_end = intervals + 30 * 60 # 30 minutes later
  )
}

test_that("combine_consumption works with explicit MPANs", {
  # Mock get_consumption to return test data
  mock_get_consumption <- function(meter_type, mpan_mprn, serial_number, ...) {
    if (identical(mpan_mprn, "123456789012")) {
      # Import data
      mock_consumption_data(c(1.5, 2.0, 1.8))
    } else if (identical(mpan_mprn, "987654321098")) {
      # Export data
      mock_consumption_data(c(0.5, 0.8, 0.3))
    } else {
      stop("No data")
    }
  }
  mockery::stub(combine_consumption, "get_consumption", mock_get_consumption)

  result <- combine_consumption(
    import_mpan = "123456789012",
    import_serial = "ABC123",
    export_mpan = "987654321098",
    export_serial = "XYZ789"
  )

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c(
      "interval_start",
      "interval_end",
      "import_consumption",
      "export_consumption",
      "net_consumption"
    )
  )
  expect_equal(result$import_consumption, c(1.5, 2.0, 1.8))
  expect_equal(result$export_consumption, c(0.5, 0.8, 0.3))
  expect_equal(result$net_consumption, c(1.0, 1.2, 1.5))
})

test_that("combine_consumption works with only import data", {
  # Mock get_consumption to return only import data
  mock_get_consumption <- function(meter_type, mpan_mprn, serial_number, ...) {
    if (identical(mpan_mprn, "123456789012")) {
      mock_consumption_data(c(1.5, 2.0, 1.8))
    } else {
      stop("No data")
    }
  }
  mockery::stub(combine_consumption, "get_consumption", mock_get_consumption)

  result <- combine_consumption(
    import_mpan = "123456789012",
    import_serial = "ABC123",
    export_mpan = "999999999999",
    export_serial = "INVALID"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(result$import_consumption, c(1.5, 2.0, 1.8))
  expect_equal(result$export_consumption, c(0, 0, 0))
  expect_equal(result$net_consumption, c(1.5, 2.0, 1.8))
})

test_that("combine_consumption works with only export data", {
  # Mock get_consumption to return only export data
  mock_get_consumption <- function(meter_type, mpan_mprn, serial_number, ...) {
    if (identical(mpan_mprn, "987654321098")) {
      mock_consumption_data(c(0.5, 0.8, 0.3))
    } else {
      stop("No data")
    }
  }
  mockery::stub(combine_consumption, "get_consumption", mock_get_consumption)

  result <- combine_consumption(
    import_mpan = "999999999999",
    import_serial = "INVALID",
    export_mpan = "987654321098",
    export_serial = "XYZ789"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(result$import_consumption, c(0, 0, 0))
  expect_equal(result$export_consumption, c(0.5, 0.8, 0.3))
  expect_equal(result$net_consumption, c(-0.5, -0.8, -0.3))
})
