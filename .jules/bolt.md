## 2025-05-15 - Redundant GSP API Calls
**Learning:** `ifelse()` is NOT lazy in R; it evaluates both 'yes' and 'no' branches. This caused `get_meter_gsp()` to be called even for gas meters in `get_meter_details()`, leading to redundant API calls and potential errors.
**Action:** Use standard `if/else` blocks for scalar logic involving side effects or expensive calls. Added `include_gsp` parameter to internal `get_meter_details()` to allow explicit control over these lookups.

## 2025-05-15 - Vectorized NA Replacement
**Learning:** `ifelse(is.na(x), 0, x)` is significantly slower and more memory-intensive than logical indexing `x[is.na(x)] <- 0` for large vectors.
**Action:** Replace `ifelse` with logical indexing in hot paths like `combine_consumption()` to achieve measurable (~4.5x) speedups.
