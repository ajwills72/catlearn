\name{slpALCOVE}
\alias{slpALCOVE}
\title{
ALCOVE category learning model
}
\description{
  
Kruschke's (1992) category learning model. 

}
\usage{

slpALCOVE(st, tr, dec = 'ER', humble = TRUE, attcon = FALSE, absval = -1,
          xtdo = FALSE)

}
\arguments{
  
  \item{st}{List of model parameters}
  
  \item{tr}{R-by-C matrix of training items}
  
  \item{dec}{String defining decision rule to be used}
  
  \item{humble}{Boolean specifying whether a humble or strict teacher is
    to be used}
  
  \item{attcon}{Boolean specifying whether attention is constrained}
  
  \item{absval}{Real number specifying teaching value for category
    absence}

  \item{xtdo}{Boolean specifying whether to write extended information
  to the console (see below).}
  
}  
  
\value{

  Returns a list containing three components: (1) matrix of response
  probabilities for each output unit on each trial, (2) attentional
  weights after final trial, (3) connection weights after final trial. 

}

\details{

  The coverage in this help file is relatively brief; Catlearn Research
  Group (2016) provides an introduction to the mathematics of the ALCOVE
  model, whilst a more extensive tutorial on using slpALCOVE can be
  found in Wills et al. (2016).

The functions works as a stateful list processor. Specifically, it takes
a matrix as an argument, where each row is one trial for the network,
and the columns specify the input representation, teaching signals, and
other control signals. It returns a matrix where each row is a trial,
and the columns are the response probabilities at the output units. It
also returns the final state of the network (attention and connection
weights), hence its description as a 'stateful' list processor.

Argument \code{st} must be a list containing the following items:

\code{colskip} - skip the first N columns of the tr array, where N =
colskip. colskip should be set to the number of optional columns you
have added to matrix tr, PLUS ONE. So, if you have added no optional
columns, colskip = 1. This is because the first (non-optional) column
contains the control values, below.
  
\code{c} - specificity constant (Kruschke, 1992, Eq. 1). Positive real
number. Scales psychological space.

\code{r} - distance metric (Kruschke, 1992, Eq. 1). Set to 1
(city-block) or 2 (Euclidean).

\code{q} - similarity gradient (Kruschke, 1992, Eq. 1). Set to 1
(exponential) or 2 (Gaussian).

\code{phi} - decision constant. For decision rule \code{ER}, it is
referred to as mapping constant phi, see Kruschke (1992, Eq. 3). For
decision rule \code{BN}, it is referred to as the background noise
constant b, see Nosofsky et al. (1994, Eq. 3).

\code{lw} - associative learning rate (Kruschke, 1992, Eq. 5) . Real
number between 0 and 1.

\code{la} - attentional learning rate (Kruschke, 1992, Eq. 6). Real
number between 0 and 1.

\code{h} - R by C matrix of hidden node locations in psychological
  space, where R = number of input dimensions and C = number of hidden
  nodes.

\code{alpha} - vector of length N giving initial attention weights for
  each input dimension, where N = number of input dimensions. If you are
  not sure what to use here, set all values to 1.

\code{w} - R by C matrix of initial associative strengths, where R =
number of output units and C = number of hidden units. If you are not
sure what to use here, set all values to zero.

Argument \code{tr} must be a matrix, where each row is one trial
presented to the network. Trials are always presented in the order
specified. The columns must be as described below, in the order
described below:
  
\code{ctrl} - vector of control codes. Available codes are: 0 = normal
  trial, 1 = reset network (i.e. set attention weights and associative
  strengths back to their initial values as specified in h and w (see
  below)), 2 = Freeze learning. Control codes are actioned before the
  trial is processed.
  
\code{opt1, opt2, \dots} - optional columns, which may have any names
  you wish, and you may have as many as you like, but they must be
  placed after the ctrl column, and before the remaining columns (see
  below). These optional columns are ignored by this function, but you
  may wish to use them for readability. For example, you might include
  columns for block number, trial number, and stimulus ID number. The
  argument colskip (see above) must be set to the number of optional
  columns plus 1.

\code{x1, x2, \dots} - input to the model, there must be one column for
each input unit. Each row is one trial.

\code{t1, t2, \dots} - teaching signal to model, there must be one
column for each output unit. Each row is one trial. If the stimulus is a
member of category X, then the teaching signal for output unit X must be
set to +1, and the teaching signal for all other output units must be
set to \code{absval}.

\code{m1, m2, \dots} - missing dimension flags, there must be one column
for each input unit. Each row is one trial. Where m = 1, that input unit
does not contribute to the activation of the hidden units on that
trial. This permits modelling of stimuli where some dimensions are
missing on some trials (e.g. where modelling base-rate negelct,
Kruschke, 1992, p. 29--32). Where m = 0, that input unit contributes as
normal. If you are not sure what to use here, set to zero.

Argument \code{dec}, if specified, must take one of the following
values:

\code{ER} specifies an exponential ratio rule (Kruschke, 1992, Eq. 3).

\code{BN} specifies a background noise ratio rule (Nosofsky et al.,
1994, Eq. 3). Any output activation lower than zero is set to zero
before entering into this rule.

Argument \code{humble} specifies whether a humble or strict teacher is
to be used. The function of a humble teacher is specified in Kruschke
(1992, Eq. 4b). In this implementation, the value -1 in Equation 4b is
replaced by \code{absval}.

Argument \code{attcon} specifies whether attention should be constrained
or not. \emph{If you are not sure what to use here, set to FALSE}. Some
implementations of ALCOVE (e.g. Nosofsky et al., 1994) constrain the sum
of the attentional weights to always be 1 (personal communication,
R. Nosofsky, June 2015). The implementation of attentional constraint in
\emph{alcovelp} is the same as that used by Nosofsky et al. (1994), and
present as an option in the source code available from Kruschke's
website (Kruschke, 1991).

Argument \code{xtdo} (eXTenDed Output), if set to TRUE, will output to
the console the following information on every trial: (1) trial number,
(2) attention weights at the end of that trial, (3) connection weights
at the end of that trial, one row for each output unit. This output can
be quite lengthy, so diverting the output to a file with the \code{sink}
command prior to running \code{alcovelp} with extended output is
advised.

}

\author{
  
Andy Wills

}

\references{

  Catlearn Research Group (2016). Description of ALCOVE.
  \url{http://catlearn.r-forge.r-project.org/desc-alcove.pdf}

  Kruschke, J. (1991). \emph{ALCOVE.c}. Retrieved 2015-07-20, page since
  removed, but archival copy here:
  \url{https://web.archive.org/web/20150605210526/http://www.indiana.edu/~kruschke/articles/ALCOVE.c}

Kruschke, J. (1992). ALCOVE: an exemplar-based connectionist model of
category learning. \emph{Psychological Review, 99}, 22-44

Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352-369.

Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
A.B.(2017). Progress in modeling through distributed collaboration:
Concepts, tools, and category-learning examples. \emph{Psychology of
  Learning and Motivation, 66}, 79-115.

}

