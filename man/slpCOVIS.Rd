\name{slpCOVIS}
\alias{slpCOVIS}
\title{
COVIS category learning model
}
\description{
  
  COmpetition between Verbal and Implicit Systems model of category
  learning (Ashby et al. 1998), as described in Ashby et al. (2011). The
  current implementation supports two-category experiments, and uses
  only single-dimension, not-below-chance, rules in the Explicit system.

}
\usage{

slpCOVIS(st, tr, crx = TRUE, respt = FALSE, rgive = TRUE, xtdo = FALSE)

}
\arguments{
  
  \item{st}{List of model parameters}
  
  \item{tr}{R-by-C matrix of training items}
  
  \item{crx}{Boolean. Explicit System. If set to TRUE, the current rule
  is included in the random selection of a rule to receive a weight
  increase from the Possion distribution. If set to FALSE, the current
  rule is not included in this random selection.}

  \item{respt}{Set to FALSE for the behaviour described in Note 5;
  behaviour when TRUE is undocumented}
              
  \item{rgive}{Set to TRUE; FALSE is undocumented}

  \item{xtdo}{Set to FALSE; TRUE is undocumented}
  
}  
  
\value{
  
  Returns a List containing eight components:

  \item{foutmat}{A two-column matrix, representing the model's response
  on each trial. For any given trial, [1,0] indicates a Category 1
  response; [0,1] indicates a Category 2 response. Responses are
  reported in this manner to facilitate cross-compatibility with models
  that produce response probabilities on each trial.}

  \item{frules}{Explicit system - rule saliences after final trial}

  \item{fsystr}{Procedural system - cortico-striatal synaptic strengths
    after final trial)}

  \item{fetrust}{Decision system - trust in explicit system after final
    trial}

  \item{fitrust}{Decision system - trust in procedural system after
    final trial}

  \item{frule}{Explicit system - rule used by explicit system on final
    trial}

  \item{fprep}{Implicit system - predicted reward value on final trial}

  \item{fprer}{Implicit system - obtained reward value on final trial}

}

