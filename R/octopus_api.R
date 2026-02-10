octopus_api <- function(
  path,
  query = NULL,
  api_key = NULL,
  use_api_key = FALSE,
  perform = TRUE
) {
  base_url <- "https://api.octopus.energy/"

  req <- httr2::request(base_url)

  if (use_api_key || !missing(api_key)) {
    if (missing(api_key)) {
      api_key <- get_api_key()
    }

    req <- req |> httr2::req_auth_basic(api_key, "")
  }

  req <- req |>
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

  parsed[["results"]] <- tibble::as_tibble(parsed[["results"]])

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
  body <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  if ("detail" %in% names(body)) {
    body[["detail"]]
  } else {
    NULL
  }
}
