skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  testthat::skip_if(
    grepl("^sk_test_", get_api_key()),
    "Using dummy API keys"
  )

  test_meter <- testing_meter("electricity")

  # Check if MPAN looks valid (not garbage from failed decryption)
  testthat::skip_if(
    !grepl("^[0-9]{10,15}$", test_meter[["mpan_mprn"]]),
    "MPAN does not look like a valid decrypted value"
  )

  expected_gsp <- safe_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "J"
  )

  # Check if expected GSP looks valid
  testthat::skip_if(
    !grepl("^[A-P]$", expected_gsp),
    "Expected GSP does not look like a valid decrypted value"
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
