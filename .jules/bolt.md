## 2025-05-14 - [GSP Optimization]
**Learning:** Redundant API calls were being made in `get_consumption` and `get_meter_gsp` due to `get_meter_details` always fetching Grid Supply Point (GSP) data, even when not needed. Additionally, default argument evaluation in `get_meter_gsp` caused a double API call to the same endpoint.
**Action:** Implement `include_gsp` parameter in `get_meter_details` and use `if/else` instead of `ifelse` to ensure lazy evaluation. Update `get_meter_gsp` to avoid redundant calls.
