\name{medin87train}
\alias{medin87train}
\encoding{UTF-8}
\title{

    Input representation of Exp. 1 in Medin et al. (1987) for models
    input-compatible with slpALCOVE or slpSUSTAIN.

}

\description{

    Creates randomized training blocks for Experiment 1 in Medin et
    al. (1987), in a format that is suitable for \code{slpALCOVE},
    \code{slpSUSTAIN}, and other models that use either of those 
    input-representation formats.

}

\usage{medin87train(blocks = 2, subjs = 2, seed = 7649, missing = 'pad')}

\arguments{

    \item{subjs}{Number of simulated participants to run.}

    \item{blocks}{Number of blocks to generate. The ten trial types
        are randomized within each block.}

    \item{seed}{Set random seed.}

    \item{missing}{If set to 'geo', output missing dimension flags (see
    below). If set to 'pad', use the padded stimulus representation
    format of slpSUSTAIN.}
    
}

\value{

    R by C matrix, where each row is one trial, and the columns contain
    model input.

}

\details{

    A matrix is produced, with one row for each trial, and with the following
    columns:

    \code{ctrl} - Set to 4 on the first trial for each participant - 4 resets
    the model to the initial state and does unsupervised learning afterwards.
    Set to 3 for unsupervised trials - normal unsupervised learning
    trial.
    
    \code{blk} - Training block.

    \code{stim} - Stimulus number, ranging from 1 to 10. The numbering scheme
    is the same as in Medin et al. (1987, Fig. 1).

    \code{x1, x2, \dots} - input representation. Where
    \code{missing='geo'}, x1, x2, and x3 are returned, each set at 1 or
    0. This is the binary dimensional representation required by models
    such as slpALCOVE, where e.g. x2 is the value on the second
    dimension. Where \code{missing='pad'}, w1, w2, x1, x2, y1, y2, z1,
    z2, are returned. This is the padded represenation required by
    models such as slpSUSTAIN; e.g. y1 and y2 represent the two possible
    values on dimension 3, so if y1 is black, y2 is white, and the
    stimulus is white, then [y1, y2] = [0, 1].

    Although the trial ordering is random, a random seed is used, so
    multiple calls of this function with the same parameters should produce
    the same output. This is usually desirable for reproducibility and
    stability of non-linear optimization. To get a different order, use the
    seed argument to set a different seed.

}

\author{

    Lenard Dome, Andy Wills
}

\references{

    Medin, D. L., Wattenmaker, W. D., & Hampson, S. E. (1987). Family
    resemblance, conceptual cohesiveness, and category construction.
    \emph{Cognitive Psychology, 19(2)}, 242–279.

}



