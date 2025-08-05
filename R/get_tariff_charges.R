#' List tariff charges for a product
#' @description Return a list of tariff charges for half-hour periods for a
#' given product and tariff. This is particularly useful for agile pricing
#' and other time-of-use tariffs.
#'
#' Unit of measurement:
#' * Electricity tariffs: pence per kWh
#' * Gas tariffs: pence per kWh
#'
#' ## Parsing dates
#' To return dates properly parsed [lubridate][lubridate::lubridate-package] is
#' required. Use the `tz` parameter to specify a time zone e.g. `tz = "UTC"`,
#' the default (`tz = NULL`) will return the dates unparsed, as characters.
#'
#' @inheritParams lubridate::ymd_hms
#' @param product_code The product code for the tariff.
#' @param tariff_code The tariff code.
#' @param fuel_type Type of fuel, either "electricity" or "gas".
#' @param rate_type Type of rate to retrieve. For electricity: "standard-unit-rates", 
#' "day-unit-rates", "night-unit-rates". For gas: "standard-unit-rates".
#' @param period_from Show charges from the given datetime (inclusive).
#' This parameter can be provided on its own.
#' @param period_to Show charges to the given datetime (exclusive).
#' This parameter also requires providing the `period_from` parameter
#' to create a range.
#' @param order_by Ordering of results returned. Default is that results are
#' returned in reverse order from latest available figure.
#' Valid values:
#' * `period`, to give results ordered forward.
#' * `-period`, (default), to give results ordered from most recent backwards.
#'
#' @return a [tibble][tibble::tibble-package] of the requested tariff charge data.
#' @export
get_tariff_charges <- function(
    product_code,
    tariff_code,
    fuel_type = c("electricity", "gas"),
    rate_type = NULL,
    period_from = NULL,
    period_to = NULL,
    tz = NULL,
    order_by = c("-period", "period")) {
  
  if (missing(product_code)) {
    cli::cli_abort("You must specify a {.arg product_code}")
  }
  
  if (missing(tariff_code)) {
    cli::cli_abort("You must specify a {.arg tariff_code}")
  }
  
  if (missing(fuel_type)) {
    cli::cli_abort(
      "You must specify {.val electricity} or {.val gas} for {.arg fuel_type}"
    )
  } else {
    fuel_type <- match.arg(fuel_type)
  }
  
  # Set default rate_type based on fuel_type
  if (is.null(rate_type)) {
    rate_type <- "standard-unit-rates"
  }
  
  # Validate rate_type
  if (fuel_type == "electricity") {
    valid_rates <- c("standard-unit-rates", "day-unit-rates", "night-unit-rates")
  } else {
    valid_rates <- c("standard-unit-rates")
  }
  
  if (!rate_type %in% valid_rates) {
    cli::cli_abort(
      "For {.val {fuel_type}}, {.arg rate_type} must be one of: {.val {valid_rates}}"
    )
  }
  
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

  if (!missing(period_to)) {
    check_datetime_format(period_to)

    if (missing(period_from)) {
      cli::cli_abort(
        "You must also specify {.arg period_from} when specifying
        {.arg period_to}."
      )
    }
  }

  if (missing(period_from)) {
    page_size <- 100L
    cli::cli_inform(c(
      "i" = "Returning 100 rows only as a date range wasn't provided.",
      "v" = "Specify a date range with {.arg period_to} and {.arg period_from}."
    ))
  } else {
    check_datetime_format(period_from)
    page_size <- 25000L
  }

  path <- glue::glue(
    "/v1",
    "products",
    product_code,
    "{fuel_type}-tariffs",
    tariff_code,
    rate_type,
    .sep = "/"
  )

  query <- list(
    period_from = period_from,
    period_to = period_to,
    page_size = page_size,
    order_by = order_by
  )

  resp <- octopus_api(
    path = path,
    query = query
  )

  tariff_data <- resp[["content"]][["results"]]

  page <- 1L
  total_rows <- resp[["content"]][["count"]]
  total_pages <- ceiling(total_rows / page_size)

  cli::cli_progress_bar("Getting tariff charge data", total = total_pages)

  while (page_size == 25000L && !is.null(resp[["content"]][["next"]])) {
    page <- page + 1L

    resp <- octopus_api(
      path = path,
      query = append(query, list("page" = page))
    )

    tariff_data <- rbind(
      tariff_data,
      resp[["content"]][["results"]]
    )

    cli::cli_progress_update()
  }

  cli::cli_progress_done()

  if (!is.null(tz)) {
    if (rlang::is_interactive()) {
      rlang::check_installed(
        pkg = "lubridate",
        reason = "to parse dates, use `tz = NULL` to return characters.",
        version = "0.2.1"
      )
    } else {
      if (!rlang::is_installed(pkg = "lubridate", version = "0.2.1")) {
        cli::cli_abort("{.pkg lubridate} must be installed to parse dates,
                       use `tz = NULL` to return characters.")
      }
    }
    tariff_data[["valid_from"]] <- lubridate::ymd_hms(
      tariff_data[["valid_from"]],
      tz = tz
    )
    tariff_data[["valid_to"]] <- lubridate::ymd_hms(
      tariff_data[["valid_to"]],
      tz = tz
    )
  }

  return(tariff_data)
}

#' Get Agile future prices
#' @description A convenience function to get future Agile tariff prices.
#' This function automatically uses the Agile Octopus product and constructs
#' tariff codes based on the region.
#'
#' @inheritParams get_tariff_charges
#' @param region The GSP region code (e.g. "H" for Southern England).
#' If not provided, it will attempt to use saved meter details.
#' @param fuel_type Type of fuel, either "electricity" or "gas". 
#' Note: Agile is typically only available for electricity.
#' @param days_ahead Number of days ahead to fetch prices for (default: 2).
#'
#' @return a [tibble][tibble::tibble-package] of Agile tariff charge data.
#' @export
get_agile_prices <- function(
    region = NULL,
    fuel_type = c("electricity", "gas"),
    days_ahead = 2,
    tz = "UTC") {
  
  if (missing(fuel_type)) {
    fuel_type <- "electricity"
  } else {
    fuel_type <- match.arg(fuel_type)
  }
  
  if (fuel_type != "electricity") {
    cli::cli_warn("Agile tariffs are typically only available for electricity")
  }
  
  if (is.null(region)) {
    # Try to get region from meter details
    tryCatch({
      region <- get_meter_gsp(fuel_type)[["group_id"]]
    }, error = function(e) {
      cli::cli_abort(
        c("You must specify a {.arg region} or set meter details first",
          "i" = "Use {.fun set_meter_details} to set your meter details")
      )
    })
  }
  
  # Construct Agile product and tariff codes
  product_code <- "AGILE-FLEX-22-11-25"
  
  if (fuel_type == "electricity") {
    tariff_code <- paste0("E-1R-AGILE-FLEX-22-11-25-", region)
  } else {
    tariff_code <- paste0("G-1R-AGILE-FLEX-22-11-25-", region)
  }
  
  # Calculate date range
  period_from <- Sys.Date()
  period_to <- Sys.Date() + days_ahead
  
  get_tariff_charges(
    product_code = product_code,
    tariff_code = tariff_code,
    fuel_type = fuel_type,
    period_from = period_from,
    period_to = period_to,
    tz = tz,
    order_by = "period"
  )
}