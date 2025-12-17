# Set the Octopus API key

Set the Octopus API key to use. This will be stored as an environment
variable. You should add `OCTOPUSR_API_KEY = <api_key>` to your
`.Renviron` otherwise you will have to call this function every session.

## Usage

``` r
set_api_key(api_key = NULL)
```

## Arguments

- api_key:

  Your API key. If you are an Octopus Energy customer, you can generate
  an API key on the [developer
  dashboard](https://octopus.energy/dashboard/developer/).

## Value

No return value, called for side effects.
