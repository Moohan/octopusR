# Set the details for your gas/electricity meter

Set the details for your gas/electricity meter. These will be stored as
environment variables. You should add:

- `OCTOPUSR_MPAN = <electric MPAN>` (or
  `OCTOPUSR_MPAN_IMPORT`/`OCTOPUSR_MPAN_EXPORT`)

- `OCTOPUSR_MPRN = <gas MPRN>`

- `OCTOPUSR_ELEC_SERIAL_NUM = <electric serial number>` (or
  `OCTOPUSR_ELEC_SERIAL_NUM_IMPORT`/`OCTOPUSR_ELEC_SERIAL_NUM_EXPORT`)

- `OCTOPUSR_GAS_SERIAL_NUM = <gas serial number>` to your `.Renviron`
  otherwise you will have to call this function every session. You can
  find your meter details (MPAN/MPRN and serial number(s)) on the
  [developer dashboard](https://octopus.energy/dashboard/developer/).

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
