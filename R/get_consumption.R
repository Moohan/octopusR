#' Get consumption data
#'
#' @inheritParams octopus_api
#' @param mpan,serial_number
#' @param period_from,period_to
#' @param page_size
#' @param order_by
#' @param group_by
#'
#' @return
#' @export
get_consumption <-
  function(mpan,
           serial_number,
           meter_type = c("electric", "gas"),
           api_key = get_api_key(),
           period_from = NULL,
           period_to = NULL,
           page_size = 100L,
           order_by = c("-period", "period"),
           group_by = c("hour", "day", "week", "month", "quarter")) {
    meter_type <- match.arg(meter_type)
    if (missing(group_by)) {
      group_by <- NULL
    } else {
      group_by <- match.arg(group_by)
    }
    if (missing(order_by)) {
      order_by <- NULL
    } else {
      order_by <- match.arg(order_by)
    }

    path <- paste("/v1",
      paste0(meter_type, "-meter-points"),
      mpan,
      "meters",
      serial_number,
      "consumption/",
      sep = "/"
    )

    resp <- octopus_api(
      path = path,
      api_key = api_key,
      query = list(
        period_from = period_from,
        period_to = period_to,
        page_size = page_size,
        order_by = order_by,
        group_by = group_by
      )
    )

    return(resp[["content"]][["results"]])
  }
