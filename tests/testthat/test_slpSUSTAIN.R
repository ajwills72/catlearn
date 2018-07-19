## Check slpSUSTAIN against a short Shepard et al. (1961) simulation
context("slpSUSTAIN")
load('../data/test_slpSUSTAIN.RData')
out <- slpSUSTAIN(st, tr)

test_that("slpSUSTAIN reproduces a short Shepard et al. (1961) Type I simulation.",
{
    expect_equal(out$p[,1], corr)
})

## Generating code
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
