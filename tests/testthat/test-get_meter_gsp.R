skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Skip if using dummy API keys or if secret key is likely wrong
  api_key <- get_api_key()
  skip_if(grepl("^sk_test_", api_key), "Using dummy API keys")

  test_meter <- testing_meter("electricity")
  # If testing_meter returned a dummy MPAN because decryption failed, skip
  skip_if(grepl("^sk_test_", test_meter$mpan_mprn), "Using dummy meter details")

  # Robust decryption for expected_gsp
  expected_gsp <- tryCatch(
    {
      val <- httr2::secret_decrypt(
        "5GkfdUf-Fp88BMOFir1kkOOl",
        "OCTOPUSR_SECRET_KEY"
      )
      # GSP should be a single uppercase letter
      if (is.na(iconv(val, to = "ASCII")) || !grepl("^[A-Z]$", val)) {
        stop("Invalid GSP decryption")
      }
      val
    },
    error = function(e) "sk_test_gsp"
  )

  skip_if(grepl("^sk_test_", expected_gsp), "Using dummy GSP")

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
