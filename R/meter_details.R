#' Set the details for your gas/electricity meter
#'
#' @description Set the details for your gas/electricity meter. These will be
#' stored as environment variables. You should add:
#'  * `OCTOPUSR_MPAN = <electric MPAN>` (or `OCTOPUSR_MPAN_IMPORT`/`OCTOPUSR_MPAN_EXPORT`)
#'  * `OCTOPUSR_MPRN = <gas MPRN>`
#'  * `OCTOPUSR_ELEC_SERIAL_NUM = <electric serial number>` (or `OCTOPUSR_ELEC_SERIAL_NUM_IMPORT`/`OCTOPUSR_ELEC_SERIAL_NUM_EXPORT`)
#'  * `OCTOPUSR_GAS_SERIAL_NUM = <gas serial number>`
#' to your `.Renviron` otherwise you will have to call this function every
#' session. You can find your meter details (MPAN/MPRN and serial number(s)) on
#' the [developer dashboard](https://octopus.energy/dashboard/developer/).
#'
#' @param meter_type Type of meter-point, electricity or gas
#' @param mpan_mprn The electricity meter-point's MPAN or gas meter-point’s
#' MPRN.
#' @param serial_number The meter's serial number.
#' @param direction For electricity meters, specify "import", "export", or NULL (default).
#' When NULL, uses the legacy single MPAN storage. When specified, stores separate
#' import/export MPANs.
#'
#' @return No return value, called for side effects.
#'
#' @export
set_meter_details <- function(
  meter_type = c("electricity", "gas"),
  mpan_mprn = NULL,
  serial_number = NULL,
  direction = NULL
) {
  meter_type <- match.arg(meter_type)

  # Validate direction parameter for electricity meters
  if (!is.null(direction) && meter_type != "electricity") {
    stop("The 'direction' parameter is only valid for electricity meters.")
  }

  if (!is.null(direction)) {
    direction <- match.arg(direction, c("import", "export"))
  }

  if (missing(mpan_mprn)) {
    mpan_mprn <- askpass::askpass(
      glue::glue(
        "Please enter your {meter_type} meter-point's
        {ifelse(meter_type == 'electricity', 'MPAN', 'MPRN')}."
      )
    )
  }
  if (missing(serial_number)) {
    serial_number <- askpass::askpass(glue::glue(
      "Please enter your {meter_type} meter-point's serial number."
    ))
  }

  if (meter_type == "electricity") {
    if (is.null(direction)) {
      # Legacy behavior - use single MPAN
      Sys.setenv("OCTOPUSR_MPAN" = mpan_mprn)
      Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM" = serial_number)
    } else {
      # New behavior - use directional MPANs
      if (direction == "import") {
        Sys.setenv("OCTOPUSR_MPAN_IMPORT" = mpan_mprn)
        Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT" = serial_number)
      } else if (direction == "export") {
        Sys.setenv("OCTOPUSR_MPAN_EXPORT" = mpan_mprn)
        Sys.setenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT" = serial_number)
      }
    }
  } else if (meter_type == "gas") {
    Sys.setenv("OCTOPUSR_MPRN" = mpan_mprn)
    Sys.setenv("OCTOPUSR_GAS_SERIAL_NUM" = serial_number)
  }
}

