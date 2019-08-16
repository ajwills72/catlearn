\name{lepell03}
\docType{data}
\alias{krus96}
\encoding{UTF-8}
\title{Learned Predictiveness AP}
\description{

   In the learning predictiveness design, participants trained on cues A, C 
   predicting outcome 1 and cues B, D predicting outcome 2. These cues are 
   paired with V, W, X, Y equally, so they are not predictive of any of the
   outcomes. In a subsequent phase, outcomes 1 and 2 are exchanged for new
   outcomes (3, 4), while cues V, W, X, Y are selectively paired with 
   previously predictive cues. For example AX and CV compounds would only
   occur with outcome outcome 3, whereas BY and DW would only occur with
   outcome 4. The main finding is that, during test, participants rate AC and
   BD to be more predictive of outcomes 3 and 4 than VX and WY, respectively. 
   Participants seem to learn new cue-outcome relationships quicker for 
   previously predictive cues than for previously nonpredictive cues.

}

\usage{data(lepell03)}

\format{

    A data frame with the following columns.

    \describe{
    
    \item{stim}{Cue compounds presented. Values are taken from Le Pelley and
    McLaren (2003).}
    \item{stage}{The learning phase.}
    \item{outcome}{The outcome paired with the cue compound.}
    \item{prop}{Mean response proportions for all trials, averaged
        across participants. If \code{prop} equals to .5, then it means
        that participants gave the correct response on half of the trials.}

    }

}

\details{

    The data is taken from Stage 1 and 2 of Le Pelley and Mclaren (2003).
    The experiment involved the prediction of allergies (itch, nausea,
    dizziness, sweating) based on a combination of food items (asparagus,
    banana, carrots, sardines, tomato, mushrooms, pasta, eggs, onion,
    dates, ham, lentils, garlic, rice vinegar, yoghurt). Stage 1 was made
    up of 14 blocks, where each trial types occurred once within block.
    Stage 2 was made up of 4 blocks, with each trial type occurring once
    within block.

    This dataset only includes the learning phases, because the paper does
    not provide the actual response proportions for the test phase. The data
    are as described in the Results section. 

}

\source{

    Le Pelley, M. E., & McLaren, I. P. L. (2003). Learned associability and 
    associative change in human causal learning. 
    \emph{The Quarterly Journal of Experimental Psychology: Section B, 56(1)},
    68–79.
}

\author{

    Lenard Dome, Andy J. Wills

}

\seealso{
    
    \code{\link{lepell03train}}, \code{\link(lepell03Mack75)}

}

\keyword{datasets}
