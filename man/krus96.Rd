\name{krus96}
\docType{data}
\alias{krus96}
\encoding{UTF-8}
\title{Inverse Base-rate Effect AP}
\description{

  In the inverse base-rate effect, participants are trained that a
  compound of two cues (I + PC) leads to a frequently-occurring outcome
  (C), while another two-cue compound (I + PR) leads to a
  rarely-occuring outcome (R). The key results are that, at test,
  participants tend to respond 'C' to cue I on its own, but 'R' to the
  cue compound (PC + PR). This latter response is striking because
  PC and PR had been perfectly predictive of diseases C and R
  respectively, and disease C is more common, so the optimal response to
  PC + PR is 'C'. Participants respond in opposition to the underlying
  disease base rates.
  
}

\usage{data(krus96)}

\format{
  
  A data frame with the following columns:
  
  \describe{
    
    \item{symptom}{Symptom presented. Take values: I, PC, PR, PC+PR,
    I+PC+PR, I+PCo, I+PRo, PC+PRo, I+PC+PRo, as defined by Kruschke
    (1996).}
    
    \item{disease}{Response made. Takes values: C, R, Co, Ro, as defined
    by Kruschke (1996).}
    
    \item{prop}{Mean probability of response, averaged across participants.}
    
    }
}
\details{

  Wills et al. (n.d.) discuss the classification of these data as a
  Auxilliary Phenomenon, rather than a CIRP (Canonical Independently
  Replicated Phenomenon). In brief, these particular results have been
  independently replicated, but are arguably not the best exemplar of
  the known phenomena in this area (in particular, they lack a
  demonstration of the shared-cue effect in IBRE). Auxilliary Phenomena
  may be included in catlearn if are the subject of a simulation
  archived in catlearn. 

  The data are from Experiment 1 of Kruschke (1996), which involved the
  diagnosis of hyopthetical diseases (F, G, H, J) on the basis of
  symptoms presented as text (e.g. "ear aches, skin rash"). Participants
  were trained with feedback across 15 blocks of 8 trials each. They
  were then tested without feedback on 18 test stimuli, each presented
  twice.

  The data are as shown in Table 2 of Kruschke (1996). The data are mean
  response probabilities for each stimulus in the test phase, averaged
  across the two presentations of the stimulus, the two copies of the
  abstract design, and across participants.
  
}

\source{

  Kruschke, J.K. (1996). Base rates in category learning. \emph{Journal
  of Experimental Psychology: Learning, Memory, and Cognition, 22},
  3-26.

}

\references{

  Wills et al. (n.d.). Benchmarks for category
  learning. \emph{Manuscript in preparation}.
  
  }

  \author{
    
    Andy J. Wills, René Schlegelmilch
    
  }

\seealso{

\code{\link{krus96train}}   

  }

\keyword{datasets}
