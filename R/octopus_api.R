octopus_api <- function(
  path,
  query = NULL,
  api_key = NULL,
  use_api_key = FALSE,
  perform = TRUE
) {
  if (use_api_key || !missing(api_key)) {
    if (missing(api_key)) {
      api_key <- get_api_key()
    }

    base_url <- glue::glue("https://{api_key}@api.octopus.energy/")
  } else {
    base_url <- "https://api.octopus.energy/"
  }

  req <- httr2::request(base_url) |>
    httr2::req_user_agent("octopusR (https://github.com/Moohan/octopusR)") |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!query) |>
    httr2::req_throttle(5L) |>
    httr2::req_cache(tools::R_user_dir("octopusR", "cache")) |>
    httr2::req_progress("down")

  if (isFALSE(perform)) {
    return(req)
  }

  resp <- req |>
    httr2::req_error(body = octopus_error_body) |>
    httr2::req_perform()

  parsed <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  if ("results" %in% names(parsed) && !is.null(parsed[["results"]])) {
    parsed[["results"]] <- tibble::as_tibble(parsed[["results"]])
  }

  structure(
    list(
      response = resp,
      path = path,
      content = parsed
    ),
    class = "octopus_api"
  )
}

octopus_error_body <- function(resp) {
  status <- httr2::resp_status(resp)
  body <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  detail <- body[["detail"]] %||% "No further details provided by API."

  if (status == 401) {
    return(paste0(
      "Authentication failed: ", detail,
      " Please check your API key with set_api_key()."
    ))
  }

  if (status == 404) {
    return(paste0(
      "Resource not found: ", detail,
      " Please verify your meter details (MPAN/MPRN)."
    ))
  }

  detail
}

# Helper for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x
