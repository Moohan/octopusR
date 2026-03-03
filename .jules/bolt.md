## 2025-01-24 - Redundant API Calls in Metadata Retrieval

**Learning:** `get_meter_details()` automatically triggered a GSP lookup for electricity meters via `get_meter_gsp()`, causing a secondary API call even when the caller (e.g., `get_consumption()`) didn't need it. This also caused circular-like behavior in `get_meter_gsp()`'s default argument.

**Action:** Implement an `include_gsp` toggle in metadata functions to lazily load or skip unnecessary API-backed fields.

## 2025-01-24 - `ifelse()` vs Logical Indexing for `NA` Handling

**Learning:** `ifelse()` is significantly slower and more memory-intensive than logical indexing when handling `NA` values in large vectors (e.g., merging consumption data), as it evaluates all branches and constructs a new vector.

**Action:** Replace `x <- ifelse(is.na(x), 0, x)` with `x[is.na(x)] <- 0` in performance-critical data merging paths.
