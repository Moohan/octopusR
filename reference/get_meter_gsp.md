# Get the GSP of a meter-point.

This endpoint can be used to get the GSP of a given meter-point.

## Usage

``` r
get_meter_gsp(mpan = get_meter_details("electricity")[["mpan_mprn"]])
```

## Arguments

- mpan:

  The electricity meter-point's MPAN

## Value

a character of the meter-points GSP.
