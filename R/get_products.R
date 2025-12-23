#' Return a list of energy products
#'
#' @description By default, results will be public energy products but if
#'  authenticated organisations will also see products available to
#'  their organisation.
#'
#' @param is_variable (boolean, optional) Show only variable products.
#' @param is_green (boolean, optional) Show only green products.
#' @param is_tracker (boolean, optional) Show only tracker products.
#' @param is_prepay (boolean, optional) Show only pre-pay products.
#' @param is_business (boolean, default: FALSE) Show only business products.
#' @param available_at Show products available for new agreements on the given
#' datetime.
#' Defaults to current datetime, effectively showing products that are
#' currently available.
#' @param authenticate (boolean, default: FALSE) Use an `api_key` to
#' authenticate. Only useful for organisations.
#' @inheritParams set_api_key
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
#' @examples
#' get_products(is_green = TRUE)
get_products <- function(
  is_variable = NULL,
  is_green = NULL,
  is_tracker = NULL,
  is_prepay = NULL,
  is_business = FALSE,
  available_at = Sys.Date(),
  authenticate = FALSE,
  api_key = NULL
) {
  if (!missing(is_variable)) {
    check_logical(is_variable)
  }
  if (!missing(is_green)) {
    check_logical(is_green)
  }
  if (!missing(is_tracker)) {
    check_logical(is_tracker)
  }
  if (!missing(is_prepay)) {
    check_logical(is_prepay)
  }

  check_logical(is_business)
  check_datetime_format(available_at)

  path <- "/v1/products/"

  query <- list(
    is_variable = is_variable,
    is_green = is_green,
    is_tracker = is_tracker,
    is_prepay = is_prepay,
    is_business = is_business,
    available_at = available_at
  )

  check_logical(authenticate)

  if (authenticate) {
    if (missing(api_key)) {
      api_key <- get_api_key()
    }
    resp <- octopus_api(
      path = path,
      query = query,
      use_api_key = TRUE,
      api_key = api_key
    )
  } else {
    resp <- octopus_api(
      path = path,
      query = query
    )
  }

  products <- resp[["content"]][["results"]]

  return(products)
}
