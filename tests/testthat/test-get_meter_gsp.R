skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")
  test_meter <- testing_meter("electricity")

  # Robust check for garbage MPAN or dummy MPAN
  mpan <- test_meter[["mpan_mprn"]]
  skip_if(
    grepl("^sk_test_", mpan) || nchar(mpan) < 10,
    "Using dummy or garbage MPAN"
  )

  expected_gsp <- tryCatch(
    {
      httr2::secret_decrypt(
        "5GkfdUf-Fp88BMOFir1kkOOl",
        "OCTOPUSR_SECRET_KEY"
      )
    },
    error = function(e) ""
  )

  # Skip if decryption failed or returned garbage (GSP is a single letter)
  skip_if(
    identical(expected_gsp, "") ||
      !grepl("^[A-P]$", expected_gsp),
    "Decryption failed or returned garbage GSP"
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
