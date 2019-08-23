medin87train <- function(ppt = 1, block = 10, seed = 7649) {
    set.seed(seed)
    train <- matrix(c(1, 1, 1, 1,
                      1, 1, 1, 0,
                      1, 1, 0, 1,
                      1, 0, 1, 1,
                      0, 1, 1, 1,
                      0, 0, 0, 0,
                      0, 0, 0, 1,
                      0, 0, 1, 0,
                      0, 1, 0, 0,
                      1, 0, 0, 0),
                    ncol = 4, byrow = train)

    biglist <- NULL
    tmp <- NULL
    for (subj in 1:ppt) {
    tmp <- do.call(rbind, replicate(block, train[sample(nrow(train)), ],
                                    simplify = FALSE))
    tmp <- cbind(3, subj, sort(rep(1:10, 10)), tmp)
    tmp[1, 1] <- 4
    biglist <- rbind(biglist, tmp)
    }

    colnames(biglist) <- c("ctrl", "ppt", "blk", "x1", "x2", "x3", "x4")

    return(biglist)
}
