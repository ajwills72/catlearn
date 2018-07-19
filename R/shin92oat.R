shin92oat <- function(dta, xtdo = FALSE) {
    # Convert to accuracies
    dta$c2p[dta$cond == 1 & dta$stim < 9] <- 1 -
        dta$c2p[dta$cond == 1 & dta$stim < 9]
    dta$c2p[dta$cond == 2 & dta$stim < 16] <- 1 -
        dta$c2p[dta$cond == 2 & dta$stim < 16]
    # Calculate size 3 accuracy
    s3 <- dta[dta$cond == 1,]
    s3old <- mean(s3$c2p[s3$stim %in% c(2:4,10:12)])
    s3proto <- mean(s3$c2p[s3$stim %in% c(1,9)])
    s3new <- mean(s3$c2p[s3$stim %in% c(5:8,13:16)])
    # Calculate size 10 accuracy
    s10 <- dta[dta$cond == 2,]
    s10old <- mean(s10$c2p[s10$stim %in% c(2:11,16:26)])
    s10proto <- mean(s10$c2p[s10$stim %in% c(1,16)])
    s10new <- mean(s10$c2p[s10$stim %in% c(12:15,27:30)])
    # OAT
    if(s10new > s3new) oat <- TRUE else oat <- FALSE
    # Summary table
    res <- cbind(c(s3old,s10old),c(s3proto,s10proto),c(s3new,s10new))
    colnames(res) <- c('old','proto','new')
    rownames(res) <- c('size3','size10')
    # Decide whether to return summary table or OAT boolean
    if(xtdo) ret <- res else ret <-oat
    return(ret)    
}
