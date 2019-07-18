source("lepelleymclaren2003train.R")
Rcpp::sourceCpp("../src/slpMK75.cpp")
lepelleymclaren2003mk75 <- function(params = c(lr = 0.3, alr = 0.1),
                                    ppt = 4,
                                    seed = 7624) {
    set.seed <- seed
    ## Set training matrix
    stim <- c("A", "B", "C", "D", "V", "W", "X", "Y")
    tr <- lepelleymclaren2003train(subj = ppt)
    # Set initial model state
    init.state <- list(lr = params[1],
                       alr = params[2],
                       w = rep(0, 8),
                       alpha = rep(0.3, 8),
                       colskip = 5)

    # Run simulation
    out <- slpMK75(init.state, tr, xtdo = TRUE)
    outw <- cbind(tr[, 2:4], out$xoutw) 
    outa <- cbind(tr[, 2:4], out$xouta) 
    outp <- NULL
    outmp <- NULL
    # Extract last output for each stage by each participants
    for (i in 1:2) {
        tmp <- outw[outw[, 1] == i, ]
        lastw <- by(tmp, tmp[, "subj"], tail, n = 1)
        lastw <- do.call(rbind, as.list(lastw))
        tmp <- outa[outa[, 1] == i, ]
        lasta <- by(tmp, tmp[, "subj"], tail, n = 1)
        lasta <- do.call(rbind, as.list(lasta))
        outp <- rbind(outp, cbind(lastw, lasta[, 4:11]))
    }
    colnames(outw)[4:11] <- stim
    colnames(outa)[4:11] <- stim
    colnames(outp)[4:19] <- c("Aw", "Bw", "Cw", "Dw",
                                "Vw", "Ww", "Xw", "Yw",
                                "Aa", "Ba", "Ca", "Da",
                                "Va", "Wa", "Xa", "Ya")
    ret <- list("trial-level data of weights" = outw,
                "trial-level data of weights" = outw,
                "last output by subj per stage" = outp)
    return(ret)
}
