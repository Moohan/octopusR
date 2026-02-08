## 2025-01-24 - Decryption Robustness and Redundant API calls

**Learning:** `httr2::secret_decrypt` returns garbage instead of erroring if the secret key is wrong but present. This garbage can lead to malformed URLs if used directly. Also, internal helper functions like `get_meter_details` often perform expensive secondary API calls (like `get_meter_gsp`) that aren't always needed by the caller.

**Action:**
1. Sanitize derived strings from `secret_decrypt` using `iconv(x, to = "ASCII", sub = "")` and regex validation.
2. Implement optional flags (e.g., `include_gsp`) in internal helpers to allow callers (like `get_consumption`) to skip redundant API calls.
3. Use `httr2::req_auth_basic` instead of embedding keys in URLs for better robustness and performance.
