skip_if_offline(host = "api.octopus.energy")
skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

test_that("Can get a meter GSP", {
  test_meter <- testing_meter("electricity")
  mpan <- test_meter[["mpan_mprn"]]

  # Skip if we have a dummy or garbage MPAN
  skip_if(grepl("^sk_test_", mpan), "Using dummy MPAN")
  skip_if(nchar(mpan) < 5, "MPAN looks like garbage")

  expected_gsp <- tryCatch(
    {
      httr2::secret_decrypt(
        "5GkfdUf-Fp88BMOFir1kkOOl",
        "OCTOPUSR_SECRET_KEY"
      )
    },
    error = function(e) NULL
  )

  # Skip if GSP decryption failed or looks like garbage
  skip_if(is.null(expected_gsp), "GSP decryption failed")
  skip_if(nchar(expected_gsp) != 1, "Decrypted GSP looks like garbage")
  skip_if(!grepl("^[A-P]$", expected_gsp), "Decrypted GSP is not a valid letter")

  expect_equal(
    get_meter_gsp(mpan = mpan),
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
