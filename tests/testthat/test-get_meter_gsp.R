skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Skip if we are using dummy keys or decryption failed
  api_key <- get_api_key()
  skip_if(grepl("^sk_test_", api_key), "Using dummy API keys")

  test_meter <- testing_meter("electricity")
  skip_if(grepl("^sk_test_", test_meter$mpan_mprn), "Using dummy MPAN")

  # Use a more robust check for the expected GSP
  verified_gsp <- tryCatch(
    httr2::secret_decrypt("5GkfdUf-Fp88BMOFir1kkOOl", "OCTOPUSR_SECRET_KEY"),
    error = function(e) NULL
  )
  skip_if(is.null(verified_gsp), "Could not decrypt expected GSP")
  # GSP should be a single character A-P
  skip_if(
    !grepl("^[A-P]$", verified_gsp),
    "Decrypted GSP looks like garbage"
  )

  expect_equal(
    get_meter_gsp(mpan = test_meter[["mpan_mprn"]]),
    verified_gsp
  )
})

test_that("Fails with bad mprn", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
