skip_if_offline(host = "api.octopus.energy")

test_that("get_tariff_charges requires product_code", {
  expect_error(
    get_tariff_charges(),
    "You must specify a `product_code`"
  )
})

test_that("get_tariff_charges requires tariff_code", {
  expect_error(
    get_tariff_charges(product_code = "AGILE-FLEX-22-11-25"),
    "You must specify a `tariff_code`"
  )
})

test_that("get_tariff_charges requires fuel_type", {
  expect_error(
    get_tariff_charges(
      product_code = "AGILE-FLEX-22-11-25",
      tariff_code = "E-1R-AGILE-FLEX-22-11-25-H"
    ),
    "You must specify \"electricity\" or \"gas\" for `fuel_type`"
  )
})

test_that("get_tariff_charges validates rate_type for electricity", {
  expect_error(
    get_tariff_charges(
      product_code = "AGILE-FLEX-22-11-25",
      tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
      fuel_type = "electricity",
      rate_type = "invalid-rate"
    ),
    "For \"electricity\", `rate_type` must be one of:"
  )
})

test_that("get_tariff_charges validates rate_type for gas", {
  expect_error(
    get_tariff_charges(
      product_code = "AGILE-FLEX-22-11-25",
      tariff_code = "G-1R-AGILE-FLEX-22-11-25-H",
      fuel_type = "gas",
      rate_type = "day-unit-rates"
    ),
    "For \"gas\", `rate_type` must be one of:"
  )
})

test_that("get_tariff_charges errors properly with period_to but no period_from", {
  expect_error(
    get_tariff_charges(
      product_code = "AGILE-FLEX-22-11-25",
      tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
      fuel_type = "electricity",
      period_to = Sys.Date()
    ),
    "To use `period_to` you must also provide the `period_from` parameter .+?$"
  )
})

test_that("Can return tariff charge data sample", {
  expect_message(
    {
      tariff_data <- get_tariff_charges(
        product_code = "AGILE-FLEX-22-11-25",
        tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
        fuel_type = "electricity"
      )
    },
    "Returning 100 rows only as a date range wasn't provided"
  )

  expect_s3_class(tariff_data, "tbl")
  expect_true("value_exc_vat" %in% names(tariff_data))
  expect_true("value_inc_vat" %in% names(tariff_data))
  expect_true("valid_from" %in% names(tariff_data))
  expect_true("valid_to" %in% names(tariff_data))
  expect_identical(nrow(tariff_data), 100L)
})

skip_if_not_installed(pkg = "lubridate", minimum_version = "0.2.1")

test_that("Returned tariff data is consistent", {
  expect_snapshot(
    suppressMessages(
      get_tariff_charges(
        product_code = "AGILE-FLEX-22-11-25",
        tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
        fuel_type = "electricity",
        period_from = "2024-01-01",
        period_to = "2024-01-02"
      )
    )
  )
  expect_snapshot(
    suppressMessages(
      get_tariff_charges(
        product_code = "AGILE-FLEX-22-11-25",
        tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
        fuel_type = "electricity",
        period_from = "2024-01-01",
        period_to = "2024-01-02",
        tz = "UTC"
      )
    )
  )
  expect_snapshot(
    suppressMessages(
      get_tariff_charges(
        product_code = "AGILE-FLEX-22-11-25",
        tariff_code = "E-1R-AGILE-FLEX-22-11-25-H",
        fuel_type = "electricity",
        period_from = "2024-01-01",
        period_to = "2024-01-02",
        tz = "UTC",
        order_by = "period"
      )
    )
  )
})

test_that("get_agile_prices returns data", {
  agile_data <- get_agile_prices(region = "H")

  expect_s3_class(agile_data, "tbl")
  expect_true("value_exc_vat" %in% names(agile_data))
  expect_true("value_inc_vat" %in% names(agile_data))
  expect_true("valid_from" %in% names(agile_data))
  expect_true("valid_to" %in% names(agile_data))
})

test_that("get_agile_prices warns for non-electricity fuel", {
  expect_warning(
    get_agile_prices(region = "H", fuel_type = "gas"),
    "Agile tariffs are typically only available for electricity"
  )
})
