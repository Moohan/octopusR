test_that("Can get a meter GSP", {
  mock_api <- function(...) {
    structure(
      list(content = list(gsp = "J")),
      class = "octopus_api"
    )
  }
  mockery::stub(get_meter_gsp, "octopus_api", mock_api)

  expect_equal(
    get_meter_gsp(mpan = "12345"),
    "J"
  )
})

test_that("Fails with bad mpan", {
  expect_error(
    get_meter_gsp(mpan = NA),
    "Meter details were missing or incomplete"
  )

  mock_api_error <- function(...) {
    stop("HTTP 404")
  }
  mockery::stub(get_meter_gsp, "octopus_api", mock_api_error)

  expect_error(get_meter_gsp(mpan = "123"), "HTTP 404")
})
