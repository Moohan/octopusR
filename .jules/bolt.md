## 2025-05-22 - Optimized NA replacement and reduced redundant GSP lookups

**Learning:** Vectorized NA replacement using logical indexing `x[is.na(x)] <- 0` is significantly faster (~6x) and more memory-efficient than `ifelse(is.na(x), 0, x)` for large vectors. Additionally, adding an `include_gsp` flag to internal meter detail retrieval avoids redundant API calls in common workflows like consumption retrieval.

**Action:** Prefer logical indexing for vector NA replacement. Always consider if internal helper functions are performing redundant work (like API calls) that can be skipped via optional flags.
