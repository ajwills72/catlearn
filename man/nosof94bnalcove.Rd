\name{nosof94bnalcove}
\alias{nosof94bnalcove}
\title{
  
   Simulation of CIRP nosof94 with BN-ALCOVE model

 }
 
\description{

  Runs a simulation of the \code{\link{nosof94}} CIRP using the
  \code{\link{slpALCOVE}} model implementation as an exemplar model and
  \code{\link{nosof94train}} as the input representation. This
  simulation replicates the one reported by Nosofsky et al. (1994).
  
}

\usage{

  nosof94bnalcove(params = c(6.33,0.011,0.409,0.179))

}

\arguments{
  
  \item{params}{A vector containing values for c, phi, la, and lw, in
  that order. See \code{\link{slpALCOVE}} for an explanation of these
  parameters.}
  
}  
  
\value{
  
  A matrix of predicted response probabilities, in the same order and
  format as the observed data contained in \code{\link{nosof94}}.

}

\details{

 An exemplar-based simulation using \code{\link{slpALCOVE}} and
 \code{\link{nosof94train}}. The co-ordinates for the radial-basis units
 are assumed, and use the same binary representation as the abstract
 category structure.
 
 The defaults for \code{params} are the best fit of the model to the
 \code{\link{nosof94}} CIRP. The derivation of this fit is described by
 Nosofsky et al. (1994). 

 The other parameters of slpALCOVE are set as follows: \code{r} = 1,
 \code{q} = 1, initial \code{alpha} = 1 / number of dimensions, initial
 \code{w} = 0. These values are conventions of modeling with ALCOVE, and
 should not be considered as free parameters. They are set within the
 \code{nosof88bnalcove} function, and hence can't be changed without
 re-writing the function.

 This is a replication of the simulation reported by Nosofsky et
 al. (1994). Compared to other published simulations with the ALCOVE
 model, their simulation is non-standard in a number of respects:

 1. A background noise ('BN') decision rule is used (other simulations
 use an exponential ratio rule).

 2. As a consequence of #1, absence of a category label is represented
 by a zero (other simulations use -1).

 3. The sum of the attentional weights is constrained to be 1 on every
 trial (other simulations do not apply this constraint).

 The current simulation replicates these non-standard aspects of the
 Nosofsky et al. (1994) simulation.
 
}

\author{
  
  Andy Wills
  
}
\references{

  Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352--369
  
}

\seealso{

\code{\link{nosof94}}, \code{\link{nosof94oat}},
\code{\link{nosof94train}}, \code{\link{slpALCOVE}},
\code{\link{nosof94bnalcove}}

}
