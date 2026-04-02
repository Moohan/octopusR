## 2025-05-14 - Redundant GSP API calls in get_meter_details

**Learning:** The internal `get_meter_details()` function was automatically calling `get_meter_gsp()` for all electricity meters. However, `get_meter_gsp()` itself calls `get_meter_details()` to find the MPAN if not provided, creating a potential circularity or at least redundant work. Furthermore, functions like `get_consumption()` only need the MPAN and serial number, making the GSP API call entirely unnecessary in that hot path.

**Action:** Added an `include_gsp` parameter to `get_meter_details()` (defaulting to `TRUE` for backward compatibility) and set it to `FALSE` in `get_consumption()` and the default argument of `get_meter_gsp()`. This halved the number of API calls for these common operations.
