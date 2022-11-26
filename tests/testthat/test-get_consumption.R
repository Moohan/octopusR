test_that("Can return consumption data", {

  consumption_data <- get_consumption("electricity")

  expect_s3_class(consumption_data, "tbl")
})
