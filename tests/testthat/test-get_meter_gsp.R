skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Skip if secrets are not available or not working correctly
  test_key <- get_api_key()
  if (identical(test_key, "sk_test_dummy_key")) {
    skip("Secrets not available")
  }

  test_meter <- testing_meter("electricity")
  # If testing_meter returned a dummy MPAN, skip
  if (identical(test_meter[["mpan_mprn"]], "123456789012")) {
    skip("Secrets not available")
  }

  expected_gsp <- tryCatch(
    httr2::secret_decrypt(
      "5GkfdUf-Fp88BMOFir1kkOOl",
      "OCTOPUSR_SECRET_KEY"
    ),
    error = function(e) ""
  )
  expected_gsp <- iconv(expected_gsp, to = "ASCII", sub = "")
  # GSP codes must be an underscore followed by a single uppercase letter.
  # Anything else is almost certainly decryption failure or malformed data.
  if (!grepl("^_[A-Z]$", expected_gsp)) {
    skip("Secrets not working as expected")
  }

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
