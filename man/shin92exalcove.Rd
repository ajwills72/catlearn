\name{shin92exalcove}
\alias{shin92exalcove}
\title{
  
   Simulation of CIRP shin92 with ex-ALCOVE model

 }
 
\description{

  Runs a simulation of the \code{\link{shin92}} CIRP using the
  \code{\link{slpALCOVE}} model implementation as an exemplar model and
  \code{\link{shin92train}} as the input representation.
  
}

\usage{

  shin92exalcove(params = NULL)

}

\arguments{
  
  \item{params}{A vector containing values for c, phi, la, and lw, in
  that order, e.g. params = c(2.1, 0.6, 0.09, 0.9). See
  \code{\link{slpALCOVE}} for an explanation of these parameters.  Where
  params = NULL, best-fitting parameters are derived from
  optimzation archive \code{\link{shin92exalcove_opt}} }
  
}  
  
\value{
  
  A matrix of predicted response probabilities, in the same order and
  format as the observed data contained in \code{\link{shin92}}.

}

\details{

 An exemplar-based simulation using \code{\link{slpALCOVE}} and
 \code{\link{shin92train}}. The co-ordinates for the radial-basis units
 are derived from the test stimuli in \code{\link{shin92train}}. The
 output is the average of 100 simulated subjects.
 
 The defaults for \code{params} are the best fit of the model to the
 \code{\link{shin92}} CIRP. They were derived through minimization of
 SSE using non-linear optimization from 16 different initial
 states (using code not included in this archive). 

 The other parameters of slpALCOVE are set as follows: \code{r} = 2,
 \code{q} = 1, initial \code{alpha} = 1 / (number of input dimensions),
 inital \code{w} = 0. These values are conventions of modeling with
 ALCOVE, and should not be considered as free parameters. They are set
 within the \code{shin92exaclove} function, and hence can't be changed
 without re-writing the function.

 This simulation was reported in Wills et al. (2017). 

}

\author{
  
  Andy Wills & Garret O'Connell
  
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
