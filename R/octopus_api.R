#' Main Octopus API
#'
#' @param path the API endpoint
#' @param query optional list of
#' @param api_key The API key to use for authentication
#' (not required on all endpoints)
#'
#' @return An Octopus API object
octopus_api <- function(path, query = NULL, api_key = get_api_key()) {
  resp <- httr2::request(paste0("https://", api_key, "@api.octopus.energy/")) |>
    httr2::req_user_agent("octopusR (https://github.com/Moohan/octopusR)") |>
    httr2::req_url_path_append(path) |>
    httr2::req_url_query(!!!query) |>
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
