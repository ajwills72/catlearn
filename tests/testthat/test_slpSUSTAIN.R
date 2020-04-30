## Check slpSUSTAIN against short supervised and unsupervised experiments.
context("slpSUSTAIN")
load('../data/test_slpSUSTAIN.RData')
out <- slpSUSTAIN(st, tr)

test_that("slpSUSTAIN reproduces a short Shepard et al. (1961) Type I simulation.",
{
    expect_equal(out$p[,1], corr)
})

out  <- slpSUSTAIN(init.state, bigtr)

test_that("slpSUSTAIN reproduces a short Medin et al. (1987) Exp. 1 simulation.",
{
    expect_equal(out$cluster[1,], cor.medin)
})

## Generating code for Shepard et al 1961
#library(catlearn)
#tr <- nosof94train(cond = 1, blocks = 1, absval = 0, blkstyle = "eights",
#                   missing = 'pad', subjs = 1, seed = 7624)

#params = c(9.01245, 1.252233, 16.924073, 0.092327)

#st <- list(r = params[1], beta = params[2], d = params[3], eta = params[4],
#           tau = 0.0, lambda = c(1, 1, 1), dims = c(2, 2, 2), cluster = NA,
#           w = NA, colskip = 4)
#rm(params)
#out <- slpSUSTAIN(st, tr)$probs
#corr <- out[,1]
#rm(out)
#save.image("../data/test_slpSUSTAIN.RData")

## Generating code for Medin et al. (1987)

##params = c(9.998779, 6.396300, 1.977312, 0.096564, 0.5)

##init.state <- list(r = params[1], beta = params[2], d = params[3],
##                   eta = params[4], tau = params[5],
##                  lambda = c(1, 1, 1, 1), dims = c(2, 2, 2, 2),
##                   cluster = NA, w = NA, colskip = 3,
##                   maxcat = 2)

##bigtr <- medin87train(subjs = 1, blocks = 1)
##out  <- slpSUSTAIN(init.state, bigtr)
##cor.medin  <- out$cluster[1,]
##save(corr, cor.medin,st,tr,init.state,bigtr,file='tests/data/test_slpSUSTAIN.RData')
