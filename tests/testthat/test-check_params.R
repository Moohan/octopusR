test_that("Works for correct dates", {
  expect_identical(
    check_datetime_format("2022-01-01", NULL),
    "2022-01-01"
  )
})
