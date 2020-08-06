# Test for slpLMSnet
## Inverse base rate effect with one participant

context("slpLMSnet")
load('../data/test_slpLMSnet.RData') # Load cor.out, str, and tr.

st.copy <- st
tr.copy <- tr
out <- slpLMSnet(st,data.matrix(tr))

test_that("slpLMSnet reproduces IBRE simulation.", {
    expect_equal(out$connectionWeightMatrix, cor.out)
})

## Below guards against common RCpp error.
test_that("slpLMSnet does not change st, tr.", {
    expect_equal(st.copy, st)
    expect_equal(tr.copy, tr)
})

## Generating code
##st <- list(beta = 0.025, theta = 1, bias = 0,
##           w = matrix(rep(0, 6*4), nrow = 4, ncol = 6), outcomes = 4,
##           colskip = 3)
##tr <- krus96train(subjs = 1, ctxt = FALSE)
##out <- slpLMSnet(st, data.matrix(tr))
##cor.out <- out$connectionWeightMatrix
##save(cor.out,st,tr,file='test_slpLMSnet.RData')
