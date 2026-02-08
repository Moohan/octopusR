check_datetime_format <- function(arg_date, call = rlang::caller_env()) {
  if (!is.character(arg_date) && !inherits(arg_date, "Date")) {
    cli::cli_abort(
      "{.arg {rlang::caller_arg(arg_date)}} must be {.cls character} or
      {.cls Date}, not {.cls {class(arg_date)}}.",
      call = call
    )
  }
  iso_8601_pattern <- paste0(
    "^([\\+-]?\\d{4}(?!\\d{2}\\b))((-?)((0[1-9]|1[0-2])(\\3([12]\\d|0[1-9]|3",
    "[01]))?|W([0-4]\\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\\d|[12]\\d{2}|3([",
    "0-5]\\d|6[1-6])))([T\\s]((([01]\\d|2[0-3])((:?)[0-5]\\d)?|24\\:?00)([",
    "\\.,]\\d+(?!:))?)?(\\17[0-5]\\d([\\.,]\\d+)?)?([zZ]|([\\+-])([01]\\d|",
    "2[0-3]):?([0-5]\\d)?)?)?)?$"
  )

  if (!grepl(iso_8601_pattern, arg_date, perl = TRUE)) {
    cli::cli_abort(
      c(
        "{.arg {rlang::caller_arg(arg_date)}} must be in
        [ISO_8601](https://en.wikipedia.org/wiki/ISO_8601) format.",
        ">" = "For example {.val {Sys.Date()}} or {.val {Sys.time()}}."
      ),
      call = call
    )
  }
}

check_logical <- function(arg_logical, call = rlang::caller_env()) {
  if (!is.logical(arg_logical)) {
    cli::cli_abort(
      "{.arg {rlang::caller_arg(arg_logical)}} must be {.cls logical},
      not {.cls {class(arg_logical)}}.",
      call = call
    )
  }
}
