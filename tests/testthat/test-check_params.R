test_that("Works for correct dates", {
  expect_invisible(check_datetime_format("2022-01-01"))
  expect_invisible(check_datetime_format("2022-01-01 00:00"))
})

test_that("Works for correct logical", {
  expect_invisible(check_logical(TRUE))
  expect_invisible(check_logical(FALSE))
})

test_that("Errors on incorrect dates", {
  expect_error(check_datetime_format("01/01/2022"))
})

test_that("Errors on incorrect logical", {
  expect_error(check_logical("TRUE"))
  expect_error(check_logical("FALSE"))
  expect_error(check_logical(1))
  expect_error(check_logical(0))
})
