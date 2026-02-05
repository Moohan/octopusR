# Bolt's Journal ⚡

## 2024-05-23 - [API Request Optimization]
**Learning:** Redundant network requests for Grid Supply Point (GSP) data in `get_consumption` significantly slow down data retrieval. Also, `httr2_request` objects are expensive to recreate in loops.
**Action:** Add `include_gsp` flag to skip redundant calls and reuse base `httr2_request` objects in pagination loops.

## 2024-05-23 - [Vectorization vs ifelse]
**Learning:** `ifelse()` is a vectorized but slow generic; for large datasets (like consumption records), logical indexing `x[is.na(x)] <- 0` is significantly faster and more memory-efficient.
**Action:** Replace `ifelse()` with logical indexing in hot paths like `combine_consumption`.

## 2024-05-23 - [CI Robustness]
**Learning:** CI environments often lack secret keys, causing decryption failures that manifest as cryptic 'wide string translation' errors when building URLs.
**Action:** Use `tryCatch` and string sanitization (`iconv`, `gsub`) in testing helpers to provide safe fallbacks. Use `req_auth_basic` instead of embedding keys in URLs.
