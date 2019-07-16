# cues (8): A, B, C, D, W, X, Y, Z
# outcomes (2): 0, 1

beesley2015train <- function(cond = 1, blocks = 24, subj = 4, seed = 7624) {
set.seed(seed)
# TODO: create two block type for P(o1) and P(o2)

# stim = 1, 2, 3, 4
# 1= AW, 2= AX, 3= BW, 4= BX

# Input Representations for Stage 1
certain <-  matrix(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 1,
                     2, 1, 0, 0, 0, 0, 1, 0, 0, 1,
                     3, 0, 1, 0, 0, 1, 0, 0, 0, 0,
                     4, 0, 1, 0, 0, 0, 1, 0, 0, 0),
                     nrow = 4, byrow = TRUE)
# 16 x uncertain1 - P(o1)
uncertain1 <- rbind(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    c(2, 1, 0, 0, 0, 0, 1, 0, 0, 1),
                    c(3, 0, 1, 0, 0, 1, 0, 0, 0, 0),
                    c(4, 0, 1, 0, 0, 0, 1, 0, 0, 0))
# 8 x uncertain2 - P(o2)
uncertain2 <- rbind(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 0),
                    c(2, 1, 0, 0, 0, 0, 1, 0, 0, 0),
                    c(3, 0, 1, 0, 0, 1, 0, 0, 0, 1),
                    c(4, 0, 1, 0, 0, 0, 1, 0, 0, 1))

# stage 2 is uniform for both conditions
# stim: 1 = AW, 4 = BX, 7 = CY, 8 = DZ
stage2 <- rbind(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                c(4, 0, 1, 0, 0, 0, 1, 0, 0, 0),
                c(7, 0, 0, 1, 0, 0, 0, 1, 0, 1),
                c(8, 0, 0, 0, 1, 0, 0, 0, 1, 0))

biglist <- NULL
makelist <- NULL
block  <- NULL
certain_biglist <- NULL

# certain condition
# create the simulated training matrix for each ppt and binds it together
for(ppt in 1:subj) {
    for(blk in 1:blocks) {
        tmp <- cbind(blk, certain[sample(nrow(certain)), ])
        block <- rbind(block, tmp)
        }
    test <- do.call(rbind,
                    replicate(6, stage2[sample(nrow(stage2)), ],
                              simplify = FALSE))
    test <- cbind(sort(rep(1:6, 4)), test)
    makelist <- rbind(cbind(0, 1, ppt, block), cbind(2, 1, ppt, test))
    makelist[1, 1] <- 1
    certain_biglist <- rbind(certain_biglist, makelist)
    block <- NULL
}

colnames(certain_biglist) <- c("ctrl", "cond", "subj", "blk", "stim",
                               "A", "B", "C", "D", "W", "X", "Y", "Z", "t")


# Uncertain Condition
makelist <- NULL
block <- NULL
blk1 <- NULL
blk2 <- NULL
uncertain_biglist <- NULL

for (ppt in 1:subj){
    blk1 <- replicate(16, uncertain1[sample(nrow(uncertain1)), ],
                      simplify = FALSE)
    blk2 <- replicate(8, uncertain2[sample(nrow(uncertain2)), ],
                      simplify = FALSE)
    block <- do.call(rbind, sample(append(blk1, blk2)))
    block <- cbind(sort(rep(1:24, 4)), block)
    test <- do.call(rbind,
                    replicate(6, stage2[sample(nrow(stage2)), ],
                              simplify = FALSE))
    test <- cbind(sort(rep(1:6, 4)), test)
    makelist <- rbind(cbind(0, 2, ppt, block), cbind(2, 2, ppt, test))
    makelist[1, 1] <- 1
    uncertain_biglist <- rbind(uncertain_biglist, makelist)
    makelist <- NULL
    blocks <- NULL
}

colnames(uncertain_biglist) <- c("ctrl", "cond", "subj", "blk", "stim",
                                 "A", "B", "C", "D", "W", "X", "Y", "Z", "t")

biglist <- list(certain_biglist, uncertain_biglist)
return(biglist)
} # end of function
