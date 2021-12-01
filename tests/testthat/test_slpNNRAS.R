context("slpNNRAS")
load("../data/test_slpNNRAS.RData")

st.copy <- st
tr.copy <- bigtr

## Run simulation
out <- slpNNRAS(st.copy, data.matrix(tr.copy)[, c(1, 4:13)])

probs <- out$p
probs <- cbind(tr.copy[, 1:3], probs)

probs <- probs[probs$ctrl == 2, 3:7]
rownames(probs) <- NULL
colnames(probs)[2:5] <- c("C1", "R1", "C2", "R2")

# Test that it reproduces a quick ibre-type simulation
test_that("slpNNRAS reproduces simulation.", {
    expect_equal(data.frame(out_sim[order(out_sim$V1), 2:5]),
                 data.frame(probs[order(probs$stim), 2:5]))
})


## Below guards against common RCpp error.
test_that("slpNNRAS does not change st, tr.", {
    expect_equal(st.copy, st)
    expect_equal(tr.copy, bigtr)
})