\name{nosof94sustain}
\alias{nosof94sustain}
\title{
  
   Simulation of CIRP nosof94 with the SUSTAIN model

 }
 
\description{

  Runs a simulation of the \code{\link{nosof94}} CIRP using the
  \code{\link{slpSUSTAIN}} model implementation and
  \code{\link{nosof94train}} as the input representation.
  
}

\usage{

  nosof94sustain(params = c(9.01245, 1.252233, 16.924073, 0.092327))

}

\arguments{
  
  \item{params}{A vector containing values for r, beta, d, and eta, in
  that order, e.g. params = c(8.1, 1.5, 9.71, 0.8). See
  \code{\link{slpSUSTAIN}} for an explanation of these parameters.} 
  
}  
  
\value{
  
  A matrix of predicted response probabilities, in the same order and
  format as the observed data contained in \code{\link{nosof94}}.

}

\details{

 NOTE: In catlearn version 0.6, the underlying slpSUSTAIN function is
 written in R, and hence this simulation can take several minutes to
 run. A goal for version 0.7 is to re-write slpSUSTAIN in C++, which
 will reduce the run time of this simulation to a few seconds.

 A simulation using \code{\link{slpSUSTAIN}} and
 \code{\link{nosof94train}}, i.e. a simulation of Nosofsky et al. (1994)
 with the Love et al. (2004) SUTAIN model.

 Other parameters of slpSUSTAIN are set as follows: \code{tau} = 0,
 initial \code{lambda} = 1, initial \code{w} = 0, inital cluster
 centered on the first stimulus presented to the siumulated
 subject. These values are conventions of modeling with SUSTAIN, and
 should not be considered as free parameters. They are set within the
 \code{nosof94sustain} function, and hence can't be changed without
 re-writing the function.

 The simulation uses 100 simulated subjects. Like the simulations
 \code{nosof94exalcove} and \code{nosof94protoalcove}, all simulated
 participants complete 16 blocks of training. This differs from the
 Nosofsky et al. (1994) experiment, in which participants are trained to
 a criterion of four consecutive errorless 8-trial subblocks.

 The simulation by Gureckis (2016) builds this criterion-based training
 into their simulation by using a random number generator to turn the
 response probability on each trial into a correct or incorrect
 response. This feature of the Gureckis (2016) simulation is not
 incorporated here, because the instability in ouput this generates
 makes parameter optimization (e.g. via \code{optim}) less reliable.

 A comparison of 10,000 simulated participants in the Gureckis (2016)
 simulation with 1,000 simulated participants in the current simulation
 reveals a mean difference in the 96 reported response probabilities of
 less than 0.01.
 
 This simulation was originally developed to support Wills et
 al. (n.d.).

}

\author{
  
  Lenard Dome, Andy Wills
  
}
\references{

  Love, B. C., Medin, D. L., & Gureckis, T. M. (2004). SUSTAIN: a
  network model of category learning. \emph{Psychological Review, 111},
  309-332.
  
  Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352--369.

  Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
  in preparation}.
   
}

\seealso{

\code{\link{nosof94}}, \code{\link{nosof94oat}},
\code{\link{nosof94train}}, \code{\link{slpALCOVE}},
\code{\link{nosof94bnalcove}}

}
