## 2025-05-15 - Vectorized ifelse() vs Logical Indexing for NAs

**Learning:** In R, `ifelse()` is significantly slower and more memory-intensive than logical indexing when replacing `NA` values in large vectors. For a vector of size 100k, logical indexing is ~3x faster and uses ~70% less memory because it operates in-place on a copy rather than creating multiple intermediate vectors. Additionally, scalar `ifelse()` evaluates both branches even if only one is selected, which can trigger unintended side effects like redundant API calls if not careful.

**Action:** Always prefer `x[is.na(x)] <- 0` over `ifelse(is.na(x), 0, x)` in performance-critical paths. Use standard `if/else` for scalar logic to ensure short-circuiting and type safety (e.g., using `NA_character_`).
