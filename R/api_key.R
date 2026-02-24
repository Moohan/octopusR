#' Set the Octopus API key
#'
#' @description Set the Octopus API key to use. This will be stored as an
#' environment variable. You should add `OCTOPUSR_API_KEY = <api_key>` to your
#' `.Renviron` otherwise you will have to call this function every session.
#'
#' @param api_key Your API key. If you are an Octopus Energy customer,
#' you can generate an API key on the
#' [developer dashboard](https://octopus.energy/dashboard/developer/).
#'
#' @return No return value, called for side effects.
#'
#' @export
set_api_key <- function(api_key = NULL) {
  if (missing(api_key)) {
    api_key <- askpass::askpass("Please enter your API key")
  }
  Sys.setenv("OCTOPUSR_API_KEY" = api_key)
}

get_api_key <- function() {
  api_key <- Sys.getenv("OCTOPUSR_API_KEY")
  if (!identical(api_key, "")) {
    api_key
  } else if (is_testing()) {
    testing_key()
  } else {
    cli::cli_abort(
      "No API key found, please supply with {.arg api_key} argument or with
      {.help [{.fun set_api_key}](octopusR::set_api_key)}",
      call = rlang::caller_env()
    )
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

testing_key <- function() {
  safe_decrypt(
    paste0(
      "gSnStfRq0gqwkVy9notuWa97vp_d7hxX3IOrlMv6",
      "g1nlNeMhtHSdvboMx_49zcVWgpityPpCtKA"
    ),
    "sk_test_mpan"
  )
}

safe_decrypt <- function(cipher, fallback) {
  res <- tryCatch(
    httr2::secret_decrypt(cipher, "OCTOPUSR_SECRET_KEY"),
    error = function(e) fallback
  )

  # Check if result is valid ASCII and matches expected pattern for keys/MPANs
  # httr2::secret_decrypt can return garbage if the key is wrong.
  is_invalid <- is.na(iconv(res, to = "ASCII")) ||
    grepl("[^A-Za-z0-9_-]", res) ||
    nchar(res) < 5

  if (is_invalid) {
    fallback
  } else {
    res
  }
}
