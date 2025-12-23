skip_if_offline(host = "api.octopus.energy")

# Skip if no API credentials are available locally or on CI
skip_if_missing_api_creds()

test_that("Can get a meter GSP", {
  # Skip if no GSP configured (user does not have GSP / not provided)
  skip_if(
    Sys.getenv("OCTOPUSR_GSP") == "",
    "OCTOPUSR_GSP not set; skipping GSP test"
  )

  test_meter <- testing_meter("electricity")

  # Get expected GSP from environment (we've skipped if not present)
  expected_gsp <- Sys.getenv("OCTOPUSR_GSP")

  expect_equal(
    get_meter_gsp(mpan = test_meter[["mpan_mprn"]]),
    expected_gsp
  )
})

test_that("Fails with bad mprn", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
