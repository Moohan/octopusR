#' List consumption for a meter
#' @description Return a list of consumption values for half-hour periods for a
#' given meter-point and meter.
#'
#' Unit of measurement:
#' * Electricity meters: kWh
#' * SMETS1 Secure gas meters: kWh
#' * SMETS2 gas meters: m^3
#'
#' ## Parsing dates
#' To return dates properly parsed [lubridate][lubridate::lubridate-package] is
#' required. Use the `tz` parameter to specify a time zone e.g. `tz = "UTC"`,
#' the default (`tz = NULL`) will return the dates unparsed, as characters.
#'
#' @inheritParams set_api_key
#' @inheritParams set_meter_details
#' @inheritParams lubridate::ymd_hms
#' @param period_from Show consumption from the given datetime (inclusive).
#' This parameter can be provided on its own.
#' @param period_to Show consumption to the given datetime (exclusive).
#' This parameter also requires providing the `period_from` parameter
#' to create a range.
#' @param order_by Ordering of results returned. Default is that results are
#' returned in reverse order from latest available figure.
#' Valid values:
#' * `period`, to give results ordered forward.
#' * `-period`, (default), to give results ordered from most recent backwards.
#' @param group_by Aggregates consumption over a specified time period.
#' A day is considered to start and end at midnight in the server's time zone.
#' The default is that consumption is returned in half-hour periods.
#' Accepted values are:
#' * `hour`
#' * `day`
#' * `week`
#' * `month`
#' * `quarter`
#' @param direction For electricity meters, specify "import", "export", or
#' NULL (default). When NULL, uses the legacy single MPAN storage.
#' @param page_size The number of results to return per page. This is intended
#' for internal testing and may be removed in a future release.
#'
#' @return a [tibble][tibble::tibble-package] of the requested consumption data.
#' @note For the fastest data aggregation, it is recommended to have either
#' the `{data.table}` or `{vctrs}` packages installed.
#' @export
get_consumption <- function(
  meter_type = c("electricity", "gas"),
  mpan_mprn = NULL,
  serial_number = NULL,
  direction = NULL,
  api_key = get_api_key(),
  period_from = NULL,
  period_to = NULL,
  tz = NULL,
  order_by = c("-period", "period"),
  page_size = NULL,
  group_by = c("hour", "day", "week", "month", "quarter")
) {
  if (missing(meter_type)) {
    cli::cli_abort(
      "You must specify {.val electricity} or {.val gas} for {.arg meter_type}"
    )
  } else {
    meter_type <- match.arg(meter_type)
  }

  # Validate direction parameter
  if (!is.null(direction) && meter_type != "electricity") {
    stop("The 'direction' parameter is only valid for electricity meters.")
  }

  if (!is.null(direction)) {
    direction <- match.arg(direction, c("import", "export"))
  }

  # Get meter details if not provided
  if (is.null(mpan_mprn) || is.null(serial_number)) {
    meter_details <- get_meter_details(meter_type, direction)
    if (is.null(mpan_mprn)) {
      mpan_mprn <- meter_details[["mpan_mprn"]]
    }
    if (is.null(serial_number)) {
      serial_number <- meter_details[["serial_number"]]
    }
  }

  force(mpan_mprn)
  force(serial_number)
  force(api_key)
  if (!missing(period_to) && missing(period_from)) {
    cli::cli_abort(
      "To use {.arg period_to} you must also provide the {.arg period_from}
      parameter to create a range."
    )
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

  if (!missing(period_to)) {
    check_datetime_format(period_to)

    if (missing(period_from)) {
      cli::cli_abort(
        "You must also specify {.arg period_to} when specifying
        {.arg period_from}."
      )
    }
  }

  if (is.null(page_size)) {
    if (missing(period_from)) {
      page_size <- 100L
      cli::cli_inform(c(
        "i" = "Returning 100 rows only as a date range wasn't provided.",
        "v" = "Specify range with {.arg period_to} and {.arg period_from}"
      ))
    } else {
      check_datetime_format(period_from)
      page_size <- 25000L
    }
  }

  path <- glue::glue(
    "/v1",
    "{meter_type}-meter-points",
    mpan_mprn,
    "meters",
    serial_number,
    "consumption",
    .sep = "/"
  )

  query <- list(
    period_from = period_from,
    period_to = period_to,
    page_size = page_size,
    order_by = order_by,
    group_by = group_by
  )

  resp <- octopus_api(
    path = path,
    api_key = api_key,
    query = query
  )

  total_rows <- resp[["content"]][["count"]]
  total_pages <- ceiling(total_rows / page_size)
  if (total_pages == 0) {
    return(tibble::tibble())
  }
  consumption_data_list <- vector("list", total_pages)
  consumption_data_list[[1L]] <- resp[["content"]][["results"]]

  if (total_pages > 1) {
    reqs <- lapply(2:total_pages, function(page) {
      octopus_api(
        path = path,
        api_key = api_key,
        query = append(query, list(page = page)),
        perform = FALSE
      )
    })

    resps <- httr2::req_perform_parallel(reqs, on_error = "continue")

    # Directly populate the final list, avoiding an intermediate object.
    consumption_data_list[2:total_pages] <- lapply(resps, function(r) {
      if (inherits(r, "httr2_response")) {
        httr2::resp_body_json(r, simplifyVector = TRUE)[["results"]]
      } else {
        NULL
      }
    })
  }
  # Filter out NULL elements from any failed API calls before binding. This
  # prevents `do.call(rbind, ...)` from failing.
  consumption_data_list <- Filter(Negate(is.null), consumption_data_list)

  # Using data.table::rbindlist() or vctrs::vec_rbind() provides a significant
  # performance boost over the base R alternative of do.call(rbind, ...).
  if (rlang::is_installed("data.table")) {
    consumption_data <- data.table::rbindlist(consumption_data_list)
  } else if (rlang::is_installed("vctrs")) {
    consumption_data <- vctrs::vec_rbind(!!!consumption_data_list)
  } else {
    consumption_data <- do.call(rbind, consumption_data_list)
  }

  consumption_data <- tibble::as_tibble(consumption_data)

  if (!is.null(tz)) {
    if (rlang::is_interactive()) {
      rlang::check_installed(
        pkg = "lubridate",
        reason = "to parse dates, use `tz = NULL` to return characters.",
        version = "0.2.1"
      )
    } else {
      if (!rlang::is_installed(pkg = "lubridate", version = "0.2.1")) {
        cli::cli_abort(
          "{.pkg lubridate} must be installed to parse dates,
                       use `tz = NULL` to return characters."
        )
      }
    }
    consumption_data[["interval_start"]] <- lubridate::ymd_hms(
      consumption_data[["interval_start"]],
      tz = tz
    )
    consumption_data[["interval_end"]] <- lubridate::ymd_hms(
      consumption_data[["interval_end"]],
      tz = tz
    )
  }

  consumption_data
}
