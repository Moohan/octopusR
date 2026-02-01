# Bolt's Journal - Critical Learnings

## 2026-02-01 - Redundant API calls in internal helper functions

**Learning:** Internal helper functions like `get_meter_details` can become performance bottlenecks if they perform expensive operations (like API calls for GSP lookups) that are not always needed by the caller. Default arguments in exported functions that call these helpers can also lead to multiple redundant calls if they are not carefully designed.

**Action:** Add optional parameters (e.g., `include_gsp = TRUE`) to internal helper functions to allow callers to skip expensive but unnecessary operations. Use `NULL` as default for arguments in exported functions and handle the single call to the helper inside the function body to avoid redundant evaluations of default arguments.

## 2026-02-01 - Inefficient `ifelse` for scalar logic

**Learning:** R's `ifelse` is designed for vectors. When used for scalar logic, it can be slightly less efficient and might lead to unexpected evaluation of arguments depending on the implementation.

**Action:** Always prefer standard `if...else` blocks for scalar logic to improve clarity and performance.
