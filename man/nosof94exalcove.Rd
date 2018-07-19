\name{nosof94exalcove}
\alias{nosof94exalcove}
\title{
  
   Simulation of CIRP nosof94 with ex-ALCOVE model

 }
 
\description{

  Runs a simulation of the \code{\link{nosof94}} CIRP using the
  \code{\link{slpALCOVE}} model implementation as an exemplar model and
  \code{\link{nosof94train}} as the input representation.
  
}

\usage{

  nosof94exalcove(params = NULL)

}

\arguments{
  
  \item{params}{A vector containing values for c, phi, la, and lw, in
  that order, e.g. params = c(2.1, 0.6, 0.09, 0.9). See
  \code{\link{slpALCOVE}} for an explanation of these parameters. Where
  params = NULL, best-fitting parameters are derived from optimzation
  archive \code{\link{nosof94exalcove_opt}}}
  
}  
  
\value{
  
  A matrix of predicted response probabilities, in the same order and
  format as the observed data contained in \code{\link{nosof94}}.

}

\details{

  N.B.: This simulation uses a standard version of ALCOVE. For a
  replication of the ALCOVE simulation of these data reported by
  Nosofsky et al. (1994), which is non-standard in a number of respects,
  see \code{\link{nosof94bnalcove}}.

  An exemplar-based simulation using \code{\link{slpALCOVE}} and
 \code{\link{nosof94train}}. The co-ordinates for the radial-basis units
 are assumed, and use the same binary representation as the abstract
 category structure.

 Other parameters of slpALCOVE are set as follows: \code{r} = 1,
 \code{q} = 1, initial \code{alpha} = 1/3, initial \code{w} = 0. These
 values are conventions of modeling with ALCOVE, and should not be
 considered as free parameters. They are set within the
 \code{nosof88exalcove} function, and hence can't be changed without
 re-writing the function.
 
 This simulation is reported in Wills & O'Connell (n.d.). 

}

\author{
  
  Andy Wills
  
}
\references{

  Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352--369
  
  Wills, A.J. & O'Connell (n.d.). Averaging
  abstractions. \emph{Manuscript in preparation}.
   
}

\seealso{

\code{\link{nosof94}}, \code{\link{nosof94oat}},
\code{\link{nosof94train}}, \code{\link{slpALCOVE}},
\code{\link{nosof94bnalcove}}

}
