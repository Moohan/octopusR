get_products <- function(is_variable = NULL,
                         is_green = NULL,
                         is_tracker = NULL,
                         is_prepay = NULL,
                         is_business = FALSE,
                         available_at = Sys.Date(),
                         authenticate = FALSE,
                         api_key = NULL) {
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
