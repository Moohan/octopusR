
<!-- README.md is generated from README.Rmd. Please edit that file -->

# octopusR

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN
status](https://www.r-pkg.org/badges/version/octopusR)](https://CRAN.R-project.org/package=octopusR)
[![R-CMD-check](https://github.com/Moohan/octopusR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Moohan/octopusR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Moohan/octopusR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Moohan/octopusR?branch=main)
[![pkgcheck](https://github.com/Moohan/octopusR/workflows/pkgcheck/badge.svg)](https://github.com/Moohan/octopusR/actions?query=workflow%3Apkgcheck)
[![OpenSSF
Scorecard](https://api.scorecard.dev/projects/github.com/Moohan/octopusR/badge)](https://scorecard.dev/viewer/?uri=github.com/Moohan/octopusR)
[![OpenSSF Best
Practices](https://www.bestpractices.dev/projects/10198/badge)](https://www.bestpractices.dev/projects/10198)
<!-- badges: end -->

octopusR is an R package that provides access to the [Octopus Energy
REST API](https://developer.octopus.energy/rest). With octopusR, you can
easily retrieve data from the Octopus Energy API and use it in your R
projects, or Shiny dashboards.

If you find this package useful, why not [sponsor me on
GitHub](https://github.com/sponsors/Moohan) or sign up for an Octopus
Energy account with [my referral code
(jolly-bloom-201)](https://share.octopus.energy/jolly-bloom-201)!

## Installation

octopusR can be installed from CRAN.

``` r
install.packages("octopusR")
```

If you would like the development version, it can be installed from
GitHub, using the `{remotes}` package:

``` r
# Install remotes if needed
if (!require("remotes")) install.packages("remotes")
remotes::install_github("moohan/octopusR")
```

## Usage

To use most functions in octopusR, you will need an API key from Octopus
Energy, you can find this on the [developer
dashboard](https://octopus.energy/dashboard/developer/). Once you have
your API key, you can use `set_api_key()` to interactively input and
store the API key for the session:

``` r
library(octopusR)

# Set your API key
set_api_key()
```

Once you have authenticated with the API, you may also want to set your
electric and/or gas meter details.

``` r
# Set details for your electricity meter
set_meter_details(meter_type = "electricity")

# Set details for your gas meter
set_meter_details(meter_type = "gas")
```

You can use the other functions in the package to interact with the API.
For example, you can use the `get_consumption()` function to retrieve
data about your energy usage:

``` r
# Get data about your energy usage
energy_usage <- get_consumption(meter_type = "elec")
#> ℹ Returning 100 rows only as a date range wasn't provided.
#> ✔ Specify a date range with `period_to` and `period_from`.

# View the data
head(energy_usage)
#> # A tibble: 0 × 0
```

For more information and examples, see the [package
documentation](https://moohan.github.io/octopusR/) and the [Octopus
Energy API documentation](https://developer.octopus.energy/docs/api/).

## Contributing

If you have suggestions for improving octopusR, or if you have found a
bug, please [open an issue](https://github.com/Moohan/octopusR/issues).
Contributions in the form of pull requests are also welcome. See the
[guide to
contributing](https://moohan.github.io/octopusR/CONTRIBUTING.html) for
more details.

### Code of Conduct

Please note that the octopusR project is released with a [Contributor
Code of
Conduct](https://moohan.github.io/octopusR/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## License

octopusR is licensed under the MIT License. See LICENSE for more
information.
