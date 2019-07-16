source("beesley2005train.R")
bsley05mk75 <- function(params = c(lr = 0.3, alr = 0.1), seed = 7624) {
    set.seed <- seed
    ## Set training matrix
    bigtr <- NULL
        bigtr <- beesley2005train()
    
    # Set initial model state
    init.state <- list(params,
                       w = rep(0, 8),
                       aw = rep(0.3, 8),
                       colskip = 5)
    
    # Run simulation
    out <- slpMK75(init.state, xtdo = TRUE)
    out <- cbind(out$xoutw, out$xouta)
    colnames(out) <- c("weights", "alpha")
    out <- data.frame(cbind(bigtr, out))
}
