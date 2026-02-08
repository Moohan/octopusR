skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  test_meter <- testing_meter("electricity")
  skip_if(grepl("^sk_test_", test_meter[["mpan_mprn"]]), "Using dummy MPAN")

  expected_gsp <- tryCatch(
    httr2::secret_decrypt(
      "5GkfdUf-Fp88BMOFir1kkOOl",
      "OCTOPUSR_SECRET_KEY"
    ),
    error = function(e) "DUMMY_GSP"
  )
  expected_gsp <- octopusR:::sanitize_derived_string(
    expected_gsp,
    "DUMMY_GSP"
  )
  skip_if(expected_gsp == "DUMMY_GSP", "No valid GSP secret")

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
