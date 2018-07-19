nosof88oat <- function(dta, xtdo = FALSE) {
    res1 <- c(     # Calculate summary
        dta$c2acc[dta$cond == 1 & dta$stim == 2],
        dta$c2acc[dta$cond == 2 & dta$stim == 2])
    res2 <- c(
        dta$c2acc[dta$cond == 1 & dta$stim == 7],
        dta$c2acc[dta$cond == 3 & dta$stim == 7])
    res3 <- c(
        dta$c2acc[dta$cond == 1 & dta$stim == 4],
        dta$c2acc[dta$cond == 2 & dta$stim == 4])
    res4 <- c(
        dta$c2acc[dta$cond == 1 & dta$stim == 9],
        dta$c2acc[dta$cond == 3 & dta$stim == 9])
    pred <- cbind(res1,res2,res3,res4)
    colnames(pred) <- c('2','7','4','9')
    rownames(pred) <- c('B','E')
    oat <- TRUE #OAT
    if(pred[1,1] >= pred[2,1]) oat <- FALSE
    if(pred[1,2] >= pred[2,2]) oat <- FALSE
    if(pred[1,3] >= pred[2,3]) oat <- FALSE
    if(pred[1,4] >= pred[2,4]) oat <- FALSE
    # Decide whether to return summary table or OAT boolean
    if(xtdo) ret <- pred else ret <- oat
    return(ret)
}
