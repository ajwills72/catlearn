\name{medin87sustain}
\alias{medin87sustain}
\encoding{UTF-8}
\title{

    Simulation of sorting behaviour from Experiment 1 in
    Medin, Wattenmaker and Hampson (1987) with the SUSTAIN
    model 

}

\description{

    Runs a simulation of Experiment 1 in Medin et al. (1987)
    using the \code{\link{slpSUSTAIN}} model implementation and
    \code{\link{medin87train}} as the input representation.

}

\usage{medin87sustain(params = c(9.998779, 6.396300, 1.977312, 0.096564, 0.5),
       seed = 7649)}

\arguments{

    \item{params}{A vector containing values for r, beta, d, and eta, tau in
        that order, e.g. params = c(8.1, 1.5, 9.71, 0.5). See
        \code{\link{slpSUSTAIN}} for an explanation of these parameters.}
    \item{seed}{Set random seed.}
}

\value{
    
    A matrix where the first four columns showing lambda values for each 
    dimension (D1, D2, D3, D4) and the fifth column showing sorting strategies 
    (1 = family resemblance, 0 = unidimensional), with each row representing
    a simulated participant.

}

\details{

    NOTE: In catlearn version 0.7, the underlying slpSUSTAIN function is
    written in R, and hence this simulation can take several minutes to
    run. A goal for version 0.8 is to re-write slpSUSTAIN in C++, which
    will reduce the run time of this simulation to a few seconds.

    Participants in Medin et al. (1987) recieved the items all
    at once in a randomly scrambled order and were allowed to scrutinize
    each before sorting them into two piles. Love et al. (2004) presented
    the 10 trial types to SUSTAIN in a random order for 10 training blocks
    to mirror human participants' ability to examine the items.
    Love et al. (2004) also restricted SUSTAIN in their simulation
    to create a maximum of two clusters. This functionality was introduced
    with an optional \code{maxcat} parameter for unsupervised learning, which
    was similarly set to 2 for this simulation. For more explanation of
    \code{maxcat}, see \code{\link{slpSUSTAIN}}.

    SUSTAIN also uses a binary nominal input representation, where each
    dimension is a vector of nominal spaces (see \code{\link{slpSUSTAIN}}).
    The \code{medin87trian} function uses binary dimensional representation,
    which is converted with \code{convertSUSTAIN} to a nominal padded
    representation for the current simulation.

    The simulation uses 1000 simulated participants. Like described in
    Love et al. (2004), all simulated participants complete 10 unsupervised
    training block. Other parameters of slpSUSTAIN are set as follows:
    \code{lambda} = 1, initial \code{w} = 0, initial cluster centered on 
    the first stimulus presented to the simulated participant.

    Sorting strategies are evaluated at the cluster level in a similar way to
    Love et al. (2004). Using values from cluster's position, the smallest
    number is subtracted from the largest number to evaluate how SUSTAIN
    organized dimensions in the cluster's representation. In the comparison,
    we tolerated a limit of 0.1 difference. If the difference between
    dimensions was smaller than 0.1, than the strategy was classified
    as family resemblance, otherwise it was classified as unidimensional. 

    Love et al. (2004) reported, that SUSTAIN used a unidimensional
    strategy 99\% of the time, and family resemblance 1\% of the time.
    The current simulation with 1000 simulated participants reports 
    a unidimensional strategy at 100\% of the time. This is the exact replica
    of the results of Medin et al.'s results from Experiment 1.

}

\author{

    Lenard Dome, Andy Wills

}

\references{

  Love, B. C., Medin, D. L., & Gureckis, T. M. (2004). SUSTAIN: a
  network model of category learning. \emph{Psychological Review, 111},
  309-332.

  Medin, D. L., Wattenmaker, W. D., & Hampson, S. E. (1987). Family
  resemblance, conceptual cohesiveness, and category construction.
  \emph{Cognitive Psychology, 19(2)}, 242–279.

}

\seealso{

    \code{\link{medin87train}},
    \code{\link{slpSUSTAIN}}

}

