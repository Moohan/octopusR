# Set the details for your gas/electricity meter

Set the details for your gas/electricity meter. These will be stored as
environment variables. You should add:

- `OCTOPUSR_MPAN = <electric MPAN>`

- `OCTOPUSR_MPRN = <gas MPRN>`

- `OCTOPUSR_ELEC_SERIAL_NUM = <electric serial number>`

- `OCTOPUSR_GAS_SERIAL_NUM = <gas serial number>` to your `.Renviron`
  otherwise you will have to call this function every session. You can
  find your meter details (MPAN/MPRN and serial number(s)) on the
  [developer dashboard](https://octopus.energy/dashboard/developer/).

## Usage

``` r
set_meter_details(
  meter_type = c("electricity", "gas"),
  mpan_mprn = NULL,
  serial_number = NULL
)
```

## Arguments

- meter_type:

  Type of meter-point, electricity or gas

- mpan_mprn:

  The electricity meter-point's MPAN or gas meter-point’s MPRN.

- serial_number:

  The meter's serial number.

## Value

No return value, called for side effects.
