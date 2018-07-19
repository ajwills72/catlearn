## Unit test for act2probrat
context("act2probrat")

test_that("act2probrat reproduces an arbitrarily-chosen set of values.", {
    expect_equal(
        act2probrat(c(0.91,0.54,0.11),3.1,0.24),
        c(0.88864751991274482101, 0.71707528549297261389, 0.40059177152436675762)
    )
}
)

