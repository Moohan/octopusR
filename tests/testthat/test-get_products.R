skip_if_offline(host = "api.octopus.energy")

test_that("Get products returns expected data", {
  products_data_vars <- c(
    "code",
    "direction",
    "full_name",
    "display_name",
    "description",
    "is_variable",
    "is_green",
    "is_tracker",
    "is_prepay",
    "is_business",
    "is_restricted",
    "term",
    "available_from",
    "available_to",
    "links",
    "brand"
  )

  get_products() |>
    expect_s3_class("tbl") |>
    expect_named(products_data_vars)

  get_products(is_green = TRUE) |>
    expect_s3_class("tbl") |>
    expect_named(products_data_vars)

  get_products(is_variable = TRUE, is_green = TRUE) |>
    expect_s3_class("tbl") |>
    expect_named(products_data_vars)

  get_products(is_variable = TRUE, is_green = TRUE, is_prepay = FALSE) |>
    expect_s3_class("tbl") |>
    expect_named(products_data_vars)
})
