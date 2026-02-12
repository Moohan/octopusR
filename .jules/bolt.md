## 2025-05-14 - [Redundant API Calls in Metadata Retrieval] **Learning:** Redundant API calls (e.g., GSP lookup when only consumption is needed) are a significant bottleneck, especially with network latency. **Action:** Use flags like `include_gsp` to toggle optional metadata retrieval in core helper functions.

## 2025-05-14 - [Vectorized NA Replacement] **Learning:** `ifelse(is.na(x), 0, x)` is significantly slower (~2.6x) and more memory-intensive (~3.4x) than logical indexing `x[is.na(x)] <- 0` for large vectors. **Action:** Prefer logical indexing for simple NA replacement in hot paths.
