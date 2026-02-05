skip_if_offline(host = "api.octopus.energy")

test_that("Can get a meter GSP", {
  # Mock the API call to return a consistent GSP
  mock_api <- function(...) {
    list(content = list(gsp = "J"))
  }
  mockery::stub(get_meter_gsp, "octopus_api", mock_api)

  # Use a dummy MPAN, the mock will handle it
  expect_equal(
    get_meter_gsp(mpan = "1234567890123"),
    "J"
  )
})

test_that("Fails with bad mprn", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )
  # This one might still make a real call if not stubbed,
  # but get_meter_gsp only calls octopus_api once.
  mock_api_error <- function(...) {
    stop("HTTP 404")
  }
  mockery::stub(get_meter_gsp, "octopus_api", mock_api_error)
  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
