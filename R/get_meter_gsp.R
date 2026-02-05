#' Get the GSP of a meter-point.
#'
#' @description This endpoint can be used to get the GSP
#' of a given meter-point.
#'
#' @param mpan The electricity meter-point's MPAN
#'
#' @return a character of the meter-points GSP.
#' @export
get_meter_gsp <- function(
  mpan = get_meter_details("electricity")[["mpan_mprn"]]
) {
  if (is.null(mpan) || is.na(mpan) || identical(mpan, "")) {
    cli::cli_abort(
      "Meter details were missing or incomplete, please supply with
      {.arg mpan_mprn} and {.arg serial_number} arguments or with
      {.help [{.fun set_meter_details}](octopusR::set_meter_details)}",
      call = rlang::caller_env()
    )
  }

  path <- glue::glue("/v1/electricity-meter-points/{mpan}")

  resp <- octopus_api(
    path = path
  )

  resp[["content"]][["gsp"]]
}
