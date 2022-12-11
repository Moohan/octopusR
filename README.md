
<!-- README.md is generated from README.Rmd. Please edit that file -->

# octopusR

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![CRAN
status](https://www.r-pkg.org/badges/version/a11ytables)](https://CRAN.R-project.org/package=octopusR)
[![R-CMD-check](https://github.com/Moohan/octopusR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Moohan/octopusR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Moohan/octopusR/branch/master/graph/badge.svg)](https://codecov.io/gh/Moohan/octopusR?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

octopusR is an R package that provides access to the [Octopus Energy
API](https://developer.octopus.energy/docs/api/). With octopusR, you can
easily retrieve data from the Octopus Energy API and use it in your R
projects.

## Installation

octopusR is not yet available on CRAN, so must be installed from GitHub,
to install, you can use the `devtools` package:

``` r
# Install devtools if needed
if (!require("devtools")) install.packages("devtools")
devtools::install_github("moohan/octopusR")
```

## Usage

To use most function in octopusR, you will need an API key from Octopus
Energy, you can find this on the [developer
dashboard](https://octopus.energy/dashboard/developer/). Once you have
your API key, you can use the `set_api_key()` function to interactively
input and store the API key for the session:

``` r
library(octopusR)

# Set your API key
set_api_key()
```

Once you have authenticated with the API, you may also want to set your
meter-point details.

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
energy_usage <- get_consumption(meter_type = "electricity")

# View the data
head(energy_usage)
```

For more information and examples, see the [package
documentation](https://moohan.github.io/octopusR/) and the [Octopus
Energy API documentation](https://developer.octopus.energy/docs/api/).

## Contributing

If you have suggestions for improving octopusR, or if you have found a
bug, please open an issue on GitHub. Contributions in the form of pull
requests are also welcome.

## License

octopusR is licensed under the MIT License. See LICENSE for more
information.
