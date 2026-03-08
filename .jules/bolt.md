## 2025-01-24 - Avoiding redundant API calls and inefficient vector operations

**Learning:** `ifelse()` in R evaluates all branches even for vector inputs, which can lead to redundant function calls (e.g., calling an API helper like `get_meter_gsp()` when not needed) and unnecessary memory allocation. For large vectors, logical indexing is significantly faster (~3x in this package) and more memory-efficient.

**Action:** Replace `ifelse(is.na(x), 0, x)` with `x[is.na(x)] <- 0` in data-heavy paths. Implement flags like `include_gsp` in internal helpers to skip expensive, redundant operations when they are not required by the caller. Always use `NA_character_` for type consistency in metadata fields.
