krus96exit <- function(params = c(2.87, 2.48, 4.42, 4.42, .222, 1.13,
                                  .401)) {
    ## Set training array
    tr <- krus96train(blocks = 15, subjs = 56, ctxt = TRUE, seed = 1) 

    ## Set state
    exemplars <- rbind(c(1,1,0,0,0,0,1),
                       c(1,0,1,0,0,0,1),
                       c(0,0,0,1,1,0,1),
                       c(0,0,0,1,0,1,1))

    w_exemplars <- exemplars
    w_exemplars[] <- 0
    nFeat = 7
    nCat = 4
    w_in_out <- matrix(0, nCat, nFeat)
    
    st <- list(nFeat = nFeat, nCat = nCat,
               phi = params[3], c = params[1], P = params[2],
               l_gain = params[4], l_weight = params[5], l_ex = params[6],
               sigma = c(rep(1,6), params[7]), 
               iterations = 10,
               exemplars = exemplars,
               w_exemplars = w_exemplars,
               w_in_out = w_in_out)

    ## Run simulation
    tout <- slpEXIT(st, tr, xtdo=F)
    predics <- tout$p
    colnames(predics) <- c("C1", "R1", "C2", "R2")
    out.all <- cbind(tr[tr[, "ctrl"] == 2,], predics[tr[, "block"] == 16,])

    ## Reduce and aggregate results to compare with Kruschke's simulation.
    out <- out.all[out.all$block == 16,]

    out.ag.C1 <- aggregate(out$C1, list(out$stim), mean)
    colnames(out.ag.C1) <- c("stim", "C1")

    out.ag.R1 <- aggregate(out$R1, list(out$stim), mean)
    colnames(out.ag.R1) <- c("stim", "R1")

    out.ag.C2 <- aggregate(out$C2, list(out$stim), mean)
    colnames(out.ag.C2) <- c("stim", "C2")

    out.ag.R2 <- aggregate(out$R2, list(out$stim), mean)
    colnames(out.ag.R2) <- c("stim", "R2")

    out.ag <- cbind(out.ag.C1, out.ag.R1[,2], out.ag.C2[,2],
                    out.ag.R2[,2])

    colnames(out.ag) <- c("stim", "C1", "R1", "C2", "R2")

    ## Generate abstract stimulus code
    
    out.ag$abstim[out.ag$stim %in% c("I1", "I2")] <- "I"
    out.ag$abstim[out.ag$stim %in% c("PC1", "PC2")] <- "PC"
    out.ag$abstim[out.ag$stim %in% c("PR1", "PR2")] <- "PR"
    out.ag$abstim[out.ag$stim %in% c("PC1.PR1", "PC2.PR2")] <- "PC.PR"
    out.ag$abstim[out.ag$stim %in% c("I1.PC1.PR1", "I2.PC2.PR2")] <-
        "I.PC.PR"
    out.ag$abstim[out.ag$stim %in% c("I1.PC2", "I2.PC1")] <- "I.PCo"
    out.ag$abstim[out.ag$stim %in% c("I1.PR2", "I2.PR1")] <- "I.PRo"
    out.ag$abstim[out.ag$stim %in% c("PC1.PR2", "PC2.PR1")] <-
        "PC.PRo"
    out.ag$abstim[out.ag$stim %in% c("I1.PC1.PR2", "I2.PC2.PR1")] <-
        "I.PC.PRo"

    ## Generate abstract response code
    set1 <- c("I1", "PC1", "PR1", "PC1.PR1", "I1.PC1.PR1", "I1.PC2",
              "I1.PR2", "PC1.PR2", "I1.PC1.PR2")

    set2 <- c("I2", "PC2", "PR2", "PC2.PR2", "I2.PC2.PR2", "I2.PC1",
              "I2.PR1", "PC2.PR1", "I2.PC2.PR1")
 
    out.ag$C[out.ag$stim %in% set1] <-
        out.ag$C1[out.ag$stim %in% set1]
    out.ag$R[out.ag$stim %in% set1] <-
        out.ag$R1[out.ag$stim %in% set1]
    out.ag$Co[out.ag$stim %in% set1] <-
        out.ag$C2[out.ag$stim %in% set1]
    out.ag$Ro[out.ag$stim %in% set1] <-
        out.ag$R2[out.ag$stim %in% set1]

    out.ag$C[out.ag$stim %in% set2] <-
        out.ag$C2[out.ag$stim %in% set2]
    out.ag$R[out.ag$stim %in% set2] <-
        out.ag$R2[out.ag$stim %in% set2]
    out.ag$Co[out.ag$stim %in% set2] <-
        out.ag$C1[out.ag$stim %in% set2]
    out.ag$Ro[out.ag$stim %in% set2] <-
        out.ag$R1[out.ag$stim %in% set2]

    ## Aggregate across abstract stim type

    out.ag.C <- aggregate(out.ag$C, list(out.ag$abstim), mean)
    colnames(out.ag.C) <- c("abstim", "C")

    out.ag.R <- aggregate(out.ag$R, list(out.ag$abstim), mean)
    colnames(out.ag.R) <- c("abstim", "R")

    out.ag.Co <- aggregate(out.ag$Co, list(out.ag$abstim), mean)
    colnames(out.ag.Co) <- c("abstim", "Co")

    out.ag.Ro <- aggregate(out.ag$Ro, list(out.ag$abstim), mean)
    colnames(out.ag.Ro) <- c("abstim", "Ro")

    out.ag.abs <- cbind(out.ag.C, out.ag.R[,2], out.ag.Co[,2],
                        out.ag.Ro[,2])

    colnames(out.ag.abs) <- c("symptom", "C", "R", "Co", "Ro")

    ## Convert to long format, and order as per Kruschke 1996
    stimorder <- c("I", "PC", "PR", "PC.PR", "I.PC.PR", "I.PCo", "I.PRo",
                   "PC.PRo", "I.PC.PRo")

    disorder <- c("C", "R", "Co", "Ro")

    longun <- tidyr::gather(out.ag.abs, key = "disease", value = "prop", 2:5)
    longun <- dplyr::arrange(longun, match(longun$symptom, longun$stimorder),
                      match(longun$disease, longun$disorder))

    return(longun)
    }
