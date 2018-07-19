## Tests for slpCOVIS
context("slpCOVIS")
load("../data/test_slpcovis.RData")
set.seed(7)
out <- slpCOVIS(st, tr, crx = TRUE, respt = FALSE, rgive = TRUE,
                xtdo = FALSE)

test_that("slpCOVIS reproduces an arbitrarily chosen short simulation.", {
    expect_equal(out$foutmat, testres$foutmat)
})