get_meter_details <-
  function(
    meter_type = c("electricity", "gas"),
    direction = NULL,
    include_gsp = TRUE
  ) {
    meter_type <- match.arg(meter_type)

    # Validate direction parameter
    if (!is.null(direction) && meter_type != "electricity") {
      stop("The 'direction' parameter is only valid for electricity meters.")
    }

    if (!is.null(direction)) {
      direction <- match.arg(direction, c("import", "export"))
    }

    if (is_testing()) {
      return(testing_meter(meter_type, include_gsp = include_gsp))
    }

    if (meter_type == "electricity") {
      if (is.null(direction)) {
        # Try legacy single MPAN first
        mpan_mprn <- Sys.getenv("OCTOPUSR_MPAN")
        serial_number <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM")
      } else {
        # Use directional MPANs
        if (direction == "import") {
          mpan_mprn <- Sys.getenv("OCTOPUSR_MPAN_IMPORT")
          serial_number <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM_IMPORT")
        } else if (direction == "export") {
          mpan_mprn <- Sys.getenv("OCTOPUSR_MPAN_EXPORT")
          serial_number <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM_EXPORT")
        }
      }
    } else if (meter_type == "gas") {
      mpan_mprn <- Sys.getenv("OCTOPUSR_MPRN")
      serial_number <- Sys.getenv("OCTOPUSR_GAS_SERIAL_NUM")
    }

    if (!identical(mpan_mprn, "") && !identical(serial_number, "")) {
      return(structure(
        list(
          type = meter_type,
          mpan_mprn = mpan_mprn,
          serial_number = serial_number,
          direction = direction,
          gsp = if (include_gsp && meter_type == "electricity") {
            get_meter_gsp(mpan = mpan_mprn)
          } else {
            NA
          }
        ),
        class = "octopus_meter-point"
      ))
    }

    cli::cli_abort(
      "Meter details were missing or incomplete, please supply with
      {.arg mpan_mprn} and {.arg serial_number} arguments or with
      {.help [{.fun set_meter_details}](octopusR::set_meter_details)}.",
      call = rlang::caller_env()
    )
  }

testing_meter <- function(
  meter_type = c("electricity", "gas"),
  include_gsp = TRUE
) {
  meter_type <- match.arg(meter_type)

  # Helper to sanitize and provide fallback
  sanitize <- function(x, fallback) {
    x <- iconv(x, to = "ASCII", sub = "")
    x <- gsub("[^a-zA-Z0-9_-]", "", x)
    if (identical(x, "")) {
      fallback
    } else {
      x
    }
  }

  if (meter_type == "electricity") {
    mpan <- tryCatch(
      httr2::secret_decrypt(
        "DR9Bvd3ppfLXD4Zq-tG0kZphNdkW3168-OQrOSk",
        "OCTOPUSR_SECRET_KEY"
      ),
      error = function(e) "1234567890123"
    )
    mpan <- sanitize(mpan, "1234567890123")

    serial_number <- tryCatch(
      httr2::secret_decrypt(
        "g_K-kAcGIIcsrXeRegX8EjMBf7xnmhbX9ts",
        "OCTOPUSR_SECRET_KEY"
      ),
      error = function(e) "12A3456789"
    )
    serial_number <- sanitize(serial_number, "12A3456789")

    structure(
      list(
        type = "electricity",
        mpan_mprn = mpan,
        serial_number = serial_number,
        gsp = if (include_gsp) {
          tryCatch(get_meter_gsp(mpan = mpan), error = function(e) "J")
        } else {
          "J"
        }
      ),
      class = "octopus_meter-point"
    )
  } else if (meter_type == "gas") {
    mprn <- tryCatch(
      httr2::secret_decrypt(
        "z-BpI17a6UVNWT8ByPzue_XI5j2zU547vi0",
        "OCTOPUSR_SECRET_KEY"
      ),
      error = function(e) "1234567890"
    )
    mprn <- sanitize(mprn, "1234567890")

    serial_number <- tryCatch(
      httr2::secret_decrypt(
        "d06raLRtC5JWyQkh64mZOtWFDOUCQlojLAyfMUk-",
        "OCTOPUSR_SECRET_KEY"
      ),
      error = function(e) "9876543210"
    )
    serial_number <- sanitize(serial_number, "9876543210")

    structure(
      list(
        type = "gas",
        mpan_mprn = mprn,
        serial_number = serial_number
      ),
      class = "octopus_meter-point"
    )
  }
}

