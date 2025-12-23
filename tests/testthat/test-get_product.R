skip_if_offline(host = "api.octopus.energy")

test_that("get_product validates input parameters", {
  expect_error(
    get_product(),
    "product_code.*must be a single character string"
  )
  
  expect_error(
    get_product(123),
    "product_code.*must be a single character string"
  )
  
  expect_error(
    get_product(c("code1", "code2")),
    "product_code.*must be a single character string"
  )
  
  expect_error(
    get_product("AGILE-FLEX-22-11-25", tariffs_active_at = 123),
    "tariffs_active_at.*must be in.*ISO_8601.*format"
  )
  
  expect_error(
    get_product("AGILE-FLEX-22-11-25", authenticate = "yes"),
    "authenticate.*must be.*logical"
  )
})

test_that("get_product returns expected data structure", {
  # Test with a known product code that should exist
  # First get a product code from the products list
  products <- get_products()
  
  # Skip if no products available
  skip_if(nrow(products) == 0, "No products available for testing")
  
  # Get the first available product code
  test_product_code <- products$code[1]
  
  product_data <- get_product(test_product_code)
  
  # Check basic structure
  expect_s3_class(product_data, "tbl_df")
  
  # Check for expected main fields
  expected_fields <- c("code", "direction", "full_name", "display_name", "description")
  expect_true(all(expected_fields %in% names(product_data)))
  
  # Check that code matches what we requested
  expect_equal(product_data$code, test_product_code)
  
  # Check for electricity tariffs attribute if it exists
  if (!is.null(attr(product_data, "electricity_tariffs"))) {
    electricity_tariffs <- attr(product_data, "electricity_tariffs")
    expect_type(electricity_tariffs, "list")
    expect_true(length(electricity_tariffs) > 0)
    # Check structure of first tariff
    if (length(electricity_tariffs) > 0) {
      first_tariff <- electricity_tariffs[[1]]
      expect_true("tariff_code" %in% names(first_tariff))
    }
  }
  
  # Check for gas tariffs attribute if it exists
  if (!is.null(attr(product_data, "gas_tariffs"))) {
    gas_tariffs <- attr(product_data, "gas_tariffs")
    expect_type(gas_tariffs, "list")
    expect_true(length(gas_tariffs) > 0)
    # Check structure of first tariff
    if (length(gas_tariffs) > 0) {
      first_tariff <- gas_tariffs[[1]]
      expect_true("tariff_code" %in% names(first_tariff))
    }
  }
})

test_that("get_product works with different datetime formats", {
  products <- get_products()
  skip_if(nrow(products) == 0, "No products available for testing")
  
  test_product_code <- products$code[1]
  
  # Test with Date object
  expect_no_error(get_product(test_product_code, tariffs_active_at = Sys.Date()))
  
  # Test with character datetime
  expect_no_error(get_product(test_product_code, tariffs_active_at = "2023-01-01T00:00:00Z"))
  
  # Test with POSIXct
  expect_no_error(get_product(test_product_code, tariffs_active_at = Sys.time()))
})

test_that("get_product handles authentication parameters", {
  products <- get_products()
  skip_if(nrow(products) == 0, "No products available for testing")
  
  test_product_code <- products$code[1]
  
  # Test without authentication
  expect_no_error(get_product(test_product_code, authenticate = FALSE))
  
  # Test with authentication flag but no API key (should use stored key)
  # This will fail if no API key is stored, but that's expected behavior
  if (!is.null(try(get_api_key(), silent = TRUE))) {
    expect_no_error(get_product(test_product_code, authenticate = TRUE))
  }
})

test_that("get_product handles non-existent product codes gracefully", {
  expect_error(
    get_product("NON-EXISTENT-PRODUCT-CODE"),
    class = "httr2_http_404"
  )
})