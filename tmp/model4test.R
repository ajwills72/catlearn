library(catlearn)
library(Rcpp)
library(data.table)
sourceCpp("src/slpModel4.cpp")

params = c(2.87, 2.48, 4.42, 4.42, .222, 1.13, .401)
tr <- krus96train(blocks = 15, subjs = 1, ctxt = FALSE, seed = 1)
tr <- data.table(tr)
print(tr)


## Set state
st <- list(P = params[1],     ## attentional normalization
           phi = params[2],   ## response consistency
           lambda = params[3], ## learning rate parameter
           mu = params[4],    ## attentional learning rate parameter
           colskip = 1,
           outcomes = 4,
           w = NULL,
           eta = NULL       ## intial salience of cues
       )

## Run simulation