#' Combine import and export consumption data
#'
#' @description Combine consumption data from import and export meters into a
#' single tibble with separate columns for import and export consumption.
#' This is useful for users with solar panels or other export generation.
#'
#' @param import_mpan The import meter MPAN
#' @param import_serial The import meter serial number
#' @param export_mpan The export meter MPAN
#' @param export_serial The export meter serial number
#' @param api_key API key for authentication
#' @param period_from Show consumption from the given datetime (inclusive)
#' @param period_to Show consumption to the given datetime (exclusive)
#' @param tz Time zone for date parsing (requires lubridate)
#' @param order_by Ordering of results returned
#' @param group_by Aggregates consumption over a specified time period
#'
#' @return a [tibble][tibble::tibble-package] with import_consumption,
#' export_consumption, and net_consumption columns
#' @export
combine_consumption <- function(
  import_mpan = NULL,
  import_serial = NULL,
  export_mpan = NULL,
  export_serial = NULL,
  api_key = get_api_key(),
  period_from = NULL,
  period_to = NULL,
  tz = NULL,
  order_by = c("-period", "period"),
  group_by = c("hour", "day", "week", "month", "quarter")
) {
  # Get import consumption data
  import_data <- NULL
  if (!is.null(import_mpan) && !is.null(import_serial)) {
    import_data <- get_consumption(
      meter_type = "electricity",
      mpan_mprn = import_mpan,
      serial_number = import_serial,
      api_key = api_key,
      period_from = period_from,
      period_to = period_to,
      tz = tz,
      order_by = order_by,
      group_by = group_by
    )
  } else {
    # Try to get from environment variables
    import_data <- tryCatch(
      {
        get_consumption(
          meter_type = "electricity",
          direction = "import",
          api_key = api_key,
          period_from = period_from,
          period_to = period_to,
          tz = tz,
          order_by = order_by,
          group_by = group_by
        )
      },
      error = function(e) NULL
    )
  }

  # Get export consumption data
  export_data <- NULL
  if (!is.null(export_mpan) && !is.null(export_serial)) {
    export_data <- get_consumption(
      meter_type = "electricity",
      mpan_mprn = export_mpan,
      serial_number = export_serial,
      api_key = api_key,
      period_from = period_from,
      period_to = period_to,
      tz = tz,
      order_by = order_by,
      group_by = group_by
    )
  } else {
    # Try to get from environment variables
    export_data <- tryCatch(
      {
        get_consumption(
          meter_type = "electricity",
          direction = "export",
          api_key = api_key,
          period_from = period_from,
          period_to = period_to,
          tz = tz,
          order_by = order_by,
          group_by = group_by
        )
      },
      error = function(e) NULL
    )
  }

  # Combine the data
  if (is.null(import_data) && is.null(export_data)) {
    stop("No import or export consumption data could be retrieved.")
  }

  if (is.null(import_data)) {
    # Only export data available
    result <- export_data
    result$import_consumption <- 0
    result$export_consumption <- result$consumption
    result$consumption <- NULL
    result$net_consumption <- -result$export_consumption
  } else if (is.null(export_data)) {
    # Only import data available
    result <- import_data
    result$import_consumption <- result$consumption
    result$export_consumption <- 0
    result$consumption <- NULL
    result$net_consumption <- result$import_consumption
  } else {
    # Both import and export data available - merge on time intervals
    result <- merge(
      import_data,
      export_data,
      by = c("interval_start", "interval_end"),
      all = TRUE,
      suffixes = c("_import", "_export")
    )

    # Rename consumption columns
    # Optimization: Logical indexing is faster and more memory-efficient than
    # ifelse() for large datasets.
    result$import_consumption <- result$consumption_import
    result$import_consumption[is.na(result$import_consumption)] <- 0
    result$export_consumption <- result$consumption_export
    result$export_consumption[is.na(result$export_consumption)] <- 0
    result$consumption_import <- NULL
    result$consumption_export <- NULL

    # Calculate net consumption (import - export)
    result$net_consumption <- result$import_consumption -
      result$export_consumption
  }

  # Reorder columns for better readability
  col_order <- c(
    "interval_start",
    "interval_end",
    "import_consumption",
    "export_consumption",
    "net_consumption"
  )
  result[col_order]
}
