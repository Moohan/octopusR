skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  skip_if(grepl("^sk_test_", get_api_key()), "Using dummy API keys")
  test_meter <- testing_meter("electricity")
  expected_gsp <- httr2::secret_decrypt(
    "5GkfdUf-Fp88BMOFir1kkOOl",
    "OCTOPUSR_SECRET_KEY"
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
