test_that("Can return consumption data sample", {
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

test_that("errors properly with incorrect params", {
  expect_error(
    get_consumption(),
    "You must specify \"electricity\" or \"gas\" for `meter_type`"
  )

  expect_error(
    get_consumption("electricity", period_to = Sys.Date()),
    "To use `period_to` you must also provide the `period_from` parameter to create a range"
  )
})
