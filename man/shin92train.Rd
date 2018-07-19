\name{shin92train}
\alias{shin92train}
\title{
  
   Input representation of shin92 for models input-compatible with
   slpALCOVE.

 }
 
\description{
  
  Creates randomized training and transfer blocks for CIRP \code{shin92}
  , in a format suitable for the \code{slpALCOVE} model, and any other
  model that uses the same input representation format. The stimulus
  co-ordinates come from a MDS solution reported by Shin & Nosofsky
  (1992). 
  
}

\usage{

  shin92train(condition = 'equal3', learn.blocks = 8, trans.blocks = 3,
          absval = -1, format = 'mds', subjs = 1, seed = 8416, missing =
          'geo')

}

\arguments{
  
  \item{condition}{Experimental condition 'equal3', 'equal10',
  'unequal3', or 'unequal10', as defined by Shin & Nosofsky (1992).}

  \item{learn.blocks}{Number of training blocks to generate. Omit this
  argument to get the same number of training blocks as the published
  study (8).}

  \item{trans.blocks}{Number of transfer blocks to generate. Omit this
  argument to get the same number of transfer blocks as the published
  study (3).}

  \item{absval}{Teaching value to be used where category is absent.}

  \item{format}{Specifies format used for input representation. Only one
  format is currently suported, so this option is provided solely to
  support future development.}

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
trial) for all other training trials, and set to 2 (freeze learning) for
all transfer trials.

\code{cond} - 1 = equal3, 2 = equal10, 3 = unequal3, 4 = unequal10

\code{phase} - 1 = training, 2 = transfer

\code{blk} - block of trials

\code{stim} - stimulus number; these correspond to the rows in Tables A3
and A4 of Shin & Nosofsky (1992)

\code{x1 ... x6} - input representation. These are the co-ordinates of
an MDS solution for these stimuli (see Shin & Nosofsky, 1992, Tables A3
and A4). Note: Size 3 conditions have a four-dimensional MDS solution,
so the output is x1 ... x4

\code{t1, t2} - teaching signal (1 = category present, absval = category
absent)

\code{m1 ...  m6} - Missing dimension flags (always set to zero in this
experiment, indicating all input dimensions are present on all
trials). Note: ranges from m1 to m4 for Size 3 conditions. Only produced
if \code{missing = 'geo'}.

Although the trial ordering is random, a random seed is used, so
multiple calls of this function with the same parameters should produce
the same output. This is usually desirable for reproducibility and
stability of non-linear optimization. To get a different order, use the
seed argument to set a different seed.

This function was originally developed to support simulations reported
in Wills et al. (2017).

}

\author{
  
  Andy Wills
  
}
\references{

  Shin, H.J. &  Nosofsky, R.M. (1992). Similarity-scaling studies of
  dot-pattern classification and recognition. \emph{Journal
    of Experimental Psychology: General, 121}, 278-304.

  Wills, A.J., O'Connell, G., Edmunds, C.E.R. & Inkster, A.B. (2017).
  Progress in modeling through distributed collaboration: Concepts,
  tools, and category-learning examples. \emph{The Psychology of
  Learning and Motivation, 66}.

}

\seealso{

\code{\link{shin92}}, \code{\link{shin92oat}}, \code{\link{slpALCOVE}}

}
