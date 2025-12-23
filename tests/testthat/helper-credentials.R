# Helper to skip API tests when credentials or CI secrets are not available

skip_if_missing_api_creds <- function() {
  # Skip if the API itself is offline
  skip_if_offline(host = "api.octopus.energy")

  # If running on CI and the secret key isn't provided, skip
  if (
    identical(Sys.getenv("CI"), "true") &&
      identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")
  ) {
    message("Skipping API tests: running on CI without OCTOPUSR_SECRET_KEY")
    skip("Running on CI without OCTOPUSR_SECRET_KEY")
  }

  # If no API key in env and no secret key to decrypt a testing key, skip
  if (
    identical(Sys.getenv("OCTOPUSR_API_KEY"), "") &&
      identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")
  ) {
    message(
      paste0("Skipping API tests: no OCTOPUSR_API_KEY and ",
             "no OCTOPUSR_SECRET_KEY available")
    )
    skip(
      paste0("No API key found in environment and no ",
             "OCTOPUSR_SECRET_KEY available to decrypt testing key")
    )
  }
}

# Meter-specific skip helper: ensure meter details are available or decryptable
skip_if_missing_meter <- function(meter_type = c("electricity", "gas")) {
  meter_type <- match.arg(meter_type)

  # CI secret requirement (same as above)
  if (
    identical(Sys.getenv("CI"), "true") &&
      identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")
  ) {
    message("Skipping meter tests: running on CI without OCTOPUSR_SECRET_KEY")
    skip("Running on CI without OCTOPUSR_SECRET_KEY")
  }

  if (meter_type == "electricity") {
    if (
      identical(Sys.getenv("OCTOPUSR_MPAN"), "") &&
        identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")
    ) {
      message(
        paste0("Skipping electricity meter tests: no OCTOPUSR_MPAN and ",
               "no OCTOPUSR_SECRET_KEY available")
      )
      skip(
        paste0("No OCTOPUSR_MPAN in environment and no ",
               "OCTOPUSR_SECRET_KEY to decrypt a testing MPAN")
      )
    }
  } else {
    # For gas tests we require either both MPRN and serial to be present in the
    # environment, or an encrypted MPRN & encrypted GAS serial together with the
    # secret key. This avoids attempting to decrypt a placeholder ciphertext.
    has_env_vals <- (
      Sys.getenv("OCTOPUSR_MPRN") != "" &&
        Sys.getenv("OCTOPUSR_GAS_SERIAL_NUM") != ""
    )

    has_encrypted_vals <- (
      Sys.getenv("OCTOPUSR_ENCRYPTED_MPRN") != "" &&
        Sys.getenv("OCTOPUSR_ENCRYPTED_GAS_SERIAL") != "" &&
        Sys.getenv("OCTOPUSR_SECRET_KEY") != ""
    )

    if (!has_env_vals && !has_encrypted_vals) {
      message(
        "Skipping gas meter tests: no valid gas meter details available",
        " (env or encrypted)"
      )
      skip(
        "No OCTOPUSR_MPRN + OCTOPUSR_GAS_SERIAL_NUM in environment and no",
        " encrypted MPRN + encrypted GAS serial with OCTOPUSR_SECRET_KEY",
        " available to decrypt testing values"
      )
    }
  }
}
