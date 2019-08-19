lepell03Mack75 <- function(params = c(lr = 0.3, alr = 0.1),
                           ppt = 100,
                           block1 = 20,
                           block2 = 20,
                           seed = 7624) {
    set.seed <- seed
    ## Set training matrix
    stim <- c("A", "B", "C", "D", "V", "W", "X", "Y")
    tr <- lepell03train(subj = ppt,
                        block1 = block1,
                        block2 = block2)
    # Set initial model state
    init.state <- list(lr = params[1],
                       alr = params[2],
                       w = rep(0, 8),
                       alpha = rep(0.3, 8),
                       colskip = 5)

    # Run simulation
    out <- slpMack75(init.state, tr, xtdo = TRUE)
    outw <- cbind(tr[, 2:4], out$xoutw)
    outa <- cbind(tr[, 2:4], out$xouta)
    outp <- NULL
    atte <- NULL
    outmp <- NULL
    # Extract last output for each stage by each participants
    for (k in 1:2) {
        for (i in 1:4) {
            tmp <- outw[outw[, 1] == i & outw[, 2] == k, ]
            lastw <- by(tmp, tmp[, "subj"], tail, n = 1)
            lastw <- do.call(rbind, as.list(lastw))
            tmp <- outa[outa[, 1] == i & outw[, 2] == k, ]
            lasta <- by(tmp, tmp[, "subj"], tail, n = 1)
            lasta <- do.call(rbind, as.list(lasta))
            atte <- rbind(atte, lasta)
            outp <- rbind(outp, lastw)
        }
    }
    colnames(outp)[4:11] <- c("Aw", "Bw", "Cw", "Dw",
                              "Vw", "Ww", "Xw", "Yw")
    colnames(atte)[4:11] <- c("Aa", "Ba", "Ca", "Da",
                              "Va", "Wa", "Xa", "Ya")

    outp <- cbind(data.frame(colMeans(outp[outp$stage==1, 4:11])),
                  data.frame(colMeans(outp[outp$stage==2, 4:11])))

    ret <- rbind(cbind(stage = 1,
                    a = colMeans(atte[atte$stage==1, 4:11]),
                    w = outp[, 1]),
                 cbind(stage = 2,
                    a = colMeans(atte[atte$stage==2, 4:11]),
                    w = outp[, 2]))

    return(ret)
}
