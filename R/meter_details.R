#' Set the details for your gas/electricity meter
#'
#' @description Set the details for your gas/electricity meter. These will be
#' stored as environment variables. You should add:
#'  * `OCTOPUSR_MPAN = <electric MPAN>`
#'  * `OCTOPUSR_MPRN = <gas MPRN>`
#'  * `OCTOPUSR_ELEC_SERIAL_NUM = <electric serial number>`
#'  * `OCTOPUSR_GAS_SERIAL_NUM = <gas serial number>`
#' to your `.Renviron` otherwise you will have to call this function every
#' session. You can find your meter details (MPAN/MPRN and serial number(s)) on
#' the [developer dashboard](https://octopus.energy/dashboard/developer/).
#'
#' For CI testing, you can provide encrypted ciphertexts via the following
#' environment variables (decrypted using `OCTOPUSR_SECRET_KEY` on CI):
#'  * `OCTOPUSR_ENCRYPTED_MPRN` - encrypted gas MPRN
#'  * `OCTOPUSR_ENCRYPTED_GAS_SERIAL` - encrypted gas serial number
#' If neither the plaintext env vars nor the encrypted values are available,
#' gas-related tests will be skipped to avoid runtime decrypt errors.
#'
#' @param meter_type Type of meter-point, electricity or gas
#' @param mpan_mprn The electricity meter-point's MPAN or gas meter-point’s
#' MPRN.
#' @param serial_number The meter's serial number.
#'
#' @return No return value, called for side effects.
#'
#' @export
set_meter_details <- function(meter_type = c("electricity", "gas"),
                              mpan_mprn = NULL,
                              serial_number = NULL) {
  meter_type <- match.arg(meter_type)

  if (missing(mpan_mprn)) {
    mpan_mprn <- askpass::askpass(
      glue::glue(
        "Please enter your {meter_type} meter-point's
        {ifelse(meter_type == 'electricity', 'MPAN', 'MPRN')}."
      )
    )
  }
  if (missing(serial_number)) {
    serial_number <- askpass::askpass(glue::glue(
      "Please enter your {meter_type} meter-point's serial number."
    ))
  }

  if (meter_type == "electricity") {
    Sys.setenv("OCTOPUSR_MPAN" = mpan_mprn)
    Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM" = serial_number)
  } else if (meter_type == "gas") {
    Sys.setenv("OCTOPUSR_MPRN" = mpan_mprn)
    Sys.setenv("OCTOPUSR_GAS_SERIAL_NUM" = serial_number)
  }
}

get_meter_details <-
  function(meter_type = c("electricity", "gas")) {
    meter_type <- match.arg(meter_type)

    if (is_testing()) {
      return(testing_meter(meter_type))
    }

    if (meter_type == "electricity") {
      mpan_mprn <- Sys.getenv("OCTOPUSR_MPAN")
      serial_number <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM")
    } else if (meter_type == "gas") {
      mpan_mprn <- Sys.getenv("OCTOPUSR_MPRN")
      serial_number <- Sys.getenv("OCTOPUSR_GAS_SERIAL_NUM")
    }

    if (!identical(mpan_mprn, "") && !identical(serial_number, "")) {
      meter <- structure(
        list(
          type = meter_type,
          mpan_mprn = mpan_mprn,
          serial_number = serial_number,
          gsp = ifelse(
            meter_type == "electricity",
            get_meter_gsp(mpan = mpan_mprn),
            NA
          )
        ),
        class = "octopus_meter-point"
      )

      return(meter)
    }

    cli::cli_abort(
      "Meter details were missing or incomplete, please supply with
      {.arg mpan_mprn} and {.arg serial_number} arguments or with
      {.help [{.fun set_meter_details}](octopusR::set_meter_details)}.",
      call = rlang::caller_env()
    )
  }

testing_meter <- function(meter_type = c("electricity", "gas")) {
  meter_type <- match.arg(meter_type)

  if (meter_type == "electricity") {
    # Try environment variables first (for local testing)
    mpan <- Sys.getenv("OCTOPUSR_MPAN")
    serial_number <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM")
    gsp <- Sys.getenv("OCTOPUSR_GSP")

    # Fall back to encrypted secrets (for GitHub CI)
    if (identical(mpan, "")) {
      mpan <- httr2::secret_decrypt(
        "qRXEs2Z4y5H0DbKfyJws97tH8kneASJp8iaok1M",
        "OCTOPUSR_SECRET_KEY"
      )
    }
    if (identical(serial_number, "")) {
      serial_number <- httr2::secret_decrypt(
        "GNgEXhPLz1GmGi4RYFavkNPsQkj9zzbFjhA",
        "OCTOPUSR_SECRET_KEY"
      )
    }
    if (identical(gsp, "")) {
      gsp <- "_P"
    }

    structure(
      list(
        type = "electricity",
        mpan_mprn = mpan,
        serial_number = serial_number,
        gsp = gsp
      ),
      class = "octopus_meter-point"
    )
  } else if (meter_type == "gas") {
    # Try environment variables first (for local testing)
    mprn <- Sys.getenv("OCTOPUSR_MPRN")
    serial_number <- Sys.getenv("OCTOPUSR_GAS_SERIAL_NUM")

    # Fall back to encrypted secrets (for GitHub CI).
    # Use explicit encrypted env vars so we don't accidentally call
    # httr2::secret_decrypt() with a placeholder string (which would error).
    encrypted_mprn <- Sys.getenv("OCTOPUSR_ENCRYPTED_MPRN")
    encrypted_gas_serial <- Sys.getenv("OCTOPUSR_ENCRYPTED_GAS_SERIAL")

    if (identical(mprn, "") && encrypted_mprn != "" && Sys.getenv("OCTOPUSR_SECRET_KEY") != "") {
      mprn <- httr2::secret_decrypt(encrypted_mprn, "OCTOPUSR_SECRET_KEY")
    }

    if (identical(serial_number, "") && encrypted_gas_serial != "" && Sys.getenv("OCTOPUSR_SECRET_KEY") != "") {
      serial_number <- httr2::secret_decrypt(encrypted_gas_serial, "OCTOPUSR_SECRET_KEY")
    }

    # If we still don't have values, leave them empty so the test helpers
    # can detect that meter credentials are missing and skip tests as needed.

    structure(
      list(
        type = "gas",
        mpan_mprn = mprn,
        serial_number = serial_number
      ),
      class = "octopus_meter-point"
    )
  }
}
