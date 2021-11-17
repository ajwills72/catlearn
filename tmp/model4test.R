library(catlearn)
library(Rcpp)
library(data.table)
sourceCpp("src/slpModel4.cpp")

params = c(2.87, 2.48, 4.42, 4.42, .222, 1.13, .401)
tr <- krus96train(blocks = 15, subjs = 1, ctxt = FALSE, seed = 1023)
print(tr)


## Set state
st <- list(P = 1,             ## attentional normalization
           phi = 5,          ## response consistency
           lambda = 0.50,       ## learning rate parameter
           mu = 0.99,           ## attentional learning rate parameter
           colskip = 1,
           outcomes = 4,
           w = matrix(0, nrow = 4, ncol = 6),
           eta = rep(1, 6)         ## intial salience of cues
       )

## Run simulation
out <- slpDRNCAG(st, data.matrix(tr[, c(1, 4:13)]))
