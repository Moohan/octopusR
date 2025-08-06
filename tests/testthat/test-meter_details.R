skip_if_offline(host = "api.octopus.energy")

test_that("set_meter_details works with direction parameter", {
  # Test setting import meter details
  expect_no_error(
    set_meter_details(
      meter_type = "electricity",
      mpan_mprn = "123456789012",
      serial_number = "ABC123",
      direction = "import"
    )
  )

  expect_equal(Sys.getenv("OCTOPUSR_MPAN_IMPORT"), "123456789012")
  expect_equal(Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT"), "ABC123")

  # Test setting export meter details
  expect_no_error(
    set_meter_details(
      meter_type = "electricity",
      mpan_mprn = "987654321098",
      serial_number = "XYZ789",
      direction = "export"
    )
  )

  expect_equal(Sys.getenv("OCTOPUSR_MPAN_EXPORT"), "987654321098")
  expect_equal(Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT"), "XYZ789")

  # Clean up
  Sys.unsetenv("OCTOPUSR_MPAN_IMPORT")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT")
  Sys.unsetenv("OCTOPUSR_MPAN_EXPORT")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT")
})

test_that("set_meter_details maintains legacy behavior without direction", {
  # Test legacy behavior (no direction specified)
  expect_no_error(
    set_meter_details(
      meter_type = "electricity",
      mpan_mprn = "111222333444",
      serial_number = "DEF456"
    )
  )

  expect_equal(Sys.getenv("OCTOPUSR_MPAN"), "111222333444")
  expect_equal(Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM"), "DEF456")

  # Clean up
  Sys.unsetenv("OCTOPUSR_MPAN")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM")
})

test_that("set_meter_details errors properly with invalid direction for gas", {
  expect_error(
    set_meter_details(
      meter_type = "gas",
      mpan_mprn = "1234567890",
      serial_number = "GAS123",
      direction = "import"
    ),
    "direction.*only valid for electricity"
  )
})

test_that("get_meter_details works with direction parameter", {
  # Set up test data
  Sys.setenv("OCTOPUSR_MPAN_IMPORT" = "123456789012")
  Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT" = "ABC123")
  Sys.setenv("OCTOPUSR_MPAN_EXPORT" = "987654321098")
  Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT" = "XYZ789")

  # Mock the GSP function to avoid API calls in tests
  with_mocked_bindings(
    get_meter_gsp = function(mpan) "A",
    is_testing = function() FALSE,
    {
      # Test getting import meter details
      import_meter <- get_meter_details("electricity", direction = "import")
      expect_equal(import_meter$mpan_mprn, "123456789012")
      expect_equal(import_meter$serial_number, "ABC123")
      expect_equal(import_meter$direction, "import")

      # Test getting export meter details
      export_meter <- get_meter_details("electricity", direction = "export")
      expect_equal(export_meter$mpan_mprn, "987654321098")
      expect_equal(export_meter$serial_number, "XYZ789")
      expect_equal(export_meter$direction, "export")
    }
  )

  # Clean up
  Sys.unsetenv("OCTOPUSR_MPAN_IMPORT")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT")
  Sys.unsetenv("OCTOPUSR_MPAN_EXPORT")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT")
})

test_that("get_meter_details errors properly with invalid direction for gas", {
  expect_error(
    get_meter_details("gas", direction = "import"),
    "direction.*only valid for electricity"
  )
})

test_that("get_meter_details falls back to legacy behavior without direction", {
  # Set up legacy test data
  Sys.setenv("OCTOPUSR_MPAN" = "111222333444")
  Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM" = "DEF456")

  # Mock the GSP function to avoid API calls in tests
  with_mocked_bindings(
    get_meter_gsp = function(mpan) "A",
    is_testing = function() FALSE,
    {
      # Test getting meter details without direction (legacy behavior)
      meter <- get_meter_details("electricity")
      expect_equal(meter$mpan_mprn, "111222333444")
      expect_equal(meter$serial_number, "DEF456")
      expect_null(meter$direction)
    }
  )

  # Clean up
  Sys.unsetenv("OCTOPUSR_MPAN")
  Sys.unsetenv("OCTOPUSR_ELEC_SERIAL_NUM")
})
