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
get_consumption <-
  function(api_key,
           mpan,
           serial_number,
           period_from = NULL,
           period_to = NULL,
           page_size = 100L,
           order_by = c("-period", "period"),
           group_by = c("hour", "day", "week", "month", "quarter")) {
    if (missing(group_by)) group_by <- NULL
    if (missing(order_by)) order_by <- NULL

    octopus_api(
      path = paste("/v1/electricity-meter-points",
        mpan,
        "meters",
        serial_number,
        "consumption/",
        sep = "/"
      ),
      api_key = api_key,
      query = list(
        period_from = period_from,
        period_to = period_to,
        page_size = page_size,
        order_by = order_by,
        group_by = group_by
      )
    )
  }
