## Test for stsimGCM
## Based on one block of Shepard et al. (1961) Type I.
context("stsimGCM")
library(catlearn)

    st<-list(
        sensitivity = 3,
        weights = c(.2,.3),
        choice_bias = c(1/3),
        gamma = 1,
        mp = 1,
        r_metric = 1,
        p = 1,
        nCats = 2,
        nFeat=3
    )
                               
    st$tr <- nosof94train(blocks = 1)

    st$mp<-c(3,5)
    
    st$training_items <- as.data.frame(
        t(matrix(cbind(c(1,0,1,1,1,0,1),c(1,1,0,2,1,0,0),
                       c(0,1,0,5,0,1,0),c(0,0,1,1,0,1,1)),
                 ncol=4, nrow=7,
                 dimnames=list(c("stim","x1", "x2", "x3",
                                 "cat1", "cat2", "mem"),
                               c(1:4)))))
    
    out <- stsimGCM(st)

corr <- c(0.248063003882215, 0.233684163448389, 0.240360372012061,
          0.240360372012061, 0.285261575734667, 0.248063003882215,
          0.233684163448389, 0.285261575734667, 0.240360372012061,
          0.240360372012061, 0.285261575734667, 0.248063003882215,
          0.248063003882215, 0.233684163448389, 0.233684163448389,
          0.285261575734667)

test_that("stsimGCM reproduces a Shepard et al. (1961) Type I simulation.", {
    expect_equal(out[,1], corr)
})

