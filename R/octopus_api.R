#' Main Octopus API
#'
#' @param path the API endpoint
#'
#' @return an Octopus API object
#' @export
#' @import httr
#'
#' @examples
octopus_api <- function(path) {
  url <- modify_url("https://api.octopus.energy/", path = path)

  resp <- GET(url, user_agent("https://github.com/Moohan/octopusR"))
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
