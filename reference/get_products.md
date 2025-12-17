# Return a list of energy products

By default, results will be public energy products but if authenticated
organisations will also see products available to their organisation.

## Usage

``` r
get_products(
  is_variable = NULL,
  is_green = NULL,
  is_tracker = NULL,
  is_prepay = NULL,
  is_business = FALSE,
  available_at = Sys.Date(),
  authenticate = FALSE,
  api_key = NULL
)
```

## Arguments

- is_variable:

  (boolean, optional) Show only variable products.

- is_green:

  (boolean, optional) Show only green products.

- is_tracker:

  (boolean, optional) Show only tracker products.

- is_prepay:

  (boolean, optional) Show only pre-pay products.

- is_business:

  (boolean, default: FALSE) Show only business products.

- available_at:

  Show products available for new agreements on the given datetime.
  Defaults to current datetime, effectively showing products that are
  currently available.

- authenticate:

  (boolean, default: FALSE) Use an `api_key` to authenticate. Only
  useful for organisations.

- api_key:

  Your API key. If you are an Octopus Energy customer, you can generate
  an API key on the [developer
  dashboard](https://octopus.energy/dashboard/developer/).

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
get_products(is_green = TRUE)
#> # A tibble: 10 × 16
#>    code        direction full_name display_name description is_variable is_green
#>    <chr>       <chr>     <chr>     <chr>        <chr>       <lgl>       <lgl>   
#>  1 AGILE-24-1… IMPORT    Agile Oc… Agile Octop… With Agile… TRUE        TRUE    
#>  2 AGILE-OUTG… EXPORT    Agile Ou… Agile Outgo… Outgoing O… TRUE        TRUE    
#>  3 COOP-SEG-E… EXPORT    Co-op Sm… Co-op Smart… This is ou… FALSE       TRUE    
#>  4 COOP-SEG-F… EXPORT    Co-op Sm… Co-op Smart… This is ou… FALSE       TRUE    
#>  5 CP-12M-25-… IMPORT    Co-op Co… Co-op Commu… This fixed… FALSE       TRUE    
#>  6 LP-SEG-EO-… EXPORT    my londo… my london s… This is ou… FALSE       TRUE    
#>  7 LP-SEG-FIX… EXPORT    my londo… my london s… This is ou… FALSE       TRUE    
#>  8 OUTGOING-S… EXPORT    Octopus … Octopus Out… Outgoing S… FALSE       TRUE    
#>  9 OUTGOING-S… EXPORT    Octopus … Octopus Out… Outgoing S… FALSE       TRUE    
#> 10 OUTGOING-V… EXPORT    Outgoing… Outgoing Oc… Outgoing O… TRUE        TRUE    
#> # ℹ 9 more variables: is_tracker <lgl>, is_prepay <lgl>, is_business <lgl>,
#> #   is_restricted <lgl>, term <int>, available_from <chr>, available_to <lgl>,
#> #   links <list>, brand <chr>
```
