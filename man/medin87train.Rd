\name{medin87train}
\alias{medin87train}
\encoding{UTF-8}
\title{

    Input representation of Experiment 1 in Medin, Wattenmaker,
    and Hampson (1987) for models compatible with binary dimensional
    input representation.

}

\description{

    Create a randomized training blocks for Experiment 1 in
    Medin et al. (1987), in a format that is suitable
    for models like \code{slpSUSTAIN} and those
    that use a similar input-representation format.

}

\usage{medin87train(ppt = 1, block = 1, seed = 7649)}

\arguments{

    \item{ppt}{Number of simulated participants to run.}

    \item{block}{Number of blocks to generate. The ten trial types
        are randomized within block.}

    \item{seed}{Set random seed.}

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
    Set to 3 for unsupervised trials - normal unsupervised learning trial.
    \code{ppt} - Number of the simulated participant.
    \code{blk} - Training block.
    \code{D1, D2, \dots} - Input representation, where each dimensions is
    set to either 1 or 0. This is a binary dimensional representation
    required by models such as slpALCOVE and is compatible with slpSUSTAIN,
    although it is encouraged to use a padded representation for slpSUSTAIN
    as the two different representation will likely give different results.
    Here, 1 and 0 represents two dinstictive features, compared to a more
    general presents or absence of a feature.

    The abstract trial types are as depicted in Figure 1. in Medin et al.
    (1987). 

    Although the trial ordering is random, a random seed is used, so
    multiple calls of this function with the same parameters should produce
    the same output. This is usually desirable for reproducibility and
    stability of non-linear optimization. To get a different order, use the
    seed argument to set a different seed.

    This routine was originally developed to support Wills et al. (n.d.).

}

\author{

    Lenard Dome, Andy Wills
}

\references{

    Medin, D. L., Wattenmaker, W. D., & Hampson, S. E. (1987). Family
    resemblance, conceptual cohesiveness, and category construction.
    \emph{Cognitive Psychology, 19(2)}, 242–279.

    Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
    in preparation}.

}

\seealso{

    \code{\link{medin87sustain}}

}

