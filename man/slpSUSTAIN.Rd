\name{slpSUSTAIN}
\alias{slpSUSTAIN}
\title{
SUSTAIN Category Learning Model
}
\description{
Supervised and Unsupervised STratified Adaptive Incremental Network
(Love, Medin & Gureckis, 2004)
}

\usage{
slpSUSTAIN(st, tr, xtdo = FALSE, ties = "random")
}

\arguments{
  \item{st}{List of model parameters}

  \item{tr}{Matrix of training items}

  \item{xtdo}{Boolean specifying whether to include extended information
  in the output (see below)}

  \item{ties}{Model behaviour where multiple clusters have the same
      highest activations. Options are: \code{random}, \code{first}, see
      below.}
    }

\value{

  Returns a list with the following items if \code{xtdo = FALSE}:

  \item{probs}{Matrix of probabilities of making each response within
  the queried dimension (e.g. column 1 = category A; column 2 = category
  B), see Love et al. (2004, Eq. 8). Each row is a single trial and
  columns are in the order presented in \code{tr}, see below. In the
  case of unsupervised learning, probabilities are calculated for all
  dimensions (as there is no queried dimension for unsupervised
  learning).}

  \item{lambda}{Vector of the receptive field tunings for each stimulus
  dimension, after the final trial. The order of dimensions corresponds
  to the order they are presented in \code{tr}, see below.}

  \item{w}{Matrix of connection weights, after the final
    trial. Each row is a separate cluster, reported in order of
    recruitment (first row is the first cluster to be recruited). The
    columns correspond to the columns on the input representation
    presented (see \code{tr} description, below).}

  \item{cluster}{Matrix of recruited clusters, with their positions in
    stimulus space. Each row is a separate cluster, reported in order of
    recruitment. The columns correspond to the columns on the input
    representation presented (see \code{tr} description, below).}

  If \code{xtdo = TRUE}, \code{xtdo} is returned instead of
  \code{probs}:

  \item{xtdo}{A matrix that includes \code{probs}, and in addition includes
  the following columns: \code{winning} - number of the winning cluster; 
  \code{activation} - its output activation after cluster competition,
  Eq. 6 in Love et al. (2004); \code{recognition_scores} - for the current stimulus
  from Eq. A6 in Love and Gureckis (2007), this measure represents the model's
  overall familiarity with the stimulus; \code{endorsement} - the probability of
  judging an item as old per Eq. 11 in Love and Gureckis (2007).}

}

