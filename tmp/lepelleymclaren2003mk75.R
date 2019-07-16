lepelleymclaren2003mk75 <- function(params = c(lr = 0.3, alr = 0.1), seed = 7624) {
    set.seed <- seed
    ## Set training matrix
    bigtr <- NULL
    bigtr <- lepelleymclaren2003ap()
    out[,"t"][out[, "t"] == 0] <- -1
    
    # Set initial model state
    init.state <- list(lr = params[1],
                       alr = params[2],
                       w = rep(0, 8),
                       aw = rep(0.3, 8),
                       colskip = 5)
    
    # Run simulation
    out <- slpMK75(init.state, xtdo = TRUE)
    out <- cbind(out$xoutw, out$xouta)
    out <- data.frame(cbind(bigtr, out))
}
