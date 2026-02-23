## 2025-01-24 - Optimization: Skip redundant GSP fetching

**Learning:** `get_meter_details` was always calling `get_meter_gsp` even when the caller (like `get_consumption`) only needed the MPAN/Serial. This resulted in redundant network calls.

**Action:** Added an `include_gsp` parameter to `get_meter_details` (defaulting to `TRUE` for compatibility) and used `include_gsp = FALSE` in `get_consumption` and the default argument of `get_meter_gsp`. This avoids unnecessary API calls and provides a significant speedup in those paths.
