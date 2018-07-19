## Tests for slpDIVA
context("slpDIVA")
    ## Test based on a Type IV Shepard et al.(1961) problem.
load("../data/test_slpdiva.RData")
tout <- slpDIVA(st,tr)

test_that("slpDIVA reproduces a Shepard et al. (1961) Type IV simulation.", {
    expect_equal(tout$out[,1], cor.out)
})


    