\details{

  This function works as a stateful list processor (slp; see Wills et
  al., 2017). It takes a matrix (tr) as an argument, where each row
  represents a single training trial, while each column represents some
  information required by the model, such as the stimulus
  representation, indications of supervised/unsupervised learning, etc.
  (details below).

  Argument \code{st} must be a list containing the following items:

  \code{r} - Attentional focus parameter, always non-negative.

  \code{beta} - Cluster competition parameter, always non-negative.

  \code{d} - Decision consistency parameter, always non-negative.

  \code{eta} - Learning rate parameter, see Note 1.

  \code{tau} - Threshold parameter for cluster recruitment under
  unsupervised learning conditions (Love et al., 2004, Eq. 11). If every
  trial is a supervised learning trial, set tau to 0. slpSUSTAIN can
  accomodate both supervised and unsupervised learning within the same
  simulation, using the \code{ctrl} column in \code{tr} (see below).

  \code{lambda} - Vector containing the initial receptive field tuning
  value for each stimulus dimension; the order corresponds to the order
  of dimensions in \code{tr}, below. For a stimulus with three
  dimensions, where all receptive fields are equally tuned, lambda = [1,
  1, 1].

  \code{cluster} - A matrix of the initial positions of each recruited
  cluster. If set to NA, \code{cluster = NA}, then each time the network is
  reset, a single cluster will be created, centered on the stimulus
  presented on the current trial.

  \code{w} - A matrix of initial connection weights. If set to NA as
  \code{w = NA} then, each time the network is reset,
  zero-strength weights to a single cluster will be created.

  \code{dims} - Vector containing the length of each dimension
  (excluding category dimension, see \code{tr}, below), i.e. the number
  of nominal spaces in the representation of each dimension. For Figure
  1 of Love et al. (2004), dims = [2, 2, 2].

  \code{maxcat} - optional. If set, maxcat is an integer specifying the
  maximum number of clusters to be recruited during unsupervised
  learning. A similar restriction has been used by Love et al. (2004) to
  simulate an unsupervised free-sorting task from Experiment 1 in Medin,
  Wattenmaker, & Hampson (1987). In this experiment, participants needed
  to sort items into two predefined categories. This parameter will only
  be used during unsupervised learning. If it is not set, or if it is
  set to 0, there is no maximum to the number of clusters that can be
  created.

  \code{colskip} - Number of optional columns skipped in \code{tr},
  PLUS ONE. So, if there are no optional columns, set colskip to 1.

  Argument \code{tr} must be a matrix, where each row is one trial
  presented to the model. Columns are always presented in the order
  specified below:

  \code{ctrl} - A vector of control codes. The control codes are
  processed prior to the trial and prior to updating cluster's position,
  lambdas and weights (Love et al., 2004, Eq.  12, 13 and 14,
  respectively). The available values are:

  0 = do supervised learning.

  1 = reset network and then do supervised learning.

  2 = freeze supervised learning.

  3 = do unsupervised learning.

  4 = reset network and then do unsupervised learning.

  5 = freeze unsupervised learning

  'Reset network' means revert \code{w}, \code{cluster},and
  \code{lambda} back to the values passed in \code{st}.

  Unsupervised learning in \code{slpSUSTAIN} is at an early stage of
  testing, as we have not yet established any CIRP for unsupervised
  learning.

  \code{opt1, opt2, \dots} - optional columns, which may have any names
  you wish, and you may have as many as you like, but they must be
  placed after the ctrl column, and before the remaining columns (see
  below). These optional columns are ignored by this function, but you
  may wish to use them for readability. For example, you might include
  columns for block number, trial number, and stimulus ID number.

  \code{x1, x2, y1, y2, y3, \dots} - Stimulus representation. The
  columns represent the kth nominal value for ith dimension. It's a
  'padded' way to represent stimulus dimensions and category membership
  (as category membership in supervised learning is treated as an
  additional dimension) with varying nominal length, see McDonnell &
  Gureckis (2011), Fig. 10.2A. All dimensions for the trial are
  represented in this single row. For example, if for the presented
  stimulus, dimension 1 is [0 1] and dimension 2 is [0 1 0] with
  category membership [0 1], then the input representation is [0 1 0 1 0
  0 1].

  Argument \code{ties} can be either \code{random} or \code{first}. It specifies
  how the model behaves in the event, when there are multiple winning clusters
  with the same activations (see Note):

  \code{random} - The model randomly selects one cluster from the ones
  that have the same activations. To increase the reproducibility of
  your simulation, set a specific random seed seed before calling
  \code{slpSUSTAIN} (use e.g.\code{set.seed}).

  \code{first} - The model selects the cluster that was first recruited
  from the clusters that have the same activations. Up to and including
  version 0.7.1 of \code{catlearn}, this was the default behaviour of
  \code{slpSUSTAIN}.

}

\references{

  Love, B. C., & Gureckis, T.M. (2007). Models in Search of a Brain.
  \emph{Cognitive, Affective, & Behavioral Neuroscience, 7}, 90-108.

  Love, B. C., Medin, D. L., & Gureckis, T. M. (2004). SUSTAIN: a
  network model of category learning. \emph{Psychological Review, 111},
  309-332.

  McDonnell, J. V., & Gureckis, T. M. (2011). Adaptive clustering models
  of categorization. In E. M. Pothos & A. J. Wills (Eds.), \emph{Formal
  Approaches in Categorization}, pp. 220-252.

  Medin, D. L., Wattenmaker, W. D., & Hampson, S. E. (1987). Family 
  resemblance, conceptual cohesiveness, and category construction. 
  \emph{Cognitive Psychology, 19(2)}, 242-279.

  Wills, A.J., O'Connell, G., Edmunds, C.E.R., & Inkster,
  A.B.(2017). Progress in modeling through distributed collaboration:
  Concepts, tools, and category-learning examples. \emph{Psychology of
  Learning and Motivation, 66}, 79-115.

}
\author{

  Lenard Dome, Andy Wills

}

\note{

1. Love et al. (2004) do not explicitly set a range for the learning
rate; we recommend a range of 0-1.

2. The specification of SUSTAIN states that under supervised learning, a
new cluster is recruited each time the model predicts category
membership incorrectly. This new cluster is centered on the current
stimulus. The implementation in slpSUSTAIN adds the stipulation that a
new cluster is NOT recruited if it already exists, i.e. if its location
in stimulus space is identical to the location on an existing
cluster. Instead, it selects the existing cluster and updates as
normal. Love et al. (2004) do not specify model behaviour under such
conditions, so this is an assumption of our implementation. We'd argue
that this is a reasonable implementation - without it SUSTAIN would add
clusters indefinitely under conditions where the stimulus -> category
associations are proabilistic rather than deterministic.

3. In some cases, two or more clusters can have identical activations
because the presented stimulus is equally similar to multiple
clusters. Love et al. (2004) does not specify how the model will behave
in these cases. In our implementation, we make the assumption that the
model picks randomly between the highest activated clusters (given that
they have the same activations). This, we felt, was in line with the
approximation of lateral inhibition in the SUTAIN specification (Love
et al.  2004, Eq. 6).

}
