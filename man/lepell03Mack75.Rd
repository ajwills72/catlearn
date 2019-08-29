\name{lepell03Mack75}
\alias{lepell03Mack75}
\title{

    Simulation of AP lepell03 with the Mackintosh (1975) model implementation
}

\description{

    Runs a simulation of the \code{\link{lepell03}} AP using the
    \code{\link{slpMack75}} model implementation and
    \code{\link{lepell03train}} as the input representation

}

\usage{

    lepell03Mack75(params = c(lr = 0.3, alr = 0.1),
                   ppt = 100,
                   block1 = 14,
                   block2 = 4,
                   seed = 7624)

}

\arguments{

    \item{params}{A vector containing lr (learning rate) and alr
    (attentional learning rate). See \code{\link{slpMack75}} for
    an explanation of these parameters.}
    \item{ppt}{Number of participants to simulate.}
    \item{block1}{Number of blocks in the first learning phase.}
    \item{block2}{Number of blocks in the second learning phase.}
    \item{seed}{Set seed.}

}

\value{

    A matrix of association strengths and attentional values for each cue
    at the end of each stage, averaged across simulated participants.
    Rownames denote the cues, while columns are as follows: stage = the
    learning phase; a = attentional values; w = association strengths.

}

\details{

    A simulation using \code{\link{slpMack75}} and
    \code{\link{lepell03train}}, i.e. a simulation of Le Pelley and Mclaren
    (2003) with Mackintosh (1975) as described by Le Pelley et al. (2016).

    Other parameters of the model set as follows: initial 'w' are set to 0;
    initial 'alpha' are set to 0. These are general conventions for simulating
    with simple associative learning models and cannot be changed without 
    modifying the \code{slpMack75} function.

    The simulation uses 100 simulated participants. Like in Le Pelley and
    McLaren (2003), simulated participants complete 14 blocks of training
    for the first learning phase, and 4 for the second. The number of blocks
    can be set for the current simulation, see \code{block1} and \code{block2}.

}

\author{

    Lenard Dome, Andy Wills, Tom Beesley

}

\references{

    Le Pelley, M. E., & McLaren, I. P. L. (2003). Learned associability and 
    associative change in human causal learning. 
    \emph{The Quarterly Journal of Experimental Psychology: Section B, 56(1)},
    68–79.
    
    Le Pelley, M. E., Mitchell, C. J., Beesley, T., George, D. N., & Wills, A. J.
    (2016). Attention and associative learning in humans:
    An integrative review. \emph{Psychological Bulletin}, 142(10),
    1111–1140. https://doi.org/10.1037/bul0000064

    Mackintosh, N.J. (1975). A theory of attention: {V}ariations in the
    associability of stimuli with reinforcement, \emph{Psychological Review,
    82}, 276-298.

}

\keywords{simulations}
