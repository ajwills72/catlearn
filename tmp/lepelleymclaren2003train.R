# block1 = stage 1 blocks
# block2 = stage 2 blocks
# novel items from stage 2 are omitted at the moment

lepelleymclaren2003train <- function(block1 = 20, block2 = 20,
                                     subj = 4, seed = 7624,
                                     stim_enc = FALSE) {
set.seed(seed)

# stim numbers
# 1 = AV, 2 = AW, 3 = BV, 4 = BW
# 5 = CX, 6 = CY, 7 = DX, 8 = DY
# 9 = AX, 10 = BY, 11 = CV, 12 = DW
stim <- cbind(1:12,
              c("AV", "AW", "BV", "BW", "CX", "CY", "DX",
                "DY", "AX", "BY", "CV", "DW"))

# Input Representations for Stage 1
################## stim A  B  C  D  V  W  X  Y  t
certain <-  matrix(c(1, 1, 0, 0, 0, 1, 0, 0, 0, 1,
                     2, 1, 0, 0, 0, 0, 1, 0, 0, 1,
                     3, 0, 1, 0, 0, 1, 0, 0, 0, -1,
                     4, 0, 1, 0, 0, 0, 1, 0, 0, -1,
                     5, 0, 0, 1, 0, 0, 0, 1, 0, -1,
                     6, 0, 0, 1, 0, 0, 0, 0, 1, -1,
                     7, 0, 0, 0, 1, 0, 0, 1, 0, 1,
                     8, 0, 0, 0, 1, 0, 0, 0, 1, 1),
                     nrow = 8, byrow = TRUE)
# stage 2 is uniform for both conditions
############### stim  A  B  C  D  V  W  X  Y  t
stage2 <- rbind(c(9,  1, 0, 0, 0, 0, 0, 1, 0, 1),
                c(10, 0, 1, 0, 0, 0, 0, 0, 1, -1),
                c(11, 0, 0, 1, 0, 1, 0, 0, 0, 1),
                c(12, 0, 0, 0, 1, 0, 1, 0, 0, -1))

biglist <- NULL
makelist <- NULL
block  <- NULL

# certain condition
# create the simulated training matrix for each ppt and binds it together
for (ppt in 1:subj) {
    for (blk in 1:block1) {
        tmp <- cbind(blk, certain[sample(nrow(certain)), ])
        block <- rbind(block, tmp)
        }
    test <- do.call(rbind,
                    replicate(block2, stage2[sample(nrow(stage2)), ],
                              simplify = FALSE))
    test <- cbind(sort(rep(1:block2, 4)), test)
    makelist <- rbind(cbind(0, 1, ppt, block), cbind(0, 2, ppt, test))
    makelist[1, 1] <- 1
    makelist[(block1 * 8) + 1, 1]  <- 3
    biglist <- rbind(biglist, makelist)
    block <- NULL
}

colnames(biglist) <- c("ctrl", "stage", "subj", "blk", "stim",
                       "A", "B", "C", "D", "V", "W", "X", "Y", "t")

# if stim is TRUE, return stimuli encodings as well
if (stim_enc == TRUE) {
    ret <- list("training set" = biglist,
                "stimuli encoding" = stim)
} else {
    ret <- biglist
}

return(ret)
} # end of function
