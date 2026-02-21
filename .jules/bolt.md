## 2026-02-21 - [Pagination Optimization] **Learning:** Reusing a base httr2_request object and using resps_successes() significantly reduces memory allocation and execution time for multi-page API requests. **Action:** Apply this pattern to all paginated API endpoints.

## 2026-02-21 - [Robust Decryption] **Learning:** httr2::secret_decrypt returns garbage if the key is wrong, which can crash downstream path construction. **Action:** Always sanitize decryption results with ASCII and regex checks.

## 2026-02-21 - [Grid Supply Point Optimization] **Learning:** Functions requiring meter metadata use include_gsp=FALSE to skip redundant secondary API calls, giving a significant speedup when GSP info is not needed. **Action:** Use optional flags for secondary data lookups.
