\name{slpLMSnet}
\alias{slpLMSnet}

\title{
  Gluck & Bower (1988) network model
}

\description{
Gluck and Bower (1988) adaptive least-mean-square (LMS) network
}

\usage{

slpLMSnet(st, tr, xtdo = FALSE)

}

\arguments{

  \item{st}{List of model parameters}
  
  \item{tr}{Numerical matrix of training items, use \code{data.matrix()} if
      matrix is not numeric.}
  
  \item{xtdo}{Boolean specifying whether to include extended information
  in the output (see below)}

}

\value{

Returns a list with the following items if \code{xtdo = FALSE}:

    \item{p}{Probabilites of responses on each trial, as output by the
        logistic choice function (Eq. 7, and Footnote 2, in Gluck and
        Bower, 1988).}

    \item{nodeActivation}{Output node activations on each trial, as
        output by Equation 3 in Gluck and Bower (1988).}
    
    \item{connectionWeightMatrix}{A connection weight matrix, W, where each 
        row represents the corresponding element in the teaching signals array
        in \code{tr}, while each column represents the corresponding element
        from the input activation array from \code{tr}. So cell \eqn{w_12} would
        be the connection weight between the second stimulus and the first
        category.}

If \code{xtdo = TRUE}, the following item also returned:
    
    \item{squaredDifferences}{The least mean squeared differences between
        desired and actual activations of output nodes on each trial
        (Eq. 4 in Gluck and Bower, 1988). This metric is an indicator of
        the network's performance, which is measured by its accuracy.}

}

\details{

The function operates as a stateful list processor (slp; see Wills et al., 2017).
Specifically, it takes a matrix as an argument. Each row represents a
single trial. Each column represents different types of
information required by the implementation of the model, such as the elemental
representation of stimuli, teaching signals, and other variables specifying
the model's behaviour (e.g. freezing learning).

Argument \code{st} must be a list containing the following items:

\code{beta} - the learning rate (fixed for a given simulation) for the LMS
    learning rule. The upper bounds of this parameter is not specified, but
    we suggest \eqn{0 < beta  \le 1}.

\code{theta} - is a positive scaling constant. When theta rises, the logistic
    choice function will become less linear. When theta is high, the logistic
    function will approximate the behaviour of a step function.

\code{bias} - is a bias parameter. It is the value of the output
  activation that results in an output rating of P = 0.5. For example,
  if you wish an output activation of 0.4 to produce a rated probability
  of 0.5, set beta to 0.4. If you are not sure what to use here, set it to
  0. The bias parameter is not part of the original Gluck and Bower (1988)
  LMS network, see Note 1.

\code{w} - is a matrix of initial connection weights, where each row is an 
    outcome, and each column is a feature or cue. If you are not sure what to
    use here, set all values to 0.

\code{outcomes} - is the number of possible categories or outcomes.

\code{colskip} - the number of optional columns to be skipped in the tr matrix.
    colskip should be set to the number of optional columns PLUS ONE. So, if
    you have added no extra columns, colskip = 1.


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
    columns (see below). These optional columns are ignored by the slpLMSnet
    function, but you may wish to use them for readability. For example, you
    might choose to include columns such as block number, trial number and
    condition. The argument colskip (see above) must be set to the number of
    optional columns plus one.

\code{x1, x2, \dots} - activation of input nodes of corresponding features.
    Feature patterns usually represented as a bit array. Each element in the
    bit array encodes the activations of the input nodes given the presence or
    absence of the corresponding features. These activations can take on either
    1 or 0, present and absent features respectively. For example, Medin and 
    Edelson's (1988) inverse base-rate effect with stimuli AB and AC can be 
    represented as [1 1 0] and [1 0 1] respectively. In a more unconventional
    scenario, you can set activation to vary between present 1 and absent -1,
    see Note 2. slpLMSnet can also support any positive or negative real number
    for activations, e.g. one might use values between 0 and 1 to represent the 
    salience of the features.

\code{d1, d2, \dots} - teaching input signals indicating the category feedback
    on the current trial. It is a bit array, similar to the activations of
    input nodes. If there are two categories and the stimuli on the current
    trial belongs to the first, then this would be represented in \code{tr} as
    [1 0], on edge cases see Note 3. The length of this array must be provided
    via \code{outcomes} in \code{st}.
    
}

\author{
   Lenard Dome, Andy Wills 
}

\references{

    Gluck, M. A., & Bower, G. H. (1988). From conditioning to category 
    learning: An adaptive network model. \emph{Journal of Experimental
    Psychology: General, 117}, 227-247.

    Markman, A. B. (1989). LMS rules and the inverse base-rate effect:
    Comment on Gluck and Bower (1988). \emph{Journal of Experimental
    Psychology: General, 118}, 417-421.
    
    Medin, D. L., & Edelson, S. M. (1988). Problem structure and the use of 
    base-rate information from experience. \emph{Journal of Experimental
      Psychology: General, 117}, 68-85.

    Nosofsky, R.M., Gluck, M.A., Plameri, T.J., McKinley, S.C. and
  Glauthier, P.  (1994). Comparing models of rule-based classification
  learning: A replication and extension of Shepaard, Hovland, and
  Jenkins (1961). \emph{Memory and Cognition, 22}, 352-369.

    Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
    A.B.(2017). Progress in modeling through distributed collaboration:
    Concepts, tools, and category-learning examples. \emph{Psychology of
    Learning and Motivation, 66}, 79-115.
    
}

\note{

    1. The \code{bias} parameter is not part of the original Gluck and
    Bower (1988) model. \code{bias} in the current implementation helps
    comparisons between simulations using the \code{act2probrat}
    logistic choice function. Set bias to 0 for operation as specified
    in Gluck & Bower (1988). Also note that, where there is more than
    one output node, the same bias value is subtracted from the output
    of each node. This form of decision mechanism is not present in the
    literature as far as we are aware, although using a negative bias
    value would, in multi-outcome cases, approximate a 'background
    noise' decision rule, as used in, for example, Nosofsky et
    al. (1994).

    2. slpLMSnet can support both positive and negative real numbers as
    input node activations. For example, one might wish to follow
    Markman's (1989) suggestion that the absence of a feature element is
    encoded as -1 instead of 0.

    3. slpLMSnet can process a bit array of teaching signals, where the
    model is told that the stimuli belongs to more than one
    category. slpLMSnet uses matrix operations to update weights, so it
    can encode and update multiple teaching signals on the same trial.
    
}

\examples{

## load catlearn
library(catlearn)

## create st with initial state
st <- list(beta = 0.025, # learning rate
           theta = 1, # decision scaling parameter
           bias = 0, # decision bias parameter
           # initial weight matrix, 
           # row = number of categories,
           # col = number of cues
           w = matrix(rep(0, 6*4), nrow = 4, ncol = 6),
           outcomes = 4, # number of possible outcomes
           colskip = 3)

## create inverse base-rate effect tr for 1 subject and without bias cue
tr <- krus96train(subjs = 1, ctxt = FALSE)

# run simulation and store output
out <- slpLMSnet(st, data.matrix(tr))

out$connectionWeightMatrix
}
