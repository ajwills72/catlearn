\name{thegrid}
\docType{data}
\alias{thegrid}
\title{Ordinal adequacy results for all catlearn simulations}
\description{
  
 Records results of all ordinal adequacy tests registered in the
 catlearn package.
  
}
\usage{data(thegrid)}
\format{
  
  A data frame with the following columns:
  
  \describe{

    \item{id}{Unique identifier number for each entry into the
    grid. When making a new entry, use the next available integer.}
    
    \item{cirp}{The CIRP (Canonical Independently Replicated Phenomenon)
    against which a model was tested. This must correspond precisely to
    the name of a data set in the catlearn package. }
    
    \item{model}{A one-word description of the model being
    tested. Simulations in the same row of The Grid must have precisely
    the same one-word description. Note, this is not the name of the
    function used to run the simulation, nor the name of the model
    implementation function. It is a descriptive term, defined by the
    modeler.}
    
    \item{result}{Indicates the result of the simulation. 1 = passes
    ordinal adequacy test, 0 = fails ordinal adequacy test, OES =
    outside explanatory scope (in other words, this is not a result the
    model was designed to accommodate), 'pending' = the function listed
    in 'sim' is currently being written or tested.}
    
    \item{sim}{The name of the catlearn function used to run the
      simulation.}

    \item{oat}{The name of the catlearn function used to perform the
    Ordinal Adequacy Test.}
    
  }
}

\details{

  The Grid is a means of centrally recording the results of model
  simulations centrally, within the catlearn package. For further
  discussion, see Wills et al. (2016).  
  
}

\source{
  
 \code{citation('catlearn')}

}

\references{

  Wills, A.J., O'Connell, G., Edmunds, C.E.R. & Inkster, A.B. (2016).
  Progress in modeling through distributed collaboration: Concepts,
  tools, and category-learning examples. \emph{The Psychology of
    Learning and Motivation}.
  
}

\author{
  Andy J. Wills \email{andy@willslab.co.uk}
  }

  
\keyword{datasets}
