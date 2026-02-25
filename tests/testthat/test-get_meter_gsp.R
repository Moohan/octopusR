skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  testthat::skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

  test_meter <- testing_meter("electricity")

  # Only attempt decryption if we have a real key
  expected_gsp <- tryCatch(
    httr2::secret_decrypt(
      "5GkfdUf-Fp88BMOFir1kkOOl",
      "OCTOPUSR_SECRET_KEY"
    ),
    error = function(e) "J"
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
