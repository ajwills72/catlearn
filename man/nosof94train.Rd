\name{nosof94train}
\alias{nosof94train}
\title{

  Input representation of nosof94 for models input-compatible with
  slpALCOVE or slpSUSTAIN
  
}
\description{
  
  Create randomized training blocks for CIRP \code{nosof94}, in a format
  suitable for the \code{slpALCOVE} or \code{slpSUSTAIN} models, and
  other models that use the same input representation formats. 

}
\usage{

nosof94train(cond = 1, blocks = 16, absval = -1, subjs = 1, seed = 7624,
missing = 'geo', blkstyle = 'accurate')

}
\arguments{
  
  \item{cond}{Category structure type (1-6), as defined by Shepard et
  al. (1961).}
  
  \item{blocks}{Number of blocks to generate. Omit this argument to get
    the same number of blocks (16) as used in the simulations reported
    by Nosofsky et al. (1994).}
  
  \item{absval}{Teaching value to be used where category is absent.}

  \item{subjs}{Number of simulated subjects to be run.}

  \item{seed}{Sets the random seed.}

  \item{missing}{If set to 'geo', output missing dimension flags (see
  below). If set to 'pad', use the padded stimulus representation format
  of slpSUSTAIN. If set to 'pad', set \code{absval} to zero.}

  \item{blkstyle}{If set to 'accurate', reproduce the randomization of
    this experiment, as described in Nosofsky et al. (1994). If set to
    'eights', use instead the randomization used in the Gureckis (2016)
    simulation of this experiment.}
  
}  
  
\value{
  
R by C matrix, where each row is one trial, and the columns contain
model input.

}

\details{
  
A matrix is produced, with one row for each trial, and with the
following columns:

\code{ctrl} - Set to 1 (reset model) for trial 1 of each simulated
subject, set to zero (normal trial) for all other trials.

\code{blk} - training block

\code{stim} - Stimulus number, ranging from 1 to 8. The numbering scheme
 is the same as in Nosofsky et al. (1994, Figure 1), under the mapping
 of dim_1_left = 0, dim_1_right = 1, dim_2_front = 0, dim_2_back = 1,
 dim_3_bottom = 0, dim_3_top = 1.

\code{x1, x2, \dots} - input representation. Where \code{missing='geo'},
x1, x2, and x3 are returned, each set at 1 or 0. This is the binary
dimensional representation required by models such as slpALCOVE, where
e.g. x2 is the value on the second dimension. Where
\code{missing='pad'}, x1, x2, y1, y2, z1, z2, are returned. This is the
padded represenation required by models such as slpSUSTAIN; e.g. y1 and
y2 represent the two possible values on dimension 2, so if y1 is black,
y2 is white, and the stimulus is white, then [y1, y2] = [0, 1].

\code{t1, t2} - Category label (1 = category present, absval = category
absent)

\code{m1, m2, m3} - Missing dimension flags (always set to zero in this
experiment, indicating all input dimensions are present on all
trials). Only produced if \code{missing = 'geo'}.

Although the trial ordering is random, a random seed is used, so
multiple calls of this function with the same parameters should produce
the same output. This is usually desirable for reproducibility and
stability of non-linear optimization. To get a different order, use the
seed argument to set a different seed.

This routine was originally developed to support Wills et al. (n.d.).

}

\author{
  
  Andy Wills, Lenard Dome
  
}
\references{
  
  Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352--369

  Gureckis, T. (2016). https://github.com/NYUCCL/sustain_python

  Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
  in preparation}.

}
\seealso{
  
  \code{\link{nosof94train}}, \code{\link{nosof94oat}}
}
