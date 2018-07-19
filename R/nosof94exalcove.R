nosof94exalcove <- function(params = NULL) {
    ## Retrieve parameters from optimization archive as a default
    if(is.null(params)) params <- nosof94exalcove_opt()

    # Set training
    bigtr <- NULL
    for(cond in 1:6) {
        bigtr <- rbind(bigtr,
                       nosof94train(cond, blocks = 16, absval = -1,
                                    subjs = 100, seed = 7624))
        }
    # Set initial model state
    init.state <- list(colskip = 4, r = 1, q = 1, alpha = c(1/3,1/3,1/3),
                       w = array(0,dim=c(2,8)),
                       h = cbind( c(0,0,0), c(0,0,1), c(0,1,0), c(0,1,1), 
                                 c(1,0,0), c(1,0,1), c(1,1,0), c(1,1,1)),
                       c = params[1], phi = params[2], la = params[3],
                       lw = params[4]
                       )
    # Run simulation
    out <- slpALCOVE(init.state,bigtr)
    out <- out$p # Strip out final state info
    # Combine output to training list
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    # Calculate response accuracy
    out$pc <- 0
    out$pc[out$t1 == 1] <- out$p1[out$t1 == 1]
    out$pc[out$t2 == 1] <- out$p2[out$t2 == 1]
    # Convert to error rate
    out$pc <- 1 - out$pc
    # Aggregate across runs
    out.ag <- aggregate(out$pc,list(out$blk,out$cond),mean)
    colnames(out.ag) <- c('block','type','error')
    return(out.ag[,c('type','block','error')])
    }
