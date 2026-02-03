skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  test_meter <- testing_meter("electricity")
  expected_gsp <- tryCatch(
    {
      val <- httr2::secret_decrypt(
        "5GkfdUf-Fp88BMOFir1kkOOl",
        "OCTOPUSR_SECRET_KEY"
      )
      val <- iconv(val, to = "ASCII", sub = "")
      gsub("[^a-zA-Z0-9_-]", "", val)
    },
    error = function(e) "H"
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
