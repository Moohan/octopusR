# Combine import and export consumption data

Combine consumption data from import and export meters into a single
tibble with separate columns for import and export consumption. This is
useful for users with solar panels or other export generation.

## Usage

``` r
combine_consumption(
  import_mpan = NULL,
  import_serial = NULL,
  export_mpan = NULL,
  export_serial = NULL,
  api_key = get_api_key(),
  period_from = NULL,
  period_to = NULL,
  tz = NULL,
  order_by = c("-period", "period"),
  group_by = c("hour", "day", "week", "month", "quarter")
)
```

## Arguments

- import_mpan:

  The import meter MPAN

- import_serial:

  The import meter serial number

- export_mpan:

  The export meter MPAN

- export_serial:

  The export meter serial number

- api_key:

  API key for authentication

- period_from:

  Show consumption from the given datetime (inclusive)

- period_to:

  Show consumption to the given datetime (exclusive)

- tz:

  Time zone for date parsing (requires lubridate)

- order_by:

  Ordering of results returned

- group_by:

  Aggregates consumption over a specified time period

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
with import_consumption, export_consumption, and net_consumption columns
