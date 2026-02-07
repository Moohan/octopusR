skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  test_meter <- testing_meter("electricity")
  # Check if MPAN looks valid
  skip_if(
    !grepl("^[0-9]{10,}$", test_meter[["mpan_mprn"]]),
    "Secret key is likely incorrect or missing"
  )

  expected_gsp <- tryCatch(
    httr2::secret_decrypt(
      "5GkfdUf-Fp88BMOFir1kkOOl",
      "OCTOPUSR_SECRET_KEY"
    ),
    error = function(e) ""
  )
  expected_gsp <- iconv(expected_gsp, to = "ASCII", sub = "")

  # GSPs are usually single letters, maybe prefixed by _
  skip_if(
    !grepl("^[A-Z_]{1,2}$", expected_gsp),
    "Secret key is likely incorrect"
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
