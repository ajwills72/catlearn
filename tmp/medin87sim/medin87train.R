medin87train <- function(ppt = 1, block = 1, seed = 7649) {
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
                    ncol = 4, byrow = TRUE)

    biglist <- NULL
    makelist <- NULL
    tmp <- NULL
    for (subj in 1:ppt) {
        ## Replicate a randomised training block according to block argument
        for (i in 1:block){
            tmp <- train[sample(nrow(train)), ]
            tmp <- cbind(i, tmp)
            makelist <- rbind(makelist, tmp)
        }
        makelist <- cbind(3, subj, makelist)
        ## reset network
        makelist[1, 1] <- 4
        biglist <- rbind(biglist, makelist)
        tmp <- NULL
        makelist <- NULL
    }

    colnames(biglist) <- c("ctrl", "ppt", "blk", "x1", "x2", "x3", "x4")

    return(biglist)
}
