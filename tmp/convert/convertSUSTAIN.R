
## function to convert data to SUSTAIN compatible format
## input  input of training matrix, a.k.a stimuli representation
## dims  Vector containing the length of each dimension
## NOTE: depends on `??foreach`, paralell computing for large datasets...
## FIXME: more elegant solution for places
## TODO: use foreach() with %dopar% instead of for()

convert.sustain <- function(input, dims) {
    out <- matrix(0, nrow = nrow(input), ncol = sum(dims))
    places <- t(apply(input, 1,
                      function (x) x + (c(0, cumsum(dims)[-length(dims)]))))
    for (i in 1:nrow(out)) {
        out[i, ][places[i, ]] <- 1
    }
    colnames(out) <- NULL
    return(out)
}
