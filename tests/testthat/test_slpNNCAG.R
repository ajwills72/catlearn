context("slpNNCAG")
load("../data/test_slpNNCAG.RData")

st.copy <- st
tr.copy <- bigtr

## Run simulation
out <- slpNNCAG(st.copy, data.matrix(tr.copy)[, c(1, 4:13)])

# Test that it reproduces a quick ibre-type simulation
test_that("slpNNCAG reproduces simulation.", {
    expect_equal(out$p, probs)
})


## Below guards against common RCpp error.
test_that("slpNNCAG does not change st, tr.", {
    expect_equal(st.copy, st)
    expect_equal(tr.copy, bigtr)
})