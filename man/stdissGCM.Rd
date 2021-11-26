\name{dissGCM}
\alias{dissGCM}
\title{
  Similarity-Dissimilarity Generalized Context Model
}

\description{
  Stewart and Morin (2007)'s extension to Nosofsky's (1984, 2011) Exemplar-based
  Generalized Context Model.
}

\usage{
  dissGCM(st, test, dec = "BIAS", exemplar_mute = FALSE, exemplar_decay = TRUE)
}
\arguments{
  \item{st}{List of model parameters}

  \item{test}{Test matrix.}

  \item{dec}{Decision mechanism. If \code{NOISE}, use O'Bryan et al. (2018)'s background-noise decision rule. If \code{BIAS} (default), use Stewart and Morin (2007)'s category-bias decision rule.}

  \item{exemplar_mute}{If \code{TRUE}, only those exemplars contribute evidence to the decision rule, which have at least one feature common with the    current stimuli. If \code{FALSE} (default), all exemplars contribute.}

  \item{exemplar_decay}{If \code{TRUE} (default), exemplar weightings decay as specified by Stewart and Morin (2007). If \code{FALSE}, exemplar weightings are static.}

}

\value{
  If \code{exemplar_decay = FALSE}, returns a list of the following matrices:

  \code{v} A matrix of evidence accumulated for each category (columns) on each
  trial (rows).

  \code{p} A matrix of category responses (columns) for each
  trial (rows).

  If \code{exemplar_decay = TURE}, the function also returns memory decay for
  each trial, \code{decay}.

}

\details{

This function operates as a stateful list processor.

\code{st} must be a list containing the following items:

\code{attentional_weights} -  vector of attentional weights, where sum of all elements equal to 1.

\code{c} - generalization constant.

\code{s} - similarity and dissimilarity weighting. If 0, evidence for a category will be purely based on the dissimilarity between current input vector and all exemplars from the other categories. If it is 1, evidence for a given category will be solely based on similarity to its own exemplars.

\code{b} - baseline level of similarity. This parameter will control how much noise will spread over all categories in the background-noise decision rule. It is only used if \code{dec} is set to NOISE.

\code{t} - exemplar weighting. If \code{memory_decay = FALSE}, it is a vector of exemplar-specific memory strength. If  \code{memory_decay = TRUE} (default), it is set by the function as specified in Equation 4 in Stewart and Morin (2007).

\code{beta} - category bias vector. Only used when \code{dec} set to BIAS. Otherwise set it to \code{NULL}.

\code{gamma} - decision scaling constant, when \code{dec} is set to BIAS.

\code{colskip} - the number of optional columns to skip in test plus one. If you have no optional columns, set it to one.

\code{outcomes} - the number of categories.

\code{exemplars} - a matrix of exemplars and their corresponding category indicated by a single integer.

\code{test} has to be a numeric data matrix with the following columns:

\code{opt1, opt2, \dots}{}

\code{x1, x2, x3, \dots}{}

}

\author{ Lenard Dome, Andy Wills }

\references{

Nosofsky, R. M. (1984). Choice, similarity, and the context theory of classification. \emph{Journal of Experimental Psychology: Learning, memory, and cognition, 10}(1), 104.

O'Bryan, Sean R., et al. (2018). Model-based fMRI reveals dissimilarity processes underlying base rate neglect. \emph{ELife 7}: e36395.

Stewart, N., & Morin, C. (2007). Dissimilarity is used as evidence of category membership in multidimensional perceptual categorization: A test of the similarity–dissimilarity generalized context model. \emph{Quarterly Journal of Experimental Psychology, 60}(10), 1337-1346.

}

\examples{
  ## Replicate O'Bryan et al. (2018)
  # Exemplars
  stim = matrix(c(
                1,1,0,0,0,0, 1,
                1,0,1,0,0,0, 2,
                0,0,0,1,1,0, 3,
                0,0,0,1,0,1, 4), ncol = 7, byrow = T)

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
               byrow = T)

  names <- c("F1 + S1", "F1 + O1", "F2 + O2", "F2 + S2", "F1", "F2", "S1", "O1",
             "O2", "S2", "S1 + O1", "O2 + S2", "F1 + O2", "F1 + S2", "F2 + S1",
             "F2 + O1", "O1 + O2", "S1 + S2")

  # parameters from paper
  aweights = c(0.27692188, 0.66524089, 0.88723335, 0.16967400, 0.71206208, 0.87939732)

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

  stdissGCM(st, tr, exemplar_decay = FALSE, exemplar_mute = TRUE, dec = "NOISE")

}

\note{

  1. In order to use the instantiation of dissGCM described in O'Bryan et al.
  (2018), set \code{exemplar_decay = FALSE} and \code{exemplar_mute = TRUE}.

  }
