\name{nosof88oat}
\alias{nosof88oat}
\title{
  
  Ordinal adequacy test for simulations of nosof88 CIRP

 }
 
\description{

  Tests whether a model output passes the ordinal adequacy criteria for
  the \code{\link{nosof88}} CIRP.
  
}

\usage{

  nosof88oat(dta, xtdo=FALSE)

}

\arguments{
  
  \item{dta}{Matrix containing model output. The matrix must have the
  same format, row order, and column names, as \code{data(nosof88)};
  with that proviso, the output of any simulation implementation can be
  handled by this function.}

  \item{xtdo}{eXTenDed Output: Either \code{TRUE} or \code{FALSE}}
  
}  
  
\value{
  
Where \code{xtdo=FALSE}, this function returns TRUE if the ordinal
adequacy tests are passed, and FALSE otherwise.

Where \code{xtdo=TRUE}, this function returns a summary matrix. The
columns are stimulus numbers. The rows ('B','E') indicate the baseline
(equal frequency) condition ('B') and the experimental conditions ('E2'
or 'E7', depending on the column).

}

\details{

This function implements the Wills & O'Connell (n.d.) ordinal adequacy
tests for the \code{\link{nosof88}} CIRP. Specifically, a model passes
this test if it passes all four component tests: 1. E2(2) > B(2), 2.
E7(7) > B(7), 3. E2(4) > B(4), 4. E7(9) > B(9). These tests refer to
classification accuracy for particular stimuli in particular
experimental conditions. For example, E7(9) indicates stimulus 9 in
experimental condition E7. 

Alternatively, by setting \code{xtdo} to \code{TRUE}, this function
returns the summary model predictions reported by Wills & O'Connell
(2016).

}

\author{
  
  Andy Wills and Garret O'Connell
  
}
\references{

   Wills, A.J. & O'Connell (n.d.). Averaging
 abstractions. \emph{Manuscript in preparation}.
  
}

\seealso{

  \code{\link{nosof88}}    

}
