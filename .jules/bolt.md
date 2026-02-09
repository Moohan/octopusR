## 2025-05-22 - [Optimizing redundant API calls in metadata retrieval]
**Learning:** Functions that retrieve meter metadata as a precursor to other operations (like `get_consumption`) often don't need all the metadata fields. Specifically, the Grid Supply Point (GSP) lookup is a separate API call that adds significant latency.
**Action:** Implement an `include_gsp` flag in metadata retrieval functions to allow skipping the expensive GSP lookup when not needed. This resulted in a ~400x speedup for the `get_meter_details` call in the consumption path.
