#' Main Octopus API
#'
#' @param path the API endpoint
#' @param query optional list passed to [httr::modify_url()]
#' @param api_key The API key to use for authentication
#' (not required on all endpoints)
#'
#' @return An Octopus API object
octopus_api <- function(path, query = NULL, api_key = NULL) {
  url <- httr::modify_url(
    url = "https://api.octopus.energy/",
    path = path,
    query = query,
    username = api_key
  )

  resp <- httr::RETRY(
    verb = "GET",
    url = url,
    httr::user_agent(agent = "https://github.com/Moohan/octopusR"),
    terminate_on = c(400L, 401L, 403L)
  )

  if (httr::http_type(resp) != "application/json") {
    cli::cli_abort("API did not return json", call = NULL)
  }

  parsed <- httr::content(
    x = resp,
    as = "parsed",
    simplifyDataFrame = TRUE
  )

  if (httr::status_code(resp) != 200L) {
    cli::cli_abort(c(
      "x" = "Octopus API request failed",
      "*" = "Status code: {status_code(resp)}",
      parsed[["detail"]],
      unname(purrr::map_chr(parsed, ~ .x[[1L]]))
    ))
  }

  parsed[["results"]] <- tibble::as_tibble(parsed[["results"]])

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "octopus_api"
  )
}
