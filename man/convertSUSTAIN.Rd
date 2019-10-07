\name{convertSUSTAIN}
\alias{convertSUSTAIN}
\title{
    Convert nominal-dimension input representation into a 'padded' 
    (slpSUSTAIN) format
}

\description{
  
    Changes a nominal-dimension input representation (e.g. 3 1 2) into a
    padded representation (e.g. 001 100 010). This form out input
    representation is required by e.g. \code{slpSUSTAIN}.
    
}

\usage{convertSUSTAIN(input, dims)}

\arguments{

    \item{input}{A matrix containing the nominal-dimension input
    representation. Each row is a trial and each column is a stimulus
    dimension.}
      
    \item{dims}{A vector of the number of nominal values for each
     dimension.  For example, if there are three dimensions with three,
     one and two possible values, then \code{dims = c(3, 1, 2)}.}  }

\value{Returns a matrix containing the padded input representation.}

\author{
    Lenard Dome, Andy Wills
  }
  
  \seealso{

    \code{\link{slpSUSTAIN}}
  }

\examples{

## Create a dummy training matrix with two dimensions. The first
## two dimensions have two possible nominal values, while the
## third and fourth have three possible nominal values.

dummy <- cbind(matrix(sample(1:2, 20, replace=TRUE), ncol = 2),
               matrix(sample(1:3, 20, replace=TRUE), ncol = 2))

## Specify the number of nominal spaces for each dimension
dims <- c(2, 2, 3, 3)

## Convert the input representation into a binary padded representation
convertSUSTAIN(dummy, dims)

}
