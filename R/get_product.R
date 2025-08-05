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
  if (!is.null(product_data[["single_register_electricity_tariffs"]])) {
    electricity_tariffs <- product_data[["single_register_electricity_tariffs"]]
    product_data[["single_register_electricity_tariffs"]] <- NULL
    
    # Create a flattened structure for easier analysis
    if (length(electricity_tariffs) > 0) {
      electricity_data <- lapply(names(electricity_tariffs), function(tariff_code) {
        tariff <- electricity_tariffs[[tariff_code]]
        
        # Extract direct tariff information
        base_data <- list(
          tariff_code = tariff_code,
          standing_charge_exc_vat = tariff[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = tariff[["standing_charge_inc_vat"]],
          online_discount_exc_vat = tariff[["online_discount_exc_vat"]],
          online_discount_inc_vat = tariff[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = tariff[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = tariff[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = tariff[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = tariff[["exit_fees_inc_vat"]],
          links = if(!is.null(tariff[["links"]])) list(tariff[["links"]]) else list(NULL)
        )
        
        # Handle standard unit rates
        if (!is.null(tariff[["standard_unit_rates"]])) {
          rates_data <- tariff[["standard_unit_rates"]]
          if (length(rates_data) > 0) {
            rates_df <- do.call(rbind, lapply(rates_data, function(rate) {
              data.frame(
                value_exc_vat = rate[["value_exc_vat"]],
                value_inc_vat = rate[["value_inc_vat"]],
                valid_from = rate[["valid_from"]],
                valid_to = rate[["valid_to"]],
                stringsAsFactors = FALSE
              )
            }))
            base_data[["standard_unit_rates"]] <- list(rates_df)
          } else {
            base_data[["standard_unit_rates"]] <- list(NULL)
          }
        } else {
          base_data[["standard_unit_rates"]] <- list(NULL)
        }
        
        # Handle day unit rates
        if (!is.null(tariff[["day_unit_rates"]])) {
          day_rates_data <- tariff[["day_unit_rates"]]
          if (length(day_rates_data) > 0) {
            day_rates_df <- do.call(rbind, lapply(day_rates_data, function(rate) {
              data.frame(
                value_exc_vat = rate[["value_exc_vat"]],
                value_inc_vat = rate[["value_inc_vat"]],
                valid_from = rate[["valid_from"]],
                valid_to = rate[["valid_to"]],
                stringsAsFactors = FALSE
              )
            }))
            base_data[["day_unit_rates"]] <- list(day_rates_df)
          } else {
            base_data[["day_unit_rates"]] <- list(NULL)
          }
        } else {
          base_data[["day_unit_rates"]] <- list(NULL)
        }
        
        # Handle night unit rates
        if (!is.null(tariff[["night_unit_rates"]])) {
          night_rates_data <- tariff[["night_unit_rates"]]
          if (length(night_rates_data) > 0) {
            night_rates_df <- do.call(rbind, lapply(night_rates_data, function(rate) {
              data.frame(
                value_exc_vat = rate[["value_exc_vat"]],
                value_inc_vat = rate[["value_inc_vat"]],
                valid_from = rate[["valid_from"]],
                valid_to = rate[["valid_to"]],
                stringsAsFactors = FALSE
              )
            }))
            base_data[["night_unit_rates"]] <- list(night_rates_df)
          } else {
            base_data[["night_unit_rates"]] <- list(NULL)
          }
        } else {
          base_data[["night_unit_rates"]] <- list(NULL)
        }
        
        return(base_data)
      })
      
      # Convert to tibble
      electricity_df <- do.call(rbind, lapply(electricity_data, function(x) {
        data.frame(
          tariff_code = x[["tariff_code"]],
          standing_charge_exc_vat = x[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = x[["standing_charge_inc_vat"]],
          online_discount_exc_vat = x[["online_discount_exc_vat"]],
          online_discount_inc_vat = x[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = x[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = x[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = x[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = x[["exit_fees_inc_vat"]],
          stringsAsFactors = FALSE
        )
      }))
      
      product_data[["electricity_tariffs"]] <- tibble::as_tibble(electricity_df)
      
      # Store detailed rates separately for advanced analysis
      rates_list <- lapply(electricity_data, function(x) {
        list(
          tariff_code = x[["tariff_code"]],
          standard_unit_rates = x[["standard_unit_rates"]][[1]],
          day_unit_rates = x[["day_unit_rates"]][[1]],
          night_unit_rates = x[["night_unit_rates"]][[1]],
          links = x[["links"]][[1]]
        )
      })
      names(rates_list) <- sapply(electricity_data, function(x) x[["tariff_code"]])
      product_data[["detailed_rates"]] <- rates_list
    }
  }
  
  # Handle gas tariffs similarly
  if (!is.null(product_data[["single_register_gas_tariffs"]])) {
    gas_tariffs <- product_data[["single_register_gas_tariffs"]]
    product_data[["single_register_gas_tariffs"]] <- NULL
    
    if (length(gas_tariffs) > 0) {
      gas_data <- lapply(names(gas_tariffs), function(tariff_code) {
        tariff <- gas_tariffs[[tariff_code]]
        
        base_data <- list(
          tariff_code = tariff_code,
          standing_charge_exc_vat = tariff[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = tariff[["standing_charge_inc_vat"]],
          online_discount_exc_vat = tariff[["online_discount_exc_vat"]],
          online_discount_inc_vat = tariff[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = tariff[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = tariff[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = tariff[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = tariff[["exit_fees_inc_vat"]]
        )
        
        if (!is.null(tariff[["standard_unit_rates"]])) {
          rates_data <- tariff[["standard_unit_rates"]]
          if (length(rates_data) > 0) {
            rates_df <- do.call(rbind, lapply(rates_data, function(rate) {
              data.frame(
                value_exc_vat = rate[["value_exc_vat"]],
                value_inc_vat = rate[["value_inc_vat"]],
                valid_from = rate[["valid_from"]],
                valid_to = rate[["valid_to"]],
                stringsAsFactors = FALSE
              )
            }))
            base_data[["standard_unit_rates"]] <- list(rates_df)
          }
        }
        
        return(base_data)
      })
      
      gas_df <- do.call(rbind, lapply(gas_data, function(x) {
        data.frame(
          tariff_code = x[["tariff_code"]],
          standing_charge_exc_vat = x[["standing_charge_exc_vat"]],
          standing_charge_inc_vat = x[["standing_charge_inc_vat"]],
          online_discount_exc_vat = x[["online_discount_exc_vat"]],
          online_discount_inc_vat = x[["online_discount_inc_vat"]],
          dual_fuel_discount_exc_vat = x[["dual_fuel_discount_exc_vat"]],
          dual_fuel_discount_inc_vat = x[["dual_fuel_discount_inc_vat"]],
          exit_fees_exc_vat = x[["exit_fees_exc_vat"]],
          exit_fees_inc_vat = x[["exit_fees_inc_vat"]],
          stringsAsFactors = FALSE
        )
      }))
      
      product_data[["gas_tariffs"]] <- tibble::as_tibble(gas_df)
    }
  }
  
  # Convert main product data to tibble
  main_fields <- c("code", "direction", "full_name", "display_name", "description",
                   "is_variable", "is_green", "is_tracker", "is_prepay", "is_business", 
                   "is_restricted", "term", "available_from", "available_to", "brand")
  
  result_data <- product_data[names(product_data) %in% main_fields]
  result_tibble <- tibble::as_tibble(data.frame(result_data, stringsAsFactors = FALSE))
  
  # Attach additional tariff data as attributes for advanced users
  if (!is.null(product_data[["electricity_tariffs"]])) {
    attr(result_tibble, "electricity_tariffs") <- product_data[["electricity_tariffs"]]
    attr(result_tibble, "detailed_rates") <- product_data[["detailed_rates"]]
  }
  if (!is.null(product_data[["gas_tariffs"]])) {
    attr(result_tibble, "gas_tariffs") <- product_data[["gas_tariffs"]]
  }
  
  return(result_tibble)
}