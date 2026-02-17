## 2025-01-24 - Optimization and Robustness Boost

**Learning:** Replacing `ifelse(is.na(x), 0, x)` with logical indexing `x[is.na(x)] <- 0` for large vectors provides a significant speedup (~3.7x) and reduces memory allocation (~3.4x) because `ifelse` is not lazy for vector inputs and creates more intermediate copies.
**Action:** Always prefer logical indexing for NA replacement or simple vector filtering.

**Learning:** Reusing an `httr2_request` object in a pagination loop via `httr2::req_url_query()` instead of recreating it from scratch (e.g., calling a constructor function repeatedly) reduces overhead and memory allocation.
**Action:** Create a base request object once and use modification functions inside loops.

**Learning:** `httr2::secret_decrypt` returns garbage instead of erroring when the secret key is missing or incorrect in some environments. This causes "input string 1 is invalid" errors later in the code.
**Action:** Sanitize decrypted secrets by checking for ASCII validity and minimum length.