\details{

  The coverage in this help file is relatively brief; for a more
  extensive tutorial, see Inkster et al. (n.d.).

  The function works as a stateful list processor (slp; see Wills et
  al., 2017). Specifically, it takes a matrix (tr) as an argument, where
  each row is one trial for the network, and the columns specify the
  input representation. It returns a List containing the predictions
  made by the model and the final state of the model, hence its
  description as a 'stateful' list processor.

  Argument \code{st} must be a list containing the following
  information. Parameter names given in brackets in the descriptions
  below follow the naming conventions of Ashby et al. (2011), and
  Edmunds & Wills (2016). Equation numbers are from Ashby et al. (2011);
  where there is no equation, the page number is given instead.

  Explicit system variables:

  \code{envar} - (sigma^2_E) - p. 68 - Variance of the noise distribution
  used to determine which response the explicit system makes on the
  current trial. See Note 4, below.
 
  \code{decbound} - (C) - Eq. 1 - location of the decision bound on a
  single dimension. In the current implementation of slpCOVIS, this
  location is the same for all dimensions.
  
  \code{corcon} - (delta_c) - Eq. 2 - constant by which to increase
  current rule saliency in the case of a correct response.
  
  \code{errcon} - (delta_e) - Eq. 3 - constant by which to decrease
  current rule saliency in the case of an incorrect response.
  
  \code{perscon} - (gamma) - Eq. 4 - perseveration constant, i.e. value
  to add to the salience of the current rule to obtain its rule weight.

  \code{lambda} - (lambda) - Eq. 5 - Mean of the Poission
  distribution. A value randomly sampled from the Poisson distribution
  is added to a randomly-selected rule when calculating the weights for
  new rule selection.
  
  \code{decsto} - (a) - Eq. 7 - decision stochasticity when using rule
  weights to select the rule for the next trial. For Ashby et
  al. (2011)'s implementation, a = 1. For other uses, see Edmunds &
  Wills (2016).

  Procedural system variables:

  \code{sconst} - (alpha) - Eq. 8 - scaling constant for cortical unit
  activation. See Note 3, below.
  
  \code{invar} - (sigma^2_p) - Eq. 9 - Variance of the
  normally-distributed noise used to calculate striatal unit activation.
 
  \code{dbase} - (D_base) - Eq. 10 - baseline dopamine level.

  \code{alphaw} - (alpha_w) - Eq. 10 - Learning rate parameter in force
  when striatal activation is above the NMDA threshold, and dopamine is
  above baseline.

  \code{betaw} - (beta_w) - Eq. 10 - Learning rate parameter in force
  when striatal activation is above the NMDA threshold, and dopamine is
  below baseline.

  \code{gammaw} - (gamma_w) - Eq. 10 - Learning rate parameter in force
  when striatal activation is between the AMPA and NMDA thresholds.

  \code{nmda} - (theta_NMDA) - Eq. 10 - Activation threshold for
  post-synaptic NMDA.

  \code{ampa} - (theta_AMPA) - Eq. 10 - Activation threshold for
  post-synaptic AMPA. See Note 1, below.

  \code{wmax} - (w_max) - Eq. 10 - Intended upper weight limit for a
  cortico-striatal link. See Note 2, below.
 
  \code{prep} - ( P_(n-1) ) - Eq. 12 - predicted reward value
  immediately prior to first trial. If unsure, set to zero.

  \code{prer} - ( R_(n-1) ) - Eq. 12 - obtained reward value immediately
  prior to first trial. If unsure, set to zero.

  Competition / decision system variables:
  
  \code{emaxval} - p.77 - The maximum possible value of the the Explicit
  system's discriminant variable. For example, if the stimulus value
  varies from zero to one, and C (see above) is 0.5, then the maximum
  value is 1-0.5 = 0.5
  
  \code{etrust} - (theta_E) - Eq. 15 - trust in the explicit system
  immediately prior to first trial. If unsure, set to .99.

  \code{itrust} - (theta_P) - p. 77 - trust in the procedural system
  immediately prior to first trial. If unsure, set to .01. See also Note
  7, below.

  \code{ocp} - (delta_OC) - Eq. 15 - constant used to increase trust in
  the Explicit system after it suggests a response that turns out to be
  correct.
  
  \code{oep} - (delta_OE) - Eq. 16 - constant used to decrease trust in
  the Explicit system after it suggests a response that turns out to be
  incorrect.

  Initial state of model:
  
  \code{initrules} - vector of length \code{stimdim}, representing the
  initial salience of each single-dimensional rule in the Explicit
  system.
  
  \code{crule} - a number indicating which rule is in use immediately
  prior to the first trial (1 = dimension 1, 2 = dimension 2, etc). If
  this is not meaningful in the context of your simulation, set it to
  zero, and ensure ctrl = 1 in the first row of your training matrix
  (see below). This will then randomly pick an initial rule.

  \code{initsy} - matrix of \code{stimdim} rows and two columns -
  contains the initial values for the cortico-striatal connection
  strengths.

  \code{scups} - matrix of \code{stimdim} columns and as many rows as
  you wish to have cortical input units. Each row represents the
  position of a cortical unit in N-dimensional stimulus space.

  And finally, a couple of things slpCOVIS needs to interpret your tr
  matrix (see below):

  \code{stimdim} - number of stimulus dimensions in the input
  representation.

  \code{colskip} - skip the first N columns of the tr array, where N =
  colskip. colskip should be set to the number of optional columns you
  have added to matrix tr, PLUS ONE. So, if you have added no optional
  columns, colskip = 1. This is because the first (non-optional) column
  contains the control values, see below.

Argument \code{tr} must be a matrix, where each row is one trial
presented to the network. Trials are always presented to the model in
the order specified. The columns must be as described below, in the
order described below:
  
  \code{ctrl} - vector of control codes. Available codes are: 0 = normal
  trial, 1 = reset network (i.e. set back to the state defined in list
  \code{st} and randomly select an initial rule for the Explicit System
  using Eq. 7) , 2 = Freeze learning. Control codes are actioned before the
  trial is processed.
  
  \code{opt1, opt2, \dots} - optional columns, which may have any names
  you wish, and you may have as many as you like, but they must be
  placed after the ctrl column, and before the remaining columns (see
  below). These optional columns are ignored by this function, but you
  may wish to use them for readability. For example, you might include
  columns for block number, trial number, and stimulus ID number. The
  argument colskip (see above) must be set to the number of optional
  columns plus 1.

  \code{x1, x2, \dots} - stimulus input to the model; there must be one
  column for each stimulus dimension. 

  \code{t1} - teaching signal to model. If the correct response is
  Category 1, t = 1. If the correct response is Category 2, t =
  -1. Experiments with something other than two categories are not
  supported in the current implementation.

  \code{optend1, optend2, \dots} - optional columns, which may have any
  names you wish, and you may have as many as you like, but they must be
  placed after the t1 column. These optional columns are ignored by this
  function, but may help with cross-compatibility with other model
  implementations. For example, the additional 't' and 'm' columns of
  input representations generated for slpALCOVE will be safely ignored
  by slpCOVIS.

}

