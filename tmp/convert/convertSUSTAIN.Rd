\name{convertSUSTAIN}
\alias{convertSUSTAIN}
\title{
    Convert non-binary nominal input representation into a padded
    slpSUSTAIN-compatible format
}

\description{
    A simple function that changes a non-binary nominal input representation
    (e.g. 322) into a padded representation (e.g. 0010101) for slpSUSTAIN.
}

\usage{convertSUSTAIN(input, dims)}
\arguments{
    \item{input}{A matrix containing the non-binary nominal input 
        representation. Each row is a trial and columns are
        stimulus dimensions.}
    \item{dims}{A vector of the number of nominal values for each dimension.
    If there are three dimension with three, one and two possible values, 
    than dims = c(3, 1, 2).}
}

\details{This function performs a simple data transformation.}
\value{Returns a matrix containing the padded input representation.}
\author{
    Lenard Dome
}
\seealso{\link{\code{slpSUSTAIN}}}
