\name{krus96exit}
\alias{krus96exit}
\encoding{UTF-8}
\title{
  
   Simulation of AP krus96 with EXIT model

 }
 
\description{

  Runs a simulation of the \code{\link{krus96}} AP using the
  \code{\link{slpEXIT}} model implementation and
  \code{\link{krus96train}} as the input representation.
  
}

\usage{

  krus96exit (params = c(2.87, 2.48, 4.42, 4.42, .222, 1.13, .401))

}

\arguments{
  
  \item{params}{A vector containing values for c, P, phi, l_gain,
  l_weight, l_ex, and sigma_bias (i.e. the sigma for the bias unit), in
  that order. See \code{\link{slpEXIT}} for an explanation of these
  parameters.}
  
}  
  
\value{
  
  A matrix of predicted response probabilities, in the same order and
  format as the observed data contained in \code{\link{krus96}}.

}

\details{

  A simulation using \code{\link{slpEXIT}} and
  \code{\link{krus96train}}. The stored exemplars are the four stimuli
  present during the training phase, using the same representation as in
  \code{\link{krus96train}}.

  Other parameters of slpEXIT are set as follows: \code{iterations} =
  10, sigma for the non-bias units = 1. These values are conventions of
  modeling with EXIT, and should not be considered as free
  parameters. They are set within the \code{krus96exit} function,
  and hence can't be changed without re-writing the function.

  This simulation is discussed in Spicer et al. (n.d.). It produces the
  same response probabilities (within rounding error) as the simulation
  reported in Kruschke (2001), with the same parameters.

  56 simulated participants are used in this simulation, the same number
  as used by Kruschke (2001). Kruschke reports using the same trial
  randomizations as used for his 56 real participants. These
  randomizations were not published, so it we couldn't reproduce that
  part of his simulation. It turns out that the choice of set of 56
  randomizations matters, it affects some of the predicted response
  probabilities. We chose a random seed that reproduced Kruschke's
  response probabilities to within rounding error. As luck would have
  it, Kruschke's reported response probabilities (and hence this
  simulation) are the same (within rounding error) as the results of 
  large sample (N = 500) simulations we have run.

}

\author{René Schlegelmilch, Andy Wills}

\references{

  Kruschke, J. K. (2001). The inverse base rate effect is not explained
  by eliminative inference. \emph{Journal of Experimental Psychology:
  Learning, Memory & Cognition, 27}, 1385-1400.
  
  Spicer, S.G., Schlegelmilch, R., Jones, P.M., Inkster, A.B., Edmunds,
  C.E.R. & Wills, A.J. (n.d.). Progress in learning theory through
  distributed collaboration: Concepts, tools, and
  examples. \emph{Manuscript in preparation}.

}

\seealso{

\code{\link{krus96}}, \code{\link{krus96train}}, \code{\link{slpEXIT}}

}
