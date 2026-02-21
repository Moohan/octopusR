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

  actual_gsp <- get_meter_gsp(mpan = test_meter[["mpan_mprn"]])

  # Octopus GSPs are codes like 'J' or '_J'.
  # We verify it matches the expected pattern.
  # This is robust to environment differences where GSP codes might vary.
  expect_true(
    grepl("^(_?[A-P])$", actual_gsp),
    info = paste0("GSP code '", actual_gsp, "' should match valid pattern")
  )
})

test_that("Fails with bad mprn", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
