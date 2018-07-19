\name{act2probrat}
\alias{act2probrat}
\title{
  Convert output activation to a rating of outcome probability
}
\description{
  Logistic function to convert output activations to rating of
  outcome probability (see e.g. Gluck & Bower, 1988).
}
\usage{ act2probrat(act, theta, beta) }
\arguments{
  \item{act}{Vector of output activations}
  \item{theta}{Scaling constant}
  \item{beta}{Bias constant}
}
\details{
  The contents of this help file are relatively brief; a more extensive
  tutorial on using act2probrat can be found in Spicer et al. (n.d.).

  The function takes the output activation of a learning model
  (e.g. slpRW), and converts it into a rating of the subjective
  probability that the outcome will occur. It does this separately for
  each activation in the vector \code{act}. It uses a logistic function
  to do this conversion (see e.g. Gluck & Bower, 1988, Equation 7). This
  function can produce a variety of monotonic mappings from activation
  to probability rating, determined by the value set for the two
  constants: 

  \code{theta} is a scaling constant; as its value rises, the function
  relating activation to rating becomes less linear and at high values
  approximates a step function.

  \code{beta} is a bias parameter; it is the value of the output
  activation that results in an output rating of P = 0.5. For example,
  if you wish an output activation of 0.4 to produce a rated probability
  of 0.5, set beta to 0.4.
}
\value{Returns a vector of probability ratings.}
\note{
  As this function returns probabilities, the numbers returned are
  always in the range 0-1. If the data you are fitting use a
  different range, convert them. For example, if your data are ratings
  on a 0-10 scale, divide them by 10.  If your data are something other
  than probability estimates (e.g. you asked participants to use
  negative ratings to indicate preventative relationships), don't use this
  function unless you are sure it is doing what you intend. 
}
\author{
  Andy Wills
}
\references{
  Gluck, M.A. & Bower, G.H. (1988). From conditioning to category
  learning: An adaptive network model. \emph{Journal of Experimental
    Psychology: General, 117}, 227-247.

  Spicer, S., Jones, P.M., Inkster, A.B., Edmunds, C.E.R. & Wills,
  A.J. (n.d.). Progress in learning theory through distributed
  collaboration: Concepts, tools, and examples. \emph{Manuscript in
    preparation}.
}
