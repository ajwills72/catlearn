act2probrat <- function(act, theta, beta) {
    1 / (1 + exp(-theta * (act - beta)))
}

