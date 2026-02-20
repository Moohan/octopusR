skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

  test_meter <- testing_meter("electricity")
  # skip if MPAN is dummy
  skip_if(grepl("^sk_test_", test_meter[["mpan_mprn"]]), "Using dummy MPAN")

  expected_gsp <- safe_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "J"
  )

  # skip if expected GSP is clearly garbage (one char letter usually A-P)
  skip_if(!grepl("^[A-P]$", expected_gsp), "Garbage GSP decryption")

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
