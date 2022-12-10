check_datetime_format <- function(date, param_name) {
  iso_8601_pattern <- "^([\\+-]?\\d{4}(?!\\d{2}\\b))((-?)((0[1-9]|1[0-2])(\\3([12]\\d|0[1-9]|3[01]))?|W([0-4]\\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\\d|[12]\\d{2}|3([0-5]\\d|6[1-6])))([T\\s]((([01]\\d|2[0-3])((:?)[0-5]\\d)?|24\\:?00)([\\.,]\\d+(?!:))?)?(\\17[0-5]\\d([\\.,]\\d+)?)?([zZ]|([\\+-])([01]\\d|2[0-3]):?([0-5]\\d)?)?)?)?$"

  if (!grepl(iso_8601_pattern, date, perl = TRUE)) {
    cli::cli_abort(c("{.arg {param_name}} must be in [ISO_8601](https://en.wikipedia.org/wiki/ISO_8601) format.",
      ">" = "For example {.val {Sys.Date()}} or {.val {Sys.time()}}."
    ))
  }

  return(date)
}

check_logical <- function(param_lgl, param_name) {
  if (class(param_lgl) != "logical") {
    cli::cli_abort("{.arg {param_name}} must be {.cls logical}, not {.cls {class(param_lgl)}}.")
  }

  return(param_lgl)
}
