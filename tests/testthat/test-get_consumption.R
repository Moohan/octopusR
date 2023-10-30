skip_if_offline(host = "api.octopus.energy")

test_that("Can return electric consumption data sample", {
  expect_message(
    {
      consumption_data <- get_consumption("electricity")
    },
    "Returning 100 rows only as a date range wasn't provided"
  )

  expect_s3_class(consumption_data, "tbl")
  expect_named(
    consumption_data,
    c("consumption", "interval_start", "interval_end")
  )
  expect_identical(nrow(consumption_data), 100L)
})

test_that("Can return gas consumption data sample", {
  expect_message(
    {
      consumption_data <- get_consumption("gas")
    },
    "Returning 100 rows only as a date range wasn't provided"
  )

  expect_s3_class(consumption_data, "tbl")
  expect_named(
    consumption_data,
    c("consumption", "interval_start", "interval_end")
  )
  expect_identical(nrow(consumption_data), 100L)
})

test_that("errors properly with incorrect params", {
  expect_error(
    get_consumption(),
    "You must specify \"electricity\" or \"gas\" for `meter_type`"
  )

  expect_error(
    get_consumption("electricity", period_to = Sys.Date()),
    "To use `period_to` you must also provide the `period_from` parameter to create a range"
  )
  expect_error(
    get_consumption("gas", period_to = Sys.Date()),
    "To use `period_to` you must also provide the `period_from` parameter to create a range"
  )
})

skip_if_not_installed(pkg = "lubridate", minimum_version = "0.2.1")

test_that("Returned electricity data is consistent", {
  expect_snapshot(
    get_consumption(
      meter_type = "electricity",
      group_by = "week",
      period_from = "2022-01-01",
      period_to = "2022-01-31"
    )
  )
  expect_snapshot(
    get_consumption(
      meter_type = "electricity",
      group_by = "week",
      period_from = "2022-01-01",
      period_to = "2022-01-31",
      tz = "UTC"
    )
  )
  expect_snapshot(
    get_consumption(
      meter_type = "electricity",
      group_by = "week",
      period_from = "2022-01-01",
      period_to = "2022-01-31",
      tz = "UTC",
      order_by = "period"
    )
  )
})

test_that("Returned gas data is consistent", {
  expect_snapshot(
    get_consumption(
      meter_type = "gas",
      group_by = "week",
      period_from = "2023-08-01",
      period_to = "2023-08-31"
    )
  )
  expect_snapshot(
    get_consumption(
      meter_type = "gas",
      group_by = "week",
      period_from = "2023-08-01",
      period_to = "2023-08-31",
      tz = "UTC"
    )
  )
  expect_snapshot(
    get_consumption(
      meter_type = "gas",
      group_by = "week",
      period_from = "2023-08-01",
      period_to = "2023-08-31",
      tz = "UTC",
      order_by = "period"
    )
  )
})
