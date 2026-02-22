skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  testthat::skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")
  test_meter <- testing_meter("electricity")

  # Use safe_decrypt to avoid "input string 1 is invalid" errors
  # and skip if we don't have the real key.
  expected_gsp <- octopusR:::safe_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "sk_test_gsp"
  )
  testthat::skip_if(grepl("^sk_test_", expected_gsp), "Using dummy API keys")

  # Additional check: Octopus GSPs are usually single letters A-P.
  # If it doesn't look like that, it's probably garbage from a wrong key.
  testthat::skip_if(
    !grepl("^[A-P]$|^_[A-P]$|^_$", expected_gsp),
    "Decrypted GSP looks like garbage"
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
  testthat::skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
