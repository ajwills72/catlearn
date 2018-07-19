\name{nosof88exalcove_opt}
\alias{nosof88exalcove_opt}
\title{
  
  Parameter optimization of ex-ALCOVE model with nosof88 CIRP
  
}
\description{
  
  Uses \code{\link{nosof88exalcove}} to find best-fitting parameters for
  the ex-ALCOVE model for the \code{\link{nosof88}} CIRP.
  
}
\usage{

  nosof88exalcove_opt(recompute = FALSE)

}
\arguments{
  
  \item{recompute}{When set to TRUE, the function re-runs the
    optimization. When set to FALSE, the function returns a stored copy
    of the results of the optimization.}

}   
\value{

  A vector containing the best-fitting values for c, phi, la, and lw, in
  that order. See \code{\link{slpALCOVE}} for an explanation of these
  parameters.
  
}
\details{

  This function is an archive of the optimization procedure used to
  derive the best-fitting parameters for the \code{\link{nosof88exalcove}}
  simulation; see Spicer et al. (2017) for a tutorial introduction to
  the concept of simulation archives.

  Optimization used the L-BFGS-B method from the \code{\link{optim}}
  function of the standard R \code{stats} package. The objective
  function was sum of squared errors. Please inspect the source code for
  further details (e.g. type \code{nosof88exalcove_opt}). The
  optimization was repeated for 16 different sets of starting values.

  Where \code{recompute = TRUE}, the function can take many hours to
  run, depending on your system, and there is no progress bar. You can
  use Task Manager (Windows) or equivalent if you want some kind of
  visual feedback that the code is working hard. The code uses all the
  processor cores on the local machine, so speed of execution is a
  simple function of clock speed times processor cores. So, for example,
  a 4 GHz i7 processor (8 virutal cores) will take a quarter of the time
  to run this compared to a 2 GHz i5 processor (4 virtual cores).
  
}

\author{
  
  Andy Wills
  
}

\references{

Spicer, S., Jones, P.M., Inkster, A.B., Edmunds, C.E.R. & Wills,
A.J. (2017). Progress in learning theory through distributed
collaboration: Concepts, tools, and examples. \emph{Manuscript in
preparation}.

  
}



