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
#' required. Use the \`tz\` parameter to specify a time zone
#' e.g. \`tz = "UTC"\`, the default (\`tz = NULL\`) will return the dates
#' unparsed, as characters.
#'
#' @inheritParams set_api_key
#' @inheritParams set_meter_details
#' @inheritParams lubridate::ymd_hms
#' @param period_from Show consumption from the given datetime (inclusive).
#' This parameter can be provided on its own.
#' @param period_to Show consumption to the given datetime (exclusive).
#' This parameter also requires providing the \`period_from\` parameter
#' to create a range.
#' @param order_by Ordering of results returned. Default is that results are
#' returned in reverse order from latest available figure.
#' Valid values:
#' * \`period\`, to give results ordered forward.
#' * \`-period\`, (default), to give results ordered from most recent backwards.
#' @param group_by Aggregates consumption over a specified time period.
#' A day is considered to start and end at midnight in the server's time zone.
#' The default is that consumption is returned in half-hour periods.
#' Accepted values are:
#' * \`hour\`
#' * \`day\`
#' * \`week\`
#' * \`month\`
#' * \`quarter\`
#' @param direction For electricity meters, specify "import", "export", or NULL
#' (default). When NULL, uses the legacy single MPAN storage.
#' @param page_size The number of results to return per page. This is intended
#' for internal testing and may be removed in a future release.
#'
#' @return a [tibble][tibble::tibble-package] of the requested consumption data.
#' @note For the fastest data aggregation, it is recommended to have either
#' the {data.table} or {vctrs} packages installed.
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
  # Direct check for meter_type to keep logic simple and stubbable
  if (missing(meter_type) || is.null(meter_type)) {
    cli::cli_abort(
      "You must specify {.val electricity} or {.val gas} for {.arg meter_type}"
    )
  }
  meter_type <- match.arg(meter_type, c("electricity", "gas"))

  # 1. Resolve meter details (Direct call for mockery stubbing)
  if (is.null(mpan_mprn) || is.null(serial_number)) {
    meter_details <- get_meter_details(meter_type, direction)
    mpan_mprn <- if (is.null(mpan_mprn)) meter_details$mpan_mprn else mpan_mprn
    serial_number <- if (is.null(serial_number)) {
      meter_details$serial_number
    } else {
      serial_number
    }
  }

  # 2. Validate and prepare parameters
  if (!is.null(direction)) {
    if (meter_type != "electricity") {
      stop("The 'direction' parameter is only valid for electricity meters.")
    }
    direction <- match.arg(direction, c("import", "export"))
  }

  opts <- prepare_consumption_opts(period_from, period_to, order_by, group_by)
  page_size <- validate_page_size(page_size, period_from)

  path <- glue::glue(
    "/v1", "{meter_type}-meter-points", mpan_mprn, "meters",
    serial_number, "consumption", .sep = "/"
  )

  query <- list(
    period_from = period_from, period_to = period_to, page_size = page_size,
    order_by = opts$order_by, group_by = opts$group_by
  )

  # 3. Initial API call (Direct call for mockery stubbing)
  resp <- octopus_api(path = path, api_key = api_key, query = query)

  total_rows <- resp[["content"]][["count"]]
  total_pages <- ceiling(total_rows / page_size)

  if (total_pages == 0) return(tibble::tibble())

  data_list <- vector("list", total_pages)
  data_list[[1L]] <- resp[["content"]][["results"]]

  # 4. Handle pagination (Direct calls for mockery stubbing)
  if (total_pages > 1) {
    reqs <- lapply(2:total_pages, function(p) {
      octopus_api(
        path = path, api_key = api_key,
        query = append(query, list(page = p)),
        perform = FALSE
      )
    })
    resps <- httr2::req_perform_parallel(reqs, on_error = "continue")
    data_list[2:total_pages] <- extract_parallel_results(resps)
  }

  # 5. Final processing
  data_list <- Filter(Negate(is.null), data_list)
  consumption_data <- combine_consumption_results(data_list)
  parse_consumption_dates(consumption_data, tz)
}

#' @noRd
prepare_consumption_opts <- function(
  period_from, period_to, order_by, group_by
) {
  if (!is.null(period_to) && is.null(period_from)) {
    cli::cli_abort(
      "To use {.arg period_to} you must also provide the {.arg period_from}
      parameter to create a range."
    )
  }

  order_by <- if (missing(order_by) || is.null(order_by)) {
    NULL
  } else {
    match.arg(order_by, c("-period", "period"))
  }

  group_by <- if (missing(group_by) || is.null(group_by)) {
    NULL
  } else {
    match.arg(group_by, c("hour", "day", "week", "month", "quarter"))
  }

  if (!is.null(period_to)) check_datetime_format(period_to)

  list(order_by = order_by, group_by = group_by)
}

#' @noRd
validate_page_size <- function(page_size, period_from) {
  if (!is.null(page_size)) return(page_size)

  if (is.null(period_from)) {
    cli::cli_inform(c(
      "i" = "Returning 100 rows only as a date range wasn't provided.",
      "v" = "Specify a date range with {.arg period_to} and {.arg period_from}."
    ))
    return(100L)
  }

  check_datetime_format(period_from)
  25000L
}

#' @noRd
extract_parallel_results <- function(resps) {
  lapply(resps, function(r) {
    if (inherits(r, "httr2_response")) {
      httr2::resp_body_json(r, simplifyVector = TRUE)[["results"]]
    } else if (is.list(r) && "content" %in% names(r)) {
      r[["content"]][["results"]]
    } else if (inherits(r, "octopus_api")) {
      r[["content"]][["results"]]
    } else {
      NULL
    }
  })
}

#' @noRd
combine_consumption_results <- function(data_list) {
  if (rlang::is_installed("data.table")) {
    res <- data.table::rbindlist(data_list)
  } else if (rlang::is_installed("vctrs")) {
    res <- vctrs::vec_rbind(!!!data_list)
  } else {
    res <- do.call(rbind, data_list)
  }
  tibble::as_tibble(res)
}

#' @noRd
parse_consumption_dates <- function(data, tz) {
  if (is.null(tz)) return(data)

  if (rlang::is_interactive()) {
    rlang::check_installed(
      pkg = "lubridate",
      reason = "to parse dates, use \`tz = NULL\` to return characters.",
      version = "0.2.1"
    )
  } else if (!rlang::is_installed(pkg = "lubridate", version = "0.2.1")) {
    cli::cli_abort(
      "{.pkg lubridate} must be installed to parse dates,
      use \`tz = NULL\` to return characters."
    )
  }

  data[["interval_start"]] <- lubridate::ymd_hms(
    data[["interval_start"]],
    tz = tz
  )
  data[["interval_end"]] <- lubridate::ymd_hms(
    data[["interval_end"]],
    tz = tz
  )
  data
}
