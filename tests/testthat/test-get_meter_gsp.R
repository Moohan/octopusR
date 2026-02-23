skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Skip if using dummy keys to avoid API errors and garbage expected values
  testthat::skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

  test_meter <- testing_meter("electricity")

  # Further check if testing_meter returned a dummy MPAN
  testthat::skip_if(
    grepl("^sk_test_", test_meter[["mpan_mprn"]]),
    "Using dummy MPAN"
  )

  expected_gsp <- safe_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "J"
  )

  # Check if expected GSP is still a dummy/garbage
  testthat::skip_if(
    identical(expected_gsp, "J") || nchar(expected_gsp) != 1,
    "Expected GSP not successfully decrypted"
  )

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
