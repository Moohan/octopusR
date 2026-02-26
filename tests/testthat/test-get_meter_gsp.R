skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Skip if using dummy API keys to avoid 404/401 errors
  skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

  test_meter <- testing_meter("electricity")

  actual_gsp <- get_meter_gsp(mpan = test_meter[["mpan_mprn"]])

  # Verify it looks like a valid GSP code (1-2 uppercase chars, maybe with _)
  expect_true(nchar(actual_gsp) >= 1)
  expect_true(grepl("^[A-Z_]+$", actual_gsp))
})

test_that("Fails with bad mprn", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
