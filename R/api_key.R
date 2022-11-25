#' Set the Octopus API key
#'
#' @description You can find your API key on the [octopus energy developer dashboard](https://octopus.energy/dashboard/developer/)
#'
#' @param key the Octopus API key to use
#'
#' @export
set_api_key <- function(key = NULL) {
  if (is.null(key)) {
    key <- askpass::askpass("Please enter your API key")
  }
  Sys.setenv("OCTOPUSR_API_KEY" = key)
}

get_api_key <- function() {
  key <- Sys.getenv("OCTOPUSR_API_KEY")
  if (!identical(key, "")) {
    return(key)
  }

  if (is_testing()) {
    return(testing_key())
  } else {
    cli::cli_abort("No API key found, please supply with {.arg api_key} argument or with OCTOPUSR_API_KEY env var")
  }
}


is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

testing_key <- function() {
  httr2::secret_decrypt("wvpeDSZ4oeBvZ72m95m2Dog2pXl3_1gfVsJsUubO1C4dwnB5sxKtlZdlkjYRsrzR", "OCTOPUSR_SECRET_KEY")
}
