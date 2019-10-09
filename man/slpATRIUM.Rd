\name{slpATRIUM}
\alias{slpATRIUM}
\title{
  
  ATRIUM category learning model

}
\description{

  Attention To Rules and Instances in a Unified Model (Erickson &
  Kruschke (1998). See Note 1.

}
\usage{

slpATRIUM(st, tr, xtdo = FALSE)

}
\arguments{

  \item{st}{List of model parameters}

  \item{tr}{R-by-C matrix of training trials}
  
  \item{xtdo}{Boolean specifying whether to include extended information
    in the output (see below)}
    . If \code{FALSE} a matrix of category predictions 
  is returned only (n-rows, and m-columns for each n-trial and each m-
  category as presented to the model in  \code{tr}, see below. If \code{TRUE} 
  extended output is returned for all network nodes that are updated in 
  Equations 5, 12, 13, 14 and 15, for every trial presented to the model,
  see below.}
}  

\value{

  Returns a list with the follwing items if \code{xtdo = FALSE}:

  \item{prob}{A matrix of response proabilities for each output unit on
  each trial.}

  
}


\details{
  Argument \code{tr} must be a numeric matrix. Each row is one trial
  presented to the network, in the order of their occurence.
  \code{tr} requires the following columns.

\code{x1, x2, \dots} - columns for each feature dimension carrying 
  numeric values of the stimulus features, which are represented
  on a continuous scale. Thus, each column \code{\dots, x2, x3, \dots}
  represents a stimulus dimension. They have to start with \code{x1} 
  ascending with dimensions \code{\dots, x2, x3, \dots} at adjacent 
  columns.

\code{t1, t2, \dots} - columns for the teaching values indicating the
  present category on a given trial. Thus, the columns represent dummy coded
  categorird. In each row values of \code{\dots, t2, t3, \dots} 
  indicate whether a category was present with \code{1}, or absent
  with \code{0}. However, a value different from \code{1} will
  be considered as absence of the category in any case. Again, these 
  columns have to start with \code{t1} ascending with categories 
  \code{\dots, t2, t3, \dots} at adjacent columns.

\code{tr} also requires a column \code{ctrl}, which gives control 
  over the network learning over trials. If \code{ctrl} is set to 
  \code{1} all network nodes are (re-)intialized to 0, and
  learning starts from scratch (again). Thus, multiple tasks or participants
  can be processed simultaneously for a given set of parameters (i.e.,
  if separated with \code{ctrl} = 1 in every first trial.)
  Setting \code{ctrl} to \code{0} represents a normal learning trial. If 
  \code{ctrl} is set to \code{2} the network learning is frozen at the 
  current state of learning for testing predictions on new trials 
  without teaching signals. 

\code{tr} may contain additional (numeric) columns with any desired 
  name, e.g. for readability. As long as the feature columns 
  \code{x1, x2, \dots} and the category columns \code{t1, t2, \dots} are 
  provided as defined (i.e. not scattered, across the range of matrix 
  columns), and as long as they have different column names, the output 
  is not affected by additional columns. 

Argument \code{st} must be a list containing the following required
  items: \code{nFeat}, \code{nCat},.... 

\code{nFeat} - integer indicating the total number of stimulus dimensions, 
  i.e. the number of \code{x1, x2, \dots} columns in \code{tr}.

\code{nCat} - integer indicating the total number of categories, i.e. the 
  number of \code{t1, t2, \dots} columns in \code{tr}.

\code{st} also requires the following items, which refer to the 
  model parameters. The corresponding equations in Erickson & Kruschke 
  (1998) are referenced in brackets.

\code{beta} - (Equation 1) a numeric vector indicating the boundaries between 
  stimuli on each dimension, and is of length n, where n denotes the number of 
  stimulus dimensions in their order corresponding to \code{x1, x2, \dots} in 
  \code{tr}. For instance, with 3 dimensions (n = 3), then \code{beta} should 
  be c(beta1,beta2,beta3), where beta1 denotes the -1*midpoint on dimension 1 
  (i.e. \code{x1} as defined in \code{tr}. Boundaries have to be -negative- 
  (-1*), due to the formulation of Eq 1. \code{beta} is required for all 
  dimensions but only become effective if a dimension is chosen to be a rule 
  dimension (see \code{primedim} below).

\code{prime_dim} - single integer, or integer vector of length n, indicating
  the dimension(s) that receives a rule, corresponding to \code{x1, x2, \dots}.
  E.g. if \code{prime_dim}=c(1,3) then dimensions \code{x1} and \code{x3} 
  will receive rule modules (n=2). In Erickson & Kruschke (1998) there is 
  only one "primary dimension" with a rule, although the stimuli 
  have two dimensions. However, for which dimension a rule is learned 
  is generally unknown to the experimenter and thus can be treated as a free 
  parameter, which you could estimate for inference. Please make sure, that 
  appropriate boundaries are set (or estimated) in \code{beta}, as well. 
  E.g. at -1*midpoints of dimensions \code{x1} and \code{x3}, as\code{prime_dim} 
  serves as index for the boundaries.
 
\code{y_r} - (Equation 1) rule gain. Has to be a numeric vector of length n, 
  where n is the number of dimensions. Again, the indices of \code{y_r} 
  correspond to \code{x1, x2, \dots} in order. Since the rule gain is not fully 
  specified for multiple rules in Erickson & Kruschke (1998), \code{y_r} could 
  be used in two ways. First, as general output scaling (or sensitivity) of the 
  rule module, i.e. if all values of \code{y_r} are set to be equal. And second, 
  it could also be used as dimension/rule specific gain, acting similar to a 
  dimension attention weight. That is if the values of \code{y_r} differ between 
  dimensions, then higher values indicate a higher sensitivity to changes
  on a dimension. Since attention (\code{alpha} see below) is rather learned
  to shift away from dimensions on which exemplars make wrong predictions,
  having dimension specific \code{y_r} seems reasonable. For example, 
  with three dimensions each having a rule then \code{y_r} = c(1,2,1), indicates
  that the predictions are most sensitive to changes on \code{x2}, assuming that
  they are equally scaled. However, please note, this is only descriptive and
  not tied to a learning rule.

\code{c} - (Equation 3) exemplar similarity/sensitivity gradient in the exemplar 
  module. Has to be a postive numeric value. (Large values lead to less strong
  generalization of exemplars.)

\code{y_g} - gate gain obtained in Equation 5, for mixing of exemplar and rule 
  outputs in Equation 6.. Has to be a positive numeric value. Higher 
  values of \code{y_g} will lead to rather 'deterministic' selection of one of 
  the two modules. (\code{y_g} is set to 1 in Erickson & Kruschke (1998)).

\code{beta_g} - (Equation 5) gate bias. Has to be a numeric value. Positive 
  values bias (give additional weight) towards the exemplar module, negative 
  values bias towards the rule model solutions, when both predictions are mixed 
  in Equation 6. For instance, if \code{beta_g} = -5, then the rule module
  will be nearly fully activated in the beginning of learning, and later
  (more or less) depending on learning.

\code{phi} - (Equation 6) response scaling parameter. Has to be a positive 
  numeric value. Values larger than 1 lead to more deterministic response 
  probabilities (does not affect learning).

\code{cost} - (Equations 9 & 10). Has to be a postive numeric vector of length 
  2, where the first index refers to the (learning) cost for the exemplar 
  module, and the second index refers to the (learning) cost of the rule 
  modules. The cost parameters are not further justified or specified in 
  Erickson & Kruschke (1998), and were set to 1 during their estimations, 
  which would be c(1,1) in the current implementation. 
  In the corresponding Equations 9 & 10 the \code{cost} acts like a module 
  specific (de-)amplifier of the error signal. E.g. setting the values of 
  \code{cost} to c(10^5,10^5) will always lead to learning weights (in later 
  equations) equal for both modules (i.e., EA=1, RA=1, and EA/(EA+RA)=.5), 
  regardless of their current accuracy in predicting the present outcome. 
  However, since the cost values also are multiplied with (e.g.) RA/MA, it
  cost also acts nearly identical as lambda_r and lambda_e (except for
  having the additional function of scaling RA and EA.). Thus, handle the  
  cost values with special care (or simply set them to c(1,1)).
  With \code{cost} set to c(1,1) the later EA and RA learning weights depend on 
  the module specific accuracy only. 

\code{lambda_r} - (Equation 12) rule module learning rate. Has to be a positive 
  numeric value.

\code{lambda_e} - (Equation 13) exemplar module learning rate. Has to be a 
  positive numeric value.

\code{lambda_a} - (Equation 14) attention learning rate. Has to be a positive 
  numeric value.

\code{lambda_g} - (Equation 15) gate-node learning rate. Has to be a positive 
  numeric value.
  
\code{exemplars} Must be numeric matrix with n rows, representing the n exemplars, and m columns representing the m dimensions \code{x1,x2 \dots}.
The matrix cells must contain the corresponding values of the exemplars on 
each dimension.


\author{René Schlegelmilch, Andy Wills}

\references{
  Erickson, M. A., & Kruschke, J. K. (1998). Rules and exemplars in category 
  learning. Journal of Experimental Psychology: General, 127(2), 107.
  Kruschke, J. K. (1992). ALCOVE: an exemplar-based connectionist model of 
  category learning. Psychological review, 99(1), 22.
}

\note{

  1. ATRIUM uses ALCOVE as its exemplar module. We have assumed this is
  a standard implementation of ALCOVE, and that hence the 0 in Equation
  7 of Erickson & Kruschke (1998) is actually meant to be a -1 (as in
  Equation 4B of Kruschke, 1992). 
  
  }
