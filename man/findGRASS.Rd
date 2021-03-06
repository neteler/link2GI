% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grass7Control.R
\name{findGRASS}
\alias{findGRASS}
\title{Search recursivly existing 'GRASS GIS' installation(s) at a given drive/mountpoint}
\usage{
findGRASS(searchLocation = "default", ver_select = FALSE,
  quiet = TRUE)
}
\arguments{
\item{searchLocation}{drive letter to be searched, for Windows systems default For Windows Systems it is mandatory to use Capitel letters with colon only
is \code{C:}, for Linux systems default is \code{/usr}.}

\item{ver_select}{boolean default is FALSE. If there is more than one 'SAGA GIS' installation and \code{ver_select} = TRUE the user can select interactively the preferred 'SAGA GIS' version}

\item{quiet}{boolean  switch for supressing console messages default is TRUE}
}
\value{
A dataframe with the 'GRASS GIS' root folder(s), version name(s) and 
installation type code(s)
}
\description{
Provides an  list of valid 'GRASS GIS' installation(s) 
on your 'Windows' system. There is a major difference between osgeo4W and 
stand_alone installations. The functions trys to find all valid 
installations by analysing the calling batch scripts.
}
\examples{
\dontrun{
# find recursively all existing 'GRASS GIS' installation folders starting 
# at the default search location
findGRASS()
}
}
\author{
Chris Reudenbach
}
