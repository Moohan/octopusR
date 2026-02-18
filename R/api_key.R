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
    return(api_key)
  }

  if (is_testing()) {
    return(testing_key())
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
    "gSnStfRq0gqwkVy9notuWa97vp_d7hxX3IOrlMv6g1nlNeMhtHSdvboMx_49zcVWgpityPpCtKA",
    "sk_test_dummy_key"
  )
}

safe_decrypt <- function(cipher, fallback) {
  val <- tryCatch(
    httr2::secret_decrypt(cipher, "OCTOPUSR_SECRET_KEY"),
    error = function(e) fallback
  )

  # Check if the decrypted value is garbage (can happen if secret key is wrong
  # but no error). We ensure it's ASCII and matches expected URL/path characters.
  if (is.na(iconv(val, to = "ASCII")) || !grepl("^[A-Za-z0-9_-]+$", val)) {
    return(fallback)
  }

  return(val)
}
