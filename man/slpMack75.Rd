\name{slpMack75}
\alias{slpMack75}
\title{
Mackintosh (1975) associative learning model
}
\description{

Mackintosh's (1975) attentional learning model, as implemented by Le
Pelley et al. (2016).

}
\usage{

slpMack75(st, tr, xtdo = FALSE)

}
\arguments{
  \item{st}{List of model parameters}
  \item{tr}{Matrix of training items}
  \item{xtdo}{Boolean specifying whether to include extended 
  information in the output (see below)}
}

\details{

The function operates as a stateful list processor (slp; see Wills et
al., 2017). Specifically, it takes a matrix (tr) as an argument, where
each row represents a single training trial, while each column
represents the different types of information required by the model,
such as the elemental representation of the training stimuli, and the
presence or absence of an outcome. It returns the output activation on
each trial (a.k.a. sum of associative strengths of cues present on that
trial), as a vector. The slpMack75 function also returns the final state of
the model - a vector of associative and attentional strengths between
each stimulus and the outcome representation.

Argument \code{st} must be a list containing the following items:

\code{lr} - the associative learning rate (fixed for a given
simulation), as denoted by \code{theta} in Equation 1 of Mackintosh
(1975).

\code{alr} - the attentional learning rate parameter. It can be set without
limit (see alpha below), but we recommend setting this parameter to somewhere
between 0.1 and 1.

\code{w} - a vector of initial associative strengths. If you are not
sure what to use here, set all values to zero.

\code{alpha} - a vector of initial attentional strengths. If the 
updated value is above 1 or below 0.1, it is capped to 1 and 0.1
respectively.

\code{colskip} - the number of optional columns to be skipped in the tr
matrix. colskip should be set to the number of optional columns you have
added to the tr matrix, PLUS ONE. So, if you have added no optional
columns, colskip=1. This is because the first (non-optional) column
contains the control values (details below).

Argument \code{tr} must be a matrix, where each row is one trial
presented to the model. Trials are always presented in the order
specified. The columns must be as described below, in the order
described below:

\code{ctrl} - a vector of control codes. Available codes are: 

    0 = normal trial 
    1 = reset model (i.e. set associative strengths back to
    their initial values as specified in w)
    2 = Freeze learning
    3 = Reset associative weights to initial state, but keep
    attentional strengths in alpha
    4 = Reset attentional strengths to initial state, but keep 
    association weights.

Control codes are actioned before the trial is processed.

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
0. However, slpMack75 supports any real number for activations, e.g. one
might use values between 0 and 1 to represent differing cue saliences.

\code{t} - Teaching signal (a.k.a. lambda). Traditionally, 1 is used to
represent the presence of the outcome, and 0 is used to represent the
absence of the outcome, although slpMack75 supports any real values for lambda.
If you are planning to use multiple outcomes, see Note 2.

Argument \code{xtdo} (eXTenDed Output) - if set to TRUE, function will
additionally return trial-level data including attentional strengths and 
the updated associative strengths after each trial (see Value).
}

\value{

Returns a list containing three components (if xtdo = FALSE) or five
components (if xtdo = TRUE, xoutw and xouta is also returned):

\item{suma}{Vector of summed associative strength for each trial.}

\item{w}{Vector of final associative strengths.}

\item{alpha}{Vector of final attentional weights.}

\item{xoutw}{Matrix of trial-level data of the associative strengths at
  the end of the trial, after each has been updated.}

\item{xouta}{Matrix of trial-level data of the attentional strengths at
  the end of the trial, after each has been updated.}

}
\author{
  
Lenard Dome, Andy Wills, Tom Beesley

}

\references{

Kamin,  L.J. (1969). Predictability,  surprise,  attention  and  conditioning. 
In Campbell, B.A. & Church, R.M. (eds.), \emph{Punishment and  Aversive  
Behaviour}. New York: Appleton-Century-Crofts, 1969,  pp.279-296.

Le Pelley, M. E., Mitchell, C. J., Beesley, T., George, D. N., & Wills, A. J. 
(2016). Attention and associative learning in humans: 
An integrative review. \emph{Psychological Bulletin}, 142(10), 
1111–1140. https://doi.org/10.1037/bul0000064

Mackintosh, N.J. (1975). A theory of attention: {V}ariations in the
associability of stimuli with reinforcement, \emph{Psychological Review,
  82}, 276-298.

Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
A.B.(2017). Progress in modeling through distributed collaboration:
Concepts, tools, and category-learning examples. \emph{Psychology of
Learning and Motivation, 66}, 79-115.

}

\note{

  1. Mackintosh (1975) did not formalise how to update the cues' associability,
  but described when associability increases or decreases in Equation 4 and 5. 
  He assumed that the change in alpha would reflect the difference between
  the prediction error generated by the current cue and the combined influence
  (a sum) of all other cues. Le Pelley et al. (2016) provided a linear
  function in Equation 2 that adheres to this description. This expression
  is probably the simplest way to express Mackintosh's somewhat
  vague description in mathematical terms. A linear function is also 
  easier to computationally implement. So we decided to use Equation 2 from 
  Le Pelley et al. (2016) for updating attentional strengths.

  2. At present, only single-outcome experiments are officially
  supported. If you want to simulate a two-outcome study, consider using
  +1 for one outcome, and -1 for the other outcome. Alternatively, run a
  separate simulation for each outcome.

}
