#' List consumption for a meter
#' @description Return a list of consumption values for half-hour periods for a given meter-point and meter.
#'
#' Unit of measurement:
#' * Electricity meters: kWh
#' * SMETS1 Secure gas meters: kWh
#' * SMETS2 gas meters: m^3
#'
#' @inheritParams set_api_key
#' @inheritParams set_meter_details
#' @param period_from Show consumption from the given datetime (inclusive). This parameter can be provided on its own.
#' @param period_to Show consumption to the given datetime (exclusive). This parameter also requires providing the `period_from` parameter to create a range.
#' @param page_size Page size of returned results. Default is 100, maximum is 25,000 to give a full year of half-hourly consumption details.
#' @param order_by Ordering of results returned. Default is that results are returned in reverse order from latest available figure.
#' Valid values:
#' * `period`, to give results ordered forward.
#' * `-period`, (default), to give results ordered from most recent backwards.
#' @param group_by Aggregates consumption over a specified time period. A day is considered to start and end at midnight in the server's timezone. The default is that consumption is returned in half-hour periods.
#' Accepted values are:
#' * `hour`
#' * `day`
#' * `week`
#' * `month`
#' * `quarter`
#'
#' @return a [tibble][tibble::tibble-package] of the requested consumption data.
#' @export
#'
#' @examples
#' data <- get_consumption("electricity")
get_consumption <-
  function(meter_type = c("electricity", "gas"),
           mpan_mprn = get_meter_details(meter_type)[["mpan_mprn"]],
           serial_number = get_meter_details(meter_type)[["serial_number"]],
           api_key = get_api_key(),
           period_from = NULL,
           period_to = NULL,
           page_size = 100L,
           order_by = c("-period", "period"),
           group_by = c("hour", "day", "week", "month", "quarter")) {
    if (missing(meter_type)) {
      cli::cli_abort("You must specify {.val electricity} or {.val gas} for {.arg meter_type}")
    }
    meter_type <- match.arg(meter_type)
    if (!missing(period_to) & missing(period_from)) {
      cli::cli_abort("To use {.arg period_to} you must also provide the {.arg period_from} parameter to create a range.")
    }
    if (page_size <= 0 | page_size > 25000) {
      cli::cli_abort("{.arg page_size} must be between 1 and 25000")
    }
    if (missing(order_by)) {
      order_by <- NULL
    } else {
      order_by <- match.arg(order_by)
    }
    if (missing(group_by)) {
      group_by <- NULL
    } else {
      group_by <- match.arg(group_by)
    }

    path <- glue::glue("/v1",
      "{meter_type}-meter-points",
      mpan_mprn,
      "meters",
      serial_number,
      "consumption",
      .sep = "/"
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
