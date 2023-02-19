#' Get the GSP of a meter-point.
#'
#' @description This endpoint can be used to get the GSP
#' of a given meter-point.
#'
#' @param mpan The electricity meter-point's MPAN
#'
#' @return a character of the meter-points GSP.
#' @export
get_meter_gsp <- function(mpan = get_meter_details("electricity")[["mpan_mprn"]]) {
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

  return(meter_gsp)
}
