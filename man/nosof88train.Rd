\name{nosof88train}
\alias{nosof88train}
\title{

  Input representation of nosof88 for models input-compatible with
  slpALCOVE.
  
}
\description{
  
  Create randomized training blocks for CIRP \code{\link{nosof88}}, in a
  format suitable for the \code{\link{slpALCOVE}} model, and any other
  model that uses the same input representation format. The stimulus
  co-ordinates come from a MDS solution reported by Nosofsky (1987) for
  the same stimuli. 

}
\usage{

nosof88train(condition = 'B', blocks = 3, absval = -1, subjs = 1, seed =
4182, missing = 'geo')

}
\arguments{
  
  \item{condition}{Experimental condition 'B', 'E2', or 'E7', as defined
    by Nosofsky (1988).}
  
  \item{blocks}{Number of blocks to generate. Omit this argument to get
    the same number of blocks as the published study (3).}
  
  \item{absval}{Teaching value to be used where category is absent.}

  \item{subjs}{Number of simulated subjects to be run.}

  \item{seed}{Sets the random seed}

  \item{missing}{If set to 'geo', output missing dimension flags (see
  below)}

}  
  
\value{
  
R by C matrix, where each row is one trial, and the columns contain
model input.

}

\details{

  A matrix is produced, with one row for each trial, and with the
  following columns:

\code{ctrl} - Set to 1 (reset model) for trial 1, set to zero (normal
trial) for all other trials.

\code{cond} - 1 = condition B, 2 = condition E2, 3 = condition E7

\code{blk} - training block

\code{stim} - stimulus number (as defined by Nosofsky, 1988)

\code{x1, x2} - input representation. These are the co-ordinates of an
MDS solution for these stimuli (see Nosofsky, 1987).

\code{t1, t2} - teaching signal (1 = category present, absval = category
absent)

\code{m1, m2} - Missing dimension flags (always set to zero in this
experiment, indicating all input dimensions are present on all
trials). Only produced if \code{missing = 'geo'}.

Although the trial ordering is random, a random seed is used, so
multiple calls of this function with the same parameters should produce
the same output. This is usually desirable for reproducibility and
stability of non-linear optimization. To get a different order, use the
seed argument to set a different seed.

This implementation assumes a block length of 64 trials for conditions
E2 and E7, rather than the 63 trials reported by Nosofsky (1988).

This routine was originally developed to support simulations reported in
Wills & O'Connell (n.d.).

}

\author{
  
  Andy Wills & Garret O'Connell
  
}
\references{
  
  Nosofsky, R.M. (1987). Attention and learning processes in the
  identification and categorization of integral stimuli, \emph{Journal
  of Experimental Psychology: Learning, Memory and Cognition, 13},
  87-108.

  Nosofsky, R.M. (1988). Similarity, frequency, and category
  representations, \emph{Journal of Experimental Psychology: Learning,
  Memory and Cognition, 14}, 54-65.

  Wills, A.J. & O'Connell (n.d.). Averaging
  abstractions. \emph{Manuscript in preparation}.

} 

\seealso{

\code{\link{nosof88}}, \code{\link{nosof88oat}}, \code{\link{slpALCOVE}}
  
}
