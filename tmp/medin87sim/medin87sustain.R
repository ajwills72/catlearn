medin87sustain <- function(params = c(9.998779, 6.396300, 1.977312,
                                      0.096564, 0.5),
                           ppt = 1000, seed = 7649) {
    ## Create training matrix and convert it to SUSTAIN-compatible format
    bigtr <- medin87train(ppt = 100, block = 10)
    ## Set initial model state
    init.state <- list(r = params[1], beta = params[2], d = params[3],
                       eta = params[4], tau = params[5],
                       lambda = c(1, 1, 1, 1), dims = c(1, 1, 1, 1),
                       cluster = NA, w = NA, colskip = 3)
    ## Run the simulation
    out <- slpSUSTAIN(init.state, bigtr)

    ## TODO: simplify output and avarage number of clusters and n of lambdas
    return(out)
}
