# Helper script to encrypt secrets for testing
# Run this locally to generate encrypted strings for your testing values

library(httr2)

# Load .Renviron explicitly
renviron_path <- path.expand("~/.Renviron")
if (file.exists(renviron_path)) {
  readRenviron(renviron_path)
  cat("Loaded .Renviron from:", renviron_path, "\n\n")
} else {
  stop("Could not find .Renviron file at: ", renviron_path)
}

# Read from environment
api_key <- Sys.getenv("OCTOPUSR_API_KEY")
mpan <- Sys.getenv("OCTOPUSR_MPAN")
mprn <- Sys.getenv("OCTOPUSR_MPRN")
elec_serial <- Sys.getenv("OCTOPUSR_ELEC_SERIAL_NUM")
gas_serial <- Sys.getenv("OCTOPUSR_GAS_SERIAL_NUM")
gsp <- Sys.getenv("OCTOPUSR_GSP")

cat("Encrypted values (copy these into your code):\n")
cat("=" , rep("=", 60), "\n\n", sep = "")

if (api_key != "") {
  cat("API Key:\n")
  cat('"', secret_encrypt(api_key, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("WARNING: OCTOPUSR_API_KEY not found\n\n")
}

if (mpan != "") {
  cat("MPAN (electricity):\n")
  cat('"', secret_encrypt(mpan, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("WARNING: OCTOPUSR_MPAN not found - add it to .Renviron\n\n")
}

if (mprn != "") {
  cat("MPRN (gas):\n")
  cat('"', secret_encrypt(mprn, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("WARNING: OCTOPUSR_MPRN not found\n\n")
}

if (elec_serial != "") {
  cat("Electric Serial Number:\n")
  cat('"', secret_encrypt(elec_serial, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("WARNING: OCTOPUSR_ELEC_SERIAL_NUM not found\n\n")
}

if (gas_serial != "") {
  cat("Gas Serial Number:\n")
  cat('"', secret_encrypt(gas_serial, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("Note: OCTOPUSR_GAS_SERIAL_NUM not found (optional for electricity-only testing)\n\n")
}

if (gsp != "") {
  cat("GSP:\n")
  cat('"', secret_encrypt(gsp, "OCTOPUSR_SECRET_KEY"), '"\n\n', sep = "")
} else {
  cat("WARNING: OCTOPUSR_GSP not found - add it to .Renviron\n\n")
}

cat("=" , rep("=", 60), "\n", sep = "")
