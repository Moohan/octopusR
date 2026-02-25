skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Robust skip logic: skip if API key is missing, dummy, or looks like garbage
  api_key <- get_api_key()
  is_dummy <- grepl("^sk_test_", api_key)
  is_garbage <- is.na(iconv(api_key, to = "ASCII")) || nchar(api_key) < 5

  testthat::skip_on_ci()
  testthat::skip_if(is_dummy || is_garbage, "Using dummy or invalid API keys")

  test_meter <- testing_meter("electricity")

  # Use robust decryption for expected value too
  expected_gsp <- tryCatch(
    {
      res <- httr2::secret_decrypt(
        "5GkfdUf-Fp88BMOFir1kkOOl",
        "OCTOPUSR_SECRET_KEY"
      )
      # GSP must be a single character A-P
      is_garbage <- is.na(iconv(res, to = "ASCII")) ||
        !grepl("^[A-P]$", res)

      if (is_garbage) {
        stop("Garbage decrypted")
      }
      res
    },
    error = function(e) "J"
  )

  # If we still got something that doesn't look like a GSP, skip
  # actual GSP from API will also be checked against this
  testthat::skip_if(
    !grepl("^[A-P]$", expected_gsp) || expected_gsp == "J",
    "Could not decrypt valid GSP or using dummy"
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
