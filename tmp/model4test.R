library(catlearn)
library(Rcpp)
sourceCpp("src/slpModel4.cpp")

params = c(2.87, 2.48, 4.42, 4.42, .222, 1.13, .401)
tr <- krus96train(blocks = 15, subjs = 56, ctxt = TRUE, seed = 1)

## Set state
nFeat = 7
nCat = 4
w_in_out <- matrix(0, nCat, nFeat)

st <- list(nFeat = nFeat, nCat = nCat,
           phi = params[3], c = params[1], P = params[2],
           l_gain = params[4], l_weight = params[5], l_ex = params[6],
           sigma = c(rep(1,6), params[7]),
           iterations = 10,
           exemplars = exemplars,
           w_exemplars = w_exemplars,
           w_in_out = w_in_out)

## Run simulation
