# Unit test for slpBM
## Redundancy effect trained on two participants, with 8 weights
## frozen test trials

context("slpBM")
load('../data/test_slpBM.RData') # Load cor.out, str, and tr.

st.copy <- st
tr.copy <- tr
out <- slpBM(st,tr)

test_that("slpBM reproduces redundancy effect simulation.", {
    expect_equal(out$suma, cor.out)
})

## Below guards against common RCpp error.
test_that("slpBM does not change st.", {
    expect_equal(st.copy$lr, st$lr)
    expect_equal(st.copy$w, st$w)
    expect_equal(st.copy$lr, st$lr)
    expect_equal(tr.copy, tr)
    
})

## Generating code
## (st and tr were taken from slpRW)
## rm(list=ls())
## library(catlearn)
## cor.out <- out$suma
## save(cor.out,st,tr,file='data/test_slpBM.RData')
