nosof94oat <- function(dta, xtdo = FALSE) {
    # Calculate mean accuracies
    ag <- aggregate(dta$error,list(dta$type),mean)
    colnames(ag) <- c('type','error')
    # Do OAT
    oat <- TRUE
    i <- ag$error[ag$type == 1]
    ii <- ag$error[ag$type == 2]
    iii <- ag$error[ag$type == 3]
    iv <- ag$error[ag$type == 4]
    v <- ag$error[ag$type == 5]
    vi <- ag$error[ag$type == 6]
    # Type I
    if(!(i < ii)) oat <- FALSE
    if(!(i < iii)) oat <- FALSE
    if(!(i < iv)) oat <- FALSE
    if(!(i < v)) oat <- FALSE
    if(!(i < vi)) oat <- FALSE
    # Type II
    if(!(ii < iii)) oat <- FALSE
    if(!(ii < iv)) oat <- FALSE
    if(!(ii < v)) oat <- FALSE
    if(!(ii < vi)) oat <- FALSE
    # Type III
    if(!(iii < vi)) oat <- FALSE
    # Type IV
    if(!(iv < vi)) oat <- FALSE
    # Type V
    if(!(v < vi)) oat <- FALSE
    # Type VI - already covered above

    # Return summary table or OAT?
    if(xtdo) {
        ret <- ag[order(ag$error),]
    } else {
        ret <- oat
        }
    return(ret)    
    }
