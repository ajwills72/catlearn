\name{homa76}
\docType{data}
\alias{homa76}
\title{Category breadth CIRP}
\description{

In some category-learning experiments, category members are distortions
of an underlying base pattern. Where this is the case, 'category breadth'
refers to the magnitude of such distortions. Broad categories take
longer to learn than narrow categories. Once trained to an errorless
criterion, the effect of category breadth on performance on novel items
depends on category size. For small categories, narrow categories are
better than broad ones. For larger categries, the reverse is true. Homa
& Vosburgh (1976) provide the data for this CIRP.
  
}
\usage{data(homa76)}
\format{
  
  A data frame with the following columns:
  
  \describe{
    
  \item{phase}{Experimental phase (within-subjects). Takes values :
  'train','imm'. The training phase is 'train', 'imm' is the immediate
  test phase.}
    
  \item{cond}{Category breadth (between-subjects). Takes values :
  'mixed', 'uni-low'}

  \item{stim}{Stimulus type (within-subjects). Takes values : 'proto',
    'low', 'med', 'high', 'old-low', 'old-med', 'old-high', 'rand'. All
    refer to novel stimuli in the test phase, except those beginning
    'old-', which are stimuli from the training phase presented during
    the test phase. 'low', 'med', 'high' refer to distortion
    level. 'proto' are prototypes. 'rand' are a set of 10 random
    stimuli, generated from prototypes unrelated to those used in
    training. These random stimuli are not mentioned in the Method of
    the paper, but are mentioned in the Results section - they are
    presented at the end of the test session. Empty cell for training
    phase.}

  \item{catsize}{Category size (within-subjects). Takes values : 3, 6,
  9. NA for training phase, where category size is not a meaningful
  variable given that the DV is blocks to criterion. Also NA for old
  stimuli; Homa & Vosburgh's (1976) Results section collapses across
  category size for old stimuli}

  \item{val}{For test phases: probability of a correct response, except
  for random stimuli, where 'val' is the probability with which the
  random stimuli were placed into the specified category. For training
  phase: number of blocks to criterion}

  }
}
  
\details{

Wills et al. (n.d.) discuss the derivation of this CIRP. In brief, the
effects have been independently replicated. Homa & Vosburgh (1976) was
selected as the only experiment to contain all three independently
replicated effects. 

Homa & Vosburgh's experiment involved the supervised classification of
nine-dot random dot patterns. Stimuli had three different levels of
distortion from the prototype - low (3.5 bit), medium (5.6 bit), and
high (7.7 bit). There were three categories in training, one with 3
members, one with 6 members, and one with 9 members. Participants were
either trained on stimuli that were all low distortion (narrow
categories), or on an equal mix of low, medium, and high distortion
stimuli (broad categories). Training was to an errorless criterion. The
test phase involved the presentation of the prototypes, old stimuli, and
novel stimuli of low, medium, and high distortion. 

The data for the prototype, and other novel test stimuli, were estimated
from Figure 1 of Homa & Vosburgh (1976), using \code{plot
digitizer} (Huwaldt, 2015). The data for old stimuli were estimated from
Figure 3, using the same procedure. The data for the training phase,
and for random stimuli, were reported in the text of Homa & Vosburgh
(1976) and are reproduced here. All data are averages across participants.

Homa & Vosburgh's (1976) experiment also includes results for further
test phases, delayed by either 1 week, or 10 weeks, from the day of
training. These data are not the focus of this category breadth CIRP and
have not been included.

}

\source{

  Homa, D. & Vosburgh, R. (1976). Category breadth and the abstraction
  of prototypical information. \emph{Journal of Experimental Psychology:
  Human Learning and Memory, 2}, 322-330.
  
  Huwaldt, J.A. (2015). Plot Digitizer
  [software]. \url{http://plotdigitizer.sourceforge.net/}

  Wills et al. (n.d.). Benchmarks for category learning. \emph{Manuscript
  in preparation}.

}
\keyword{datasets}

