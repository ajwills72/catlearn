\name{slpMBMF}
\alias{slpMBMF}
\title{
  MB/MF reinforcement learning model
}
\description{
  Gillan et al.'s (2015) model-free / model-based hybrid Reinforcement
  Learning model (see Note 1).
}
\usage{
slpMBMF(st, tr, xtdo = FALSE)
}
\arguments{
  \item{st}{List of model parameters}  
  \item{tr}{Matrix of training items}
  \item{xtdo}{Boolean. When TRUE, extended output is provided, see below}
}

\details{
  The contents of this help file are relatively brief; a more extensive
  discussion of this model can be found in the supplementary materials
  of Gillan et al. (2015).

  The function operates as a stateful list processor (slp; see Wills et
  al., 2017). Specifically, it takes a matrix (tr) as an argument, where
  each row represents a single training trial, while each column
  represents the different types of information required by the
  model. It returns a matrix of predicted response probabilities for
  each stage 1 action on each trial. The slpMBMF function also returns
  the final Q values for the model.

  The current implementation of slpMBMF deals only with relatively
  simple Reinforcement Learning experiments, of which Gillan et
  al. (2015, Exp. 2) is one example. Specifically, each trial has two
  stages. In the first stage of the trial, there is a single state, and
  the participant can emit one of \code{x} actions. In the second stage,
  there are \code{y} states. A reward follows (or doesn't) without a
  further action from the participant.

  A hybrid MB/MF model thus has \code{2x} Q-values at stage 1 (\code{x}
  for the model-based system, and \code{x} for the model-free system),
  and \code{y} Q-values at stage 2 (one for each state; there are no
  actions at stage 2, and the MB and MF systems evaluate stage 2
  Q-values the same way in this model). See Note 3.

  Argument \code{st} must be a list containing the following items:

  \code{alpha} - the model-free learning rate (range: 0-1)

  \code{lambda} - the eligibility trace parameter (range: 0-1)

  \code{w} - A number between 0 and 1, representing the relative
  contribution of the model-based and model-free parts of the model to
  the response (0 = pure model-free, 1 = pure model-based).
  
  \code{beta} - Decision stochasticity parameter

  \code{p} - Decision perseveration (p > 0) or switching (p < 0)
  parameter

  \code{tprob} - A 2 x 2 matrix of transition probabilities, used by the
  model-based system. The rows are the actions at stage 1. The columns
  are the states at stage 2. The cells are transition probabilities
  (e.g. tprob[2,1] is the probability of arriving at stage 2 state #1
  given action #2 at stage 1). 

  \code{q1.mf} - A vector of initial model-free Q values for the actions
  at stage 1.

  \code{q1.mb} - A vector of initial model-based Q values for the
  actions at stage 1.

  \code{q2} - A vector of initial Q values for the states at stage 2
  (the MB and MF systems share common Q values at stage 2).

  If you are unsure what initial Q values to use, set all to 0.5.
  
  Argument \code{tr} must be a matrix, where each row is one
  trial. Trials are always presented to the model in the order
  specified. The matrix must contain the following named columns (other
  columns will be ignored):

  \code{s1.act} - The action made by the participant at stage 1, for
  each trial; must be an integer in the range 1-\code{x}.

  \code{s2.state} - State of environment at stage 2, for each trial;
  must be an integer in the range 1-\code{y}.

  \code{t} - Reward signal for trial; must be a real number. If you're
  unsure what to use here, use 1 = rewarded, 0 = not rewarded.

}

\value{

  When xtdo = FALSE, returns a list containing these components:

  \code{out} - Matrix of response probabilities, for each stage 1 action
  on each trial.

  \code{q1.mf} - A vector of final model-free Q values for the actions at
  stage 1.

  \code{q1.mb} - A vector of final model-based Q values for the
  actions at stage 1

  \code{q2} - A vector of final Q values for the states at stage 2
  (the MB and MF systems share common Q values at stage 2).

When xtdo = TRUE, the list also contains the following model-state
information :

  \code{xout} - A matrix containing the state of the model at the end of
    each trial. Each row is one trial. It has the following columns:

  \code{q1.mb.1, q1.mb.2, \dots} - One column for each model-based Q
  value at stage 1.

  \code{q1.mf.1, q1.mf.2, \dots} - One column for each model-free Q
  value at stage 1.

  \code{q2.1, q2.2, \dots} - One column for each Q value at stage 2.

  \code{q1.h.1, q1.h.2, \dots} - One column for each hybrid Q value at
  stage 1.

  \code{s1.d.mf} - Model-free delta at stage 2, wrt. stage 1 action.

  \code{s2.d.mf} - Model-free delta at outcome. 

In addition, when xtdo = TRUE, the list also contains the following
information that is not used by the model (but which might be handy as
potential neural regressors).

  \code{s1.d.mb} - Model-based delta at stage 2, wrt. stage 1
  action.

  \code{s1.d.h} - Hybrid delta (based on stage 1 hybrid Q values) at
  stage 2, wrt. stage 1 action.

  \code{s1.d.diff} - s1.d.mf - s1.d.mb

}
\author{
  Andy Wills ( andy@willslab.co.uk ), Tom Sambrook
}
\references{

  Daw, N.D., Gershman, S.J., Seymour, B., Dayan, P., & Dolan, R.J.
  (2011). Model-based influences on humans' choices and striatal
  prediction errors. \emph{Neuron, 69}, 1204-1215.

  Gillan, C.M., Otto, A.R., Phelps, E.A. & Daw, N.D. (2015). Model-based
  learning protects against forming
  habits. \emph{Cogn. Affect. Behav. Neurosci., 15}, 523-536.
  
  Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
  A.B.(2017). Progress in modeling thrXSough distributed collaboration:
  Concepts, tools, and category-learning examples. \emph{Psychology of
  Learning and Motivation, 66}, 79-115.

}
\note{ 

  1. Gillan et al.'s (2015) choice rule, at least as stated in their
  supplementary materials, would lead to the response probabilities
  being infinite on switch trials, which is presumably an error. The
  current implementation uses Daw et al. (2011, suppl. mat., Eq. 2).

  2. Gillan et al. (2015) decay Q values for unselected actions by
  (1-alpha). This is not part of the current implementation.

  3. In the current implementation of the model, \code{x} must be 2 and
  \code{y} must be two, otherwise the model will fail or behave
  unpredictably. If you'd like to develop a more general version of this
  implementation, contact the author. 

}
