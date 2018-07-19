\name{slpEXIT}
\alias{slpEXIT}
\encoding{UTF-8}
\title{
  EXIT Category Learning Model
}
\description{
  EXemplar-based attention to distinctive InpuT model (Kruschke, 2001)
  
}
\usage{
  slpEXIT(st, tr, xtdo = FALSE)
}
\arguments{
  
  \item{st}{List of model parameters}
  
  \item{tr}{R-by-C matrix of training items}
  
  \item{xtdo}{if \code{TRUE} extended output is returned}
}  

\value{

  Returns a list containing three components (if xtdo = FALSE) or four
  components (if xtdo = TRUE, \code{g} is also returned):

  \item{p}{Matrix of response probabilities for each outcome on each
    trial}

  \item{w_in_out}{Matrix of final cue -> outcome associative strengths}

  \item{w_exemplars}{Matrix of final cue -> exemplar associative
    strengths}

  \item{g}{Vector of gains at the end of the final trial}
  
}

\details{

  The contents of this help file are relatively brief; a more extensive
  tutorial on using slpEXIT can be found in Spicer et al. (n.d.).

  The functions works as a stateful list processor. Specifically, it
  takes a data frame as an argument, where each row is one trial for the
  network, and the columns specify the input representation, teaching
  signals, and other control signals. It returns a matrix where each row
  is a trial, and the columns are the response probabilities at the
  output units. It also returns the final state of the network (cue ->
  exemplar, and cue -> outcome weights), hence its description as a
  'stateful' list processor.

  References to Equations refer to the equation numbers used in the
  Appendix of Kruschke (2001). 
  
  Argument \code{tr} must be a data frame, where each row is one trial
  presented to the network, in the order of their occurence.
  \code{tr} requires the following columns:
  
  \code{x1, x2, \dots} - columns for each cue (\code{1} = cue present,
  \code{0} = cue absent). These columns have to start with \code{x1}
  ascending with features \code{\dots, x2, x3, \dots} at adjacent
  columns. See Notes 1, 2.
  
  \code{t1, t2, \dots} - columns for the teaching values indicating the
  category feedback on the current trial. Each category needs a single
  teaching signal in a dummy coded fashion, e.g., if the first category
  is the correct category for that trial, then \code{t1} is set to
  \code{1}, else it is set to \code{0}. These columns have to start with
  \code{t1} ascending with categories \code{\dots, t2, t3, \dots} at
  adjacent columns.

  \code{ctrl} - vector of control codes. Available codes are: 0 = normal
  trial, 1 = reset network (i.e. reset connection weights to the values
  specified in \code{st}). 2 = freeze learning. Control codes are
  actioned before the trial processed.
  
  \code{opt1, opt2, ...} - optional columns, which may have any name you
  wish. These optional columns are ignored by this function, but you may
  wish to use them for readability. For example, you might include
  columns for block number, trial number, and stimulus ID..

  Argument \code{st} must be a list containing the following items:

  \code{nFeat} - integer indicating the total number of possible
  stimulus features, i.e. the number of \code{x1, x2, \dots} columns in
  \code{tr}.
  
  \code{nCat} - integer indicating the total number of possible
  categories, i.e. the number of \code{t1, t2, \dots} columns in
  \code{tr}.
  
  \code{phi} - response scaling constant - Equation (2)
  
  \code{c} - specificity parameter. Defines the narrowness of 
  receptive field in exemplar node activation - Equation (3).
  
  \code{P} - Attentional normalization power (attentional capacity) -
  Equation (5). If \code{P} equals \code{1} then the attention weights
  will satisfy the constraint that attention strength for currently
  present features will sum to one. The sum of attention strengths for
  present features grows as a function of \code{P}.
  
  \code{l_gain} - attentional shift rate - Equation (7)
  
  \code{l_weight} - learning rate for feature to category associations.
  - Equation (8)
  
  \code{l_ex} - learning rate for exemplar_node to gain_node associations
  - Equation (9)
  
  \code{iterations} - number of iterations of shifting attention on each
  trial (see Kruschke, 2001, p. 1400). If you're not sure what to use
  here, set it to 10.
  
  \code{sigma} - Vector of cue saliences, one for each cue. If you're
  not sure what to put here, use 1 for all cues except the bias cue. For
  the bias cue, use some value between 0 and 1. 
 
  \code{w_in_out} - matrix with \code{nFeat} columns and \code{nCat} rows,
  defining the input-to-category association weights, i.e. how much each
  feature is associated to a category (see Equation 1). The \code{nFeat} 
  columns follow the same order as \code{x1, x2, \dots} in \code{tr}, 
  and likewise, the \code{nCat} rows follow the order of  
  \code{t1, t2, \dots}.

  \code{exemplars} - matrix with \code{nFeat} columns and n rows, where
  n is the number of exemplars, such that each row represents a single
  exemplar in memory, and their corresponding feature values. 
  The \code{nFeat} columns follow the same order as \code{x1, x2, \dots} 
  in \code{tr}. The n-rows follow the same order as in the 
  \code{w_exemplars} matrix defined below. See Note 3.
  
  \code{w_exemplars} - matrix which is structurally equivalent to 
  \code{exemplars}. However, the matrix represents the associative weight
  from the exemplar nodes to the gain nodes, as given in Equation 4.
  The \code{nFeat} columns follow the same order as 
  \code{x1, x2, \dots} in \code{tr}. The n-rows follow the same order 
  as in the \code{exemplars} matrix.

  }
  
\author{René Schlegelmilch, Andy Wills}

\references{
  Kruschke, J. K. (1996). Base rates in category learning. \emph{Journal 
  of Experimental Psychology-Learning Memory and Cognition, 22}(1), 3-26.
  
  Kruschke, J. K. (2001). The inverse base rate effect is not explained
  by eliminative inference. \emph{Journal of Experimental Psychology:
  Learning, Memory & Cognition, 27}, 1385-1400.

  Spicer, S.G., Schlegelmilch, R., Jones, P.M., Inkster, A.B., Edmunds,
  C.E.R. & Wills, A.J. (n.d.). Progress in learning theory through
  distributed collaboration: Concepts, tools, and
  examples. \emph{Manuscript in preparation}.


}

\note{

  1. Code optimization in slpEXIT means it's essential that every cue is
  either set to 1 or to 0. If you use other values, it won't work
  properly. If you wish to represent cues of unequal salience, use
  \code{sigma}.

  2. EXIT simulations normally include a 'bias' cue, i.e. a cue that is
  present on all trials. You will need to explicitly include this in
  your input representation in \code{tr}. For an example, see the output
  of \code{krus96train}.

  3. The bias cue should be included in these exemplar representations,
  i.e. they should be the same as the representation of the stimuli in
  \code{tr}. For an example, see the output of \code{krus96train}.
  
  }