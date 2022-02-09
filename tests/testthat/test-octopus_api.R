test_that("Octopus API fails when not authenticated", {
  expect_error(octopus_api(path = "v1/accounts/"),
               "Authentication credentials were not provided")
  expect_error(octopus_api(path = "v1/accounts/", api_key = "incorrect_api_key"),
               "Invalid API key.")
})

test_that("Octopus API returns correctly", {
  path <- "v1/products/"
  result <- octopus_api(path)

  expect_s3_class(result, "octopus_api")
  expect_type(result$content, "list")
  expect_s3_class(result$content$results, "tbl_df")
  expect_type(result$content$count, "integer")
  expect_null(result$content$`next`)
  expect_null(result$content$previous)

  expect_type(result$path, "character")
  expect_type(result$response, "list")

  expect_equal(httr::status_code(result$response), 200)
  expect_equal(result$path, path)

  expect_named(result$content$results,
    c(
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
  )
})
