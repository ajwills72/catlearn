## Check that OAT functions return TRUE when given CIRP
context("OAT")

test_that("nosof88oat returns TRUE for nosof88.", {
    expect_true(nosof88oat(nosof88))
})

test_that("nosof94oat returns TRUE for nosof94.", {
    expect_true(nosof94oat(nosof94))
})

## shin92oat was the first OAT function written in catlearn. For this
## historical reason, it does not accept the OAT as input. If
## shin92oat is ever updated, this should be fixed. For now, there's
## no easy automated test that can be done here. 
