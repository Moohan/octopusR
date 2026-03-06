## 2025-05-14 - [Optimization] Replace ifelse() with logical indexing for NA handling
**Learning:** In R, `ifelse()` evaluates all branches for vector inputs, leading to unnecessary computation and memory allocation. Logical indexing (`x[is.na(x)] <- 0`) modifies the vector in-place (or with minimal copying) and is significantly faster (~4.4x in this case) and more memory-efficient (~3.5x reduction).
**Action:** Always prefer logical indexing or `replace()` over `ifelse()` when performing simple value replacements in vectors, especially in "hot" paths like data processing/merging.
