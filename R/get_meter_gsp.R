#' Get the GSP of a meter-point.
#'
#' @description This endpoint can be used to get the GSP
#' of a given meter-point.
#'
#' @param mpan The electricity meter-point's MPAN
#'
#' @return a character of the meter-points GSP.
#' @export
get_meter_gsp <- function(mpan = NULL) {
  if (is.null(mpan)) {
    # If mpan is NULL, we explicitly attempt to fetch electricity meter details.
    # This will fail with a clear error if they are not set.
    mpan <- get_meter_details("electricity", include_gsp = FALSE)[["mpan_mprn"]]
  }

  if (is.null(mpan) || is.na(mpan) || mpan == "") {
    cli::cli_abort(
      "Meter details were missing or incomplete, please supply with
      {.arg mpan_mprn} and {.arg serial_number} arguments or with
      {.help [{.fun set_meter_details}](octopusR::set_meter_details)}",
      call = rlang::caller_env()
    )
  }

  path <- glue::glue(
    "/v1",
    "electricity-meter-points",
    mpan,
    .sep = "/"
  )

  resp <- octopus_api(
    path = path
  )

  meter_gsp <- resp[["content"]][["gsp"]]

  meter_gsp
}
