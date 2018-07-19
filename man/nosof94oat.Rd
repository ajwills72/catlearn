\name{nosof94oat}
\alias{nosof94oat}
\title{
  
  Ordinal adequacy test for simulations of nosof94 CIRP

 }
 
\description{

  Tests whether a model output passes the ordinal adequacy criteria for
  the \code{\link{nosof94}} CIRP.
  
}

\usage{

  nosof94oat(dta, xtdo=FALSE)

}

\arguments{
  
  \item{dta}{Matrix containing model output. The matrix must have the
  same format, row order, and column names, as \code{data(nosof94)};
  with that proviso, the output of any simulation implementation can be
  handled by this function.}

  \item{xtdo}{eXTenDed Output: Either \code{TRUE} or \code{FALSE}}
  
}  
  
\value{
  
Where \code{xtdo=FALSE}, this function returns TRUE if the ordinal
adequacy tests are passed, and FALSE otherwise.

Where \code{xtdo=TRUE}, this function returns a summary matrix,
containing mean errors (across blocks) for each of the six problem
types.

}

\details{

  This function implements a standard ordinal adequacy test for the
  \code{\link{nosof94}} CIRP. Specifically, a model passes this test if
  the mean errors (averaged across blocks), obey the following:

  I < II < [III, IV, V] < VI

  Note that '[III, IV, V]' indicates that the these three problems can
  be in any order of difficulty (or all be of equal difficulty), as long
  as all three are harder than Problem 2 and all three are easier than
  Problem 6.   

  Alternatively, by setting \code{xtdo} to \code{TRUE}, this function
  returns the mean classification error by Problem type.

}

\author{
  
  Andy Wills 
  
}

\seealso{

  \code{\link{nosof94}}    

}
