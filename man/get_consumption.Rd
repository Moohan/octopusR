% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_consumption.R
\name{get_consumption}
\alias{get_consumption}
\title{List consumption for a meter}
\usage{
get_consumption(
  meter_type = c("electricity", "gas"),
  mpan_mprn = get_meter_details(meter_type)[["mpan_mprn"]],
  serial_number = get_meter_details(meter_type)[["serial_number"]],
  api_key = get_api_key(),
  period_from = NULL,
  period_to = NULL,
  tz = NULL,
  order_by = c("-period", "period"),
  group_by = c("hour", "day", "week", "month", "quarter")
)
}
\arguments{
\item{meter_type}{Type of meter-point, electricity or gas}

\item{mpan_mprn}{The electricity meter-point's MPAN or gas meter-point’s
MPRN.}

\item{serial_number}{The meter's serial number.}

\item{api_key}{Your API key. If you are an Octopus Energy customer,
you can generate an API key on the
\href{https://octopus.energy/dashboard/developer/}{developer dashboard}.}

\item{period_from}{Show consumption from the given datetime (inclusive).
This parameter can be provided on its own.}

\item{period_to}{Show consumption to the given datetime (exclusive).
This parameter also requires providing the \code{period_from} parameter
to create a range.}

\item{tz}{a character string that specifies which time zone to parse the date with. The string
must be a time zone that is recognized by the user's OS.}

\item{order_by}{Ordering of results returned. Default is that results are
returned in reverse order from latest available figure.
Valid values:
\itemize{
\item \code{period}, to give results ordered forward.
\item \code{-period}, (default), to give results ordered from most recent backwards.
}}

\item{group_by}{Aggregates consumption over a specified time period.
A day is considered to start and end at midnight in the server's time zone.
The default is that consumption is returned in half-hour periods.
Accepted values are:
\itemize{
\item \code{hour}
\item \code{day}
\item \code{week}
\item \code{month}
\item \code{quarter}
}}
}
\value{
a \link[tibble:tibble-package]{tibble} of the requested consumption data.
}
\description{
Return a list of consumption values for half-hour periods for a
given meter-point and meter.

Unit of measurement:
\itemize{
\item Electricity meters: kWh
\item SMETS1 Secure gas meters: kWh
\item SMETS2 gas meters: m^3
}
\subsection{Parsing dates}{

To return dates properly parsed \link[lubridate:lubridate-package]{lubridate} is
required. Use the \code{tz} parameter to specify a time zone e.g. \code{tz = "UTC"},
the default (\code{tz = NULL}) will return the dates unparsed, as characters.
}
}
