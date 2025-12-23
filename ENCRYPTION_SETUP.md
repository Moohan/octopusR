# Encryption Setup for Testing

This document explains how to encrypt your API credentials for use in GitHub CI testing.

## Overview

The package uses `httr2::secret_encrypt()` to store sensitive testing values. This allows:
- **Local development**: Uses values from `.Renviron`
- **GitHub CI**: Uses encrypted values decrypted with `OCTOPUSR_SECRET_KEY` GitHub secret

## Setup Steps

### 1. Add all required values to your `.Renviron`

Your `.Renviron` file should contain:

```
OCTOPUSR_SECRET_KEY = "6m2V1PX3qQeua7xXePTC7A"
OCTOPUSR_API_KEY = "sk_live_..."
OCTOPUSR_MPAN = "your_electricity_mpan"
OCTOPUSR_MPRN = "your_gas_mprn"
OCTOPUSR_ELEC_SERIAL_NUM = "your_electric_serial"
OCTOPUSR_GAS_SERIAL_NUM = "your_gas_serial"  # Optional
OCTOPUSR_GSP = "your_grid_supply_point"
```

Find your MPAN, MPRN, serial numbers, and GSP at:
https://octopus.energy/dashboard/developer/

### 2. Run the encryption script

```r
source("encrypt_secrets.R")
```

This will output encrypted strings for each value.

### 3. Update the code with encrypted values

Copy the encrypted strings into:
- `R/api_key.R` - `testing_key()` function
- `R/meter_details.R` - `testing_meter()` function
- `tests/testthat/test-get_meter_gsp.R` - test expectations

Replace the placeholder strings:
- `"ENCRYPTED_MPAN_HERE"` → your encrypted MPAN
- `"ENCRYPTED_GSP_HERE"` → your encrypted GSP

### 4. Configure GitHub Secret

Add a GitHub repository secret:
- Name: `OCTOPUSR_SECRET_KEY`
- Value: `6m2V1PX3qQeua7xXePTC7A`

This allows GitHub Actions to decrypt the values during testing.

> Note: CI behavior — when running on CI (e.g. GitHub Actions) the test suite will be skipped if `OCTOPUSR_SECRET_KEY` is not set. Ensure you add `OCTOPUSR_SECRET_KEY` as a repository secret so encrypted test values can be decrypted.

### 5. Test locally

```r
devtools::test()
```

All tests should pass using your `.Renviron` values.

## Current Status

✅ API Key - encrypted
✅ Electric Serial Number - encrypted
✅ Gas MPRN - encrypted
❌ MPAN (electricity) - **needs to be added to .Renviron and re-encrypted**
❌ GSP - **needs to be added to .Renviron and re-encrypted**

## Next Steps

1. Add `OCTOPUSR_MPAN` and `OCTOPUSR_GSP` to your `.Renviron`
2. Run `source("encrypt_secrets.R")`
3. Update the placeholder strings in the code with the output
4. Commit and push the changes
