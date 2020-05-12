medin87sustain <- function(params = c(9.998779, 6.396300, 1.977312,
                                      0.096564, 0.5), seed = 7649) {
    set.seed(seed)
    bigtr <- medin87train(subjs = 1000, blocks = 10)
    bigtr <- cbind(bigtr[, 1:3], convertSUSTAIN(bigtr[, 4:7], c(2, 2, 2, 2)))
    ## Set initial model state
    init.state <- list(r = params[1], beta = params[2], d = params[3],
                       eta = params[4], tau = params[5],
                       lambda = c(1, 1, 1, 1), dims = c(2, 2, 2, 2),
                       cluster = NA, w = NA, colskip = 3,
                       maxcat = 2)

    ## Run the simulation
    ret <- NULL
    out <- NULL
    sort <- NULL
    strategy <- NULL
    for (i in 1:1000) {
        out <- slpSUSTAIN(init.state, bigtr[bigtr[, 2] == i, ])
        cluster <- out$cluster
        for (k in 1:nrow(cluster)) {
            sort[k] <- abs(max(cluster[k, ]) - min(cluster[k, ])) < 0.1
            ## if all true, select family resemblance
            ## otherwise select unidimensional
            ifelse(all(sort), strategy <- 1, strategy <- 0)
        }
        ret <- rbind(ret, c(out$lambda, strategy))
    }
    colnames(ret) <- c("D1", "D2", "D3", "D4", "sort")
    return(ret)
}
