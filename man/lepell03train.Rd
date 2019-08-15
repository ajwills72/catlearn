\name{lepell03train}
\alias{lepell03train}
\title{

    Input representation of lepell03 for models input-compatible with 
    slpBM, slpRW, slpMack75, slpSUSTAIN, slpEXIT.

}

\description {
    
    Create randomized training blocks for AP \code{lepell03}, in a format
    suitable for the \code{slpMack75} and \code{slpRW}, and other models that
    are compatible with the same input representation format.

}

\usage{

lepell03train(block1 = 20, block2 = 20, subj = 4, seed = 7624)

}

\arguments{

    \item{block1}{Number of Stage 1 blocks to generate.}
    \item{block2}{Number of Stage 2 blocks to generate.}
    \item{subj}{Number of simulated subjects to be run.}
    \item{seed}{Sets the random seed.}

}

\value {

R by C matrix, where each row is one trial, and the columns contain
model input.

}

\details{

A matrix is produced, with one row for each trial, and with the 
following columns:

\code{ctrl} - Set to 1 (reset model) for trial 1 of each simulated subject,
to 0 (normal trial) for all other trials, set to 3 (reset weights but not
alphas, see slpMack75) when outcomes change in Stage 2. 

\code{subj} - The number of the current subject.

\code{stage} - Indicating in which stage the trial takes place.

\code{blk} - Training or testing block.

\code{stim} - Stimulus number ranging from 1 to 12. The numbering scheme is as
follows: 1 = AV, 2 = AW, 3 = BV, 4 = BW, 5 = CX, 6 = CY, 7 = DX, 8 = DY,
9 = AX, 10 = BY, 11 = CV, 12 = DW.

\code{A, B, C, ...} - input representation. Where A, B, C, etc are returned,
each set at 1 or 0. This is a binary representation required by models like
slpMack75 or slpRW, where columns represent the presence (1) or absence (0) 
of a cue or a feature to the model.

\code{t} - Outcome representation. Presence of an outcome is represented as
1 or -1 for an additional outcome, while its absence is represented as 0.
An outcome representation involving multiple columns corresponding with
multiple outcomes are in development, see slpMack75.

Although trial ordaring is randomized within block, a random seed is used, so
multiple calls of this function with the same parameters should produce
the same output. This is usually desirable for reproducibility and
stability of non-linear optimization. To get a different order, use the
seed argument to set a different seed.

This routine was originally developed to support Wills et al. (n.d.).
}

\author{

    Lenard Dome, Andy Wills, Tom Beesley

}

\references {

    Le Pelley, M. E., & McLaren, I. P. L. (2003). Learned associability and 
    associative change in human causal learning. 
    \emph{The Quarterly Journal of Experimental Psychology: Section B, 56(1)},
    68–79.

}

\seealso{

    \code{\link{lepell03}}

}

\note {

1. For simplicity, both test phase and novel stimuli introduced in Stage 2
(EF, GH, IJ, KL) are left out from this training matrix.

2. All single linear operators, which are implemented in catlearn, use a single
feedback column. These functions are slpBM, slpRW, slpMack75. Additional features
in development include enabling these functions to process multiple feedback 
columns. To maintain consistency across implementation and in lack of time,
we decided to push this feature to later releases.

}
