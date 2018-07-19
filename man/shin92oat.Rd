\name{shin92oat}
\alias{shin92oat}
\title{
  
  Ordinal adequacy test for simulations of shin92 CIRP

 }
 
\description{

  Tests whether a model output passes the ordinal adequacy criterion for
  the \code{\link{shin92}} CIRP.
  
}

\usage{

  shin92oat(dta, xtdo=FALSE)

}

\arguments{
  
  \item{dta}{Matrix containing model output. The matrix must have the
  same format, row order, and column names, as that returned by
  \code{shin92exalcove}; with that proviso, the output of any simulation
  implementation can be handled by this function.}

  \item{xtdo}{eXTenDed Output: Either \code{TRUE} or \code{FALSE}}
  
}  
  
\value{
  
Where \code{xtdo=FALSE}, this function returns TRUE if the ordinal
adequacy test is passed, and FALSE otherwise.

Where \code{xtdo=TRUE}, this function returns a summary matrix. The rows
are the two category sizes, the columns are the three principal stimulus
types (old, prototype, new), and the values are predicted accuracy
scores.

}

\details{

This function implements the Wills et al. (2017) ordinal adequacy
test for the \code{\link{shin92}} CIRP. Specifically, a model passes
this test if response accuracy is higher for novel items from the
size-10 condition than novel items from the size-3 condition.

Alternatively, by setting \code{xtdo} to \code{TRUE}, this function
returns the summary model predictions reported by Wills et al. (2017). 

}

\author{
  
  Andy Wills and Garret O'Connell
  
}
\references{

  Shin, H.J. &  Nosofsky, R.M. (1992). Similarity-scaling studies of
  dot-pattern classification and recognition. \emph{Journal
    of Experimental Psychology: General, 121}, 278--304.

  Wills, A.J., O'Connell, G., Edmunds, C.E.R. & Inkster, A.B. (2017).
  Progress in modeling through distributed collaboration: Concepts,
  tools, and category-learning examples. \emph{The Psychology of
  Learning and Motivation, 66}, 79-115.
  
}

\seealso{

\code{\link{shin92}}

}

