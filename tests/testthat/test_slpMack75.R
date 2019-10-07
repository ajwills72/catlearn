## Test for slpMack75
## Le Pelley & McLaren (2003) design, stages 1 and 2, trained on 1
## participant for 8 blocks per stage

## Redundancy effect trained on two participants, with 8 weights
## frozen test trials

context("slpMack75")
load('../data/test_slpMack75.RData') # Load cor.out, st, and tr.

st.copy <- st
tr.copy <- tr
out <- slpMack75(st,tr)

test_that("slpMack75 reproduces learned predictiveness effect simulation.", {
    expect_equal(out$suma, cor.out)
})

## Below guards against common RCpp error.
test_that("slpMack75 does not change st or tr.", {
    expect_equal(st.copy$lr, st$lr)
    expect_equal(st.copy$alr, st$alr)    
    expect_equal(st.copy$w, st$w)
    expect_equal(st.copy$alpha, st$alpha)
    expect_equal(tr.copy, tr)
})

## Generating code
## 
#st  <- list(lr = .3, alr = .1, w = rep(0,8), alpha = rep(0.3,8), colskip=5)
#tr  <- lepell03train(subj = 1, block1 = 8, block2 = 8)
#out  <- slpMack75(st, tr)
#cor.out  <- out$suma
#save(cor.out,st,tr,file='tests/data/test_slpMack75.RData')

#lepell03train <- function(block1 = 20, block2 = 20,
#                                     subj = 4, seed = 7624) {
#    set.seed(seed)
#    stage1 <-  matrix(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 1,
#                        2, 1, 0, 0, 0, 0, 1, 0, 0, 1,
#                        3, 0, 1, 0, 0, 1, 0, 0, 0, -1,
#                        4, 0, 1, 0, 0, 0, 1, 0, 0, -1,
#                        5, 0, 0, 1, 0, 0, 0, 1, 0, -1,
#                        6, 0, 0, 1, 0, 0, 0, 0, 1, -1,
#                        7, 0, 0, 0, 1, 0, 0, 1, 0, 1,
#                        8, 0, 0, 0, 1, 0, 0, 0, 1, 1),
#                      nrow = 8, byrow = TRUE)
#    stage2 <- rbind(c(9,  1, 0, 0, 0, 0, 0, 1, 0, 1),
#                    c(10, 0, 1, 0, 0, 0, 0, 0, 1, -1),
#                    c(11, 0, 0, 1, 0, 1, 0, 0, 0, 1),
#                    c(12, 0, 0, 0, 1, 0, 1, 0, 0, -1))
#    biglist <- NULL
#    makelist <- NULL
#    block <- NULL
#    # create the simulated training matrix for each ppt and bind it together
#    for (ppt in 1:subj) {
#        dt1 <- do.call(rbind,
#                       replicate(block1, stage1[sample(nrow(stage1)), ],
#                                 simplify = FALSE))
#        dt1 <- cbind(sort(rep(1:block1, 8)), dt1)
#        dt2 <- do.call(rbind,
#                       replicate(block2, stage2[sample(nrow(stage2)), ],
#                                 simplify = FALSE))
#        dt2 <- cbind(sort(rep(1:block2, 4)), dt2)
#        makelist <- rbind(cbind(0, ppt, 1, dt1), cbind(0, ppt, 2, dt2))
#        makelist[1, 1] <- 1
#        makelist[(block1 * 8) + 1, 1]  <- 3
#        biglist <- rbind(biglist, makelist)
#        block <- NULL
#    }
#    colnames(biglist) <- c("ctrl", "subj", "stage", "blk", "stim",
#                           "A", "B", "C", "D", "V", "W", "X", "Y", "t")
#    return(biglist)
#} 
