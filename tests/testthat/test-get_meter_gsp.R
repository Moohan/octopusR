skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  skip_if(
    Sys.getenv("OCTOPUSR_MPAN") == "" && Sys.getenv("OCTOPUSR_SECRET_KEY") == "",
    "OCTOPUSR_MPAN environment variable or OCTOPUSR_SECRET_KEY not set"
  )

  test_meter <- testing_meter("electricity")

  # Get expected GSP from environment or encrypted secret
  expected_gsp <- Sys.getenv("OCTOPUSR_GSP")
  if (identical(expected_gsp, "")) {
    expected_gsp <- httr2::secret_decrypt(
      "ENCRYPTED_GSP_HERE",  # Run encrypt_secrets.R to get this
      "OCTOPUSR_SECRET_KEY"
    )
  }

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
