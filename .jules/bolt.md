## 2025-01-24 - NA Handling Optimization in `combine_consumption`
**Learning:** In R, `ifelse()` is lazy for scalar tests but evaluates all branches for vector inputs, causing unnecessary memory allocation and slower execution. Logical indexing `x[is.na(x)] <- 0` is much more efficient.
**Action:** Always prefer logical indexing or `replace()` for simple NA replacement in large vectors or data frames.

## 2025-01-24 - Robustness in Testing
**Learning:** `httr2::secret_decrypt` returns garbage if the `OCTOPUSR_SECRET_KEY` is incorrect, which causes downstream failures (like "input string 1 is invalid" in `sub()`).
**Action:** Sanitize decrypted strings with `iconv(x, to = "ASCII")` and regex checks in test helpers to ensure stability in environments without the secret key.
