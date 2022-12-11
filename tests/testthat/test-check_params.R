test_that("Works for correct dates", {
  expect_invisible(
    check_datetime_format("2022-01-01"),
  )
  expect_invisible(
    check_datetime_format("2022-01-01 00:00"),
  )
})

test_that("Errors on incorrect dates", {
  expect_error(
    check_datetime_format("01/01/2022"),
  )
})
