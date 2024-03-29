% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_products.R
\name{get_products}
\alias{get_products}
\title{Return a list of energy products}
\usage{
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
}
\arguments{
\item{is_variable}{(boolean, optional) Show only variable products.}

\item{is_green}{(boolean, optional) Show only green products.}

\item{is_tracker}{(boolean, optional) Show only tracker products.}

\item{is_prepay}{(boolean, optional) Show only pre-pay products.}

\item{is_business}{(boolean, default: FALSE) Show only business products.}

\item{available_at}{Show products available for new agreements on the given
datetime.
Defaults to current datetime, effectively showing products that are
currently available.}

\item{authenticate}{(boolean, default: FALSE) Use an \code{api_key} to
authenticate. Only useful for organisations.}

\item{api_key}{Your API key. If you are an Octopus Energy customer,
you can generate an API key on the
\href{https://octopus.energy/dashboard/developer/}{developer dashboard}.}
}
\value{
a \link[tibble:tibble-package]{tibble}
}
\description{
By default, results will be public energy products but if
authenticated organisations will also see products available to
their organisation.
}
\examples{
get_products(is_green = TRUE)
}
