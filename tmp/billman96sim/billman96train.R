
# TODO: indicate unsupervised learning with 'ctrl' coloumn
# TODO: create bigtest for test phases for each experiment

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
    return(out)
}

## exp = 1-4
## 1 = Experiment 2 Nonintercorrelated/Isolating
## 2 = Experiment 2 Intercorrelated/Structured
## 3 = Experiment 3 Nonintercorrelated/Isolating
## 4 = Experiment 3 Intercorrelated/Structured

billman96train <- function(exp = 1, block = 4, ppt = 1, seed = 7469) {

    set.seed = 7469

## Experiment 2

## Nonintercorrelated Block

    non2 <- matrix(c(1, 2, 3, 1, 2, 3, rep(0, 15)), ncol = 7, nrow = 3)
    non2 <- do.call(rbind, replicate(9, non2, simplify = FALSE))
    non2[, 3:7] <- matrix(sample(rep(1:3, 5)), ncol = 5)

## Intercorrelated Block

    int2 <- matrix(c(1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, rep(0, 9)),
                   ncol = 7, nrow = 3)
    int2 <- do.call(rbind, replicate(9, int2, simplify = FALSE))
    int2[, 5:7] <- matrix(sample(rep(1:3, 3)), ncol = 3)


## Experiment 3

## Nonintercorrelated

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

    non3 <- matrix(rbind(a3, b3, c3), ncol = 7, byrow = TRUE)
    non3[, 7] <- sample(rep(1:3, nrow(non3) / 3))

## Intercorrelated

    int3 <- c(1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 3, 3, 3, 0, 0, 0, 0)

    int3 <- matrix(rep(int3, 9), ncol = 7, byrow = TRUE)
    int3[, 4:7] <- matrix(sample(rep(1:3, 4)), ncol = 4)

## combine list

    biglist <- list(non2, int2, non3, int3)

    for (i in 1:ppt) {
    }

    return(bigtr)
}
