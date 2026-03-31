## 2025-05-22 - Optimized GSP lookup and consumption combining

**Learning:** R's `ifelse()` function is eager and evaluates all arguments, even for scalar conditions. This can lead to redundant and potentially error-prone API calls if an expensive function is passed as an argument. Additionally, logical indexing is significantly faster (~4.5x) than `ifelse()` for handling NAs in large vectors.

**Action:** Always use standard `if/else` for scalar logic involving side effects or expensive calls. Use logical indexing (`x[is.na(x)] <- 0`) instead of `ifelse(is.na(x), 0, x)` in performance-critical data paths.
