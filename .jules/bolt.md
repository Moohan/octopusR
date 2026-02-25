## 2026-02-25 - Optimize consumption retrieval and combine operations
**Learning:** Functions requiring meter metadata (e.g., `get_consumption`) use the `include_gsp` flag in `get_meter_details` to skip redundant secondary API calls for Grid Supply Point data, providing a speedup by avoiding network latency. Vectorized NA replacement in `combine_consumption` using logical indexing is significantly faster than `ifelse()` for large datasets.
**Action:** Use `include_gsp = FALSE` when Grid Supply Point data is not required. Prefer `x[is.na(x)] <- 0` over `ifelse(is.na(x), 0, x)` for performance in data-heavy paths.

## 2026-02-25 - Robust decryption in tests
**Learning:** `httr2::secret_decrypt` returns garbage if the key is wrong or missing (common in CI). This causes "input string 1 is invalid" errors in regex or path functions.
**Action:** Centralize decryption in a `safe_decrypt` helper that validates output (ASCII check, length, regex) and returns a dummy fallback if invalid. Use `skip_if(grepl("^sk_test_", key))` in tests that require real API calls.

## 2026-02-25 - Mocking Internal Package Calls
**Learning:** `testthat::with_mocked_bindings` may not reliably intercept calls between functions in the same package namespace during tests, especially when the package is loaded. `mockery::stub` is more robust as it explicitly stubs the function in the target namespace.
**Action:** Prefer `mockery::stub` for mocking internal package functions to ensure reliable test isolation.
