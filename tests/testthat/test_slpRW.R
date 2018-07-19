# Test for slpRW
## Redundancy effect trained on two participants, with 8 weights
## frozen test trials

context("slpRW")
load('../data/test_slpRW.RData') # Load cor.out, str, and tr.

st.copy <- st
tr.copy <- tr
out <- slpRW(st,tr)

test_that("slpRW reproduces redundancy effect simulation.", {
    expect_equal(out$suma, cor.out)
})

## Below guards against common RCpp error.
test_that("slpRW does not change st.", {
    expect_equal(st.copy$lr, st$lr)
    expect_equal(st.copy$w, st$w)
    expect_equal(st.copy$lr, st$lr)
    expect_equal(tr.copy, tr)
    
})

## Generating code
##rm(list=ls())
##library(catlearn)

##    st <- list(lr = 0.01, w = rep(0, 5), colskip = 1) # Initial state

##    train <- matrix(c(1, 0, 0, 0, 0, 1,           # Train array
##                      1, 0, 0, 1, 0, 1,           
##                      0, 1, 0, 0, 1, 1,
##                      0, 0, 1, 0, 1, 0), 
##                    nrow = 4, ncol = 6, byrow = TRUE,
##                    dimnames = list(c(),
##                        c("A", "B", "C", "X", "Y", "t")))
##    train <- do.call(rbind, replicate(100,train,simplify = FALSE)) 
##    ctrl <- c(1,rep(0,191),rep(2,8))
##    tr <- cbind(ctrl,train)

## cor.out <- out$suma
##  save(cor.out,st,tr,file='data/test_slpRW.RData')
