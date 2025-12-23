# Helper to skip API tests when credentials or CI secrets are not available

skip_if_missing_api_creds <- function() {
  # Skip if the API itself is offline
  skip_if_offline(host = "api.octopus.energy")

  # If running on CI and the secret key isn't provided, skip
  if (identical(Sys.getenv("CI"), "true") && identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")) {
    message("Skipping API tests: running on CI without OCTOPUSR_SECRET_KEY")
    skip("Running on CI without OCTOPUSR_SECRET_KEY")
  }

  # If no API key in env and no secret key to decrypt a testing key, skip
  if (identical(Sys.getenv("OCTOPUSR_API_KEY"), "") && identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")) {
    message("Skipping API tests: no OCTOPUSR_API_KEY and no OCTOPUSR_SECRET_KEY available")
    skip("No API key found in environment and no OCTOPUSR_SECRET_KEY available to decrypt testing key")
  }
}

# Meter-specific skip helper: ensures meter details are available or can be decrypted
skip_if_missing_meter <- function(meter_type = c("electricity", "gas")) {
  meter_type <- match.arg(meter_type)

  # CI secret requirement (same as above)
  if (identical(Sys.getenv("CI"), "true") && identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")) {
    message("Skipping meter tests: running on CI without OCTOPUSR_SECRET_KEY")
    skip("Running on CI without OCTOPUSR_SECRET_KEY")
  }

  if (meter_type == "electricity") {
    if (identical(Sys.getenv("OCTOPUSR_MPAN"), "") && identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")) {
      message("Skipping electricity meter tests: no OCTOPUSR_MPAN and no OCTOPUSR_SECRET_KEY available")
      skip("No OCTOPUSR_MPAN in environment and no OCTOPUSR_SECRET_KEY to decrypt a testing MPAN")
    }
  } else {
    if (identical(Sys.getenv("OCTOPUSR_MPRN"), "") && identical(Sys.getenv("OCTOPUSR_SECRET_KEY"), "")) {
      message("Skipping gas meter tests: no OCTOPUSR_MPRN and no OCTOPUSR_SECRET_KEY available")
      skip("No OCTOPUSR_MPRN in environment and no OCTOPUSR_SECRET_KEY to decrypt a testing MPRN")
    }
  }
}
