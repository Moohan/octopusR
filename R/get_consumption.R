#' Get consumption data
#'
#' @param api_key
#' @param mpan
#' @param serial_number
#' @param period_from
#' @param period_to
#' @param page_size
#' @param order_by
#' @param group_by
#'
#' @return
#' @export
get_consumption <- function(api_key, mpan, serial_number, period_from = NULL, period_to = NULL, page_size = 100, order_by = "-period", group_by = c("hour", "day", "week", "month", "quarter")) {
  octopus_api(path = glue::glue("/v1/electricity-meter-points/{mpan}/meters/{serial_number}/consumption/"),
              api_key = api_key)
}


