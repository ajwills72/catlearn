\name{nosof88}
\docType{data}
\alias{nosof88}
\title{Instantiation frequency CIRP}
\description{

Instantiation frequency is the number of times a stimulus has been
observed as a member of a specific category (Barsalou, 1985). Increasing
instantiation frequency of a stimulus increases categorization accuracy
for that stimulus ('direct' effect), and for other similar stimuli
('indirect' effect). Experiment 1 of Nosofsky (1988) provides the data
for this CIRP.
  
}

\usage{data(nosof88)}

\format{
  
  A data frame with the following columns:
  \describe{
    
    \item{cond}{Experimental condition, see 'details'. 1 = 'B', 2 =
    'E2', 3 = 'E7'}
    
    \item{stim}{Stimulus number, see Nosofsky (1988), Figure 1. Takes
    values: 1-12}
    
    \item{c2acc}{Mean probability, across participants, of responding
      that the item belongs to category 2.}
  }
}

\details{

 Wills et al. (n.d.) discuss the derivation of this CIRP. In brief,
 both the direct and indirect effects have been independently
 replicated. Experiment 1 of Nosofsky (1988) was selected due to the
 availability of a multidimensional scaling solution for the stimuli,
 see \code{\link{nosof88train}}.
 
 Experiment 1 of Nosofsky(1988) involved the classification of Munsell
 chips of fixed hue (5R) varying in brightness (value) and saturation
 (chroma). Instantiation frequency was manipulated between subjects. In
 condition B, all stimuli were equally frequent. In condition E2 (E7),
 stimulus 2 (7) was approximately five times as frequent as each of the
 other stimuli. In condition E2 (E7), stimulus 4 (9) indexes the
 indirect effect. There were three blocks of training. Block length was
 48 trials for condition B and 63 trials for conditions E2 and E7. The
 training phase was followed by a transfer phase, which is not included
 in this CIRP (see Nosofsky, 1988, for details).

 The data are as shown in Table 1 of Nosofsky (1988). The data are mean
 response probabilities for each stimulus in the training phase,
 averaged across blocks and participants.  
  
}

\source{

  Nosofsky, R.M. (1988). Similarity, frequency, and category
  representations, \emph{Journal of Experimental Psychology: Learning,
  Memory and Cognition, 14}, 54-65.

}

\references{

 Barsalou, L.W. (1985). Ideals, central tendency, and frequency of
 instantiation as determinants of graded structure in
 categories. \emph{Journal of Experimental Psychology: Learning, Memory
 & Cognition, 11}, 629-654.
 
 Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
 in preparation}.
 
}

\author{
  Andy J. Wills \email{andy@willslab.co.uk}
  }

\seealso{

\code{\link{nosof88train}}, \code{\link{nosof88oat}}    

  }

\keyword{datasets}
