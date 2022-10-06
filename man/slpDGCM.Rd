\name{slpDGCM}
\alias{slpDGCM}
\title{
  Similarity-Dissimilarity Generalized Context Model (DGCM)
}

\description{
  Stewart and Morin (2007)'s extension to Nosofsky's (1984, 2011)
  Exemplar-based Generalized Context Model. The implementation also
  contains O'Bryan et al. (2018)'s version of the
  Similarity-Dissimilarity Generalized Context Model, see Note 1.  
}

\usage{
  slpDGCM(st, test, dec = "BIAS", exemplar_mute = FALSE, exemplar_decay = TRUE)
}
\arguments{
  \item{st}{List of model parameters}
  \item{test}{Test matrix.}
  \item{dec}{Decision mechanism. If \code{NOISE}, use O'Bryan et al. (2018)'s
             background-noise decision rule. If \code{BIAS} (default), use
             Stewart and Morin (2007)'s category-bias decision rule.}
  \item{exemplar_mute}{If \code{TRUE}, only those exemplars contribute evidence
                       to the decision rule, which have at least one feature
                       common with the current stimuli (O'Bryan et al., 2018).
                       If \code{FALSE} (default), all exemplars contribute.}
  \item{exemplar_decay}{If \code{TRUE} (default), exemplar weightings decay
                        as specified by Stewart and Morin (2007). If
                        \code{FALSE}, exemplar weightings are static.}

}

\value{

  If \code{exemplar_decay = FALSE}, returns a list of the following
  matrices:

  \code{v} A matrix of evidence accumulated for each category (columns)
  on each trial (rows) as output by Equation 3 in Stewart and Morin
  (2007).

  \code{p} A matrix of response probabilities. Category responses
  (columns) for each trial (rows).

  If \code{exemplar_decay = TURE}, the function also returns memory
  decay for each trial, \code{decay}.

}

\details{

This implementation houses the two version of DGCM.  In order to use the
instantiation of DGCM described in O'Bryan et al.  (2018), set
\code{exemplar_decay = FALSE} and \code{exemplar_mute = TRUE}.  The
default settings of the function will run the model that corresponds to
Stewart and Morin (2007).

The functions works as a stateful list processor. Specifically, it takes
a data frame as an argument, where each row is one trial for the model,
and the columns specify the input representation, teaching signals, and
other control signals. It returns two matrices containing, for each
trial, response probabilities and the accumulated evidence for each
category.  It also returns the final state of the network (e.g. memory
decay), hence its description as a 'stateful' list processor, see Note
1.

This implementation took the assumption that when \code{exemplar_decay =
TRUE}, memory strengths for exemplar are equal to each other at the
beginning of the test phase. In future releases, we plan to implement a
feature that allows initial memory strengths to be treated as freely
varying parameters.

\code{st} must be a list containing the following items:

\code{attentional_weights} - vector of attentional weights, where sum of
all elements equal to 1.

\code{c} - generalization constant.

\code{r} - The Minkowski metric parameter \emph{r} gives a city block
           metric when r = 1 (used for separable-dimension stimuli) and
           a Euclidean metric when r = 2 (used for integral-dimension
           stimuli).

\code{s} - similarity and dissimilarity weighting. If 0, evidence for a
           category will be purely based on the dissimilarity between
           current input vector and all exemplars from the other
           categories. If it is 1, evidence for a given category will be
           solely based on similarity to its own exemplars.

\code{t} - exemplar weighting. If \code{memory_decay = FALSE}, it is a
           vector of exemplar-specific memory strength. If
           \code{memory_decay = TRUE} (default), it is a vector of
           exemplar-specific memory strengths that will update according
           to the function as specified in Equation 4 in Stewart and
           Morin (2007).

\code{beta} - category bias vector. Only used when \code{dec} set to
            BIAS, otherwise ignored.  Currently, there is no restriction
            in place on what values are allowed in this implementation,
            but Stewart and Morin (2007) specifies that elements of
            \code{beta} should sum to 1.

\code{base} - a vector of baseline level of similarity. This parameter
           will control how much noise will spread over all categories
           in the background-noise decision rule. It is only used if
           \code{dec} is set to NOISE.

\code{gamma} - decision scaling constant. Only used when \code{dec} is
set to BIAS.

\code{theta} - decay rate. If \code{exemplar_decay = FALSE}, theta is
ignored.

\code{colskip} - the number of optional columns to skip in test plus
one. If you have no optional columns, set it to one.

\code{outcomes} - the number of categories.

\code{exemplars} - a matrix of exemplars and their corresponding
category indicated by a single integer.

\code{test} must be a \code{data.matix} with the following columns:

\code{opt1, opt2, \dots} - any number of optional columns, the names of
    which can be chosen by the user. These optional columns are ignored
    by the slpDGCM function, but you may wish to use them for
    readability.

\code{x1, x2, x3, \dots}- {input to the model, there must be one column
    for each input unit. Each row is one trial. DGCM uses a nominal
    stimulus representation, which means that features are coded as
    either 0 (absent) or 1 (present).}

}

\author{ Lenard Dome, Andy Wills }

\references{

Nosofsky, R. M. (1984). Choice, similarity, and the context theory of
classification. \emph{Journal of Experimental Psychology: Learning,
memory, and cognition, 10}, 104.

O'Bryan, Sean R., et al. (2018). Model-based fMRI reveals dissimilarity
processes underlying base rate neglect. \emph{ELife 7}: e36395.

Stewart, N., & Morin, C. (2007). Dissimilarity is used as evidence of
category membership in multidimensional perceptual categorization: A
test of the similarity–dissimilarity generalized context
model. \emph{Quarterly Journal of Experimental Psychology, 60},
1337-1346.

}

\examples{
  ## Replicate O'Bryan et al. (2018)
  # Exemplars
  stim = matrix(c(
                1,1,0,0,0,0, 1,
                1,0,1,0,0,0, 2,
                0,0,0,1,1,0, 3,
                0,0,0,1,0,1, 4), ncol = 7, byrow = TRUE)

  # Transfer/test stimuli
  # This is a row for each unique transfer stimulus
  tr = matrix(c(
               1, 1, 0, 0, 0, 0, #0,1,2
               1, 0, 1, 0, 0, 0, #3
               0, 0, 0, 1, 1, 0, #4,5,6
               0, 0, 0, 1, 0, 1, #7
               1, 0, 0, 0, 0, 0, #8
               0, 0, 0, 1, 0, 0, #9
               0, 1, 0, 0, 0, 0, #10
               0, 0, 1, 0, 0, 0, #11
               0, 0, 0, 0, 1, 0, #12
               0, 0, 0, 0, 0, 1, #13
               0, 1, 1, 0, 0, 0, #14, 15
               0, 0, 0, 0, 1, 1, #16, 17
               1, 0, 0, 0, 1, 0, #18
               1, 0, 0, 0, 0, 1, #19
               0, 1, 0, 1, 0, 0, #20
               0, 0, 1, 1, 0, 0, #21
               0, 0, 1, 0, 1, 0, #22, 23
               0, 1, 0, 0, 0, 1 #24, 25
               ),
               ncol = 6,
               byrow = TRUE)

  # parameters from paper
  aweights = c(0.27692188, 0.66524089, 0.88723335, 0.16967400, 0.71206208,
               0.87939732)

  st <- list(attentional_weights = aweights/sum(abs(aweights)),
             c = 9.04906080,
             s = 0.94614863,
             b = 0.02250668,
             t = c(3, 1, 3, 1),
             beta = c(1, 1, 1, 1)/4,
             gamma = 1,
             theta = 0.4,
             r = 1,
             colskip = 1,
             outcomes = 4,
             exemplars = stim)

  slpDGCM(st, tr, exemplar_decay = FALSE, exemplar_mute = TRUE, dec = "NOISE")

}

\note{

1. O'Bryan et al. (2018)'s version of the DGCM is not a stateful list processor, but
we decided to include it in the same implementation. In fact, Stewart and Morin
(2007)'s version only classifies as a stateful list processor, because of the memory
decay function.

}
