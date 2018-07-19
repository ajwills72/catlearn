\name{slpBM}
\alias{slpBM}
\title{
Bush & Mosteller (1951) simple associative learning model
}
\description{

  A model often attributed to Bush & Mosteller (1951), more precisely
  this is the separable error term learning equation discussed by
  authors such as Mackintosh (1975) and Le Pelley (2004); see Note 1.

}
\usage{

slpBM(st, tr, xtdo = FALSE)

}
\arguments{
  \item{st}{ List of model parameters
  }
  \item{tr}{ R matrix of training items
  }
  \item{xtdo}{ Boolean specifying whether to include extended information in the output (see below)
  }
}

\details{

The function operates as a stateful list processor (slp; see Wills et
al., 2017). Specifically, it takes a matrix (tr) as an argument, where
each row represents a single training trial, while each column
represents the different types of information required by the model,
such as the elemental representation of the training stimuli, and the
presence or absence of an outcome. It returns the output activation on
each trial (a.k.a sum of associative strengths of cues present on that
trial), as a vector. The slpBM function also returns the final state of
the model - a vector of associative strengths between each stimulus and
the outcome representation.

Argument \code{st} must be a list containing the following items:

\code{lr} - the learning rate (fixed for a given simulation), as denoted
by, for example, \code{theta} in Equation 1 of Mackintosh (1975). If you
want different elements to differ in salience (different alpha values)
use the input activations (x1, x2, \dots, see below) to represent
element-specific salience.

\code{w} - a vector of initial associative strengths. If you are not
sure what to use here, set all values to zero.

\code{colskip} - the number of optional columns to be skipped in the tr
matrix. colskip should be set to the number of optional columns you have
added to the tr matrix, PLUS ONE. So, if you have added no optional
columns, colskip=1. This is because the first (non-optional) column
contains the control values (details below).

Argument \code{tr} must be a matrix, where each row is one trial
presented to the model. Trials are always presented in the order
specified. The columns must be as described below, in the order
described below:

\code{ctrl} - a vector of control codes. Available codes are: 0 = normal
trial; 1 = reset model (i.e. set associative strengths (weights) back to
their initial values as specified in w (see above)); 2 = Freeze
learning. Control codes are actioned before the trial is processed.

\code{opt1, opt2, \dots} - any number of preferred optional columns, the
names of which can be chosen by the user. It is important that these
columns are placed after the control column, and before the remaining
columns (see below). These optional columns are ignored by the
function, but you may wish to use them for readability. For example, you
might choose to include columns such as block number, trial number and
condition. The argument colskip (see above) must be set to the number of
optional columns plus one.

\code{x1, x2, \dots} - activation of any number of input elements. There
must be one column for each input element. Each row is one trial. In
simple applications, one element is used for each stimulus (e.g. a
simulation of blocking (Kamin, 1969), A+, AX+, would have two inputs,
one for A and one for X). In simple applications, all present elements
have an activation of 1 and all absence elements have an activation of
0. However, slpBM supports any real number for activations, e.g. one
might use values between 0 and 1 to represent differing cue saliences.

\code{t} - Teaching signal (a.k.a. lambda). Traditionally, 1 is used to
represent the presence of the outcome, and 0 is used to represent the
absence of the outcome, altough slpBM supports any real values for lambda..

Argument \code{xtdo} (eXTenDed Output) - if set to TRUE, function will
return the associative strengths for the end of each trial (see Value).
}

\value{

Returns a list containing two components (if xtdo = FALSE) or three 
components (if xtdo = TRUE, xout is also returned):

  \item{st}{Vector of final associative strengths
  }
  \item{suma}{Vector of output activations for each trial
  }
  \item{xout}{Matrix of associative strengths at the end of each trial
  }
  
}
\author{
Lenard Dome, Stuart Spicer, Andy Wills

}
\references{

Bush, R. R., & Mosteller, F. (1951). A mathematical model for
simple learning. \emph{Psychological Review, 58(5)}, 313-323.
  
Kamin,  L.J. (1969). Predictability,  surprise,  attention  and  conditioning. 
In Campbell, B.A. & Church, R.M. (eds.), \emph{Punishment and  Aversive  
Behaviour}. New York: Appleton-Century-Crofts, 1969,  pp.279-296.

Le Pelley, M.E. (2004). The role of associative history in models of
associative learning: A selective review and a hybrid model,
\emph{Quarterly Journal of Experimental Psychology, 57B}, 193-243.

Mackintosh, N.J. (1975). A theory of attention: {V}ariations in the
associability of stimuli with reinforcement, \emph{Psychological Review,
  82}, 276-298.

Rescorla, R. A., & Wagner, A. R. (1972). A theory of Pavlovian
conditioning: Variations in the effectiveness of reinforcement and
nonreinforcement. In A. H. Black & W. F. Prokasy (Eds.), \emph{Classical
conditioning II: Current research and theory} (pp. 64-99). New York:
Appleton-Century-Crofts.

Spicer, S., Jones, P.M., Inkster, A.B., Edmunds, C.E.R. & Wills,
A.J. (n.d.). Progress in learning theory through distributed
collaboration: Concepts, tools, and examples. \emph{Manuscript in preparation}.

Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
A.B.(2017). Progress in modeling through distributed collaboration:
Concepts, tools, and category-learning examples. \emph{Psychology of
Learning and Motivation, 66}, 79-115.

}

\note{

  1. Bush & Mosteller's (1951) Equations 2 outputs response probability,
  not associative strength. Also, it has two learning rate paramters,
  \code{a} and \code{b}. At least to a first approximation, \code{b}
  serves a similar function to \code{beta-outcome-absent} in Rescorla &
  Wagner (1972), and \code{a-b} is similar to
  \code{beta-outcome-present} in that same model.
  
}
