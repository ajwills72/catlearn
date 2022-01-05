\name{slpNNCAG}
\alias{slpNNCAG}
\title{
A Neural Network with Competitive Attentional Gating (NNCAG)
}

\description{

  This is Model 4 from Paskewitz and Jones (2020).  Model 4 is a Neural
  Network with Competitive Attentional Gating - a fragmented version of
  EXIT (Kruschke, 2001) lacking exemplar-based rapid attentional shifts.

}
\usage{

slpNNCAG(st, tr, xtdo = FALSE)

}
\arguments{
  \item{st}{ List of model parameters}
  \item{tr}{ R matrix of training items}
  \item{xtdo}{ Boolean specifying whether to include extended
    information in the output (see below).}
}

\details{

The function operates as a stateful list processor (slp; see Wills et
al., 2017). Specifically, it takes a matrix (tr) as an argument, where
each row represents a single training trial, while each column
represents the different types of information required by the model,
such as the elemental representation of the training stimuli, and the
presence or absence of an outcome.

Argument \code{st} must be a list containing the following items:

\code{P} - attention normalization constant, \eqn{P}.

\code{phi} - decision-making constant, \eqn{\phi}, also referred to as
specificity constant.

\code{lambda} - learning rate, \eqn{\lambda}.

\code{mu} - attentional learning rate, \eqn{\mu}.

\code{outcomes} - The number of categories.

\code{w} - a \eqn{k \times i}{k by i} matrix of initial weights, where
\eqn{k} equals to the number of categories and \eqn{i} equals to the
number of stimuli.

\code{eta} - \eqn{\eta}, a vector with \eqn{i} elements, where
\eqn{\eta^{th}}{\eta -th} is the salience of the \eqn{i^{th}}{i -th}
cue. In edge cases, \eqn{\eta} is capped at lower bound of 0.1, see Note
1.

\code{colskip} - The number of optional columns to be skipped in the tr
matrix. colskip should be set to the number of optional columns you have
added to the tr matrix, PLUS ONE. So, if you have added no optional
columns, colskip=1. This is because the first (non-optional) column
contains the control values (details below).

Argument \code{tr}must be a matrix, where each row is one trial
presented to the model. Trials are always presented in the order
specified. The columns must be as described below, in the order
described below:

\code{ctrl} - a vector of control codes. Available codes are: 0 = normal
trial; 1 = reset model (i.e. set matrix of initial weights and vector of
salience back to their initial values as specified in \code{st}); 2 =
Freeze learning. Control codes are actioned before the trial is
processed.

\code{opt1, opt2, \dots} - any number of preferred optional columns, the
names of which can be chosen by the user. It is important that these
columns are placed after the control column, and before the remaining
columns (see below). These optional columns are ignored by the function,
but you may wish to use them for readability. For example, you might
choose to include columns such as block number, trial number and
condition. The argument colskip (see above) must be set to the number of
optional columns plus one.

\code{x1, x2, \dots} - columns for each cue (\code{1} = cue present,
\code{0} = cue absent). There must be one column for each input
element. Each row is one trial. In simple applications, one element is
used for each stimulus (e.g. a simulation of blocking (Kamin, 1969), A+,
AX+, would have two inputs, one for A and one for X). In simple
applications, all present elements have an activation of 1 and all
absent elements have an activation of 0. However, slpNNCAG supports any
real number for activations.

\code{t1, t2, \dots} - columns for the teaching values indicating the
category feedback on the current trial. Each category needs a single
teaching signal in a dummy coded fashion, e.g., if there are four
categories and the current stimulus belongs to the second category, then
we would have \code{[0, 1, 0, 0]}.  }

\value{

Returns a list containing three components (if xtdo = FALSE) or four
components (if xtdo = TRUE).

if \code{xtdo = FALSE}:

  \item{p}{Response probabilities for each trial (rows) and each
    category (columns).}
  
  \item{final_eta}{Salience at the end of training. \eqn{\eta} for each
    stimulus \eqn{i}.}
  
  \item{final_weights}{An \eqn{k \times i}{k by i} weight matrix at the end of
  training, where rows are categories and columns are stimuli. Order of
  stimuli and categories correspond to their order in \code{tr}.}

if \code{xtdo = TRUE}, the following values are also returned:

  \item{model_predictions}{The matrix for trial-level predictions of the
    model as specified by Equation 5 in Paskewitz and Jones (2021).}
  
  \item{eta}{The updated salience at the end of each trial.}

}
\author{
Lenard Dome, Andy Wills

}

\seealso{
  \code{\link{slpEXIT}}
}

\note{

1. If there is only one stimulus present on a given trial with
\eqn{\eta} = \code{0} or with \eqn{g} = \code{0}, Equation 12 of
Paskewitz & Jones (2020) breaks down. In order to avoid this, \eqn{eta}
and \eqn{g} are capped at the lower limit of \code{0.01}.

2. This model is implemented in C++ for speed.

}

\references{

Kamin, L.J. (1969). Predictability, surprise, attention and
conditioning.  In Campbell, B.A. & Church, R.M. (eds.), \emph{Punishment
and Aversive Behaviour}. New York: Appleton-Century-Crofts, 1969,
pp.279-296.

Kruschke, J. K. (2001). Toward a unified model of attention in
associative learning. \emph{Journal of Mathematical Psychology, 45(6)},
812-863.

Paskewitz, S., & Jones, M. (2020). Dissecting EXIT. \emph{Journal of
Mathematical Psychology, 97}, 102371.

Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
A.B.(2017). Progress in modeling through distributed collaboration:
Concepts, tools, and category-learning examples. \emph{Psychology of
Learning and Motivation, 66}, 79-115.

}
