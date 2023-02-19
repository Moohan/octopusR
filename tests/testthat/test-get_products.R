skip_if_offline(host = "api.octopus.energy")

test_that("Get products returns data", {
  expect_s3_class(
    get_products(),
    "tbl"
  )

  expect_s3_class(
    get_products(is_green = TRUE),
    "tbl"
  )

  expect_s3_class(
    get_products(is_variable = TRUE, is_green = TRUE),
    "tbl"
  )

  expect_s3_class(
    get_products(is_variable = TRUE, is_green = TRUE, is_prepay = FALSE),
    "tbl"
  )
})
