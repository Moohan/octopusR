## 2025-05-14 - Redundant API calls via ifelse()

**Learning:** The `ifelse()` function evaluates both branches when the test is not a simple scalar, and even with scalars in older R versions or complex expressions. In `get_meter_details()`, using `ifelse()` to conditionally call `get_meter_gsp()` resulted in redundant network calls for electricity meters and unnecessary execution for gas meters. Additionally, `get_meter_gsp()`'s default argument triggered a circular dependency that was masked but not avoided.

**Action:** Use explicit `if/else` blocks for scalar control flow that involves expensive operations like API calls. For vector operations, replace `ifelse()` with logical indexing (e.g., `x[is.na(x)] <- 0`) which is ~4x faster and more memory-efficient.
