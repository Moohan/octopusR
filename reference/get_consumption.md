# List consumption for a meter

Return a list of consumption values for half-hour periods for a given
meter-point and meter.

Unit of measurement:

- Electricity meters: kWh

- SMETS1 Secure gas meters: kWh

- SMETS2 gas meters: m^3

### Parsing dates

To return dates properly parsed
[lubridate](https://lubridate.tidyverse.org/reference/lubridate-package.html)
is required. Use the `tz` parameter to specify a time zone e.g.
`tz = "UTC"`, the default (`tz = NULL`) will return the dates unparsed,
as characters.

## Usage

``` r
get_consumption(
  meter_type = c("electricity", "gas"),
  mpan_mprn = get_meter_details(meter_type)[["mpan_mprn"]],
  serial_number = get_meter_details(meter_type)[["serial_number"]],
  api_key = get_api_key(),
  period_from = NULL,
  period_to = NULL,
  tz = NULL,
  order_by = c("-period", "period"),
  group_by = c("hour", "day", "week", "month", "quarter"),
  page_size = NULL
)
```

## Arguments

- meter_type:

  Type of meter-point, electricity or gas

- mpan_mprn:

  The electricity meter-point's MPAN or gas meter-point’s MPRN.

- serial_number:

  The meter's serial number.

- api_key:

  Your API key. If you are an Octopus Energy customer, you can generate
  an API key on the [developer
  dashboard](https://octopus.energy/dashboard/developer/).

- period_from:

  Show consumption from the given datetime (inclusive). This parameter
  can be provided on its own.

- period_to:

  Show consumption to the given datetime (exclusive). This parameter
  also requires providing the `period_from` parameter to create a range.

- tz:

  a character string that specifies which time zone to parse the date
  with. The string must be a time zone that is recognized by the user's
  OS.

- order_by:

  Ordering of results returned. Default is that results are returned in
  reverse order from latest available figure. Valid values:

  - `period`, to give results ordered forward.

  - `-period`, (default), to give results ordered from most recent
    backwards.

- group_by:

  Aggregates consumption over a specified time period. A day is
  considered to start and end at midnight in the server's time zone. The
  default is that consumption is returned in half-hour periods. Accepted
  values are:

  - `hour`

  - `day`

  - `week`

  - `month`

  - `quarter`

- page_size:

  The number of results to return per page. This is intended for
  internal testing and may be removed in a future release.

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
of the requested consumption data.
