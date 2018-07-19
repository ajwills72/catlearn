\name{shin92exalcove_opt}
\alias{shin92exalcove_opt}
\title{
  
  Parameter optimization of ex-ALCOVE model with shin92 CIRP
  
}
\description{
  
  Uses \code{\link{shin92exalcove}} to find best-fitting parameters for
  the ex-ALCOVE model for the \code{\link{shin92}} CIRP.
  
}
\usage{

  shin92exalcove_opt(params = c(2, 1, 0.25, 0.75), recompute = FALSE,
  trace = 0)

}
\arguments{
  
  \item{params}{A vector containing the initial values for c, phi, la,
  and lw, in that order. See \code{\link{slpALCOVE}} for an explanation
  of these parameters. Where \code{recompute} is FALSE, this argument
  has no effect.}

  \item{recompute}{When set to TRUE, the function re-runs the
  optimization (which takes about 25 minutes on a 2.4 GHz
  processor). When set to FALSE, the function returns a stored copy of
  the results of the optimization (which is instantaneous).}

  \item{trace}{Sets the level of tracing information (i.e. information
  about the progress of the optimization), as defined by the
  \code{\link{optim}} function. Set to 6 for maximally verbose
  output. Where \code{recompute} is FALSE, this argument has no effect.}

}   
\value{

  A vector containing the best-fitting values for c, phi, la,
  and lw, in that order. See \code{\link{slpALCOVE}} for an explanation
  of these parameters.
  
}
\details{

  This function is an archive of the optimization procedure used to
  derive the best-fitting parameters for the \code{\link{shin92exalcove}}
  simulation; see Spicer et al. (2017) for a tutorial introduction to
  the concept of simulation archives.

  Optimization used the L-BFGS-B method from the \code{\link{optim}}
  function of the standard R \code{stats} package. The objective
  function was sum of squared errors. Please inspect the source code for
  further details (e.g. type \code{shin92exalcove_opt}). 

  This function was run in 16 times from different starting points,
  using 8 threads on a Core i7 3.6 GHz processor. The default
  parameters of this function are those for the best fit from those 16
  starting points. The 16 starting points were

  \code{
    pset <- rbind(
      c(2,1,.25,.25),c(2,1,.25,.75),c(2,1,.75,.25),c(2,1,.75,.75),
      c(2,3,.25,.25),c(2,3,.25,.05),c(2,3,.75,.25),c(2,3,.75,.75),
      c(8,1,.25,.25),c(8,1,.25,.75),c(8,1,.75,.25),c(8,1,.75,.75),
      c(8,3,.25,.25),c(8,3,.25,.75),c(8,3,.75,.25),c(8,3,.75,.75)
    )
  }

  not all of which converged successfully.

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



