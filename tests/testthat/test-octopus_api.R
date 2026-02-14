skip_if_offline(host = "api.octopus.energy")

test_that("Octopus API fails when not authenticated", {
  expect_error(
    octopus_api(path = "v1/accounts/"),
    "Authentication credentials were not provided"
  )

  expect_error(
    octopus_api(path = "v1/accounts/", api_key = get_api_key()),
    "Unauthorized|permission|Invalid API key"
  )

  expect_error(
    octopus_api(path = "v1/accounts/", api_key = "incorrect_api_key"),
    "Invalid API key"
  )
})

test_that("Octopus API returns correctly", {
  path <- "v1/products/"
  resp <- octopus_api(path)
  data <- resp[["content"]][["results"]]

  expect_s3_class(resp, "octopus_api")
  expect_type(resp[["content"]], "list")
  expect_s3_class(data, "tbl_df")
  expect_type(resp[["content"]][["count"]], "integer")
  expect_null(resp[["content"]][["next"]])
  expect_null(resp[["content"]][["previous"]])

  expect_type(resp[["path"]], "character")
  expect_type(resp[["response"]], "list")

  expect_identical(resp[["response"]][["status_code"]], 200L)
  expect_identical(resp[["path"]], path)

  expect_named(
    data,
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
