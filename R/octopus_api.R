#' Main Octopus API
#'
#' @param path the API endpoint
#' @param query optional list passed to [httr::modify_url()]
#' @param api_key The API key to use for authentication (not required on all endpoints)
#'
#' @return An Octopus API object
#' @import httr
octopus_api <- function(path, query = NULL, api_key = NULL) {
  url <- modify_url("https://api.octopus.energy/", path = path, query = query, username = api_key)

  resp <- RETRY("GET", url, user_agent("https://github.com/Moohan/octopusR"),
    terminate_on = c(401)
  )
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- content(resp, "parsed", simplifyDataFrame = TRUE)

  if (status_code(resp) != 200) {
    stop(
      sprintf(
        "Octopus API request failed [%s]\n%s",
        status_code(resp),
        parsed$detail
      ),
      call. = FALSE
    )
  }

  parsed$results <- tibble::as_tibble(parsed$results)

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "octopus_api"
  )
}
