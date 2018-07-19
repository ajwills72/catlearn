\name{krus96train}
\alias{krus96train}
\encoding{UTF-8}
\title{

  Input representation of krus96 for models input-compatible with
  slpEXIT
  
}
\description{
  
  Create randomized training blocks for AP \code{krus96}, in a format
  suitable for the \code{slpEXIT} model, and other models that use the
  same input representation format.

}
\usage{

krus96train(blocks = 15, subjs = 56, ctxt = TRUE, seed = 1)


}
\arguments{
  
  \item{blocks}{Number of training blocks to generate. Omit this
    argument to get the same number of blocks (15) as used in
    \code{krus96}.}

  \item{subjs}{Number of simulated subjects to be run.}

  \item{ctxt}{If \code{TRUE}, include a context cue (\code{x7}) that
  appears on every trial.}

  \item{seed}{Sets the random seed.}
  
}  
  
\value{
  
A data frame, where each row is one trial, and the columns contain
model input.

}

\details{
  
A data frame is produced, with one row for each trial, and with the
following columns:

\code{ctrl} - Set to 1 (reset model) for trial 1 of each simulated
subject, set to zero (normal trial) for all other training trials, and
set to 2 for test trials (i.e. those with no feedback). 

\code{block} - training block

\code{stim} - Stimulus code, as described in Kruschke (1996). 

\code{x1, x2, \dots} - symptom representation. Each column represents
one symptom, in the order I1, PC1, PR1, I2, PC2, PR2, context. 1 =
symptom present, 0 = symptom absent

\code{t1, t2, \dots} - Disease representation. Each column represents
one disease, in the order C1, R1, C2, R2. 1 = disease present. 0 =
disease absent.

Although the trial ordering is random, a random seed is used, so
multiple calls of this function with the same parameters should produce
the same output. This is usually desirable for reproducibility and
stability of non-linear optimization. To get a different order, use the
seed argument to set a different seed.

This routine was originally developed to support Wills et al. (n.d.).

}

\author{
  
   René Schlegelmilch, Andy Wills
  
}
\references{

  Kruschke, J.K. (1996). Base rates in category learning. \emph{Journal
  of Experimental Psychology: Learning, Memory, and Cognition, 22},
  3-26.
  
  Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
  in preparation}.

}
\seealso{
  
  \code{\link{krus96}}
}
