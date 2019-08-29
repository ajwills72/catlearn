\name{convertSUSTAIN}
\alias{convertSUSTAIN}
\title{
    Convert non-binary nominal input representation into a padded
    slpSUSTAIN-compatible format
}

\description{
    A simple function that changes a non-binary nominal representation
    (e.g. 312) into a padded representation (e.g. 0011001) for slpSUSTAIN.
}

\usage{convertSUSTAIN(input, dims)}
\arguments{

    \item{input}{A matrix containing the non-binary nominal input
        representation. Each row is a trial and each column is a
        stimulus' dimension.}
    \item{dims}{A vector of the number of nominal values for each dimension.
        If there are three dimensions with three, one and two possible values,
        than dims = c(3, 1, 2).}
}

\details{This function performs a simple data transformation. When the trial
    types are represented by numbers in a non-binary format,
    \code{convertSUSTAIN} translates it into a binary and padded
    representation, which is compatible with the model.}
\value{Returns a matrix containing the padded input representation.}
\author{
    Lenard Dome
}
\seealso{\link{\code{slpSUSTAIN}}}

\examples{

## Create a dummy training matrix with two dimensions. The first
## two dimensions have two possible nominal values, while the
## third and fourth have three possible nominal values.

dummy <- cbind(matrix(sample(1:2, 100, replace=T), ncol = 2),
               matrix(sample(1:3, 100, replace=T), ncol = 2))

## Specify the number of nominal spaces for each dimension
dims <- c(2, 2, 3, 3)

## Convert the input representation into a binary padded representation
convertSUSTAIN(dummy, dims)

}