\author{
  
Angus Inkster, Andy Wills, Charlotte Edmunds

}

\references{

Ashby, F.G., Alfonso-Reese, L.A., Turken, A.U. & Waldron, E.M. (1998).
A neuropsychological theory of multiple systems in category learning.
\emph{Psychological Review, 105}, 442-481.

Ashby, F.G., Paul, E.J., & Maddox, W.T. (2011). COVIS. In Pothos, E.M. &
Wills, A.J. (2011). \emph{Formal approaches in
  categorization}. Cambridge, UK: Cambridge University Press.

Edmunds, C.E.R., & Wills, A.J. (2016). Modeling category learning using
a dual-system approach: A simulation of Shepard, Hovland and Jenkins
(1961) by COVIS. In A. Papfragou, D. Grodner, D. Mirman, &
J.C. Trueswell (Eds.). \emph{Proceedings of the 38th Annual Conference
of the Cognitive Science Society} (pp. 69-74). Austin, TX: Cognitive
Science Society.

Inkster, A.B., Edmunds, C.E.R., & Wills, A.J. (n.d.). A
distributed-collaboration resource for dual-process modeling in category
learning. \emph{Manuscript in preparation}.

Pothos, E.M. & Wills, A.J.(2011). \emph{Formal approaches in 
Categorisation.}Cambridge: University Press.

Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
A.B.(2017). Progress in modeling through distributed collaboration:
Concepts, tools, and category-learning examples. \emph{Psychology of
  Learning and Motivation, 66}, 79-115.

}

\note{

  1. Ashby et al. (2011) state (p. 74) that the intended operation of
  COVVIS is theta_NMDA > theta_AMPA, but the values they report are
  theta_NMDA = .0022, theta_AMPA = .01.

  2.  Ashby et al. (2011) did not specify a value for w_max; Edmunds &
  Wills (2016) assumed the intended value was 1.

  3. Ashby et al. (2011) do not use Eq. 8 in their simulation, they
  manually set sensory cortex activation to 1 for the presented stimulus
  and 0 for all the others (p. 78). They thus do not have a value for
  alpha. Edmunds & Wills (2016) set alpha to 0.14, which produces
  similar behaviour for 0,1 coded stimulus dimensions, without having to
  manually set the activations.

  4. In Ashby et al. (2011) and Edmunds & Wills (2016), sigma^2_E is set
  to zero. In this implementation of slpRW, positive values should also
  work but have not been extensively tested.

  5. In the descriptions provided by Ashby et al. (2011, p. 69 & p. 75),
  there is some ambiguity about the meaning of the term 'response' -
  does this mean the response of a system (e.g. the Explicit system), or
  the overall response (i.e. the output of the decision system). In the
  current implementation, the response of the Explicit System is
  compared to the feedback to determine whether the Explicit System was
  correct or incorrect, and the response of the Procedural System is
  compared to the feedback to determine whether the Procedural System
  was correct or incorrect.

  6. It seems that in Ashby et al.'s (2011) simulations, each dimension
  generates only one single-dimension rule for a two-category problem,
  rather than two as one might expect (e.g. small = A, large = B, but
  also large = A, small = B). Rules that would produce below-chance
  responding are excluded from the rule set.

  7. Ashby et al. (2011) state that theta_E + theta_P = 1. However,
  slpCOVIS does not perform this check on the initial state, so it is
  important to check this manually. 

  }