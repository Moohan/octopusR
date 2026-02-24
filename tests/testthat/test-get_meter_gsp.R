skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  test_meter <- testing_meter("electricity")
  skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")

  expected_gsp <- safe_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "J"
  )

  # Double check if we have real data or fallback garbage
  skip_if(identical(expected_gsp, "J"), "Using dummy GSP")
  skip_if(nchar(test_meter[["mpan_mprn"]]) < 5, "Using dummy MPAN")
  # Matches pattern for garbage returned by secret_decrypt with wrong key
  skip_if(grepl("[^A-P]", expected_gsp), "Decrypted GSP looks like garbage")

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
