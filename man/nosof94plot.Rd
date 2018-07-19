\name{nosof94plot}
\alias{nosof94plot}
\title{
  
Plot Nosofsky et al. (1994) data / simulations

}
\description{
  
  Produce a line graph similar to that shown in Nosofsky et al. (1994,
  Figures 1, 6-9).
  
}
\usage{

nosof94plot(results,title = 'Nosofsky et al. (1994)')

}
\arguments{
  
  \item{results}{Mean error probability by block and problem, in the same format 
    as data set \code{nosof94}}
  
  \item{title}{Title to appear at top of plot}
  
}  
\author{
  Andy Wills
}
\references{
  
  Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352--369.
  
}
\examples{
  data(nosof94)
  nosof94plot(nosof94)
}
