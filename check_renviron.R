# Check what values are in .Renviron and what's missing

library(cli)

# Load .Renviron
renviron_path <- path.expand("~/.Renviron")
if (file.exists(renviron_path)) {
  readRenviron(renviron_path)
  cli_alert_success("Loaded .Renviron from: {renviron_path}")
} else {
  cli_alert_danger("Could not find .Renviron file at: {renviron_path}")
  quit()
}

cat("\n")
cli_h1("Environment Variables Status")
cat("\n")

check_var <- function(var_name, required = TRUE) {
  value <- Sys.getenv(var_name)
  if (value != "") {
    cli_alert_success("{var_name} = {value}")
    return(TRUE)
  } else {
    if (required) {
      cli_alert_danger("{var_name} = (missing) - REQUIRED")
    } else {
      cli_alert_warning("{var_name} = (missing) - Optional")
    }
    return(FALSE)
  }
}

# Check all variables
secret_key_ok <- check_var("OCTOPUSR_SECRET_KEY", required = TRUE)
api_key_ok <- check_var("OCTOPUSR_API_KEY", required = TRUE)
mpan_ok <- check_var("OCTOPUSR_MPAN", required = TRUE)
mprn_ok <- check_var("OCTOPUSR_MPRN", required = FALSE)
elec_serial_ok <- check_var("OCTOPUSR_ELEC_SERIAL_NUM", required = TRUE)
gas_serial_ok <- check_var("OCTOPUSR_GAS_SERIAL_NUM", required = FALSE)
gsp_ok <- check_var("OCTOPUSR_GSP", required = TRUE)

cat("\n")
cli_h1("Next Steps")
cat("\n")

if (!mpan_ok || !gsp_ok) {
  cli_alert_info("Add the missing values to your .Renviron file:")
  cli_alert_info("Find them at: {.url https://octopus.energy/dashboard/developer/}")
  cat("\n")
}

if (secret_key_ok && api_key_ok && mpan_ok && elec_serial_ok && gsp_ok) {
  cli_alert_success("All required variables are set!")
  cli_alert_info("Run: {.code source('encrypt_secrets.R')} to generate encrypted strings")
} else {
  cli_alert_warning("Add missing variables to .Renviron, then run this script again")
}
