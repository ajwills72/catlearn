\name{stsimGCM}
\alias{stsimGCM}
\title{
  Generalized Context Model
}
\description{
  Nosofsky's (1984, 2011) Generalized Context Model; an exemplar-based
  model of categorization.
}
\usage{
  stsimGCM(st)
}
\arguments{
  \item{st}{List of model parameters}
}  
  
\value{
  A matrix of probabilities for category responses (columns) for each 
  stimulus (rows) presented to the model (e.g. test trials). Stimuli 
  and categories are in the same order as presented to the model in 
  \code{st}, see below. 
}

\details{

  Argument \code{st} must be a list containing the following required
  items: \code{training_items}, \code{tr}, \code{nCats}, \code{nFeat}, 
  \code{sensitivity}, \code{weights}, \code{choice_bias}, \code{p},
  \code{r_metric}, \code{mp}, and \code{gamma}
  
  \code{nCats} - integer indicating the number of categories
   
  \code{nFeat} - integer indicating the number of stimulus dimensions
  
  \code{tr} - the stimuli presented to the model, for which the choice
  probabilities will be predicted. \code{tr} has to be a matrix or
  dataframe with one row for each stimulus. \code{tr} requires the
  following columns.
  
  \code{x1, x2, \dots} - columns for each dimension carrying the
  corresponding values (have to be coded as numeric values) for each
  exemplar (trial) given in the row. Columns have to start with
  \code{x1} ascending with dimensions \code{\dots, x2, x3, \dots} at
  adjacent columns.
  
  \code{tr} may have any number of additional columns with any desired 
  name and position, e.g. for readability. As long as the feature columns 
  \code{x1, x2, \dots} are given as defined (i.e. not scattered, across 
  the range of matrix columns), the output is not affected by optional 
  columns.
  
  \code{training_items} - all unique exemplars assumed to be stored in 
  memory; has to be a matrix or dataframe with one row for each exemplar. 
  The rownames have to start with 1 in ascending order.
  \code{training_items} requires the following columns:
  
  \code{x1, x2, \dots} - columns for each feature dimension carrying 
  the corresponding values (have to be coded as numeric values) for each 
  exemplar (row). Columns have to start with \code{x1} ascending with 
  dimensions \code{\dots, x2, x3, \dots} at adjacent columns.
  
  \code{cat1, cat2, \dots} - columns that indicate the category
  assignment of each exemplar (row). For example, if the exemplar in row
  2 belongs to category 1 the corresponding cell of \code{cat1} has to
  be set to \code{1}, else \code{0}. Columns have to start with
  \code{cat1} ascending with categories \code{\dots, cat2, cat3, \dots}
  at adjacent columns.
  
  \code{mem} - (optional) one column that indicates whether an exemplar 
  receives an extra memory weight, yes = \code{1}, no = \code{0}. 
  For each exemplar (row) in the \code{training_items} with \code{mem}
  set to \code{0} the corresponding memory strength parameter is set to 1.
  When \code{mem} for an exemplar is set to \code{1} the memory strength
  parameter is set as defined in \code{mp}, see below.
  
  \code{training_items} may have any number of additional columns with any 
  desired name and position, e.g. for readability. As long as the feature
  columns \code{x1, x2, \dots} and \code{cat1, cat2, \dots} are given as 
  defined (i.e. not scattered, across the range of matrix columns), the 
  output is not affected by optional columns.
  
  NOTE: The current model can be implemented as a prototype model if
  the \code{training_items} only carry one row for each category representing
  the values of the corresponding prototypes (e.g. see Minda & Smith, (2011).
  
  \code{mp} - memory strength parameter (optional). Can take any numeric 
  value between -Inf and +Inf. The default is 1, i.e. all exemplars have 
  the same memory strength. There are two ways of specifying \code{mp},
  i.e. either \emph{globally} or \emph{exemplar specific}:
  
  When \emph{globally} setting \code{mp} to a single integer,
  e.g. to 5, then all exemplars in \code{training_items} with \code{mem} 
  = 1 will receive a memory strength 5 times higher than the memory strengths
  for the remaining exemplars. 
  
  For setting \emph{exemplar specific} memory strengths \code{mp} has to be 
  a vector of length n, where n is the overall number of of exemplars with 
  \code{mem} = 1 in the \code{training_items}. The order of memory strengths 
  defined in this vector exactly follows their row-wise ascending order of 
  appearence in the \code{training_items}. E.g. if there are two exemplars 
  with \code{mem} = 1 in the \code{training_items}, the first one in row 2 
  and the second one in row 10, then setting \code{mp} to c(3,2) will result 
  in assigning a memory strength of 3 to the first exemplar (in row 2) and 
  a memory strength of 2 to the second exemplar (in row 10). The memory 
  strengths for all other exemplars will be set to 1. See Note 1.

  \code{sensitivity} - sensitivity parameter c; can take any value
  between 0 (all exemplars are equally similar) and +infinity 
  (towards being  insensitive to large differences). There are two ways 
  of specifying \code{sensitivity}, i.e. either \emph{globally} or 
  \emph{exemplar specific}: When \emph{globally} setting \code{sensitivity} 
  to a single value, e.g. \code{sensitivity}=3, then the same parameter is 
  applied to all exemplars. On the other hand, \emph{exemplar specific}
  sensitivity parameters can be used by defining \code{sensitivity} as
  a vector of length n, where n is the number of rows in 
  \code{training_items}. The \code{sensitivity} vector values then represent 
  the sensitivity parameters for all exemplars in \code{training_items} at 
  the corresponding row positions. E.g. if there are 3 exemplars (rows) in 
  \code{training_items}, then setting \code{sensitivity} to \code{c(1,1,3)} 
  assigns \code{sensitivity} = 1 to the first two exemplars, and 
  \code{sensitivity} = 3 for the third exemplar. See Note 2. 

  \code{weights} - dimensional attention weights. Order corresponds
  to the definitions of \code{x1, x2, \dots} in \code{tr} and 
  \code{training_items}. Has to be a vector with length n-1 , where n
  equals to \code{nFeat} dimension weights, e.g. of length 2 when
  there are three features, leaving out the \emph{last} dimension. A
  constraint in the GCM is that all attentional weights sum to 1. Thus,
  the sum of n-1 weights should be equal to or smaller than 1, too.  The
  last n-th weight then is computed within the model with: 1 - (sum of
  n-1 feature weights). When setting the weights to 1/\code{nFeat} =
  equal weights. See Note 3.
  
  \code{choice_bias} - Category choice biases. Has to be a vector with 
  length n-1, where n equals to \code{nCats} category biases, leaving out 
  the last category bias, under the constraint that all biases sum to 1. 
  Order corresponds to the definitions of \code{cat1, cat2} in the
  \code{training_items}. The sum of n-1 choice biases has to be equal
  to or smaller than 1. Setting the weights to 1/\code{nCats} = no
  choice bias. The bias for the last category then is computed in the
  model with: 1 - (sum of \code{nCats}-1 choice biases). See Note 3.

  \code{gamma} - decision constant/ response scaling.  Can take any 
  value between 0 (towards more probabilistic) and +infinity (towards 
  deterministic choices). Nosofsky (2011) suggests setting gamma higher 
  than 1 when individual participants' data are considered. See Note 2.

  \code{r_metric} - distance metric. Set to 1 (city-block) or 2
  (Euclidean). See Nosofsky (2011), and Note 4, for more details.

  \code{p} - similarity gradient. Set to 1 (exponential) or 2 (Gaussian). 
  See Nosofsky (2011), for more details. 

}

\author{ Rene Schlegelmilch, Andy Wills }

\references{
  
  Minda, J. P., & Smith, J. D. (2011). Prototype models of 
  categorization: Basic formulation, predictions, and limitations. 
  Formal approaches in categorization, 40-64.
  
  Navarro, D. J. (2007). On the interaction between exemplar-based 
  concepts and a response scaling process. Journal of Mathematical 
  Psychology, 51(2), 85-98.
  
  Nosofsky, R. M. (1984). Choice, similarity, and the context theory 
  of classification. \emph{Journal of Experimental Psychology: 
  Learning, memory, and cognition, 10}(1), 104.
  
  Nosofsky, R. M. (2011). The generalized context model: An exemplar
  model of classification. In Pothos, E.M. & Wills, A.J. \emph{Formal
  approaches in categorization}. Cambridge University Press.
  
  Rodrigues, P. M., & Murre, J. M. (2007). Rules-plus-exception tasks: 
  A problem for exemplar models?. \emph{Psychonomic Bulletin & Review, 
  14}(4), 640-646.
  
  Tversky, A., & Gati, I. (1982). Similarity, separability, and the 
  triangle inequality. \emph{Psychological review, 89}(2), 123.
  

}

\examples{

    ## Three Categories with 2 Training Items each, and repeatedly presented
    ## transfer/test items (from nosof94train()). Each item has three 
    ## features with two (binary) values: memory strength (st$mp and 
    ## 'mem' column in st$training_items are optional) is 
    ## equal for all exemplars
    
    st<-list(
        sensitivity = 3,
        weights = c(.2,.3),
        choice_bias = c(1/3),
        gamma = 1,
        mp = 1,
        r_metric = 1,
        p = 1,
        nCats = 2,
        nFeat=3
    )
    
    ## training item definitions 
    st$training_items <- as.data.frame(
        t(matrix(cbind(c(1,0,1,1,1,0,0),c(1,1,0,2,1,0,0),
                       c(0,1,0,5,0,1,0),c(0,0,1,1,0,1,0)),
                 ncol=4, nrow=7,
                 dimnames=list(c("stim","x1", "x2", "x3",
                                 "cat1", "cat2", "mem"),
                               c(1:4)))))
                               
    st$tr <- nosof94train()
    
    ## get the resulting predictions for the test items
    
    ## columns of the output correspond to category numbers as defined
    ## above rows correspond to the column indices of the test_items
    
    stsimGCM(st)

    ## columns of the output correspond to category numbers as defined
    ## above rows correspond to the column indices of the test_items

    ## Example 2

    ## Same (settings) as above, except: memory strength is 5 times higher
    ## for for some exemplars
    st$mp<-5
    
    ## which exemplars?
    ## training item definitions 
    st$training_items <- as.data.frame(
        t(matrix(cbind(c(1,0,1,1,1,0,1),c(1,1,0,2,1,0,0),
                       c(0,1,0,5,0,1,0),c(0,0,1,1,0,1,1)),
                 ncol=4, nrow=7,
                 dimnames=list(c("stim","x1", "x2", "x3",
                                 "cat1", "cat2", "mem"),
                               c(1:4)))))
    ## exemplars in row 1 and 4 will receive a memory strength of 5
    ## get predictions
    stsimGCM(st)

    ## Example 3 
    ## Same (settings) as above, except: memory strength is item specific
    ## for the two exemplars i.e. memory strength boost is not the same 
    ## for both exemplars (3 for the first in row 1, and 5 for the 
    ## second exemplar in row 4)
    st$mp<-c(3,5) 


    ## get predictions
    stsimGCM(st)
}  
\note{

  1. Please note that setting mp = 1 or e.g. mp = 5 globally, will 
  yield identical response probabilities. Crucially, memory strength 
  is indifferent from the category choice bias parameter, if (and only
  if) mp's vary between categories, without varying within categories. 
  Thus, the memory strength parameter can therefore be interpreted in 
  terms of an exemplar choice bias (potentially related to categorization 
  accuracy). In addition, if exemplar specific mp's are assigned during 
  parameter fitting, one might want to calculate the natural log of the 
  corresponding estimates, enabling direct comparisons between mp's 
  indicating different directions, e.g. -log(.5) = log(2), for loss and 
  gain, respectively, which are equal regarding their extent into different 
  directions.

  2. Theoretically, increasing global sensitivity indicates that 
  categorization mainly relies on the most similar exemplars, usually
  making choices less probabilistic. Thus sensitivity c is likely to 
  be correlated with gamma. See Navarro (2007) for a detailed discussion.  
  However, it is possible to assume exemplar specific sensitivities, or
  specificity. Then, exemplars with lower sensitivity parameters
  will have a stronger impact on stimulus similarity and thus 
  categorization behavior for stimuli. See Rodrigues & Murre 
  (2007) for a related study. 

  3. Setting only the n-1 instead of all n feature weights (or bias
  parameters) eases model fitting procedures, in which the last weight
  always is a linear combination of the n-1 weights.

  4. See Tversky & Gati (1982) for further info on r. In brief summary,
  r=2 (usually termed Euclidean), then a large difference on only one 
  feature outweighs small differences on all features. In contrast, 
  if r=1 (usually termed City-Block or Manhattan distance) both aspects 
  contribute to an equal extent to the distance. Thus, r = 2 comes with 
  the assumption that small differences in all features may be less 
  recognized, than a large noticable differences on one feature, which 
  may be depend on confusability of the stimuli or on the nature of the 
  given task domain (perceptual or abstract).

  
  }