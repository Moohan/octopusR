#' Set the details for your gas/electricity meter
#'
#' @description You can find your meter details on the
#' [Octopus Energy developer dashboard](https://octopus.energy/dashboard/developer/)
#'
#' @param meter_type Type of meter-point, electricity or gas
#' @param mpan_mprn The electricity meter-point's MPAN or gas meter-point’s
#' MPRN.
#' @param serial_number The meter's serial number.
#'
#' @export
set_meter_details <- function(meter_type = c("electricity", "gas"),
                              mpan_mprn = NULL,
                              serial_number = NULL) {
  meter_type <- match.arg(meter_type)

  if (missing(mpan_mprn)) {
    mpan_mprn <- askpass::askpass(
      glue::glue(
        "Please enter your {meter_type} meter-point's {ifelse(meter_type == 'electricity', 'MPAN', 'MPRN')}."
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
      meter_gsp <- get_meter_gsp(mpan = mpan_mprn)
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
          gsp = ifelse(meter_type == "electricity", meter_gsp, NA)
        ),
        class = "octopus_meter-point"
      )

      return(meter)
    }

    cli::cli_abort(
      "Meter details were missing or incomplete, please supply with {.arg mpan_mprn} and {.arg serial_number} arguments or with {.help [{.fun set_meter_details}](octopusR::set_meter_details)}",
      call = rlang::caller_env()
    )
  }

testing_meter <- function(meter_type = c("electricity", "gas")) {
  meter_type <- match.arg(meter_type)

  if (meter_type == "electricity") {
    mpan <- httr2::secret_decrypt(
      "OPGJ1brZHps9UGVyAmrmmw_gaD4wxrnCCYURXiQ",
      "OCTOPUSR_SECRET_KEY"
    )
    serial_number <- httr2::secret_decrypt(
      "539iFcHHKYdThm5G3Q6MkDmDIvXj8_Xae1M",
      "OCTOPUSR_SECRET_KEY"
    )
    meter_gsp <- get_meter_gsp(mpan = mpan)

    structure(
      list(
        type = "electricity",
        mpan_mprn = mpan,
        serial_number = serial_number,
        gsp = meter_gsp
      ),
      class = "octopus_meter-point"
    )
  } else if (meter_type == "gas") {
    structure(
      list(
        type = "gas",
        mpan_mprn = "",
        serial_number = ""
      ),
      class = "octopus_meter-point"
    )
  }
}
