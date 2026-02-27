## 2024-05-22 - Optimize meter details and consumption merging

**Learning:** Replacing `ifelse(is.na(x), 0, x)` with logical indexing `x[is.na(x)] <- 0` provided a ~3x speedup and ~3x reduction in memory allocation for large vectors (n=1e5). Additionally, using an `include_gsp` flag in internal metadata fetchers like `get_meter_details()` eliminates redundant API calls when the extra data isn't needed, and prevents potential circular dependencies in default arguments.

**Action:** Always prefer logical indexing over `ifelse()` for vector-wide replacements. Implement optional flags in internal utility functions to skip expensive or redundant sub-operations in performance-critical paths.
