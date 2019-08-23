
# TODO: create bigtest for test phases for each experiment

.conversion <- function(x) {
    out <- matrix(0, nrow = c(nrow(x)), ncol = c(ncol(x) * 3))
    for (i in 1:ncol(x)) {
        fac <- (i - 1) * 3 + c(x[, i])
        for (j in 1:length(fac)) {
            out[j, fac[j]] <- 1
        }
    }
    return(out)
}

## exp = 1-4
## 1 = Experiment 2 Nonintercorrelated/Isolating
## 2 = Experiment 2 Intercorrelated/Structured
## 3 = Experiment 3 Nonintercorrelated/Isolating
## 4 = Experiment 3 Intercorrelated/Structured

billman96train <- function(exp = 2, block = 4, ppt = 1, seed = 7469) {

    set.seed = 7469

    ## Experiment 2

    ## Nonintercorrelated Block

    non2 <- matrix(c(1, 2, 3, 1, 2, 3, rep(0, 15)), ncol = 7, nrow = 3)
    non2 <- do.call(rbind, replicate(9, non2, simplify = FALSE))
    non2[, 3:7] <- matrix(sample(rep(1:3, 5)), ncol = 5)
    non2 <- cbind(1:3, non2)
    ## Intercorrelated Block

    int2 <- matrix(c(1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, rep(0, 9)),
                   ncol = 7, nrow = 3)
    int2 <- do.call(rbind, replicate(9, int2, simplify = FALSE))
    int2[, 5:7] <- matrix(sample(rep(1:3, 3)), ncol = 3)
    int2 <- cbind(1:3, int2)

    ## Experiment 3

    ## Nonintercorrelated

    a3 <- matrix(c(1, 1, 1, 1, 1, 1, 0,
                   1, 1, 1, 1, 2, 2, 0,
                   1, 1, 1, 1, 3, 3, 0,
                   1, 1, 2, 2, 1, 1, 0,
                   1, 1, 2, 2, 2, 2, 0,
                   1, 1, 2, 2, 3, 3, 0,
                   1, 1, 3, 3, 1, 1, 0,
                   1, 1, 3, 3, 2, 2, 0,
                   1, 1, 3, 3, 3, 3, 0),
                 ncol = 7, byrow = TRUE)
    b3 <- matrix(c(2, 2, 1, 1, 1, 1, 0,
                   2, 2, 1, 1, 2, 2, 0,
                   2, 2, 1, 1, 3, 3, 0,
                   2, 2, 2, 2, 1, 1, 0,
                   2, 2, 2, 2, 2, 2, 0,
                   2, 2, 2, 2, 3, 3, 0,
                   2, 2, 3, 3, 1, 1, 0,
                   2, 2, 3, 3, 2, 2, 0,
                   2, 2, 3, 3, 3, 3, 0),
                 ncol = 7, byrow = TRUE)
    c3 <- matrix(c(3, 3, 1, 1, 1, 1, 0,
                   3, 3, 1, 1, 2, 2, 0,
                   3, 3, 1, 1, 3, 3, 0,
                   3, 3, 2, 2, 1, 1, 0,
                   3, 3, 2, 2, 2, 2, 0,
                   3, 3, 2, 2, 3, 3, 0,
                   3, 3, 3, 3, 1, 1, 0,
                   3, 3, 3, 3, 2, 2, 0,
                   3, 3, 3, 3, 3, 3, 0),
                 ncol = 7, byrow = TRUE)

    non3 <- rbind(a3, b3, c3)
    non3[, 7] <- sample(rep(1:3, nrow(non3) / 3))
    non3 <- cbind(sort(rep(1:3, 9)), non3)

    ## Intercorrelated

    int3 <- c(1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0)

    int3 <- matrix(rep(int3, 9), ncol = 7, byrow = TRUE)
    int3[, 4:7] <- matrix(sample(rep(1:3, 4)), ncol = 4)
    int3 <- cbind(1:3, int3)

    ## combine list

    ret <- list(non2, int2, non3, int3)

    ## TODO test phase
    tst1 <- matrix(c(1, 1, 0, 0, 0, 0, 0,
                     2, 2, 0, 0, 0, 0, 0,
                     3, 3, 0, 0, 0, 0, 0),
                   nrow = 3,
                   byrow = TRUE)
    
    ## subset current experimental condition

    tmp <- ret[[exp]]
    blk <- NULL
    makelist <- NULL
    maketest <- NULL
    biglist <- NULL

    for (i in 1:ppt) {
        blk <- do.call(rbind, replicate(block, tmp[sample(nrow(tmp)), ],
                                        simplify = FALSE))
        blk <- cbind(blk[, 1], .conversion(blk[, 2:8]))
        makelist <- cbind(3, ppt, exp, sort(rep(1:block, 27)), blk, 0)
        makelist[1, 1] <- 4
        maketest <- 
        biglist <- rbind(biglist, makelist)
        blk <- NULL
    }

    colnames(biglist) <- c("ctrl", "ppt", "exp", "blk", "stim",
                           "a1", "a2", "a3", "b1", "b2", "b3", "c1", "c2", "c3",
                           "d1", "d2", "d3", "e1", "e2", "e3", "f1", "f2", "f3",
                           "g1", "g2", "g3", "t")

    return(biglist)
}
