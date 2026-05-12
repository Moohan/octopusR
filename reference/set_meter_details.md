# Set meter details

Store your meter details in environment variables for the session. To
find your meter details, check your \[Octopus Energy
dashboard\](https://octopus.energy/dashboard/developer/).

## Usage

``` r
set_meter_details(
  meter_type = c("electricity", "gas"),
  mpan_mprn = NULL,
  serial_number = NULL,
  direction = NULL
)
```

## Arguments

- meter_type:

  Type of meter-point, electricity or gas

- mpan_mprn:

  The electricity meter-point's MPAN or gas meter-point’s MPRN.

- serial_number:

  The meter's serial number.

- direction:

  For electricity meters, specify "import", "export", or NULL (default).
  When NULL, uses the legacy single MPAN storage. When specified, stores
  separate import/export MPANs.

## Value

No return value, called for side effects.
