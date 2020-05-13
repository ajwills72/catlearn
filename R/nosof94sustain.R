nosof94sustain <- function(params = c(9.01245, 1.252233, 16.924073, 0.092327))
{
    ## Set training
    bigtr <- NULL
    for(cond in 1:6) {
        bigtr <- rbind(bigtr,
                       nosof94train(cond, blocks = 16, absval = 0,
                                    blkstyle = "eights", missing = 'pad',
                                    subjs = 100, seed = 7624))
        }
    ## Set initial model state
    init.state <- list(r = params[1], beta = params[2], d = params[3], eta = params[4],
                       tau = 0.0, lambda = c(1, 1, 1), dims = c(2, 2, 2), cluster = NA,
                       w = NA, colskip = 4)
    ## Run simulation
    out <- slpSUSTAIN(init.state,bigtr, ties = "first")
    out <- out$probs # Strip out final state info
    ## Combine output to training list
    colnames(out) <- c('p1','p2')
    out <- data.frame(cbind(bigtr,out))
    ## Calculate response accuracy
    out$pc <- 0
    out$pc[out$t1 == 1] <- out$p1[out$t1 == 1]
    out$pc[out$t2 == 1] <- out$p2[out$t2 == 1]
    ## Convert to error rate
    out$pc <- 1 - out$pc
    ## Archive raw output
    ## save(out, file = "rawout.RData")
    ## Aggregate across runs
    out.ag <- aggregate(out$pc,list(out$blk,out$cond),mean)
    colnames(out.ag) <- c('block','type','error')
    return(out.ag[,c('type','block','error')])
    }
