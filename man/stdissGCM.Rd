\name{stsimGCM}
\alias{stsimGCM}
\title{
  Similarity-Dissimilarity Generalized Context Model
}

\description{
  An extension to Nosofsky's (1984, 2011) Generalized Context Model by Stewart and Morin (2007) ; an
  exemplar-based model of categorization with differentially weighed similarity
  and dissimilarity.
}

\usage{
  stsimGCM(st, test, dec = "NOISE", exemplar_mute = TRUE, exemplar_decay = TRUE, xtdo = FALSE)
}
\arguments{
  \item{st}{List of model parameters}

  \item{test}{Test matrix.}

  \item{dec}{Decision mechanism.}

  \item{exemplar_mute}{If \code{TRUE}, only those exemplars contribute evidence to the decision mechanism, which have at least one feature common with the current stimuli. If \code{FALSE}, all exemplars contribute.}

  \item{exemplar_decay}

  \item{xtdo}
}

\value{
  If \code{xtdo = FALSE}, returns a list of the following matrices:

  \code{v} A matrix of evidence accumulated for each category (columns) on each trial (rows).

  \code{p} A matrix of category responses (columns) for each
  trial (rows).

  If \code{xtdo = TURE}, the function also returns the following matrices:

  \code{d}

  \code{s}

}

\details{



}

\author{ Lenard Dome, Andy Wills }

\references{

Nosofsky, R. M. (1984). Choice, similarity, and the context theory
of classification. \emph{Journal of Experimental Psychology:
Learning, memory, and cognition, 10}(1), 104.

Stewart, N., & Morin, C. (2007). Dissimilarity is used as evidence of category membership in multidimensional perceptual categorization: A test of the similarity–dissimilarity generalized context model. \emph{Quarterly Journal of Experimental Psychology, 60}(10), 1337-1346.

}

\examples{

}

\note{

  1.

  2.

  }
