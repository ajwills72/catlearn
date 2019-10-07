convertSUSTAIN <- function(input, dims) {
    out <- matrix(0, nrow = nrow(input), ncol = sum(dims))
    places <- t(apply(input, 1,
                      function (x) x + (c(0, cumsum(dims)[-length(dims)]))))
    for (i in 1:nrow(out)) {
        out[i, ][places[i, ]] <- 1
    }
    colnames(out) <- NULL
    return(out)
}
