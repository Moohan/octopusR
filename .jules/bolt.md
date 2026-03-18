## 2025-05-15 - Redundant API Calls in Parameter Initialization

**Learning:** Initializing function parameters with defaults that call other internal functions (e.g., `get_meter_gsp` calling `get_meter_details`) can trigger unexpected redundant API calls if those internal functions also perform network requests. In `octopusR`, `get_meter_details` was fetching the GSP by default, leading to 2 API calls where 1 was sufficient.

**Action:** Use an `include_gsp = FALSE` flag in internal helper calls when the GSP is not strictly required for the immediate task (like MPAN retrieval), and prefer `NA_character_` over logical `NA` for type consistency in R data structures.
