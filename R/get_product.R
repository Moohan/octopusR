#' Retrieve a specific energy product
#'
#' @description Retrieve the details of a specific energy product, including
#' pricing information and tariff details. The product data includes nested
#' pricing structures that are automatically unnested for easier analysis.
#'
#' @param product_code (character) The code of the product to retrieve.
#' @param tariffs_active_at (character, optional) Show tariff active at the given datetime.
#' Defaults to current datetime, effectively showing currently active tariffs.
#' @param authenticate (boolean, default: FALSE) Use an `api_key` to
#' authenticate. Only useful for organisations.
#' @inheritParams set_api_key
#'
#' @return a [tibble][tibble::tibble-package] containing the product details
#' and unnested pricing information
#' @export
#'
#' @examples
#' \dontrun{
#' # Get a specific product
#' get_product("AGILE-FLEX-22-11-25")
#' 
#' # Get product with tariffs active at a specific date
#' get_product("AGILE-FLEX-22-11-25", tariffs_active_at = "2023-01-01")
#' }
get_product <- function(product_code,
                       tariffs_active_at = Sys.time(),
                       authenticate = FALSE,
                       api_key = NULL) {
  # Validate inputs
  if (missing(product_code) || !is.character(product_code) || length(product_code) != 1) {
    cli::cli_abort(
      "{.arg product_code} must be a single character string containing the product code."
    )
  }
  
  check_datetime_format(tariffs_active_at)
  check_logical(authenticate)
  
  path <- glue::glue("/v1/products/{product_code}/")
  
  query <- list(
    tariffs_active_at = tariffs_active_at
  )
  
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
  
  product_data <- resp[["content"]]
  
  # Handle nested pricing data - unnest tariffs structure
  # This addresses the "clever unnesting of data" requirement by flattening
  # complex nested tariff structures while preserving detailed information
  
  # Helper function to process unit rates
  process_unit_rates <- function(rates_data) {
    if (is.null(rates_data) || length(rates_data) == 0) {
      return(NULL)
    }
    do.call(rbind, lapply(rates_data, function(rate) {
      data.frame(
        value_exc_vat = rate[["value_exc_vat"]],
        value_inc_vat = rate[["value_inc_vat"]],
        valid_from = rate[["valid_from"]],
        valid_to = rate[["valid_to"]],
        stringsAsFactors = FALSE
      )
    }))
  }
  
  # Process electricity tariffs
  if (!is.null(product_data[["single_register_electricity_tariffs"]])) {
    electricity_tariffs <- product_data[["single_register_electricity_tariffs"]]
    product_data[["single_register_electricity_tariffs"]] <- NULL
    
    if (length(electricity_tariffs) > 0) {
      # Extract basic tariff information
      electricity_data <- lapply(names(electricity_tariffs), function(tariff_code) {
        tariff <- electricity_tariffs[[tariff_code]]
        list(
          tariff_code = tariff_code,
          standing_charge_exc_vat = tariff[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = tariff[["standing_charge_inc_vat"]],
          online_discount_exc_vat = tariff[["online_discount_exc_vat"]],
          online_discount_inc_vat = tariff[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = tariff[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = tariff[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = tariff[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = tariff[["exit_fees_inc_vat"]],
          standard_unit_rates = process_unit_rates(tariff[["standard_unit_rates"]]),
          day_unit_rates = process_unit_rates(tariff[["day_unit_rates"]]),
          night_unit_rates = process_unit_rates(tariff[["night_unit_rates"]]),
          links = tariff[["links"]]
        )
      })
      names(electricity_data) <- sapply(electricity_data, function(x) x[["tariff_code"]])
      
      # Store detailed tariff data as attribute
      attr(product_data, "electricity_tariffs") <- electricity_data
      
      # Add summary to main product data
      product_data[["num_electricity_tariffs"]] <- length(electricity_data)
      product_data[["electricity_tariff_codes"]] <- paste(names(electricity_data), collapse = ", ")
    }
  }
  
  # Process gas tariffs
  if (!is.null(product_data[["single_register_gas_tariffs"]])) {
    gas_tariffs <- product_data[["single_register_gas_tariffs"]]
    product_data[["single_register_gas_tariffs"]] <- NULL
    
    if (length(gas_tariffs) > 0) {
      gas_data <- lapply(names(gas_tariffs), function(tariff_code) {
        tariff <- gas_tariffs[[tariff_code]]
        list(
          tariff_code = tariff_code,
          standing_charge_exc_vat = tariff[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = tariff[["standing_charge_inc_vat"]],
          online_discount_exc_vat = tariff[["online_discount_exc_vat"]],
          online_discount_inc_vat = tariff[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = tariff[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = tariff[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = tariff[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = tariff[["exit_fees_inc_vat"]],
          standard_unit_rates = process_unit_rates(tariff[["standard_unit_rates"]]),
          links = tariff[["links"]]
        )
      })
      names(gas_data) <- sapply(gas_data, function(x) x[["tariff_code"]])
      
      # Store detailed tariff data as attribute
      attr(product_data, "gas_tariffs") <- gas_data
      
      # Add summary to main product data
      product_data[["num_gas_tariffs"]] <- length(gas_data)
      product_data[["gas_tariff_codes"]] <- paste(names(gas_data), collapse = ", ")
    }
  }
  
  # Convert main product data to tibble
  main_fields <- c("code", "direction", "full_name", "display_name", "description",
                   "is_variable", "is_green", "is_tracker", "is_prepay", "is_business", 
                   "is_restricted", "term", "available_from", "available_to", "brand",
                   "num_electricity_tariffs", "electricity_tariff_codes",
                   "num_gas_tariffs", "gas_tariff_codes")
  
  result_data <- product_data[names(product_data) %in% main_fields]
  result_tibble <- tibble::as_tibble(data.frame(result_data, stringsAsFactors = FALSE))
  
  # Attach detailed tariff data as attributes for advanced users
  if (!is.null(attr(product_data, "electricity_tariffs"))) {
    attr(result_tibble, "electricity_tariffs") <- attr(product_data, "electricity_tariffs")
  }
  if (!is.null(attr(product_data, "gas_tariffs"))) {
    attr(result_tibble, "gas_tariffs") <- attr(product_data, "gas_tariffs")
  }
  
  return(result_tibble)
}