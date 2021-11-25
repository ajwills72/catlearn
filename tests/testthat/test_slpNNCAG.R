context("slpNNCAG")
load("../data/test_slpNNCAG.RData")

st.copy <- st
tr.copy <- bigtr

## Run simulation
out <- slpNNCAG(st.copy, data.matrix(tr.copy)[, c(1, 4:13)])

probs <- out$p
probs <- cbind(bigtr[, 1:3], probs)

probs <- probs[probs$ctrl == 2, 3:7]

diff <- out_sim[order(out_sim$rn), 2:5] - probs[order(probs$stim), 2:5]

test_that("slpNNCAG reproduces simulation.", {
    expect_equal(mean(data.matrix(diff)), 0)
})


## Below guards against common RCpp error.
test_that("slpNNCAG does not change st, tr.", {
    expect_equal(st.copy, st)
    expect_equal(tr.copy, bigtr)
})

## print(paste("The C++ Model 4 implementation can replicate the simulation of",
##             "Paskewitz and Jones (2021) with a mean difference of", mdiff))