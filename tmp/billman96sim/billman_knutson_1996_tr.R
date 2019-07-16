
# TODO: indicate unsupervised learning with 'ctrl' coloumn
# TODO: make .conversion universal for any binary input representation
# fit Logical Structure of Stimulus Items from Billman and Knutson (1996) as it
# was described in Table 8 in Love, Meding and Gureckis (2004)

.conversion <- function(x) {
  out <- matrix(0, nrow = c(nrow(x)), ncol = c(ncol(x) * 3))
 # TODO: do it with paralell computing
  for (i in 1:ncol(x)) {
    fac <- (i - 1) * 3 + c(x[, i])
    # TODO: nested loops are a bit much
    for (j in 1:length(fac)) {
      out[j, fac[j]] <- 1
    }
  }
  out <- cbind(rep(0, nrow(out)), out)
  out[, 1] <- 3
  out[1, 1] <- 4
  colnames(out) <- c("ctrl", rep(1:3, 7))
  return(out)
}

# Experiment 2

# Nonintercorrelated
non2 <- matrix(c(1, 2, 3, 1, 2, 3, rep(0, 15)), ncol = 7, nrow = 3)
non2 <- matrix(rep(t(non2), 4 * 27), ncol = 7, byrow = TRUE)
non2[, 3:7] <- matrix(sample(rep(1:3, 5)), ncol = 5)
non2 <- non2[sample(nrow(non2)), ]
bk2a <- .conversion(non2)

# Intercorrelated
int2 <- matrix(c(1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, rep(0, 9)),
                 ncol = 7, nrow = 3)
int2 <- matrix(rep(t(int2), 4 * 27), ncol = 7, byrow = TRUE)
int2[, 5:7] <- matrix(sample(rep(1:3, 3)), ncol = 3)
int2 <- int2[sample(nrow(int2)), ]
bk2b <- .conversion(int2)

# Experiment 3

# Nonintercorrelated
a3 <- c(1, 1, 1, 1, 1, 1, 0,
        1, 1, 1, 1, 2, 2, 0,
        1, 1, 1, 1, 3, 3, 0,
        1, 1, 2, 2, 1, 1, 0,
        1, 1, 2, 2, 2, 2, 0,
        1, 1, 2, 2, 3, 3, 0,
        1, 1, 3, 3, 1, 1, 0,
        1, 1, 3, 3, 2, 2, 0,
        1, 1, 3, 3, 3, 3, 0)
b3 <- c(2, 2, 1, 1, 1, 1, 0,
        2, 2, 1, 1, 2, 2, 0,
        2, 2, 1, 1, 3, 3, 0,
        2, 2, 2, 2, 1, 1, 0,
        2, 2, 2, 2, 2, 2, 0,
        2, 2, 2, 2, 3, 3, 0,
        2, 2, 3, 3, 1, 1, 0,
        2, 2, 3, 3, 2, 2, 0,
        2, 2, 3, 3, 3, 3, 0)
c3 <- c(3, 3, 1, 1, 1, 1, 0,
        3, 3, 1, 1, 2, 2, 0,
        3, 3, 1, 1, 3, 3, 0,
        3, 3, 2, 2, 1, 1, 0,
        3, 3, 2, 2, 2, 2, 0,
        3, 3, 2, 2, 3, 3, 0,
        3, 3, 3, 3, 1, 1, 0,
        3, 3, 3, 3, 2, 2, 0,
        3, 3, 3, 3, 3, 3, 0)

non3 <- matrix(rep(c(a3, b3, c3), 12), ncol = 7, byrow = TRUE)
non3[, 7] <- sample(rep(1:3, nrow(non3) / 3))
non3 <- non3[sample(nrow(non3)), ]

bk3a <- .conversion(non3)

# Intercorrelated

i3 <- c(1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0)

i3 <- matrix(rep(i3, 4 * 27), ncol = 7, byrow = TRUE)
i3[, 4:7] <- matrix(sample(rep(1:3, 4)), ncol = 4)
i3 <- i3[sample(nrow(i3)), ]
bk3b <- .conversion(i3)

rm(int2, non2, non3, a3, b3, c3, i3)
