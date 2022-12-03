#' Main Octopus API
#'
#' @param path the API endpoint
#' @param query optional list of
#' @inheritParams set_api_key
#'
#' @return An Octopus API object
octopus_api <- function(path, query = NULL, api_key = NULL, use_api_key = FALSE) {
  if (use_api_key || !missing(api_key)) {
    if (missing(api_key)) api_key <- get_api_key()

    base_url <- glue::glue("https://{api_key}@api.octopus.energy/")
  } else {
    base_url <- "https://api.octopus.energy/"
  }

  req <- httr2::request(base_url) |>
    httr2::req_user_agent("octopusR (https://github.com/Moohan/octopusR)") |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!query)

  resp <- req |>
    httr2::req_throttle(5 / 1) |>
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
  resp |>
    httr2::resp_body_json() |>
    magrittr::extract2("detail")
}
